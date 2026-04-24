import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_scaffold_messenger.dart';
import 'app_navigator.dart';
import 'native_custom_tabs.dart';
import '../state/app_state.dart';
import '../../features/tracking/view/stay_and_earn_screen.dart';

class TrackedWebLauncherService with WidgetsBindingObserver {
  TrackedWebLauncherService._();

  static final TrackedWebLauncherService instance =
      TrackedWebLauncherService._();

  bool _initialized = false;
  _TrackedSession? _activeSession;
  String? _promptingSessionId;
  StreamSubscription<NativeCustomTabEvent>? _nativeTabEventsSub;
  Timer? _tabHiddenCancelTimer;

  static const _backgroundCancelAfter = Duration(seconds: 30);

  void init() {
    if (_initialized) return;
    WidgetsBinding.instance.addObserver(this);
    _initNativeCustomTabs();
    _initialized = true;
  }

  void _initNativeCustomTabs() {
    if (!NativeCustomTabs.instance.isSupported) return;
    if (_nativeTabEventsSub != null) return;

    NativeCustomTabs.instance.warmup();
    _nativeTabEventsSub = NativeCustomTabs.instance.events().listen((event) {
      final session = _activeSession;
      if (session == null) return;
      final now = event.timestamp ?? DateTime.now();
      session.nativeEventsSeen = true;

      switch (event.type) {
        case NativeCustomTabEventType.shown:
          final hiddenAt = session.lastTabHiddenAt;
          if (hiddenAt != null &&
              now.difference(hiddenAt) >= _backgroundCancelAfter) {
            resetSession(session.id);
            break;
          }
          session.lastTabHiddenAt = null;
          _tabHiddenCancelTimer?.cancel();
          _tabHiddenCancelTimer = null;
          session.startedAt = now;
          break;
        case NativeCustomTabEventType.hidden:
          final startedAt = session.startedAt;
          if (startedAt != null) {
            session.accumulated += now.difference(startedAt);
            session.startedAt = null;
          }
          session.lastTabHiddenAt = now;
          _tabHiddenCancelTimer?.cancel();
          _tabHiddenCancelTimer = Timer(_backgroundCancelAfter, () {
            final active = _activeSession;
            if (active == null || active.id != session.id) return;
            final hiddenAt = active.lastTabHiddenAt;
            if (hiddenAt != null &&
                DateTime.now().difference(hiddenAt) >= _backgroundCancelAfter) {
              resetSession(active.id);
            }
          });

          // If this event was delivered late (e.g. app was backgrounded),
          // immediately cancel when background time already exceeded threshold.
          if (DateTime.now().difference(now) >= _backgroundCancelAfter) {
            resetSession(session.id);
          }
          break;
      }
    });
  }

  Future<void> open(
    String url, {
    required String label,
    required bool showDurationToastOnReturn,
    bool? enableStayAndEarnPrompt,
    Completer<void>? onClosed,
  }) async {
    init();
    final prev = _activeSession;
    if (prev != null) resetSession(prev.id);
    final sessionId = DateTime.now().microsecondsSinceEpoch.toString();
    _activeSession = _TrackedSession(
      id: sessionId,
      url: url,
      label: label,
      showDurationToastOnReturn: showDurationToastOnReturn,
      enableStayAndEarnPrompt:
          enableStayAndEarnPrompt ?? showDurationToastOnReturn,
      onClosed: onClosed,
    );
    await _launch(_activeSession!);
  }

  Future<void> openAndWait(
    String url, {
    required String label,
    bool enableStayAndEarnPrompt = false,
  }) async {
    final completer = Completer<void>();
    await open(
      url,
      label: label,
      showDurationToastOnReturn: false,
      enableStayAndEarnPrompt: enableStayAndEarnPrompt,
      onClosed: completer,
    );
    return completer.future;
  }

  Future<void> resumeSession(String sessionId) async {
    final session = _activeSession;
    if (session == null || session.id != sessionId) return;
    if (session.rewardGranted) {
      resetSession(sessionId);
      return;
    }
    await _launch(session);
  }

  void resetSession(String sessionId) {
    final session = _activeSession;
    if (session?.id == sessionId) {
      final c = session!.onClosed;
      if (c != null && !c.isCompleted) c.complete();
      _activeSession = null;
    }
    if (_promptingSessionId == sessionId) {
      _promptingSessionId = null;
    }
    _tabHiddenCancelTimer?.cancel();
    _tabHiddenCancelTimer = null;
  }

  Future<void> _launch(_TrackedSession session) async {
    session.startedAt = DateTime.now();
    session.observedPause = false;
    session.lastTabHiddenAt = null;
    session.nativeEventsSeen = false;
    session.returnAttempts = 0;

    if (NativeCustomTabs.instance.isSupported) {
      // If the native events are wired up we will stop counting on TAB_HIDDEN
      // (including when user presses Home) so background time isn't included.
      // For older devices or if binding fails, fall back to lifecycle-based timing.
      session.startedAt = DateTime.now();
      await NativeCustomTabs.instance.open(session.url);
      return;
    }

    await launchUrl(
      Uri.parse(session.url),
      customTabsOptions: CustomTabsOptions(
        showTitle: true,
        urlBarHidingEnabled: true,
        colorSchemes: CustomTabsColorSchemes.defaults(
          toolbarColor: const Color(0xFF201402),
          navigationBarColor: const Color(0xFF0B0700),
        ),
        shareState: CustomTabsShareState.off,
      ),
      safariVCOptions: const SafariViewControllerOptions(
        barCollapsingEnabled: true,
        entersReaderIfAvailable: false,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _activeSession?.observedPause = true;
      return;
    }

    if (state == AppLifecycleState.detached) {
      final c = _activeSession?.onClosed;
      if (c != null && !c.isCompleted) c.complete();
      _activeSession = null;
      _promptingSessionId = null;
      return;
    }

    if (state != AppLifecycleState.resumed) return;
    final session = _activeSession;
    if (session == null) return;

    if (!session.observedPause) return;
    session.observedPause = false;

    // Defer handling a tick so any queued native TAB_HIDDEN event can be
    // delivered before we read `accumulated` / `lastTabHiddenAt`.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = _activeSession;
      if (current == null || current.id != session.id) return;
      _handleReturn(current);
    });
  }

  void _handleReturn(_TrackedSession session) {
    final now = DateTime.now();

    // If native callbacks are enabled and we haven't received TAB_HIDDEN yet,
    // wait briefly so the queued platform message can arrive before we finalize.
    if (NativeCustomTabs.instance.isSupported &&
        session.nativeEventsSeen &&
        session.startedAt != null &&
        session.lastTabHiddenAt == null &&
        session.returnAttempts < 20) {
      session.returnAttempts += 1;
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        final current = _activeSession;
        if (current == null || current.id != session.id) return;
        _handleReturn(current);
      });
      return;
    }

    // If the user backgrounds the Custom Tab (TAB_HIDDEN) and leaves it in
    // background for too long, cancel tracking.
    final hiddenAt = session.lastTabHiddenAt;
    if (hiddenAt != null && now.difference(hiddenAt) > _backgroundCancelAfter) {
      resetSession(session.id);
      return;
    }

    // Native callbacks seen but TAB_HIDDEN missing (or delayed). Treat as the
    // tab being closed when we return to the app.
    if (NativeCustomTabs.instance.isSupported &&
        session.nativeEventsSeen &&
        session.lastTabHiddenAt == null) {
      final startedAt = session.startedAt;
      if (startedAt != null) {
        session.accumulated += now.difference(startedAt);
        session.startedAt = null;
      }
    }

    // If native events are not wired up (or not supported), approximate
    // duration by using lifecycle timing.
    if (!NativeCustomTabs.instance.isSupported || !session.nativeEventsSeen) {
      final startedAt = session.startedAt;
      if (startedAt != null) {
        session.accumulated += now.difference(startedAt);
        session.startedAt = null;
      }
    }

    if (session.enableStayAndEarnPrompt) {
      final earned = _earnedCoins(session.accumulated);
      if (earned > 0 && !session.rewardGranted) {
        session.rewardGranted = true;
        _grantCoins(earned);
        resetSession(session.id);
        _showToast('Earned $earned coins');
        return;
      }

      if (session.accumulated.inSeconds < 180) {
        _showStayAndEarn(
          sessionId: session.id,
          elapsedSeconds: session.accumulated.inSeconds,
        );
        return;
      }
    }

    if (!session.showDurationToastOnReturn) {
      resetSession(session.id);
      return;
    }

    final text =
        '${session.label}: ${_formatDuration(session.accumulated.inSeconds)}';
    _showToast(text);
    resetSession(session.id);
  }

  static String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final remSeconds = seconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = remSeconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  static int _earnedCoins(Duration total) {
    final seconds = total.inSeconds;
    if (seconds >= 15 * 60) return 5000;
    if (seconds >= 10 * 60) return 3000;
    if (seconds >= 5 * 60) return 1000;
    if (seconds >= 3 * 60) return 500;
    return 0;
  }

  void _grantCoins(int coins) {
    final ctx =
        appNavigatorKey.currentContext ??
        appScaffoldMessengerKey.currentContext;
    if (ctx == null) return;
    final container = ProviderScope.containerOf(ctx);
    container.read(balanceProvider.notifier).add(coins);
  }

  void _showToast(String text) {
    final messenger = appScaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showStayAndEarn({
    required String sessionId,
    required int elapsedSeconds,
  }) {
    if (_promptingSessionId == sessionId) return;
    _promptingSessionId = sessionId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = _activeSession;
      if (session == null ||
          session.id != sessionId ||
          session.rewardGranted ||
          session.accumulated.inSeconds >= 180) {
        if (_promptingSessionId == sessionId) _promptingSessionId = null;
        return;
      }

      final nav = appNavigatorKey.currentState;
      if (nav == null) {
        if (_promptingSessionId == sessionId) _promptingSessionId = null;
        return;
      }

      nav
          .push(
            PageRouteBuilder<void>(
              opaque: false,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  StayAndEarnScreen(
                    sessionId: sessionId,
                    elapsedSeconds: elapsedSeconds,
                    onReset: () => resetSession(sessionId),
                    onStayAndEarn: () => resumeSession(sessionId),
                  ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                      reverseCurve: Curves.easeInCubic,
                    );
                    return FadeTransition(opacity: curved, child: child);
                  },
            ),
          )
          .then((_) {
            if (_promptingSessionId == sessionId) _promptingSessionId = null;
          });
    });
  }
}

class _TrackedSession {
  _TrackedSession({
    required this.id,
    required this.url,
    required this.label,
    required this.showDurationToastOnReturn,
    required this.enableStayAndEarnPrompt,
    this.onClosed,
  });

  final String id;
  final String url;
  final String label;
  final bool showDurationToastOnReturn;
  final bool enableStayAndEarnPrompt;
  final Completer<void>? onClosed;

  DateTime? startedAt;
  Duration accumulated = Duration.zero;
  bool observedPause = false;
  bool rewardGranted = false;
  DateTime? lastTabHiddenAt;
  bool nativeEventsSeen = false;
  int returnAttempts = 0;
}
