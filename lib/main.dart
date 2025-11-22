import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:hive_flutter/hive_flutter.dart';

import 'app_constant.dart';
import 'home_page.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('remindersBox');

  // Initialize Timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

  // Initialize Notifications
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidInit);

  await notificationsPlugin.initialize(initSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstant.APP_NAME,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppConstant.PRIMARY_COLOR,
        scaffoldBackgroundColor: AppConstant.BACKGROUND_COLOR,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstant.PRIMARY_COLOR,
          brightness: Brightness.light,
          primary: AppConstant.PRIMARY_COLOR,
          secondary: AppConstant.SECONDARY_COLOR,
          background: AppConstant.BACKGROUND_COLOR,
          surface: AppConstant.SURFACE_COLOR,
          error: AppConstant.ERROR_COLOR,
        ),
      ),
      home: const HomePage(),
    );
  }
}
