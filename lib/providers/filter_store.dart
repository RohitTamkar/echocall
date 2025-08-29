import 'package:flutter/material.dart';
import 'package:echocall/models/call_entry.dart';
import 'package:echocall/models/call_group.dart';

class FilterStore extends ChangeNotifier {
  String? _simLabel; // null = all
  CallDirection? _direction; // null = all
  DateTimeRange? _range; // null = all
  String _query = '';

  String? get simLabel => _simLabel;
  CallDirection? get direction => _direction;
  DateTimeRange? get range => _range;
  String get query => _query;

  void setSim(String? v) { _simLabel = v; notifyListeners(); }
  void setDirection(CallDirection? v) { _direction = v; notifyListeners(); }
  void setRange(DateTimeRange? v) { _range = v; notifyListeners(); }
  void setQuery(String v) { _query = v; notifyListeners(); }

  void clearAll() {
    _simLabel = null;
    _direction = null;
    _range = null;
    _query = '';
    notifyListeners();
  }

  bool matches(CallEntryModel e) {
    if (_simLabel != null && (e.simLabel ?? 'Unknown') != _simLabel) return false;
    if (_direction != null && e.direction != _direction) return false;
    if (_range != null) {
      if (e.timestamp.isBefore(_range!.start) || e.timestamp.isAfter(_range!.end)) return false;
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      final txt = '${e.number} ${e.name ?? ''}'.toLowerCase();
      if (!txt.contains(q)) return false;
    }
    return true;
  }

  bool matchesGroup(CallGroup group) {
    if (_simLabel != null && (group.simLabel ?? 'Unknown') != _simLabel) return false;
    if (_direction != null && group.lastDirection != _direction) return false;
    if (_range != null) {
      if (group.lastCallTime.isBefore(_range!.start) || group.lastCallTime.isAfter(_range!.end)) return false;
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      final txt = '${group.number} ${group.contactName ?? ''}'.toLowerCase();
      if (!txt.contains(q)) return false;
    }
    return true;
  }
}
