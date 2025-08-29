import 'package:flutter/material.dart';
import 'package:echocall/models/call_entry.dart';
import 'package:echocall/services/call_log_service.dart';
import 'package:echocall/services/firebase_service.dart';

class CallLogStore extends ChangeNotifier {
  final CallLogService _callLogService = CallLogService();
  final FirebaseService _firebaseService = FirebaseService();

  List<CallEntryModel> _all = [];
  bool _loading = false;

  List<CallEntryModel> get all => List.unmodifiable(_all);
  bool get loading => _loading;

  CallLogStore() {
    _initialize();
  }

  Future<void> _initialize() async {
    await refresh();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();

    try {
      _all = await _callLogService.getAllCallLogs();
      _all.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort newest first
    } catch (e) {
      debugPrint('Error refreshing call logs: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<int> uploadAllUnsynced() async {
    try {
      final unsynced = _all.where((call) => !call.synced).toList();
      int uploadedCount = 0;

      for (final call in unsynced) {
        final success = await _firebaseService.uploadCallLog(call);
        if (success) {
          // Mark as synced
          final index = _all.indexWhere((c) => c.id == call.id);
          if (index != -1) {
            _all[index] = call.copyWith(synced: true);
          }
          uploadedCount++;
        }
      }

      if (uploadedCount > 0) {
        notifyListeners();
      }

      return uploadedCount;
    } catch (e) {
      debugPrint('Error uploading call logs: $e');
      return 0;
    }
  }

  void addCallEntry(CallEntryModel entry) {
    _all.insert(0, entry); // Add to beginning
    notifyListeners();
  }

  void updateCallEntry(CallEntryModel entry) {
    final index = _all.indexWhere((c) => c.id == entry.id);
    if (index != -1) {
      _all[index] = entry;
      notifyListeners();
    }
  }
}