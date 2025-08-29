import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:echocall/theme.dart';
import 'package:echocall/providers/call_log_store.dart';
import 'package:echocall/providers/filter_store.dart';
import 'package:echocall/providers/sync_store.dart';
import 'package:echocall/providers/settings_store.dart';
import 'package:echocall/ui/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EchoCallApp());
}

class EchoCallApp extends StatelessWidget {
  const EchoCallApp({super.key});

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
      child: MaterialApp(
        title: 'EchoCall',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const AppShell(),
      ),
    );
  }
}
