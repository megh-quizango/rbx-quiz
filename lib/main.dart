import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routing/app_router.dart';
import 'core/services/app_scaffold_messenger.dart';
import 'core/services/tracked_web_launcher_service.dart';
import 'core/state/app_state.dart';
import 'firebase_options.dart';

Future<void> _configureOrientation() async {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final dpr = view.devicePixelRatio;
  final physical = view.physicalSize;
  final logicalShortestSide = physical.shortestSide / (dpr == 0 ? 1 : dpr);
  final isTablet = logicalShortestSide >= 600;

  if (isTablet) {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  } else {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  }
  OneSignal.initialize('64130787-f0fd-4385-a4b2-4158d1ba7eab');
  OneSignal.Notifications.requestPermission(false);

  final prefsFuture = SharedPreferences.getInstance();
  await _configureOrientation();
  TrackedWebLauncherService.instance.init();
  late final Future<FirebaseApp> firebaseInit;
  try {
    firebaseInit = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    firebaseInit = Firebase.initializeApp();
  }
  final prefs = await prefsFuture;
  runApp(
    ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        firebaseInitProvider.overrideWithValue(firebaseInit),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: appScaffoldMessengerKey,
      theme: ThemeData(
        splashFactory: InkRipple.splashFactory,
        highlightColor: const Color(0x22000000),
      ),
    );
  }
}
