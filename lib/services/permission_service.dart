import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();

  factory PermissionService() => _instance;

  PermissionService._internal();

  Future<bool> hasPhonePermission() async {
    if (!Platform.isAndroid) return false;
    return await Permission.phone.isGranted;
  }

  Future<bool> ensureCorePermissions() async {
    if (!Platform.isAndroid) return false;

    // Request multiple permissions
    final statuses = await [
      Permission.phone,
      Permission.contacts,
      Permission.notification, // For Android 13+ notifications
    ].request();

    // Check if all required permissions are granted
    bool allGranted = statuses.values.every((status) => status.isGranted);
    return allGranted;
  }

  /// ✅ Checks whether all battery optimizations are currently disabled.
  /// Does *not* show any UI or system dialog — purely a silent check.
  Future<bool> ensureBatteryOptimizationStatus() async {
    if (!Platform.isAndroid) return true;

    final bool isBatteryDisabled =
        (await DisableBatteryOptimization.isBatteryOptimizationDisabled) ?? false;

    final bool isManBatteryDisabled =
        (await DisableBatteryOptimization.isManufacturerBatteryOptimizationDisabled) ?? false;

    // Both need to be disabled for smooth operation
    return isBatteryDisabled && isManBatteryDisabled;
  }

  /// Requests to disable both Android and manufacturer-specific battery optimizations.
  Future<void> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return;

    // Check if standard battery optimization is disabled
    bool isBatteryDisabled = (await DisableBatteryOptimization.isBatteryOptimizationDisabled) ?? false;
    if (!isBatteryDisabled) {
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    }

    // Check manufacturer-specific optimizations
    bool isManBatteryDisabled = (await DisableBatteryOptimization.isManufacturerBatteryOptimizationDisabled) ?? false;
    if (!isManBatteryDisabled) {
      await DisableBatteryOptimization.showDisableManufacturerBatteryOptimizationSettings(
        "Your device has additional battery optimization",
        "Follow the steps to disable optimizations for smooth functioning of EchoCall",
      );
    }

    // // Optional: also show list so user can manually verify
    // const settingsIntent = AndroidIntent(
    //   action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
    //   flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    // );
    // await settingsIntent.launch();
  }
}