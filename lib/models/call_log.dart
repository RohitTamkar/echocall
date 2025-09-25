class CallLog {
  final String id;
  final int createdAt;
  final String department;
  final String? deviceId;
  final String direction;
  final int durationSeconds;
  final String name;
  final String number;
  final String phoneAccountId;
  final String receiverMobileNo;
  final String receiverName;
  final String simLabel;
  final String? simPhoneNumber;
  final String? subscriptionId;
  final int timestamp;
  final String uploadedAt;

  CallLog({
    required this.id,
    required this.createdAt,
    required this.department,
    this.deviceId,
    required this.direction,
    required this.durationSeconds,
    required this.name,
    required this.number,
    required this.phoneAccountId,
    required this.receiverMobileNo,
    required this.receiverName,
    required this.simLabel,
    this.simPhoneNumber,
    this.subscriptionId,
    required this.timestamp,
    required this.uploadedAt,
  });

  factory CallLog.fromMap(Map<String, dynamic> map) => CallLog(
    id: map['id'] ?? '',
    createdAt: map['createdAt'] ?? 0,
    department: map['department'] ?? '',
    deviceId: map['deviceId'],
    direction: map['direction'] ?? '',
    durationSeconds: map['durationSeconds'] ?? 0,
    name: map['name'] ?? '',
    number: map['number'] ?? '',
    phoneAccountId: map['phoneAccountId'] ?? '',
    receiverMobileNo: map['receiverMobileNo'] ?? '',
    receiverName: map['receiverName'] ?? '',
    simLabel: map['simLabel'] ?? '',
    simPhoneNumber: map['simPhoneNumber'],
    subscriptionId: map['subscriptionId'],
    timestamp: map['timestamp'] ?? 0,
    uploadedAt: map['uploadedAt'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'createdAt': createdAt,
    'department': department,
    'deviceId': deviceId,
    'direction': direction,
    'durationSeconds': durationSeconds,
    'name': name,
    'number': number,
    'phoneAccountId': phoneAccountId,
    'receiverMobileNo': receiverMobileNo,
    'receiverName': receiverName,
    'simLabel': simLabel,
    'simPhoneNumber': simPhoneNumber,
    'subscriptionId': subscriptionId,
    'timestamp': timestamp,
    'uploadedAt': uploadedAt,
  };

  String get formattedDuration {
    final duration = Duration(seconds: durationSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}