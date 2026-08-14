import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/firebase_options.dart';
import 'package:gym/scr/binding/initial_binding.dart';
import 'package:gym/scr/core/constants/app_theme.dart';
import 'package:gym/scr/core/services/local_notification_service.dart';
import 'package:gym/scr/core/utils/navigation/app_routes.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService.showRemoteMessage(message, dataOnly: true);
  debugPrint('Background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (error) {
    debugPrint('Firebase is unavailable; notifications are disabled: $error');
  }

  try {
    await LocalNotificationService.initialize();
  } catch (error) {
    // FCM notification payloads can still be displayed by Android while the
    // app is backgrounded, even if local foreground notification setup fails.
    debugPrint('Unable to initialize local notifications: $error');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GYM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }
}
