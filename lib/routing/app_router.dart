import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/services/app_navigator.dart';
import '../features/home/view/main_screen.dart';
import '../features/calculator/view/rbx_calculator_screen.dart';
import '../features/calculator/view/rbx_conversion_screen.dart';
import '../features/calculator/model/calculator_options.dart';
import '../features/play_games/view/play_games_screen.dart';
import '../features/redeem/view/redeem_coins_screen.dart';
import '../features/redeem/view/redeem_email_screen.dart';
import '../features/scratch/view/scratch_card_screen.dart';
import '../features/spin/view/spin_to_win_screen.dart';
import '../features/splash/view/splash_screen.dart';
import '../features/instructions/view/instructions_screen.dart';
import '../features/daily/view/daily_new_rbx_screen.dart';
import '../features/skins/model/skins_detail_args.dart';
import '../features/skins/view/skins_detail_screen.dart';
import '../features/skins/view/skins_home_screen.dart';
import '../features/skins/view/skins_list_screen.dart';
import '../features/skins/view/skins_node_screen.dart';

final appRouter = GoRouter(
  navigatorKey: appNavigatorKey,
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
      path: '/calculator/convert/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final spec = kConversionSpecs.firstWhere(
          (s) => s.id == id,
          orElse: () => kConversionSpecs.first,
        );
        return _smoothPage(
          state: state,
          child: RbxConversionScreen(spec: spec),
        );
      },
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
    GoRoute(
      path: '/instructions',
      pageBuilder: (context, state) =>
          _smoothPage(state: state, child: const InstructionsScreen()),
    ),
    GoRoute(
      path: '/daily',
      pageBuilder: (context, state) =>
          _smoothPage(state: state, child: const DailyNewRbxScreen()),
    ),
    GoRoute(
      path: '/skins',
      pageBuilder: (context, state) =>
          _smoothPage(state: state, child: const SkinsHomeScreen()),
    ),
    GoRoute(
      path: '/skins/node/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return _smoothPage(state: state, child: SkinsNodeScreen(nodeId: id));
      },
    ),
    GoRoute(
      path: '/skins/list/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return _smoothPage(state: state, child: SkinsListScreen(listId: id));
      },
    ),
    GoRoute(
      path: '/skins/detail',
      pageBuilder: (context, state) {
        final args = state.extra;
        if (args is! SkinsDetailArgs) {
          return _smoothPage(
            state: state,
            child: const SkinsHomeScreen(),
          );
        }
        return _smoothPage(state: state, child: SkinsDetailScreen(args: args));
      },
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
