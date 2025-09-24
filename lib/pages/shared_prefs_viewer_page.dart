import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preharness/widgets/responsive_scaffold.dart';
import 'package:preharness/routes/app_routes.dart';
import 'package:preharness/utils/shared_prefs_helper.dart';
import 'package:preharness/core/constants/app_colors.dart';

class SharedPrefsViewerPage extends StatefulWidget {
  const SharedPrefsViewerPage({super.key});

  @override
  State<SharedPrefsViewerPage> createState() => _SharedPrefsViewerPageState();
}

class _SharedPrefsViewerPageState extends State<SharedPrefsViewerPage> {
  Map<String, dynamic> _preferences = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList()..sort();

    final Map<String, dynamic> prefsMap = {};
    for (String key in keys) {
      final value = prefs.get(key);
      prefsMap[key] = value;
    }

    setState(() {
      _preferences = prefsMap;
      _isLoading = false;
    });
  }

  Future<void> _deleteKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    await _loadPreferences();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('削除しました: $key')));
    }
  }

  String _getValueTypeAndValue(dynamic value) {
    if (value is String) {
      return 'String: "$value"';
    } else if (value is int) {
      return 'int: $value';
    } else if (value is double) {
      return 'double: $value';
    } else if (value is bool) {
      return 'bool: $value';
    } else if (value is List<String>) {
      return 'List<String>: [${value.join(', ')}]';
    } else {
      return 'Unknown: $value';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'SharedPreferences一覧',
      currentPage: AppRoutes.sharedPrefsViewer,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _preferences.isEmpty
          ? const Center(
              child: Text(
                '保存されているPreferencesがありません',
                style: TextStyle(fontSize: 16),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '保存済み項目: ${_preferences.length}件',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          ElevatedButton(
                            onPressed: _loadPreferences,
                            child: const Text('再読み込み'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          // ここで背景色を設定
                          color: AppColors.getCardColor(context),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.getLineSubColor(context),
                            width: .5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cache: ${SharedPrefsHelper.notifier.cache}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.getLineColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _preferences.length,
                    itemBuilder: (context, index) {
                      final key = _preferences.keys.elementAt(index);
                      final value = _preferences[key];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          title: Text(
                            key,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(_getValueTypeAndValue(value)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(key),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showDeleteDialog(String key) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('削除確認'),
          content: Text('「$key」を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteKey(key);
              },
              child: const Text('削除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
