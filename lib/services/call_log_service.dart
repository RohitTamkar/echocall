import 'dart:io';
import 'package:call_log/call_log.dart' as cl;
import 'package:echocall/models/call_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echocall/models/call_log.dart';

class CallLogService {
  static const String _collectionName = 'CALL_LOGS';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CallLog>> getCallLogsStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final logData = Map<String, dynamic>.from(data);
      logData['id'] = doc.id;
      return CallLog.fromMap(logData);
    })
        .toList());
  }

  Future<List<CallLog>> getCallLogsByDateRange(DateTime startDate, DateTime endDate) async {
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;

    final snapshot = await _firestore
        .collection(_collectionName)
        .where('createdAt', isGreaterThanOrEqualTo: startTimestamp)
        .where('createdAt', isLessThanOrEqualTo: endTimestamp)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final logData = Map<String, dynamic>.from(data);
      logData['id'] = doc.id;
      return CallLog.fromMap(logData);
    })
        .toList();
  }

  Future<List<CallLog>> searchCallLogsByName(String name) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final logData = Map<String, dynamic>.from(data);
      logData['id'] = doc.id;
      return CallLog.fromMap(logData);
    })
        .where((log) =>
    log.name.toLowerCase().contains(name.toLowerCase()) ||
        log.receiverName.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  Future<List<CallLog>> getFilteredCallLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? nameFilter,
    String? departmentFilter,
    String? directionFilter,
  }) async {
    Query query = _firestore.collection(_collectionName);

    if (startDate != null && endDate != null) {
      query = query
          .where('createdAt', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('createdAt', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch);
    }

    if (departmentFilter != null && departmentFilter.isNotEmpty) {
      query = query.where('department', isEqualTo: departmentFilter);
    }

    if (directionFilter != null && directionFilter.isNotEmpty) {
      query = query.where('direction', isEqualTo: directionFilter);
    }

    query = query.orderBy('createdAt', descending: true);

    final snapshot = await query.get();
    var results = snapshot.docs
        .map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final logData = Map<String, dynamic>.from(data);
      logData['id'] = doc.id;
      return CallLog.fromMap(logData);
    })
        .toList();

    if (nameFilter != null && nameFilter.isNotEmpty) {
      results = results
          .where((log) =>
      log.name.toLowerCase().contains(nameFilter.toLowerCase()) ||
          log.receiverName.toLowerCase().contains(nameFilter.toLowerCase()) ||
          log.number.contains(nameFilter) ||
          log.receiverMobileNo.contains(nameFilter))
          .toList();
    }

    return results;
  }


  Future<List<CallEntryModel>> getAllCallLogs() async {
    return await fetchRecent(days: 1); // Get all calls from past year
  }
  Future<List<CallEntryModel>> fetchRecent({int days = 1, int? limit}) async {
    if (!Platform.isAndroid) return [];
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day, 0, 1);
    int from = todayStart.millisecondsSinceEpoch;
    final Iterable<cl.CallLogEntry> raw = await cl.CallLog.query(dateFrom: from);
    final items = raw.map(_mapEntry).where((e) => e.number.isNotEmpty).toList();
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (limit != null && items.length > limit) return items.take(limit).toList();
    return items;
  }

  Future<CallEntryModel?> mostRecentForNumber(String number, {Duration window = const Duration(minutes: 5)}) async {
    final items = await fetchRecent(days: 1);
    final n = number.replaceAll(' ', '');
    final now = DateTime.now();
    for (final e in items) {
      if (e.number.replaceAll(' ', '') == n && now.difference(e.timestamp).abs() <= window) {
        return e;
      }
    }
    return null;
  }

  CallEntryModel _mapEntry(cl.CallLogEntry e) {
    final direction = _mapType(e.callType);
    final ts = e.timestamp ?? 0;
    final id = '${e.number ?? 'unknown'}_${ts}_${direction.name}';
    return CallEntryModel(
      id: id,
      number: e.number ?? '',
      name: e.name,
      direction: direction,
      timestamp: DateTime.fromMillisecondsSinceEpoch(ts),
      durationSeconds: e.duration ?? 0,
      simLabel: e.simDisplayName,
      phoneAccountId: e.phoneAccountId,
      subscriptionId: null,
      simPhoneNumber: null,
    );
  }

  CallDirection _mapType(cl.CallType? t) {
    switch (t) {
      case cl.CallType.incoming:
        return CallDirection.incoming;
      case cl.CallType.outgoing:
        return CallDirection.outgoing;
      case cl.CallType.missed:
        return CallDirection.missed;
      case cl.CallType.rejected:
        return CallDirection.rejected;
    // Some platforms may not expose voicemail
    // case cl.CallType.voicemail:
    //   return CallDirection.voicemail;
      default:
        return CallDirection.unknown;
    }
  }



}
