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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const EchoCallApp());
}

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
