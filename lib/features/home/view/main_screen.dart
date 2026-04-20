import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_urls.dart';
import '../../../core/services/tracked_web_launcher_service.dart';
import '../../../core/state/app_state.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  static const _headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A2A07), Color(0xFF0B0700)],
  );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(balanceProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFFF6EFE2),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF6EFE2),
        endDrawer: const _FullScreenMenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Header(
                gradient: _headerGradient,
                balance: balance,
                onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 18 + bottomPadding),
                  children: [
                    _ActionCard(
                      title: 'PLAY GAMES & EARN',
                      iconAsset: 'assets/play.png',
                      route: '/play',
                    ),
                    SizedBox(height: 14),
                    _ActionCard(
                      title: 'GET FREE ROBUX',
                      icon: Icons.card_giftcard,
                      url: AppUrls.freeRobux,
                      label: 'Get free robux',
                      showAdBadge: true,
                    ),
                    SizedBox(height: 14),
                    _ActionCard(
                      title: 'SPIN TO WIN',
                      iconAsset: 'assets/spin.png',
                      route: '/spin',
                    ),
                    SizedBox(height: 14),
                    _ActionCard(
                      title: 'TRIVIA QUIZ',
                      iconAsset: 'assets/trivia.png',
                      url: AppUrls.triviaQuiz,
                      label: 'Trivia quiz',
                      showAdBadge: true,
                    ),
                    SizedBox(height: 14),
                    _ActionCard(
                      title: 'SCRATCH CARD',
                      icon: Icons.auto_awesome,
                      route: '/scratch',
                    ),
                    SizedBox(height: 14),
                    _ActionCard(
                      title: 'RBX CALCULATOR',
                      iconAsset: 'assets/calculator.png',
                      route: '/calculator',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.gradient,
    required this.balance,
    required this.onMenuTap,
  });

  final Gradient gradient;
  final int balance;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 26),
      decoration: BoxDecoration(gradient: gradient),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onMenuTap,
              icon: const Icon(Icons.menu),
              color: const Color(0xCCFFFFFF),
            ),
          ),
          const SizedBox(height: 6),
          Image.asset(
            'assets/splash_logo.png',
            width: 86,
            height: 86,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 10),
          const Text(
            'MY BALANCE:',
            style: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 14,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$balance',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 54,
              height: 1.0,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    this.iconAsset,
    this.icon,
    this.url,
    this.label,
    this.route,
    this.showAdBadge = false,
  });

  final String title;
  final String? iconAsset;
  final IconData? icon;
  final String? url;
  final String? label;
  final String? route;
  final bool showAdBadge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFDFBF6),
      elevation: 1,
      shadowColor: const Color(0x22000000),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          final route = this.route;
          if (route != null) {
            context.push(route);
            return;
          }
          final url = this.url;
          final label = this.label;
          if (url == null || label == null) return;
          TrackedWebLauncherService.instance.open(
            url,
            label: label,
            showDurationToastOnReturn: true,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF201402),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: iconAsset != null
                          ? Image.asset(
                              iconAsset!,
                              width: 28,
                              height: 28,
                              color: Colors.white,
                            )
                          : Icon(
                              icon ?? Icons.circle,
                              color: Colors.white,
                              size: 28,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF2A200F),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              if (showAdBadge)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF201402),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'AD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullScreenMenuDrawer extends StatelessWidget {
  const _FullScreenMenuDrawer();

  static const _background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A2A07), Color(0xFF0B0700)],
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Drawer(
      width: width,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(gradient: _background),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Row(
                  children: [
                    const Spacer(),
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xCCFFFFFF),
                          side: const BorderSide(color: Color(0x33FFFFFF)),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.center,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {},
                        child: const Center(child: Icon(Icons.share_outlined)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xCCFFFFFF),
                          side: const BorderSide(color: Color(0x33FFFFFF)),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.center,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Center(child: Icon(Icons.close)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Image.asset(
                'assets/splash_logo.png',
                width: 110,
                height: 110,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(height: 46),
              _MenuItem(
                icon: Icons.info_outline,
                label: 'INSTRUCTIONS',
                onTap: () {},
              ),
              const SizedBox(height: 18),
              _MenuItem(
                icon: Icons.wallet_giftcard_outlined,
                label: 'REDEEM',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/redeem');
                },
              ),
              const SizedBox(height: 18),
              _MenuItem(
                icon: Icons.person_outline,
                label: 'ABOUT US',
                onTap: () {},
              ),
              const Spacer(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE2A321), size: 26),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
