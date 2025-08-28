import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:echocall/models/call_entry.dart';
import 'package:echocall/services/call_log_service.dart';
import 'package:echocall/services/phone_state_service.dart';
import 'package:echocall/services/firebase_service.dart';

class CallLogStore extends ChangeNotifier {
  final CallLogService _callLogService = CallLogService();
  final PhoneStateWatcher _watcher = PhoneStateWatcher();
  final FirebaseSyncService _firebase = FirebaseSyncService();

  List<CallEntryModel> _all = [];
  bool _loading = false;
  String? _deviceId;

  List<CallEntryModel> get all => _all;
  bool get loading => _loading;
  String? get deviceId => _deviceId;

  CallLogStore() {
    _init();
  }

  Future<void> _init() async {
    _deviceId = await _resolveDeviceId();
    await refresh();
    await _watcher.start();
    _watcher.onCallFinished.listen((entry) async {
      // Upsert local
      final idx = _all.indexWhere((e) => e.id == entry.id);
      if (idx >= 0) {
        _all[idx] = entry;
      } else {
        _all.insert(0, entry);
      }
      notifyListeners();
      // Try upload silently
      try {
        final uploaded = await _firebase.uploadBatch([entry], deviceId: _deviceId);
        if (uploaded > 0) {
          final i = _all.indexWhere((e) => e.id == entry.id);
          if (i >= 0) {
            _all[i] = _all[i].copyWith(synced: true);
            notifyListeners();
          }
        }
      } catch (_) {}
    });
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    try {
      final items = await _callLogService.fetchRecent(days: 14);
      _all = items;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<int> uploadAllUnsynced() async {
    final pending = _all.where((e) => !e.synced).toList();
    if (pending.isEmpty) return 0;
    final uploaded = await _firebase.uploadBatch(pending, deviceId: _deviceId);
    if (uploaded > 0) {
      _all = _all.map((e) => e.copyWith(synced: true)).toList(growable: false);
      notifyListeners();
    }
    return uploaded;
  }

  Future<String?> _resolveDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('device_id');
    if (id == null || id.isEmpty) {
      id = 'android-${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_id', id);
    }
    return id;
  }

  @override
  void dispose() {
    _watcher.dispose();
    super.dispose();
  }
}
