import 'dart:async';
import 'dart:io';
import 'package:phone_state/phone_state.dart';
import 'package:echocall/services/call_log_service.dart';
import 'package:echocall/models/call_entry.dart';
import 'package:echocall/services/firebase_service.dart';
import 'package:sim_data/sim_data.dart';

class PhoneStateWatcher {
  final _controller = StreamController<CallEntryModel>.broadcast();
  StreamSubscription? _sub;
  final CallLogService _callLogService = CallLogService();
  final FirebaseService _firebaseService = FirebaseService();

  Stream<CallEntryModel> get onCallFinished => _controller.stream;

  Future<void> start() async {
    if (!Platform.isAndroid) return;
    _sub?.cancel();
    _sub = PhoneState.stream.listen((status) async {
      if (status == null) return;
      switch (status.status) {
        case PhoneStateStatus.CALL_ENDED:
        // case PhoneStateStatus.CALL_STARTED:
        // case PhoneStateStatus.CALL_INCOMING:
          final Set<String> _uploadedCalls = {};
          final number = status.number ?? '';
          if (number.isEmpty) return;

          final logs = await _callLogService.fetchRecent(limit: 1);
          if (logs.isNotEmpty) {
            final entry = logs.first;
            if (_uploadedCalls.contains(entry.id)) {
              print("Skipping duplicate upload for ${entry.id}");
              return;
            }

            final simNumber = await _getSimNumber(entry.simLabel);
            final updatedEntry = entry.copyWith(simPhoneNumber: simNumber);
            print("Phone state: ${status.status}, number: ${status.number}");
            _controller.add(updatedEntry);
            await _firebaseService.uploadCallLog(updatedEntry);
            _uploadedCalls.add(entry.id);
          }


          // final entry = await _callLogService.mostRecentForNumber(number);
          // if (entry != null) {
          //   // ✅ Fetch actual SIM number
          //   final simNumber = await _getSimNumber(entry.simLabel);
          //   final updatedEntry = entry.copyWith(simPhoneNumber: simNumber);
          //   print("Phone state: ${status.status}, number: ${status.number}");
          //   _controller.add(updatedEntry);
          //
          //   // ✅ Upload to Firestore with SIM phone number
          //   await _firebaseService.uploadCallLog(updatedEntry);
          // }
          break;
        default:
          break;
      }
    });
  }

  Future<String?> _getSimNumber(String? simLabel) async {
    try {
      final simData = await SimDataPlugin.getSimData();
      for (final card in simData.cards) {
        if (card.displayName == simLabel || card.carrierName == simLabel) {
          return card.serialNumber;
        }
      }
    } catch (e) {
      print("Error getting SIM number: $e");
    }
    return null;
  }

  Future<void> stop() async => _sub?.cancel();

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}






// import 'dart:async';
// import 'dart:io';
// import 'package:phone_state/phone_state.dart';
// import 'package:echocall/services/call_log_service.dart';
// import 'package:echocall/models/call_entry.dart';
//
// class PhoneStateWatcher {
//   final _controller = StreamController<CallEntryModel>.broadcast();
//   StreamSubscription? _sub;
//   final CallLogService _callLogService = CallLogService();
//
//   Stream<CallEntryModel> get onCallFinished => _controller.stream;
//
//   Future<void> start() async {
//     if (!Platform.isAndroid) return;
//     _sub?.cancel();
//     _sub = PhoneState.stream.listen((status) async {
//       if (status == null) return;
//       switch (status.status) {
//         case PhoneStateStatus.CALL_ENDED:
//           final number = status.number ?? '';
//           if (number.isEmpty) return;
//           final entry = await _callLogService.mostRecentForNumber(number);
//
//           if (entry != null) _controller.add(entry);
//           break;
//         default:
//           break;
//       }
//     });
//   }
//
//   Future<void> stop() async => _sub?.cancel();
//
//   void dispose() {
//     _sub?.cancel();
//     _controller.close();
//   }
// }
