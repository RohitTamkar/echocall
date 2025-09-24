import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore extends ChangeNotifier {
  Set<String> _enabledSims = <String>{};
  bool _groupByNumber = true;
  bool _loaded = false;

  Set<String> get enabledSims => _enabledSims;
  bool get groupByNumber => _groupByNumber;
  bool get loaded => _loaded;

  Future<void> loadSettings() async {
      final prefs = await SharedPreferences.getInstance();
      _enabledSims = (prefs.getStringList('enabled_sims') ?? []).toSet();
    _groupByNumber = prefs.getBool('group_by_number') ?? true;
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggleSim(String simLabel) async {
    if (_enabledSims.contains(simLabel)) {
      _enabledSims.remove(simLabel);
    } else {
      _enabledSims.add(simLabel);
    }
    await _saveSettings();
    notifyListeners();
  }

  Future<void> enableAllSims(List<String> allSims) async {
    _enabledSims = allSims.toSet();
    await _saveSettings();
    notifyListeners();
  }

  Future<void> disableAllSims() async {
    _enabledSims.clear();
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setGroupByNumber(bool value) async {
    _groupByNumber = value;
    await _saveSettings();
    notifyListeners();
  }

  bool isSimEnabled(String? simLabel) {
    if (_enabledSims.isEmpty) return true; // Show all if none selected
    return _enabledSims.contains(simLabel ?? 'Unknown');
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('enabled_sims', _enabledSims.toList());
    await prefs.setBool('group_by_number', _groupByNumber);
  }
}