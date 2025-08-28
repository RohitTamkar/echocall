import 'dart:async';
import 'dart:io';
import 'package:phone_state/phone_state.dart';
import 'package:echocall/services/call_log_service.dart';
import 'package:echocall/models/call_entry.dart';

class PhoneStateWatcher {
  final _controller = StreamController<CallEntryModel>.broadcast();
  StreamSubscription? _sub;
  final CallLogService _callLogService = CallLogService();

  Stream<CallEntryModel> get onCallFinished => _controller.stream;

  Future<void> start() async {
    if (!Platform.isAndroid) return;
    _sub?.cancel();
    _sub = PhoneState.stream.listen((status) async {
      if (status == null) return;
      switch (status.status) {
        case PhoneStateStatus.CALL_ENDED:
          final number = status.number ?? '';
          if (number.isEmpty) return;
          final entry = await _callLogService.mostRecentForNumber(number);
          if (entry != null) _controller.add(entry);
          break;
        default:
          break;
      }
    });
  }

  Future<void> stop() async => _sub?.cancel();

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
