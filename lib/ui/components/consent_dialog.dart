import 'package:flutter/material.dart';
import 'dart:io';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:android_intent_plus/android_intent.dart';
// import 'package:android_intent_plus/flag.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:echocall/main.dart'; // for initializeService()
import 'package:echocall/services/permission_service.dart';
import 'dialogs.dart';
import 'package:provider/provider.dart';
import 'package:echocall/providers/call_log_store.dart';


/// Main entry point for checking terms consent and starting background tasks.
Future<void> ensureUserConsent(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final accepted = prefs.getBool('termsAccepted') ?? false;

  if (accepted) {
    final permissionService = PermissionService();

    // ✅ Re-check all critical permissions
    bool granted = await permissionService.ensureCorePermissions();

    // ✅ Re-check battery optimizations
    bool batteryOk = await permissionService.ensureBatteryOptimizationStatus();

    if (granted && batteryOk) {
      // ✅ Initialize the call log store lazily now
      final callLogStore = Provider.of<CallLogStore>(context, listen: false);
      await callLogStore.init();
      await initializeService();
      return;
    } else {
      // 🔒 Show persistent dialog forcing user to fix permissions
      await showPermissionFixDialog(context, granted, batteryOk);
      return;
    }
  }

  final result = await showTermsAndConditionsDialog(context);

  if (result == true) {
    await prefs.setBool('termsAccepted', true);

    // ✅ Ask for core permissions first
    bool granted = await PermissionService().ensureCorePermissions();

    if (granted) {
      // ✅ Ask to disable battery optimizations
      await PermissionService().requestIgnoreBatteryOptimizations();

      // ✅ Start background service after everything is ready
      await initializeService();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All permissions are required to continue.')),
      );
      exitApp();
    }
  } else {
    exitApp();
  }
}

/// Shows the consent dialog for Terms & Conditions.
Future<bool?> showTermsAndConditionsDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        title: const Text("Terms & Conditions"),
        content: const SingleChildScrollView(
          child: Text(
            "By continuing, you consent to allow EchoCall to track and log "
                "your business-related calls for analytics and performance purposes. "
                "You may disable call tracking at any time by uninstalling or force-closing "
                "the app, or by contacting the EchoCall team to remove your data.\n\n"
                "To ensure accurate tracking, EchoCall will request to ignore battery optimizations "
                "and run as a background service.",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false), // Decline
            child: const Text("Decline"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true), // Accept
            child: const Text("Accept"),
          ),
        ],
      );
    },
  );
}

  // // Optional: also show list so user can manually verify
  // const settingsIntent = AndroidIntent(
  //   action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
  //   flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
  // );
  // await settingsIntent.launch();

void exitApp() {
  if (Platform.isAndroid) {
    // Gracefully close the app
    Future.delayed(const Duration(milliseconds: 100), () {
      SystemNavigator.pop(); // Better than exit(0)
    });
  } else {
    exit(0);
  }
}
