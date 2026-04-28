import 'dart:async';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_urls.dart';
import '../state/app_state.dart';

class SplashTabsUrl {
  const SplashTabsUrl({required this.url, required this.weight});

  final String url;
  final int weight;

  factory SplashTabsUrl.fromAny(Object? value) {
    if (value is Map) {
      final map = value.map((k, v) => MapEntry(k.toString(), v));
      final url = (map['url'] ?? map['link'] ?? '').toString().trim();
      final wRaw = map['weight'] ?? map['w'] ?? 1;
      final weight = wRaw is num ? wRaw.toInt() : int.tryParse('$wRaw') ?? 1;
      return SplashTabsUrl(url: url, weight: weight);
    }
    if (value is String) {
      return SplashTabsUrl(url: value.trim(), weight: 1);
    }
    return const SplashTabsUrl(url: '', weight: 0);
  }
}

class SplashTabsConfig {
  const SplashTabsConfig({
    required this.enabled,
    required this.launchAfterSplashEnabled,
    required this.tabsPerTrigger,
    required this.urls,
  });

  final bool enabled;
  final bool launchAfterSplashEnabled;
  final int tabsPerTrigger;
  final List<SplashTabsUrl> urls;

  static const fallback = SplashTabsConfig(
    enabled: true,
    launchAfterSplashEnabled: true,
    tabsPerTrigger: 1,
    urls: [SplashTabsUrl(url: AppUrls.welcome, weight: 1)],
  );

  factory SplashTabsConfig.fromAny(Object? value) {
    if (value is String) {
      final u = value.trim();
      return SplashTabsConfig(
        enabled: true,
        launchAfterSplashEnabled: true,
        tabsPerTrigger: 1,
        urls: [SplashTabsUrl(url: u.isEmpty ? AppUrls.welcome : u, weight: 1)],
      );
    }

    if (value is List) {
      final urls = value
          .map(SplashTabsUrl.fromAny)
          .where((e) => e.url.isNotEmpty)
          .toList();
      return SplashTabsConfig(
        enabled: true,
        launchAfterSplashEnabled: true,
        tabsPerTrigger: 1,
        urls: urls.isEmpty ? fallback.urls : urls,
      );
    }

    if (value is Map) {
      final map = value.map((k, v) => MapEntry(k.toString(), v));
      final enabledRaw = map['enabled'];
      final enabled = enabledRaw == null
          ? true
          : enabledRaw is bool
          ? enabledRaw
          : ('$enabledRaw'.toLowerCase() == 'true');

      final afterRaw =
          map['launchAfterSplashEnabled'] ?? map['launchAfterSplash'];
      final launchAfterSplashEnabled = afterRaw == null
          ? true
          : afterRaw is bool
          ? afterRaw
          : ('$afterRaw'.toLowerCase() == 'true');

      final tRaw = map['tabsPerTrigger'] ?? map['tabs'] ?? 1;
      final tabsPerTrigger = tRaw is num
          ? tRaw.toInt()
          : int.tryParse('$tRaw') ?? 1;

      final urlsRaw = map['urls'] ?? map['items'] ?? map['list'];
      final urls = <SplashTabsUrl>[];
      if (urlsRaw is List) {
        for (final item in urlsRaw) {
          final u = SplashTabsUrl.fromAny(item);
          if (u.url.isNotEmpty) urls.add(u);
        }
      } else if (urlsRaw is Map) {
        for (final item in urlsRaw.values) {
          final u = SplashTabsUrl.fromAny(item);
          if (u.url.isNotEmpty) urls.add(u);
        }
      }

      return SplashTabsConfig(
        enabled: enabled,
        launchAfterSplashEnabled: launchAfterSplashEnabled,
        tabsPerTrigger: tabsPerTrigger,
        urls: urls.isEmpty ? fallback.urls : urls,
      );
    }

    return fallback;
  }

  String? firstUrlOrNull() {
    for (final u in urls) {
      if (u.url.trim().isNotEmpty) return u.url.trim();
    }
    return null;
  }

  String pickWeightedUrl([Random? random]) {
    final r = random ?? Random();
    final candidates = urls.where((u) => u.url.isNotEmpty).toList();
    if (candidates.isEmpty) return AppUrls.welcome;

    var total = 0;
    for (final c in candidates) {
      final w = c.weight <= 0 ? 0 : c.weight;
      total += w;
    }
    if (total <= 0) return candidates.first.url;

    var roll = r.nextInt(total);
    for (final c in candidates) {
      final w = c.weight <= 0 ? 0 : c.weight;
      if (w == 0) continue;
      if (roll < w) return c.url;
      roll -= w;
    }
    return candidates.first.url;
  }
}

class RemoteUrls {
  const RemoteUrls({
    required this.splash,
    required this.playGames,
    required this.freeRobux,
    required this.triviaQuiz,
    required this.aboutUs,
    required this.stylishAvatarSkins,
    required this.dailyNewRbx,
  });

  final String splash;
  final String playGames;
  final String freeRobux;
  final String triviaQuiz;
  final String aboutUs;
  final String stylishAvatarSkins;
  final String dailyNewRbx;

  static const fallback = RemoteUrls(
    splash: AppUrls.welcome,
    playGames: AppUrls.punoGames,
    freeRobux: AppUrls.freeRobux,
    triviaQuiz: AppUrls.triviaQuiz,
    aboutUs: AppUrls.aboutUs,
    stylishAvatarSkins: AppUrls.stylishAvatarSkins,
    dailyNewRbx: AppUrls.dailyNewRbx,
  );

  factory RemoteUrls.fromAny(Object? value) {
    if (value is Map) {
      final map = value.map((k, v) => MapEntry(k.toString(), v));
      String readUrl(List<String> keys, String fallback) {
        for (final k in keys) {
          final v = map[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
          if (v is Map || v is List) {
            final cfg = SplashTabsConfig.fromAny(v);
            final first = cfg.firstUrlOrNull();
            if (first != null && first.isNotEmpty) return first;
          }
        }
        return fallback;
      }

      return RemoteUrls(
        splash: readUrl(const [
          'splash',
          'welcome',
          'afterSplash',
          'splashUrl',
        ], fallback.splash),
        playGames: readUrl(const [
          'playGames',
          'games',
          'punoGames',
          'playGamesUrl',
        ], fallback.playGames),
        freeRobux: readUrl(const [
          'freeRobux',
          'getFreeRobux',
          'freeRobuxUrl',
        ], fallback.freeRobux),
        triviaQuiz: readUrl(const [
          'triviaQuiz',
          'trivia',
          'triviaQuizUrl',
        ], fallback.triviaQuiz),
        aboutUs: readUrl(const [
          'aboutUs',
          'about',
          'aboutUsUrl',
        ], fallback.aboutUs),
        stylishAvatarSkins: readUrl(const [
          'stylishAvatarSkins',
          'skins',
          'skinsUrl',
          'avatarSkins',
          'avatarSkinsUrl',
        ], fallback.stylishAvatarSkins),
        dailyNewRbx: readUrl(const [
          'dailyNewRbx',
          'daily',
          'dailyUrl',
          'dailyNewRbxUrl',
        ], fallback.dailyNewRbx),
      );
    }
    return fallback;
  }
}

class RemoteGame {
  const RemoteGame({
    required this.name,
    required this.imageUrl,
    this.url,
    this.order,
  });

  final String name;
  final String imageUrl;
  final String? url;
  final int? order;

  factory RemoteGame.fromAny(Object? value) {
    if (value is Map) {
      final map = value.map((k, v) => MapEntry(k.toString(), v));
      final name = (map['name'] ?? map['title'] ?? map['gameName'] ?? '')
          .toString();
      final imageUrl = (map['imageUrl'] ?? map['image'] ?? map['img'] ?? '')
          .toString();
      final url = (map['url'] ?? map['link'])?.toString();
      final orderRaw = map['order'];
      final order = orderRaw is num
          ? orderRaw.toInt()
          : int.tryParse('$orderRaw');
      return RemoteGame(
        name: name.trim(),
        imageUrl: imageUrl.trim(),
        url: (url ?? '').trim().isEmpty ? null : url!.trim(),
        order: order,
      );
    }
    return const RemoteGame(name: '', imageUrl: '');
  }
}

final remoteUrlsProvider = StreamProvider<RemoteUrls>((ref) async* {
  final app = await ref.watch(firebaseInitProvider);
  final db = _databaseFor(app);
  yield* db.ref('config/urls').onValue.map((e) {
    return RemoteUrls.fromAny(e.snapshot.value);
  });
});

final splashTabsConfigProvider = StreamProvider<SplashTabsConfig>((ref) async* {
  final app = await ref.watch(firebaseInitProvider);
  final db = _databaseFor(app);
  yield* db.ref('config/urls/splash').onValue.map((e) {
    return SplashTabsConfig.fromAny(e.snapshot.value);
  });
});

final welcomeUrlProvider = FutureProvider<String>((ref) async {
  try {
    final cfg = await ref
        .watch(splashTabsConfigProvider.future)
        .timeout(const Duration(seconds: 5));
    return cfg.pickWeightedUrl();
  } catch (_) {
    final cfg = ref.read(splashTabsConfigProvider).valueOrNull;
    final local = cfg?.firstUrlOrNull();
    if (local != null && local.isNotEmpty) return local;

    final remote = ref.read(remoteUrlsProvider).valueOrNull;
    return remote?.splash ?? AppUrls.welcome;
  }
});

final remoteGamesProvider = StreamProvider<List<RemoteGame>>((ref) async* {
  final app = await ref.watch(firebaseInitProvider);
  final db = _databaseFor(app);
  yield* db.ref('games').onValue.map((e) {
    final v = e.snapshot.value;
    final games = <RemoteGame>[];
    if (v is List) {
      for (final item in v) {
        final g = RemoteGame.fromAny(item);
        if (g.name.isNotEmpty && g.imageUrl.isNotEmpty) games.add(g);
      }
    } else if (v is Map) {
      for (final item in v.values) {
        final g = RemoteGame.fromAny(item);
        if (g.name.isNotEmpty && g.imageUrl.isNotEmpty) games.add(g);
      }
    }
    games.sort((a, b) {
      final ao = a.order ?? 1 << 30;
      final bo = b.order ?? 1 << 30;
      final byOrder = ao.compareTo(bo);
      if (byOrder != 0) return byOrder;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return games;
  });
});

// extension AsyncValueX<T> on AsyncValue<T> {
//   T? get valueOrNull =>
//       when(data: (d) => d, error: (_, __) => null, loading: () => null);
// }

FirebaseDatabase _databaseFor(FirebaseApp app) {
  final projectId = app.options.projectId;
  final guessed = 'https://$projectId-default-rtdb.firebaseio.com';
  return FirebaseDatabase.instanceFor(app: app, databaseURL: guessed);
}
