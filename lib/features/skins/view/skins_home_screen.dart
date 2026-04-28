import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../model/skins_catalog.dart';
import '../../../core/services/splash_tabs_launcher_service.dart';

class SkinsHomeScreen extends StatelessWidget {
  const SkinsHomeScreen({super.key});

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
              SkinsCatalog.homeTitle,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: 0.2,
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _CategoryCard(
                        title: 'All Character',
                        asset: 'assets/all_character.png',
                        onTap: () {
                          SplashTabsLauncherService.openForTrigger(
                            context,
                            trigger: 'skins_card',
                          ).whenComplete(() {
                            if (!context.mounted) return;
                            context.push('/skins/list/all_character');
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _CategoryCard(
                        title: 'Animations',
                        asset: 'assets/animations.png',
                        onTap: () {
                          SplashTabsLauncherService.openForTrigger(
                            context,
                            trigger: 'skins_card',
                          ).whenComplete(() {
                            if (!context.mounted) return;
                            context.push('/skins/node/animations');
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _CategoryCard(
                        title: 'Accesories',
                        asset: 'assets/accesories.png',
                        onTap: () {
                          SplashTabsLauncherService.openForTrigger(
                            context,
                            trigger: 'skins_card',
                          ).whenComplete(() {
                            if (!context.mounted) return;
                            context.push('/skins/node/accesories');
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _CategoryCard(
                        title: 'All Clothing',
                        asset: 'assets/all_clothing.png',
                        onTap: () {
                          SplashTabsLauncherService.openForTrigger(
                            context,
                            trigger: 'skins_card',
                          ).whenComplete(() {
                            if (!context.mounted) return;
                            context.push('/skins/node/all_clothing');
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _CategoryCard(
                  title: 'Head & Body',
                  asset: 'assets/head_body.png',
                  onTap: () {
                    SplashTabsLauncherService.openForTrigger(
                      context,
                      trigger: 'skins_card',
                    ).whenComplete(() {
                      if (!context.mounted) return;
                      context.push('/skins/node/head_body');
                    });
                  },
                  wide: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.title,
    required this.asset,
    required this.onTap,
    this.wide = false,
  });

  final String title;
  final String asset;
  final VoidCallback onTap;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final height = wide ? 220.0 : 200.0;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: const Color(0x22000000),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Image.asset(
                      asset,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, _, __) => const Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Color(0x662A200F),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF2A200F),
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    height: 1.05,
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
