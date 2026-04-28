import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/splash_tabs_launcher_service.dart';
import '../../../core/widgets/overlay_shimmer.dart';

class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  static const _background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A2A07), Color(0xFF0B0700)],
  );

  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextOrClose() {
    if (_index < 2) {
      _controller.animateToPage(
        _index + 1,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await SplashTabsLauncherService.openForTrigger(
          context,
          trigger: 'back',
        );
        return true;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: const Color(0xFF0B0700),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFF0B0700),
          body: Container(
            decoration: const BoxDecoration(gradient: _background),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _controller,
                        onPageChanged: (i) => setState(() => _index = i),
                        children: const [
                          _InstructionsPage(
                            iconAsset: 'assets/ins1.png',
                            title: 'Spin\nTo Win',
                            description:
                                'Luck Is The Key Here. You Get One\nSpin Every Day And Rest Goes As Its\nName. Spin It And Win Coins.',
                          ),
                          _InstructionsPage(
                            iconAsset: 'assets/ins2.png',
                            title: 'Redeeming\nCoins',
                            description:
                                "You Get 100\$ For Every 500.000 Coins You\nEarn. The Payment Is Cleared Within End\nOf Actually Month. If We Find Out To You\nUse Some 'cheats' To Achieve More Coins\nWe Will Have To Cancel Your Account",
                          ),
                          _InstructionsPage(
                            iconAsset: 'assets/ins3.png',
                            title: 'Play Game\nTo Earn',
                            description:
                                "By Playing Games And Leveling Up,\nYou'll Unlock More Rewards And\nEnjoy Even More Exciting Moments",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _Dots(activeIndex: _index),
                    const SizedBox(height: 22),
                    OverlayShimmer(
                      borderRadius: BorderRadius.circular(18),
                      opacity: 0.5,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0AA14),
                            foregroundColor: const Color(0xFF2A200F),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: _nextOrClose,
                          child: Text(
                            _index < 2 ? 'CONTINUE' : 'CLOSE INSTRUCTIONS',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: 22,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InstructionsPage extends StatelessWidget {
  const _InstructionsPage({
    required this.iconAsset,
    required this.title,
    required this.description,
  });

  final String iconAsset;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.sizeOf(context).height / 900).clamp(0.70, 0.92);
    final maxTextWidth = (MediaQuery.sizeOf(context).width * 0.86).clamp(
      0,
      360,
    );
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(top: 22 * scale),
        child: Column(
          children: [
            SizedBox(
              height: 150 * scale,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: Image.asset(
                    iconAsset,
                    width: 128 * scale,
                    height: 128 * scale,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24 * scale),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 46 * scale,
                height: 1.05,
              ),
            ),
            SizedBox(height: 18 * scale),
            SizedBox(
              width: maxTextWidth.toDouble(),
              child: Text(
                description,
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                  color: const Color(0xCCFFFFFF),
                  fontWeight: FontWeight.w500,
                  fontSize: 19 * scale,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final selected = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: selected ? 16 : 10,
          height: selected ? 16 : 10,
          decoration: BoxDecoration(
            color: selected ? Colors.white : const Color(0x55FFFFFF),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
