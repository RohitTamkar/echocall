import 'package:flutter/services.dart';

class SimService {
  static const platform = MethodChannel('sim_service');

  static Future<List<Map<String, dynamic>>> getSimCards() async {
    try {
      final sims = await platform.invokeMethod<List<dynamic>>('getSimCards');
      return sims?.cast<Map<dynamic, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList() ??
          [];
    } on PlatformException catch (e) {
      print("Failed to get SIM cards: '${e.message}'.");
      return [];
    }
  }
}
