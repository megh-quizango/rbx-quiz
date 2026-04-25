import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_urls.dart';
import '../../../core/services/firebase_content_service.dart';
import '../../../core/services/tracked_web_launcher_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/services/splash_tabs_launcher_service.dart';

class PlayGamesScreen extends ConsumerStatefulWidget {
  const PlayGamesScreen({super.key});

  @override
  ConsumerState<PlayGamesScreen> createState() => _PlayGamesScreenState();
}

class _PlayGamesScreenState extends ConsumerState<PlayGamesScreen> {
  int _selectedIndex = 0;
  bool _showAllGames = false;

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(balanceProvider);
    final remoteUrls = ref.watch(remoteUrlsProvider).valueOrNull;
    final playGamesUrl = remoteUrls?.playGames ?? AppUrls.punoGames;

    final gamesAsync = ref.watch(remoteGamesProvider);
    final games = gamesAsync.valueOrNull ?? const <RemoteGame>[];
    final visibleGames = _showAllGames ? games : games.take(6).toList();
    final gridCount = (gamesAsync.isLoading && games.isEmpty)
        ? 6
        : (gamesAsync.hasError && games.isEmpty)
        ? 1
        : visibleGames.length;

    return WillPopScope(
      onWillPop: () async {
        await SplashTabsLauncherService.openForTrigger(context, trigger: 'back');
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
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Row(
                    children: [
                      Image.asset('assets/rbx.png', width: 30, height: 30),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Complete Offers, Earn More\nPerks!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2A200F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Text(
                    'Top Pick For You',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2A200F),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        TrackedWebLauncherService.instance.open(
                          playGamesUrl,
                          label: 'Top pick',
                          showDurationToastOnReturn: true,
                        );
                      },
                      child: _FeaturedOfferCard(totalEarn: balance),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'More Games For You',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2A200F),
                          ),
                        ),
                      ),
                      _SeeAllButton(
                        expanded: _showAllGames,
                        onTap: () =>
                            setState(() => _showAllGames = !_showAllGames),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (gamesAsync.isLoading && games.isEmpty) {
                      return const _GamePlaceholder();
                    }
                    if (gamesAsync.hasError && games.isEmpty) {
                      return const _GameErrorTile();
                    }

                    final game = visibleGames[index];
                    return _GameCard(
                      title: game.name,
                      imageUrl: game.imageUrl,
                      onTap: () {
                        TrackedWebLauncherService.instance.open(
                          game.url ?? playGamesUrl,
                          label: game.name,
                          showDurationToastOnReturn: true,
                        );
                      },
                    );
                  }, childCount: gridCount),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              const SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    'No More Offers',
                    style: TextStyle(
                      color: Color(0x992A200F),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 88)),
              ],
            ),
          ),
          bottomNavigationBar: _BottomNavBar(
            selectedIndex: _selectedIndex,
            onSelected: (index) => setState(() => _selectedIndex = index),
          ),
        ),
      ),
    );
  }
}

class _FeaturedOfferCard extends StatelessWidget {
  const _FeaturedOfferCard({required this.totalEarn});

  final int totalEarn;

  @override
  Widget build(BuildContext context) {
    const bottomBarHeight = 92.0;

    return SizedBox(
      height: 290,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/bg.png', fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x662A200F), Color(0x992A200F)],
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: Image.asset(
              'assets/multi.png',
              height: 28,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          // Positioned.fill(
          //   bottom: bottomBarHeight,
          //   child: Center(
          //     child: Image.asset(
          //       'assets/puno.png',
          //       width: 120,
          //       fit: BoxFit.contain,
          //       filterQuality: FilterQuality.high,
          //     ),
          //   ),
          // ),
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomBarHeight + 14,
            child: const Text(
              'PunoGames',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 26,
                height: 1.1,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: bottomBarHeight,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/puno_icon.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'TOTAL EARNED',
                              style: TextStyle(
                                color: Color(0xFF8B8B8B),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Row(
                              children: [
                                Text(
                                  '$totalEarn',
                                  style: const TextStyle(
                                    color: Color(0xFF2A200F),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 30,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Image.asset(
                                  'assets/rbx.png',
                                  width: 26,
                                  height: 26,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/play_now.png',
                    height: 46,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFDFBF6),
      elevation: 1,
      shadowColor: const Color(0x22000000),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(color: const Color(0xFFF1E6D1));
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF1E6D1),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.broken_image,
                                color: Color(0x992A200F),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Image.asset('assets/app_badge.png', height: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2A200F),
                ),
              ),
              const SizedBox(height: 4),
              Image.asset('assets/verified.png', height: 18),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    '88',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2A200F),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Image.asset('assets/rbx.png', width: 18, height: 18),
                  const Spacer(),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E6D1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: Color(0xFF2A200F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Image.asset('assets/track.png', width: 14, height: 14),
                  const SizedBox(width: 6),
                  const Text(
                    'Auto-Tracked',
                    style: TextStyle(
                      color: Color(0x992A200F),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GamePlaceholder extends StatelessWidget {
  const _GamePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF6),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1E6D1),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF1E6D1),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF1E6D1),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameErrorTile extends StatelessWidget {
  const _GameErrorTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF6),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(14),
      child: const Text(
        'Failed to load games',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0x992A200F), fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        decoration: const BoxDecoration(
          color: Color(0xFFF6EFE2),
          border: Border(top: BorderSide(color: Color(0x22FFFFFF))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              label: 'Earn',
              asset: 'assets/play.png',
              selected: selectedIndex == 0,
              onTap: () => onSelected(0),
            ),
            _NavItem(
              label: 'Spin',
              asset: 'assets/spin.png',
              selected: selectedIndex == 1,
              onTap: () {
                onSelected(1);
                context.push('/spin');
              },
            ),
            _NavItem(
              label: 'RBX Calc',
              asset: 'assets/calculator.png',
              selected: selectedIndex == 2,
              onTap: () {
                onSelected(2);
                context.push('/calculator');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF2A200F) : const Color(0x992A200F);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(asset, width: 24, height: 24, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeeAllButton extends StatelessWidget {
  const _SeeAllButton({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF201402),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            expanded ? 'See Less' : 'See All',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
