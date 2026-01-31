import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'services/notification_service.dart';
import 'utils/routes.dart';
import 'pages/alert_detail_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("DEBUG: Entered _firebaseMessagingBackgroundHandler");
  await Firebase.initializeApp();
  debugPrint("DEBUG: Firebase.initializeApp() completed in background handler");

  final data = message.data;
  debugPrint("DEBUG: Background handler received data=$data");

  // ✅ ไม่เด้งซ้ำ: เก็บ payload ไว้เฉย ๆ
  NotificationService.lastPayload = Map<String, dynamic>.from(data);
  NotificationService.shouldOpenAlert = true;
  debugPrint("DEBUG: Background handler stored payload only");
}

Future<void> main() async {
  debugPrint("DEBUG: main() started");
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("DEBUG: WidgetsFlutterBinding.ensureInitialized() done");

  await Firebase.initializeApp();
  debugPrint("DEBUG: Firebase.initializeApp() done in main()");

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  debugPrint("DEBUG: FirebaseMessaging.onBackgroundMessage registered");

  NotificationService.init(navigatorKey);
  debugPrint("DEBUG: NotificationService.init() executed");

  try {
    final RemoteMessage? initialMsg =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMsg != null) {
      final data = initialMsg.data;
      debugPrint("DEBUG: getInitialMessage() returned data=$data");
      NotificationService.lastPayload = Map<String, dynamic>.from(data);
      NotificationService.shouldOpenAlert = true;
      debugPrint(
          "DEBUG: shouldOpenAlert=true set by getInitialMessage, lastPayload updated");
    } else {
      debugPrint("DEBUG: getInitialMessage() returned null");
    }
  } catch (e) {
    debugPrint("DEBUG: getInitialMessage error: $e");
  }

  runApp(const MyApp());
  debugPrint("DEBUG: runApp(MyApp) executed");
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    debugPrint("DEBUG: MyApp.initState() called");
    _setupFCMForegroundHandlers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (NotificationService.shouldOpenAlert &&
          NotificationService.lastPayload != null) {
        debugPrint(
            "DEBUG: PostFrameCallback triggered → Navigating to AlertDetailPage");
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (_) => AlertDetailPage(
              alertData: NotificationService.lastPayload!,
            ),
          ),
        );
      } else {
        debugPrint("DEBUG: No payload or flag=false → App stays on initScreen");
      }
    });
  }

  void _setupFCMForegroundHandlers() {
    debugPrint("DEBUG: Setting up FCM foreground handlers");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("DEBUG: onMessage triggered with data=${message.data}");
      final data = message.data;
      final alertId = data['alert_id'];

      // ✅ กันซ้ำด้วย alert_id
      if (alertId != null &&
          alertId != NotificationService.lastPayload?['alert_id']) {
        final title = data['title'] ?? 'Rain Alert';
        final body = data['body'] ?? '';
        NotificationService.showLocalNotification(title, body, data);
        NotificationService.lastPayload = Map<String, dynamic>.from(data);
        debugPrint("DEBUG: Local notification shown and lastPayload updated");
      } else {
        debugPrint("DEBUG: Duplicate alert_id=$alertId skipped");
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          "DEBUG: onMessageOpenedApp triggered with data=${message.data}");
      final data = Map<String, dynamic>.from(message.data);
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (_) => AlertDetailPage(alertData: data),
        ),
      );
      debugPrint("DEBUG: Navigated to AlertDetailPage from onMessageOpenedApp");
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("DEBUG: MyApp.build() called");
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      routes: Routes.routes(),
      home: Routes.routes()[Routes.initScreen()]!(context),
      onGenerateRoute: (settings) {
        debugPrint("DEBUG: onGenerateRoute called with name=${settings.name}");
        if (settings.name == Routes.alertDetailRoute) {
          final args = (settings.arguments as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{};
          debugPrint("DEBUG: Navigating to AlertDetailPage with args=$args");
          return MaterialPageRoute(
            builder: (_) => AlertDetailPage(alertData: args),
          );
        }
        return null;
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('th', 'TH'),
        Locale('en', 'US'),
      ],
      theme: ThemeData(fontFamily: 'Kanit'),
    );
  }
}
