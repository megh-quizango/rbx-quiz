import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_urls.dart';
import '../../../core/services/tracked_web_launcher_service.dart';

class PlayGamesScreen extends StatefulWidget {
  const PlayGamesScreen({super.key});

  @override
  State<PlayGamesScreen> createState() => _PlayGamesScreenState();
}

class _PlayGamesScreenState extends State<PlayGamesScreen> {
  int _selectedIndex = 0;
  bool _showAllGames = false;

  static const List<String> _gameAssets = [
    'assets/ball_blaster.jpg',
    'assets/block_vs_ball.png',
    'assets/2048.png',
    'assets/bottle_shoot.jpg',
    'assets/bubble_shooter.jpg',
    'assets/carnival_ducks.jpg',
    'assets/color_bump.jpg',
    'assets/colorup.jpg',
    'assets/drop_the_number.png',
    'assets/fighter_jet.jpg',
    'assets/flappy_bird.jpeg',
    'assets/fruit_ninja.jpg',
    'assets/infinite_jumper.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final visibleGames = _showAllGames ? _gameAssets : _gameAssets.take(6);
    return AnnotatedRegion<SystemUiOverlayStyle>(
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
                  child: GestureDetector(
                    onTap: () {
                      TrackedWebLauncherService.instance.open(
                        AppUrls.punoGames,
                        label: 'Top pick',
                        showDurationToastOnReturn: true,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/featured.png',
                        fit: BoxFit.cover,
                      ),
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
                    final asset = visibleGames.elementAt(index);
                    final title = _titleFromAsset(asset);
                    return _GameCard(
                      title: title,
                      asset: asset,
                      onTap: () {
                        TrackedWebLauncherService.instance.open(
                          AppUrls.punoGames,
                          label: title,
                          showDurationToastOnReturn: true,
                        );
                      },
                    );
                  }, childCount: visibleGames.length),
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
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.title,
    required this.asset,
    required this.onTap,
  });

  final String title;
  final String asset;
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
                        child: Image.asset(asset, fit: BoxFit.cover),
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
    return InkWell(
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

String _titleFromAsset(String assetPath) {
  var name = assetPath.split('/').last;
  final dot = name.lastIndexOf('.');
  if (dot >= 0) name = name.substring(0, dot);

  final parts = name.split('_').where((p) => p.isNotEmpty);
  final words = parts.map((p) {
    if (RegExp(r'^[0-9]+$').hasMatch(p)) return p;
    final lower = p.toLowerCase();
    if (lower.length == 1) return lower.toUpperCase();
    return lower[0].toUpperCase() + lower.substring(1);
  });
  return words.join(' ');
}
