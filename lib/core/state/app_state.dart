import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final prefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('prefsProvider must be overridden in main()');
});

final balanceProvider = NotifierProvider<BalanceNotifier, int>(
  BalanceNotifier.new,
);

class BalanceNotifier extends Notifier<int> {
  static const _key = 'balance';

  @override
  int build() {
    final prefs = ref.read(prefsProvider);
    return prefs.getInt(_key) ?? 200;
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
