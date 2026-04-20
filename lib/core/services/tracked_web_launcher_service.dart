import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

import 'app_scaffold_messenger.dart';

class TrackedWebLauncherService with WidgetsBindingObserver {
  TrackedWebLauncherService._();

  static final TrackedWebLauncherService instance =
      TrackedWebLauncherService._();

  bool _initialized = false;
  _Session? _session;

  void init() {
    if (_initialized) return;
    WidgetsBinding.instance.addObserver(this);
    _initialized = true;
  }

  Future<void> open(
    String url, {
    required String label,
    required bool showDurationToastOnReturn,
  }) async {
    init();
    _session = _Session(
      label: label,
      startedAt: DateTime.now(),
      showDurationToastOnReturn: showDurationToastOnReturn,
    );

    await launchUrl(
      Uri.parse(url),
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
      _session?.observedPause = true;
      return;
    }

    if (state == AppLifecycleState.detached) {
      _session = null;
      return;
    }

    if (state != AppLifecycleState.resumed) return;
    final session = _session;
    if (session == null) return;
    _session = null;

    if (!session.observedPause) return;
    if (!session.showDurationToastOnReturn) return;
    final duration = DateTime.now().difference(session.startedAt);
    final seconds = duration.inSeconds;
    final text = '${session.label}: ${_formatDuration(seconds)}';

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

  static String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final remSeconds = seconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = remSeconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

class _Session {
  _Session({
    required this.label,
    required this.startedAt,
    required this.showDurationToastOnReturn,
  });

  final String label;
  final DateTime startedAt;
  final bool showDurationToastOnReturn;
  bool observedPause = false;
}
