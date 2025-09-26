import 'package:echocall/services/phone_state_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:echocall/theme.dart';
import 'package:echocall/providers/call_log_store.dart';
import 'package:echocall/providers/filter_store.dart';
import 'package:echocall/providers/sync_store.dart';
import 'package:echocall/providers/settings_store.dart';
import 'package:echocall/ui/app_shell.dart';
import 'package:echocall/ui/pages/login_page.dart';
import 'package:echocall/auth_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeService();
  runApp(const EchoCallApp());
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'sensiblecall_service',
      initialNotificationTitle: 'SensibleCall',
      initialNotificationContent: 'Monitoring calls in background…',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  await Firebase.initializeApp();
  // 🔔 Update notification if needed
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "SensibleCall",
      content: "Still monitoring calls…",
    );
  }

  // Here you can start your PhoneStateWatcher
  final watcher = PhoneStateWatcher();
  watcher.start();
}

// Future<void> initializeService() async {
//   final service = FlutterBackgroundService();
//
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       isForegroundMode: true,
//       autoStart: true,
//       notificationChannelId: 'echocall_service',
//       initialNotificationTitle: 'EchoCall',
//       initialNotificationContent: 'Monitoring calls...',
//     ),
//     iosConfiguration: IosConfiguration(),
//   );
//
//   service.startService();
// }
//
// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   // Make sure Firebase + your service is available in background isolate
//   await Firebase.initializeApp();
//
//   final watcher = PhoneStateWatcher();
//   watcher.start();
//
//   service.on('stopService').listen((event) {
//     watcher.stop();
//     service.stopSelf();
//   });
// }


class EchoCallApp extends StatelessWidget {
  const EchoCallApp({super.key});

  Future<Widget> _getStartPage() async {
    final auth = AuthService();
    bool loggedIn = await auth.checkLogin();
    return loggedIn ? const AppShell() : const LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CallLogStore()),
        ChangeNotifierProvider(create: (_) => FilterStore()),
        ChangeNotifierProvider(create: (_) => SyncStore()),
        ChangeNotifierProvider(create: (ctx) {
          final store = SettingsStore();
          store.loadSettings();
          return store;
        }),
      ],
      child: FutureBuilder(
        future: _getStartPage(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
          }
          return MaterialApp(
            title: 'EchoCall',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            home: snapshot.data,
          );
        },
      ),
    );
  }
}
