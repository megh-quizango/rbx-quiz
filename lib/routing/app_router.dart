import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/view/main_screen.dart';
import '../features/calculator/view/rbx_calculator_screen.dart';
import '../features/play_games/view/play_games_screen.dart';
import '../features/redeem/view/redeem_coins_screen.dart';
import '../features/redeem/view/redeem_email_screen.dart';
import '../features/scratch/view/scratch_card_screen.dart';
import '../features/spin/view/spin_to_win_screen.dart';
import '../features/splash/view/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          _smoothPage(state: state, child: const MainScreen()),
    ),
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) =>
          _smoothPage(state: state, child: const SplashScreen()),
    ),
    GoRoute(
      path: '/play',
      pageBuilder: (context, state) =>
          _smoothPage(state: state, child: const PlayGamesScreen()),
    ),
    GoRoute(
      path: '/calculator',
      pageBuilder: (context, state) =>
          _smoothPage(state: state, child: const RbxCalculatorScreen()),
    ),
    GoRoute(
      path: '/spin',
      pageBuilder: (context, state) =>
          _smoothPage(state: state, child: const SpinToWinScreen()),
    ),
    GoRoute(
      path: '/redeem',
      pageBuilder: (context, state) =>
          _smoothPage(state: state, child: const RedeemCoinsScreen()),
    ),
    GoRoute(
      path: '/redeem/email',
      pageBuilder: (context, state) {
        final coins =
            int.tryParse(state.uri.queryParameters['coins'] ?? '') ?? 0;
        return _smoothPage(
          state: state,
          child: RedeemEmailScreen(coins: coins),
        );
      },
    ),
    GoRoute(
      path: '/scratch',
      pageBuilder: (context, state) =>
          _smoothPage(state: state, child: const ScratchCardScreen()),
    ),
  ],
);

Page<void> _smoothPage({required GoRouterState state, required Widget child}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final offset = Tween<Offset>(
        begin: const Offset(0, 0.03),
        end: Offset.zero,
      ).animate(curved);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(position: offset, child: child),
      );
    },
  );
}
