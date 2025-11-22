import 'package:shared_preferences/shared_preferences.dart';

class IssueStorageService {
  static const String _issuesKey = 'custom_issues';

  /// تحميل الأعطال المحفوظة
  static Future<List<String>> loadIssues() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_issuesKey) ?? [];
  }

  /// حفظ عطل جديد (يضيفه للقائمة المحفوظة)
  static Future<void> saveIssue(String issue) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_issuesKey) ?? [];
    if (!current.contains(issue)) {
      current.add(issue);
      await prefs.setStringList(_issuesKey, current);
    }
  }

  /// حفظ قائمة أعطال كاملة (يستبدل كل الأعطال المحفوظة)
  static Future<void> saveIssues(List<String> issues) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_issuesKey, issues);
  }
}




