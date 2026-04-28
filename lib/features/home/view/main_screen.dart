import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_urls.dart';
import '../../../core/services/firebase_content_service.dart';
import '../../../core/services/share_service.dart';
import '../../../core/services/tracked_web_launcher_service.dart';
import '../../../core/services/splash_tabs_launcher_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/widgets/overlay_shimmer.dart';
import '../../exit/view/exit_dialog.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isEndDrawerOpen = false;
  bool _isExitDialogOpen = false;

  Future<void> _precacheMainAssets() async {
    const assets = [
      'assets/currency.png',
      'assets/exit.png',
      'assets/profile_1.png',
      'assets/profile_2.png',
      'assets/profile_3.png',
      'assets/profile_4.png',
      'assets/profile_5.png',
    ];

    for (final a in assets) {
      if (!mounted) return;
      try {
        await precacheImage(AssetImage(a), context);
      } catch (_) {
        // ignore
      }
      await Future<void>.delayed(const Duration(milliseconds: 8));
    }
  }

  Future<void> _showExitDialog() async {
    if (_isExitDialogOpen) return;
    if (!mounted) return;

    _isExitDialogOpen = true;
    try {
      String adUrl;
      try {
        adUrl = await ref.read(welcomeUrlProvider.future);
      } catch (_) {
        final remote = ref.read(remoteUrlsProvider).valueOrNull;
        adUrl = remote?.splash ?? AppUrls.welcome;
      }
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            ExitDialog(playStoreUrl: AppUrls.playStore, adUrl: adUrl),
      );
    } finally {
      _isExitDialogOpen = false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      _precacheMainAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(balanceProvider);
    final remoteUrls = ref.watch(remoteUrlsProvider).valueOrNull;
    final triviaUrl = remoteUrls?.triviaQuiz ?? AppUrls.triviaQuiz;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Color(0xFF241802),
        systemStatusBarContrastEnforced: true,
      ),
      child: PopScope(
        canPop: _isEndDrawerOpen,
        onPopInvoked: (didPop) {
          if (didPop) return;
          if (_isEndDrawerOpen) {
            Navigator.of(context).pop();
            return;
          }
          SplashTabsLauncherService.openForTrigger(
            context,
            trigger: 'back',
          ).whenComplete(_showExitDialog);
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF6EFE2),
          endDrawer: const _FullScreenMenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          onEndDrawerChanged: (isOpen) {
            if (!mounted) return;
            setState(() => _isEndDrawerOpen = isOpen);
          },
          body: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                _TopBar(
                  onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _BalanceBar(balance: balance),
                ),
                const SizedBox(height: 16),
                const _ProfilesCarousel(),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 18 + bottomPadding),
                    children: [
                      _ActionCard(
                        title: 'STYLISH AVATAR & SKINS',
                        iconAsset: 'assets/skins.png',
                        route: '/skins',
                      ),
                      SizedBox(height: 14),
                      _ActionCard(
                        title: 'DAILY NEW RBX',
                        iconAsset: 'assets/daily.png',
                        route: '/daily',
                        variant: _ActionCardVariant.dark,
                      ),
                      SizedBox(height: 14),
                      _ActionCard(
                        title: 'PLAY GAMES & EARN',
                        iconAsset: 'assets/play.png',
                        route: '/play',
                      ),
                      SizedBox(height: 14),
                      _ActionCard(
                        title: 'TRIVIA QUIZ',
                        iconText: 'AD',
                        url: triviaUrl,
                        label: 'Trivia quiz',
                        variant: _ActionCardVariant.dark,
                      ),
                      SizedBox(height: 14),
                      _ActionCard(
                        title: 'RBX CALCULATOR',
                        iconAsset: 'assets/calculator.png',
                        route: '/calculator',
                      ),
                      SizedBox(height: 14),
                      _ActionCard(
                        title: 'SPIN TO WIN',
                        iconAsset: 'assets/spin.png',
                        route: '/spin',
                        variant: _ActionCardVariant.dark,
                      ),
                      SizedBox(height: 14),
                      _ActionCard(
                        title: 'SCRATCH TO WIN',
                        iconAsset: 'assets/scratch_icon.png',
                        route: '/scratch',
                      ),
                      SizedBox(height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    const topGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF241802), Color(0xFF241802)],
    );
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: topInset),
      decoration: const BoxDecoration(gradient: topGradient),
      child: SizedBox(
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 8,
              child: IconButton(
                onPressed: onMenuTap,
                icon: const Icon(Icons.menu),
                color: Colors.white,
                splashRadius: 24,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 64),
              child: Text(
                'Robux Rewards Get Easy RBX',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceBar extends StatelessWidget {
  const _BalanceBar({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.82,
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x22000000), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/rbx.png',
                width: 34,
                height: 34,
                color: const Color(0xFF241802),
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'MY BALANCE: ',
                          style: TextStyle(
                            color: Color(0xFF241802),
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            letterSpacing: 0.4,
                          ),
                        ),
                        TextSpan(
                          text: '$balance',
                          style: const TextStyle(
                            color: Color(0xFF241802),
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
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

class _ProfilesCarousel extends StatefulWidget {
  const _ProfilesCarousel();

  @override
  State<_ProfilesCarousel> createState() => _ProfilesCarouselState();
}

class _ProfilesCarouselState extends State<_ProfilesCarousel>
    with SingleTickerProviderStateMixin {
  static const _names = [
    'Ananya', // F (Indian)
    'Sophia', // F (US)
    'Arjun', // M (Indian)
    'Ava', // F (US)
    'Priya', // F (Indian)
    'Noah', // M (US)
    'Diya', // F (Indian)
    'Liam', // M (US)
    'Rohan', // M (Indian)
    'Emma', // F (US)
    'Kabir', // M (Indian)
    'Mia', // F (US)
    'Isha', // F (Indian)
    'Ethan', // M (US)
    'Vihaan', // M (Indian)
  ];

  static const _startIndex = 12000;
  static const _itemExtent = 110.0;
  static const _scrollSpeed = 26.0; // px/sec

  late final ScrollController _controller;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  double _accumulatedSeconds = 0;
  DateTime _pauseUntil = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(
      initialScrollOffset: _startIndex * _itemExtent,
    );
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _pauseAutoScroll() {
    _pauseUntil = DateTime.now().add(const Duration(seconds: 2));
    _lastElapsed = Duration.zero;
    _accumulatedSeconds = 0;
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    if (!_controller.hasClients) return;
    if (DateTime.now().isBefore(_pauseUntil)) {
      _lastElapsed = elapsed;
      return;
    }

    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    if (dt <= 0) return;
    _accumulatedSeconds += dt;
    if (_accumulatedSeconds < (1 / 30)) return;
    final stepSeconds = _accumulatedSeconds;
    _accumulatedSeconds = 0;

    final next = _controller.offset + (stepSeconds * _scrollSpeed);
    final max = _controller.position.maxScrollExtent;
    if (max > 0 && next >= max - 2000) {
      _controller.jumpTo(_startIndex * _itemExtent);
      return;
    }
    final target = max.isFinite ? next.clamp(0.0, max) : next;
    try {
      _controller.jumpTo(target);
    } catch (_) {
      // ignore
    }
  }

  int _amountForIndex(int index) {
    final v = (index * 1103515245 + 12345) & 0x7fffffff;
    return 60 + (v % 420);
  }

  @override
  Widget build(BuildContext context) {
    const carouselGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF241802), Color(0xFF241802)],
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(gradient: carouselGradient),
      child: SizedBox(
        height: 148,
        child: Listener(
          onPointerDown: (_) => _pauseAutoScroll(),
          onPointerMove: (_) => _pauseAutoScroll(),
          onPointerUp: (_) => _pauseAutoScroll(),
          child: NotificationListener<UserScrollNotification>(
            onNotification: (n) {
              _pauseAutoScroll();
              return false;
            },
            child: ListView.builder(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemExtent: _itemExtent,
              itemCount: 1000000,
              itemBuilder: (context, index) {
                final avatar = (index % 15) + 1;
                final name = _names[index % _names.length];
                final amount = _amountForIndex(index);
                final imageAsset = 'assets/profile_$avatar.png';
                return RepaintBoundary(
                  child: _ProfileCard(
                    imageAsset: imageAsset,
                    name: name,
                    amount: amount,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.imageAsset,
    required this.name,
    required this.amount,
  });

  final String imageAsset;
  final String name;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(22),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                cacheWidth: 180,
                cacheHeight: 180,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${amount}\$',
            style: const TextStyle(
              color: Color(0xFFE2A321),
              fontSize: 18,
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
    this.iconText,
    this.url,
    this.label,
    this.route,
    this.showAdBadge = false,
    this.variant = _ActionCardVariant.light,
  });

  final String title;
  final String? iconAsset;
  final IconData? icon;
  final String? iconText;
  final String? url;
  final String? label;
  final String? route;
  final bool showAdBadge;
  final _ActionCardVariant variant;

  @override
  Widget build(BuildContext context) {
    const darkCardColor = Color(0xFF241802);
    const lightCardColor = Color(0xFFFFFFFF);

    final isDark = variant == _ActionCardVariant.dark;
    final cardRadius = BorderRadius.circular(22);

    final iconBg = isDark ? Colors.white : darkCardColor;
    final iconFg = isDark ? darkCardColor : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF241802);

    final card = Material(
      color: isDark ? darkCardColor : lightCardColor,
      elevation: 1,
      shadowColor: const Color(0xFF241802),
      borderRadius: cardRadius,
      child: InkWell(
        borderRadius: cardRadius,
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: iconText != null
                          ? Text(
                              iconText!,
                              style: TextStyle(
                                color: iconFg,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            )
                          : iconAsset != null
                          ? Image.asset(
                              iconAsset!,
                              width: 34,
                              height: 34,
                              color: iconFg,
                            )
                          : Icon(icon ?? Icons.circle, color: iconFg, size: 34),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
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
                      color: isDark ? Colors.white : darkCardColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'AD',
                      style: TextStyle(
                        color: isDark ? darkCardColor : Colors.white,
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

    if (!isDark) return card;
    return OverlayShimmer(borderRadius: cardRadius, child: card);
  }
}

enum _ActionCardVariant { light, dark }

class _FullScreenMenuDrawer extends StatelessWidget {
  const _FullScreenMenuDrawer();

  static const _headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF241802), Color(0xFF241802)],
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Drawer(
      width: width,
      backgroundColor: const Color(0xFFF6EFE2),
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              decoration: const BoxDecoration(gradient: _headerGradient),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      iconSize: 28,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: const Color(0xCCFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF241802),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/splash_logo.png',
                        width: 86,
                        height: 86,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                child: Column(
                  children: [
                    _DrawerCard(
                      title: 'INSTRUCTIONS',
                      iconAsset: 'assets/instructions.png',
                      onTap: () {
                        Navigator.of(context).pop();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!context.mounted) return;
                          context.push('/instructions');
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    _DrawerCard(
                      title: 'SHARE',
                      iconAsset: 'assets/share.png',
                      onTap: () {
                        Navigator.of(context).pop();
                        final text = 'RBX Quiz: ${AppUrls.playStore}';
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ShareService.shareText(text);
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    _DrawerCard(
                      title: 'REDEEM',
                      iconAsset: 'assets/redeem.png',
                      onTap: () {
                        Navigator.of(context).pop();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!context.mounted) return;
                          context.push('/redeem');
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    Consumer(
                      builder: (context, ref, _) {
                        final remoteUrls = ref
                            .watch(remoteUrlsProvider)
                            .valueOrNull;
                        final aboutUrl = remoteUrls?.aboutUs ?? AppUrls.aboutUs;
                        return _DrawerCard(
                          title: 'ABOUT US',
                          iconAsset: 'assets/about.png',
                          onTap: () {
                            Navigator.of(context).pop();
                            TrackedWebLauncherService.instance.open(
                              aboutUrl,
                              label: 'About us',
                              showDurationToastOnReturn: false,
                              enableStayAndEarnPrompt: false,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerCard extends StatelessWidget {
  const _DrawerCard({
    required this.title,
    required this.iconAsset,
    required this.onTap,
  });

  final String title;
  final String iconAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFDFBF6),
      elevation: 1,
      shadowColor: const Color(0x22000000),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF201402),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Image.asset(
                    iconAsset,
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF2A200F),
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    letterSpacing: 0.2,
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
