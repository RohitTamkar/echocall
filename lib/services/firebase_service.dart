import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:echocall/models/call_entry.dart';

class FirebaseService {
  bool _initialized = false;
  FirebaseFirestore? _db;

  bool get isAvailable => _initialized && _db != null;

  Future<void> tryInit() async {
    if (_initialized) return;
    try {
      // If options are not provided, Firebase initializes with default from google-services files.
      await Firebase.initializeApp();
      _db = FirebaseFirestore.instance;
      _initialized = true;
    } catch (e) {
      // Not configured; keep disabled but do not crash app.
      _initialized = false;
      _db = null;
      if (kDebugMode) {
        debugPrint('Firebase not initialized: $e');
      }
    }
  }

  Future<bool> uploadCallLog(CallEntryModel entry, {String collection = 'CALL_LOGS', String? deviceId}) async {
    await tryInit();
    if (!isAvailable || _db == null) return false;
    try {
      final doc = _db!.collection(collection).doc(entry.id);
      await doc.set(entry.toFirestoreMap(deviceId: deviceId), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Error uploading call log: $e');
      return false;
    }
  }

  Future<int> uploadBatch(List<CallEntryModel> entries, {String collection = 'CALL_LOGS', String? deviceId}) async {
    await tryInit();
    if (!isAvailable || _db == null) return 0;
    final batch = _db!.batch();
    final col = _db!.collection(collection);
    for (final e in entries) {
      final doc = col.doc(e.id);
      batch.set(doc, e.toFirestoreMap(deviceId: deviceId), SetOptions(merge: true));
    }
    await batch.commit();
    return entries.length;
  }
}
