import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncStore extends ChangeNotifier {
  bool _autoSync = true;
  bool _wifiOnly = false; // Toggle only; connectivity not enforced in this build
  DateTime? _lastSync;

  bool get autoSync => _autoSync;
  bool get wifiOnly => _wifiOnly;
  DateTime? get lastSync => _lastSync;

  SyncStore() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _autoSync = p.getBool('auto_sync') ?? true;
    _wifiOnly = p.getBool('wifi_only') ?? false;
    final t = p.getInt('last_sync');
    _lastSync = t != null ? DateTime.fromMillisecondsSinceEpoch(t) : null;
    notifyListeners();
  }

  Future<void> setAutoSync(bool v) async {
    _autoSync = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool('auto_sync', v);
  }

  Future<void> setWifiOnly(bool v) async {
    _wifiOnly = v;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool('wifi_only', v);
  }

  Future<void> markSyncedNow() async {
    _lastSync = DateTime.now();
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setInt('last_sync', _lastSync!.millisecondsSinceEpoch);
  }
}
