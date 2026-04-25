import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_content_service.dart';
import 'tracked_web_launcher_service.dart';

class SplashTabsLauncherService {
  SplashTabsLauncherService._();

  static const _timeout = Duration(seconds: 5);
  static final Random _random = Random();

  static Future<void> openForTrigger(
    BuildContext context, {
    required String trigger,
  }) async {
    final container = ProviderScope.containerOf(context, listen: false);

    SplashTabsConfig config;
    try {
      config = await container
          .read(splashTabsConfigProvider.future)
          .timeout(_timeout);
    } catch (_) {
      config = SplashTabsConfig.fallback;
    }

    if (!config.enabled) return;

    final count = config.tabsPerTrigger.clamp(0, 10);
    if (count == 0) return;

    for (var i = 0; i < count; i++) {
      final url = config.pickWeightedUrl(_random);
      try {
        await TrackedWebLauncherService.instance.openAndWait(
          url,
          label: 'splash:$trigger',
          enableStayAndEarnPrompt: false,
        );
      } catch (_) {
        // ignore
      }
    }
  }

  static Future<void> openAfterSplashIfEnabled(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);

    SplashTabsConfig config;
    try {
      config = await container
          .read(splashTabsConfigProvider.future)
          .timeout(_timeout);
    } catch (_) {
      config = SplashTabsConfig.fallback;
    }

    if (!config.enabled || !config.launchAfterSplashEnabled) return;
    await openForTrigger(context, trigger: 'after_splash');
  }
}
