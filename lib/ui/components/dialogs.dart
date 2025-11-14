import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

import '../../services/permission_service.dart';

Future<void> showPermissionFixDialog(
    BuildContext context,
    bool permissionsGranted,
    bool batteryOptimizationDisabled,
    ) async {
  String buildMessage(bool permissionsGranted, bool batteryOptimizationDisabled) {
    String message = 'Some required permissions are missing or restricted:\n\n';
    if (!permissionsGranted) {
      message += '• Phone / Contacts / Notification permissions\n';
    }
    if (!batteryOptimizationDisabled) {
      message += '• Battery optimization is enabled\n';
    }
    message +=
    '\nTo continue using EchoCall, please enable the above in Settings.';
    return message;
  }

  bool allGranted = false;
  final permissionService = PermissionService();

  while (!allGranted) {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: Text(buildMessage(permissionsGranted, batteryOptimizationDisabled)),
          actions: [
            TextButton(
              onPressed: () {
                // Exit app
                if (Platform.isAndroid) {
                  SystemNavigator.pop();
                } else {
                  exit(0);
                }
              },
              child: const Text('Exit App', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                // Open required settings
                if (!permissionsGranted) {
                  await openAppSettings();
                }
                if (!batteryOptimizationDisabled && Platform.isAndroid) {
                  await permissionService.requestIgnoreBatteryOptimizations();
                }

                // Short delay for user to interact
                await Future.delayed(const Duration(seconds: 1));

                // Re-check using PermissionService
                permissionsGranted = await permissionService.ensureCorePermissions();
                batteryOptimizationDisabled = await permissionService.ensureBatteryOptimizationStatus();

                if (permissionsGranted && batteryOptimizationDisabled) {
                  Navigator.of(ctx).pop();
                  allGranted = true;
                } else {
                  // Optionally show feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Permissions not granted yet. Please enable them.')),
                  );
                }
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}