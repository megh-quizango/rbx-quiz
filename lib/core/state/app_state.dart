import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

final prefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('prefsProvider must be overridden in main()');
});

final firebaseInitProvider = Provider<Future<FirebaseApp>>((ref) {
  throw UnimplementedError('firebaseInitProvider must be overridden in main()');
});

final balanceProvider = NotifierProvider<BalanceNotifier, int>(
  BalanceNotifier.new,
);

class BalanceNotifier extends Notifier<int> {
  static const _key = 'balance';

  @override
  int build() {
    final prefs = ref.read(prefsProvider);
    return prefs.getInt(_key) ?? 0;
  }

  Future<void> add(int delta) async {
    state = state + delta;
    await ref.read(prefsProvider).setInt(_key, state);
  }
}

final spinRewardGateProvider =
    NotifierProvider<SpinRewardGateNotifier, DateTime?>(
      SpinRewardGateNotifier.new,
    );

class SpinRewardGateNotifier extends Notifier<DateTime?> {
  static const _key = 'last_spin_reward_ms';

  @override
  DateTime? build() {
    final prefs = ref.read(prefsProvider);
    final ms = prefs.getInt(_key);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  bool canRewardNow(DateTime now) {
    final last = state;
    if (last == null) return true;
    return now.difference(last) >= const Duration(hours: 24);
  }

  Future<void> markRewarded(DateTime now) async {
    state = now;
    await ref.read(prefsProvider).setInt(_key, now.millisecondsSinceEpoch);
  }
}

final dailyRbxClaimProvider = NotifierProvider<DailyRbxClaimNotifier, String?>(
  DailyRbxClaimNotifier.new,
);

class DailyRbxClaimNotifier extends Notifier<String?> {
  static const _key = 'daily_rbx_last_claim_ymd';

  @override
  String? build() {
    final prefs = ref.read(prefsProvider);
    return prefs.getString(_key);
  }

  bool canClaimToday(DateTime now) {
    final today = _ymd(now);
    return state != today;
  }

  Future<void> markClaimed(DateTime now) async {
    final today = _ymd(now);
    state = today;
    await ref.read(prefsProvider).setString(_key, today);
  }
}

String _ymd(DateTime now) {
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
