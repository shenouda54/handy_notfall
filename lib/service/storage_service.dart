import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _issuesKey = 'custom_issues';
  static const String _deviceTypesKey = 'custom_device_types';

  // الأعطال
  static Future<List<String>> loadIssues() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_issuesKey) ?? [];
  }

  static Future<void> saveIssue(String issue) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_issuesKey) ?? [];
    if (!current.contains(issue)) {
      current.add(issue);
      await prefs.setStringList(_issuesKey, current);
    }
  }

  static Future<void> deleteIssue(String issue) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_issuesKey) ?? [];
    current.remove(issue);
    await prefs.setStringList(_issuesKey, current);
  }

  // أنواع الأجهزة
  static Future<List<String>> loadDeviceTypes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_deviceTypesKey) ?? [];
  }

  static Future<void> saveDeviceType(String deviceType) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_deviceTypesKey) ?? [];
    if (!current.contains(deviceType)) {
      current.add(deviceType);
      await prefs.setStringList(_deviceTypesKey, current);
    }
  }

  static Future<void> deleteDeviceType(String deviceType) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_deviceTypesKey) ?? [];
    current.remove(deviceType);
    await prefs.setStringList(_deviceTypesKey, current);
  }
}
