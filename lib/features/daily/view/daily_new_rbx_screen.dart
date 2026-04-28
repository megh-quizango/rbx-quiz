import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_urls.dart';
import '../../../core/services/custom_tab_service.dart';
import '../../../core/services/firebase_content_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/services/splash_tabs_launcher_service.dart';
import '../../../core/widgets/overlay_shimmer.dart';

class DailyNewRbxScreen extends ConsumerStatefulWidget {
  const DailyNewRbxScreen({super.key});

  @override
  ConsumerState<DailyNewRbxScreen> createState() => _DailyNewRbxScreenState();
}

class _DailyNewRbxScreenState extends ConsumerState<DailyNewRbxScreen> {
  bool _busy = false;

  String _ymd(DateTime now) {
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  int _amountForToday(DateTime now) {
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final v = (seed * 1103515245 + 12345) & 0x7fffffff;
    return 1 + (v % 300);
  }

  Future<void> _claim({required String url, required int amount}) async {
    if (_busy) return;
    setState(() => _busy = true);
    SplashTabsConfig config;
    try {
      config = await ref.read(splashTabsConfigProvider.future);
    } catch (_) {
      config = SplashTabsConfig.fallback;
    }
    if (config.enabled) {
      try {
        await CustomTabService.open(url);
      } catch (_) {
        // ignore
      }
    }
    if (!mounted) return;
    await ref.read(balanceProvider.notifier).add(amount);
    await ref.read(dailyRbxClaimProvider.notifier).markClaimed(DateTime.now());
    if (!mounted) return;
    context.go('/');
  }

  Future<void> _done({required String url}) async {
    if (_busy) return;
    setState(() => _busy = true);
    SplashTabsConfig config;
    try {
      config = await ref.read(splashTabsConfigProvider.future);
    } catch (_) {
      config = SplashTabsConfig.fallback;
    }
    if (config.enabled) {
      try {
        await CustomTabService.open(url);
      } catch (_) {
        // ignore
      }
    }
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final splashUrl =
        ref.watch(welcomeUrlProvider).valueOrNull ?? AppUrls.welcome;
    final now = DateTime.now();
    final lastClaimYmd = ref.watch(dailyRbxClaimProvider);
    final canClaim = lastClaimYmd != _ymd(now);
    final amount = _amountForToday(now);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final giftWidth = (screenWidth * 0.55).clamp(160.0, 220.0);
    final giftHeight = (screenHeight * 0.16).clamp(80.0, 130.0);

    return WillPopScope(
      onWillPop: () async {
        await SplashTabsLauncherService.openForTrigger(
          context,
          trigger: 'back',
        );
        return true;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: const Color(0xFFF6EFE2),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF6EFE2),
          appBar: AppBar(
            backgroundColor: const Color(0xFF241802),
            foregroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 0,
            title: const Text(
              'Daily New RBX',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 24,
                letterSpacing: 0.2,
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxHeight < 560;
                        final cardSize = compact ? 180.0 : 210.0;
                        final topGap = compact ? 14.0 : 28.0;
                        final betweenGap = compact ? 16.0 : 24.0;
                        final bodyFont = compact ? 16.0 : 18.0;
                        final titleFont = compact ? 20.0 : 22.0;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: topGap),
                              Center(
                                child: _RbxAmountCard(
                                  amount: amount,
                                  showAmount: canClaim,
                                  size: cardSize,
                                ),
                              ),
                              SizedBox(height: betweenGap),
                              if (canClaim) ...[
                                Text(
                                  "You've earned great bonus points today thanks to your effort and activity! Keep going and collect more rewards every day.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF2A200F),
                                    fontWeight: FontWeight.w700,
                                    height: 1.15,
                                    fontSize: bodyFont,
                                  ),
                                ),
                                SizedBox(height: compact ? 14 : 18),
                                Text(
                                  'We truly appreciate your dedication. Every step brings you closer to new rewards and exclusive benefits. Stay active your next milestone may be just around the corner!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF2A200F),
                                    fontWeight: FontWeight.w600,
                                    height: 1.15,
                                    fontSize: bodyFont,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: SizedBox(
                                    width: giftWidth,
                                    height: giftHeight,
                                    child: Image.asset(
                                      'assets/gift.png',
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.medium,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  "You've already collected\ntoday's daily bonus!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF2A200F),
                                    fontWeight: FontWeight.w900,
                                    height: 1.12,
                                    fontSize: titleFont,
                                  ),
                                ),
                                SizedBox(height: compact ? 10 : 14),
                                Text(
                                  'No worries - more rewards are waiting.\nCome back tomorrow to claim your next\nbonus and keep your streak alive!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF2A200F),
                                    fontWeight: FontWeight.w600,
                                    height: 1.35,
                                    fontSize: bodyFont,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (canClaim) ...[const SizedBox(height: 8)],
                  OverlayShimmer(
                    borderRadius: BorderRadius.circular(18),
                    enabled: !_busy, // shimmer only when active (optional)
                    opacity: 0.5,
                    child: SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE2A321),
                          foregroundColor: const Color(0xFF2A200F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _busy
                            ? null
                            : canClaim
                            ? () => _claim(url: splashUrl, amount: amount)
                            : () => _done(url: splashUrl),
                        child: Text(
                          canClaim ? 'CLAIM NOW' : 'DONE',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            fontSize: 20,
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
    );
  }
}

class _RbxAmountCard extends StatelessWidget {
  const _RbxAmountCard({
    required this.amount,
    required this.showAmount,
    required this.size,
  });

  final int amount;
  final bool showAmount;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF241802), Color(0xFF0B0700)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showAmount) ...[
            Image.asset(
              'assets/splash_logo.png',
              width: size * 0.40,
              height: size * 0.40,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
            SizedBox(height: size * 0.08),
            Text(
              '$amount',
              style: TextStyle(
                color: const Color(0xFFE7D39A),
                fontWeight: FontWeight.w900,
                fontSize: size * 0.20,
                height: 1.0,
              ),
            ),
          ] else ...[
            Center(
              child: Image.asset(
                'assets/rbx.png',
                width: size * 0.58,
                height: size * 0.58,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
