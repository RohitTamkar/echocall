import 'dart:io';
import 'package:call_log/call_log.dart' as cl;
import 'package:echocall/models/call_entry.dart';

class CallLogService {
    Future<List<CallEntryModel>> getAllCallLogs() async {
    return await fetchRecent(days: 1); // Get all calls from past year
  }
  Future<List<CallEntryModel>> fetchRecent({int days = 1, int? limit}) async {
    if (!Platform.isAndroid) return [];
    final now = DateTime.now();
    final from = now.subtract(Duration(days: days)).millisecondsSinceEpoch;
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
