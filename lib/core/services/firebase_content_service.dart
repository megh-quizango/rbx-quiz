import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_urls.dart';
import '../state/app_state.dart';

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
