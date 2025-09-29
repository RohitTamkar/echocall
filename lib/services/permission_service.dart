import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();

  factory PermissionService() => _instance;

  PermissionService._internal();

  Future<bool> hasPhonePermission() async {
    if (!Platform.isAndroid) return false;
    return await Permission.phone.isGranted;
  }

  Future<bool> ensureCorePermissions() async {
    final statuses = await [
      Permission.phone,
      Permission.contacts,
      Permission.sms,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }
  // Future<bool> ensureCorePermissions() async {
  //   if (!Platform.isAndroid) return false;
  //
  //   final status = await Permission.phone.request();
  //   return status.isGranted;
  // }
}