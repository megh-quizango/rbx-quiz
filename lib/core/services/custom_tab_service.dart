import 'dart:ui';

import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class CustomTabService {
  CustomTabService._();

  static Future<void> open(String url) async {
    await launchUrl(
      Uri.parse(url),
      customTabsOptions: CustomTabsOptions(
        showTitle: true,
        urlBarHidingEnabled: true,
        colorSchemes: CustomTabsColorSchemes.defaults(
          toolbarColor: const Color(0xFF241802),
          navigationBarColor: const Color(0xFFF6EFE2),
        ),
        shareState: CustomTabsShareState.off,
      ),
      safariVCOptions: const SafariViewControllerOptions(
        barCollapsingEnabled: true,
        entersReaderIfAvailable: false,
      ),
    );
  }
}

