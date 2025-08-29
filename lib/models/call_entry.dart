import 'dart:convert';

enum CallDirection { incoming, outgoing, missed, rejected, voicemail, unknown }

class CallEntryModel {
  final String id; // device call id or composed key
  final String number;
  final String? name;
  final CallDirection direction;
  final DateTime timestamp;
  final int durationSeconds;
  final String? simPhoneNumber;
  final String? simLabel; // e.g., SIM1 / Carrier name
  final String? phoneAccountId; // Android account id
  final int? subscriptionId; // Android subscription id
  final bool synced;

  const CallEntryModel({
    required this.id,
    required this.number,
    required this.direction,
    required this.timestamp,
    required this.durationSeconds,
    this.name,
    this.simLabel,
    this.phoneAccountId,
    this.subscriptionId,
    this.simPhoneNumber,
    this.synced = false,
  });

  CallEntryModel copyWith({
    String? id,
    String? number,
    String? name,
    CallDirection? direction,
    DateTime? timestamp,
    String? simPhoneNumber,
    int? durationSeconds,
    String? simLabel,
    String? phoneAccountId,
    int? subscriptionId,
    bool? synced,
  }) => CallEntryModel(
    id: id ?? this.id,
    number: number ?? this.number,
    name: name ?? this.name,
    direction: direction ?? this.direction,
    timestamp: timestamp ?? this.timestamp,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    simLabel: simLabel ?? this.simLabel,
    simPhoneNumber: simPhoneNumber ?? this.simPhoneNumber,
    phoneAccountId: phoneAccountId ?? this.phoneAccountId,
    subscriptionId: subscriptionId ?? this.subscriptionId,
    synced: synced ?? this.synced,
  );

  Map<String, dynamic> toFirestoreMap({String? deviceId}) => {
    'id': id,
    'number': number,
    'name': name,
    'direction': direction.name,
    'timestamp': timestamp.toUtc().millisecondsSinceEpoch,
    'durationSeconds': durationSeconds,
    'simLabel': simLabel,
    'simPhoneNumber': simPhoneNumber,
    'phoneAccountId': phoneAccountId,
    'subscriptionId': subscriptionId,
    'deviceId': deviceId,
    'createdAt': DateTime.now().toUtc().millisecondsSinceEpoch,
  };

  static CallEntryModel fromMap(Map<String, dynamic> map) => CallEntryModel(
    id: map['id']?.toString() ?? '',
    number: map['number']?.toString() ?? '',
    name: map['name']?.toString(),
    direction: _directionFromString(map['direction']?.toString()),
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] is int ? map['timestamp'] : int.tryParse('${map['timestamp']}') ?? 0, isUtc: true).toLocal(),
    durationSeconds: map['durationSeconds'] is int ? map['durationSeconds'] : int.tryParse('${map['durationSeconds']}') ?? 0,
    simLabel: map['simLabel']?.toString(),
    simPhoneNumber: map['simPhoneNumber']?.toString(),
    phoneAccountId: map['phoneAccountId']?.toString(),
    subscriptionId: map['subscriptionId'] is int ? map['subscriptionId'] : int.tryParse('${map['subscriptionId']}'),
    synced: map['synced'] == true,
  );

  static CallDirection _directionFromString(String? v) {
    switch (v) {
      case 'incoming':
        return CallDirection.incoming;
      case 'outgoing':
        return CallDirection.outgoing;
      case 'missed':
        return CallDirection.missed;
      case 'rejected':
        return CallDirection.rejected;
      case 'voicemail':
        return CallDirection.voicemail;
      default:
        return CallDirection.unknown;
    }
  }

  String toJson() => jsonEncode(toFirestoreMap());
}
