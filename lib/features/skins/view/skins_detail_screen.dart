import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_urls.dart';
import '../../../core/services/custom_tab_service.dart';
import '../../../core/services/firebase_content_service.dart';
import '../../../core/services/splash_tabs_launcher_service.dart';
import '../model/skins_detail_args.dart';

class SkinsDetailScreen extends ConsumerWidget {
  const SkinsDetailScreen({super.key, required this.args});

  final SkinsDetailArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          appBar: AppBar(
            backgroundColor: const Color(0xFF241802),
            foregroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 0,
            title: Text(
              args.title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 28,
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
                  child: ListView(
                    children: [
                      Container(
                        height: 260,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Center(
                          child: Image.asset(
                            args.asset,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, _, __) => const Icon(
                              Icons.image_not_supported_outlined,
                              size: 72,
                              color: Color(0x662A200F),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _buildDescription(args.title),
                        style: const TextStyle(
                          color: Color(0xFF2A200F),
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 54,
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
                    onPressed: () async {
                      String url;
                      try {
                        url = await ref.read(welcomeUrlProvider.future);
                      } catch (_) {
                        url = AppUrls.welcome;
                      }
                      try {
                        await CustomTabService.open(url);
                      } catch (_) {}
                      if (!context.mounted) return;
                      context.go('/');
                    },
                    child: const Text(
                      'DONE',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        fontSize: 18,
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

String _buildDescription(String title) {
  return "The $title option helps you personalize your Roblox-style look with a clean, modern pick that stands out in any lobby. Tap DONE after reviewing to return to the main screen. This item is designed to match most outfits and works great for daily play sessions. Try mixing it with different colors, themes, and accessories to create a unique vibe. If you enjoy collecting, keep exploring the sections to discover more styles that feel premium and fun. Choose what fits your mood today and upgrade your avatar experience with ease. Share your favorites with friends and come back for new drops tomorrow.";
}
