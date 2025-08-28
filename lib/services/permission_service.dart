import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> ensureCorePermissions() async {
    if (!Platform.isAndroid) return false; // iOS not supported for call logs
    final statuses = await [Permission.phone].request();
    final granted = statuses.values.every((s) => s.isGranted);
    // Some OEMs gate call logs under contacts or never ask; prompt settings if denied
    if (!granted) await openAppSettings();
    return granted;
  }

  Future<bool> hasPhonePermission() async {
    if (!Platform.isAndroid) return false;
    return await Permission.phone.isGranted;
  }
}
