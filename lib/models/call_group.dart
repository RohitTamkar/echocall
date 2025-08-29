import 'package:echocall/models/call_entry.dart';

class CallGroup {
  final String number;
  final String? contactName;
  final List<CallEntryModel> calls;
  final DateTime lastCallTime;
  final int totalDuration;
  final String? simLabel;

  CallGroup({
    required this.number,
    required this.contactName,
    required this.calls,
    required this.lastCallTime,
    required this.totalDuration,
    required this.simLabel,
  });

  int get callCount => calls.length;
  int get incomingCount => calls.where((c) => c.direction == CallDirection.incoming).length;
  int get outgoingCount => calls.where((c) => c.direction == CallDirection.outgoing).length;
  int get missedCount => calls.where((c) => c.direction == CallDirection.missed).length;

  CallDirection get lastDirection => calls.first.direction;

  factory CallGroup.fromCalls(List<CallEntryModel> calls) {
    if (calls.isEmpty) throw ArgumentError('Cannot create group from empty calls list');

    // Sort by timestamp descending (newest first)
    calls.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final latest = calls.first;
    final totalDuration = calls.fold<int>(0, (sum, call) => sum + call.durationSeconds);

    return CallGroup(
      number: latest.number,
      contactName: latest.name,
      calls: calls,
      lastCallTime: latest.timestamp,
      totalDuration: totalDuration,
      simLabel: latest.simLabel,
    );
  }
}