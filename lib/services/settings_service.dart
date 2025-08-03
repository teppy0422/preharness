// lib/services/settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyMainPath = 'main_path';
  static const _keyPath01 = 'path_01';
  static const _keyMachineType = 'machine_type';
  static const _keyMachineSerial = 'machine_serial';
  static const _keyWorkName = 'work_name';

  Future<void> saveSettings({
    required String mainPath,
    required String path01,
    required String machineType,
    required String machineSerial,
    required String workName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMainPath, mainPath);
    await prefs.setString(_keyPath01, path01);
    await prefs.setString(_keyMachineType, machineType);
    await prefs.setString(_keyMachineSerial, machineSerial);
    await prefs.setString(_keyWorkName, workName);
  }

  Future<Map<String, String>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'main_path': prefs.getString(_keyMainPath) ?? '',
      'path_01': prefs.getString(_keyPath01) ?? '',
      'machine_type': prefs.getString(_keyMachineType) ?? '',
      'machine_serial': prefs.getString(_keyMachineSerial) ?? '',
      'work_name': prefs.getString(_keyWorkName) ?? '',
    };
  }
}
