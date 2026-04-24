import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_urls.dart';
import '../../../core/services/firebase_content_service.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  bool _welcomeLaunched = false;
  late final Future<String> _welcomeUrlFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _welcomeUrlFuture = _prefetchWelcomeUrl();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _controller.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      if (!mounted) return;
      _launchWelcomeTab();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_welcomeLaunched) return;
    if (state != AppLifecycleState.resumed) return;
    if (!mounted) return;
    context.go('/');
  }

  Future<String> _prefetchWelcomeUrl() async {
    try {
      final remote = await ref
          .read(remoteUrlsProvider.future)
          .timeout(const Duration(seconds: 5));
      return remote.splash;
    } catch (_) {
      final remote = ref.read(remoteUrlsProvider).valueOrNull;
      return remote?.splash ?? AppUrls.welcome;
    }
  }

  Future<void> _launchWelcomeTab() async {
    if (_welcomeLaunched) return;
    _welcomeLaunched = true;
    final url = await _welcomeUrlFuture;
    try {
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
    } catch (_) {
      if (!mounted) return;
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF0B0700),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _SplashBackground(),
            SafeArea(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Column(
                    children: [
                      const Spacer(),
                      const _CenterMark(),
                      const Spacer(),
                      _LoadingSection(progress: _controller.value),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3A2A07), Color(0xFF0B0700)],
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.85),
              radius: 1.2,
              colors: [Color(0x554D370A), Color(0x00000000)],
              stops: [0.0, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

class _CenterMark extends StatelessWidget {
  const _CenterMark();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortestSide = constraints.biggest.shortestSide;
        final outerSize = shortestSide * 0.64;
        final innerSize = outerSize * 0.62;

        return SizedBox(
          width: outerSize,
          height: outerSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.38,
                child: Image.asset(
                  'assets/splash_center.png',
                  width: outerSize,
                  height: outerSize,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Image.asset(
                'assets/splash_logo.png',
                width: innerSize,
                height: innerSize,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'LOADING',
            style: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 12,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _ProgressBar(value: progress),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final clamped = value.clamp(0.0, 1.0);
        final filledWidth = width * clamped;

        return SizedBox(
          height: 4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x99D9D9D9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: filledWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2A321),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
