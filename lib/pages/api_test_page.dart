import 'package:flutter/material.dart';
import 'package:preharness/services/api_service.dart';
import 'package:http/http.dart' as http; // Added missing import
import 'package:shared_preferences/shared_preferences.dart'; // Added
import 'dart:convert'; // Added
import 'dart:developer'; // Added for debugPrint
import 'package:hive/hive.dart'; // Added for Hive
import 'package:preharness/models/color_entry.dart'; // Added for ColorEntry
import 'package:collection/collection.dart'; // Added for firstWhereOrNull
import 'package:preharness/utils/color_utils.dart';
import 'package:preharness/utils/global.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  String _response = 'APIレスポンスがここに表示されます';
  bool _isLoading = false;
  List<Map<String, dynamic>> _users = []; // Added
  bool _usersLoading = false; // Added
  List<Widget> _colorWidgets = [];

  Future<void> _runApi(Future<dynamic> apiCall) async {
    setState(() {
      _isLoading = true;
      _response = '実行中...';
      _colorWidgets = [];
    });
    try {
      final result = await apiCall;
      setState(() {
        _response = result.toString();
      });
    } catch (e) {
      setState(() {
        _response = 'エラー: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // New method for fetching users
  Future<void> _fetchUsers() async {
    setState(() {
      _usersLoading = true;
      _response = '取得中...';
      _colorWidgets = [];
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final nasIp = prefs.getString('main_path')?.replaceAll(r'\', '') ?? '';
      final url = Uri.parse('http://$nasIp:3000/api/users');

      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          _users = List<Map<String, dynamic>>.from(data);
          _response =
              'ユーザーデータ:\n${const JsonEncoder.withIndent('  ').convert(_users)}';
        });
      } else {
        throw Exception("HTTP error: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error loading users: $e");
      setState(() {
        _response = '取得エラー: $e';
      });
    } finally {
      setState(() {
        _usersLoading = false;
      });
    }
  }

  Future<void> _fetchColorList() async {
    setState(() {
      _usersLoading = true;
      _response = '取得中...';
      _colorWidgets = [];
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final nasIp = prefs.getString('main_path')?.replaceAll(r'\', '') ?? '';
      final url = Uri.parse('http://$nasIp:3000/api/color_list');

      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        final List<ColorEntry> colorEntries = data.map((item) {
          final String colorNum = item['color_num']?.toString() ?? '';
          final int backColorInt =
              int.tryParse(item['back_color_int']?.toString() ?? '') ?? 0;
          final int foreColorInt =
              int.tryParse(item['fore_color_int']?.toString() ?? '') ?? 0;
          return ColorEntry(
            colorNum: colorNum,
            backColor: convertIntToColor(backColorInt),
            foreColor: convertIntToColor(foreColorInt),
          );
        }).toList();

        setState(() {
          _users = List<Map<String, dynamic>>.from(
            data,
          ); // Keep original data for display
          _response =
              'color_list:\n${const JsonEncoder.withIndent('  ').convert(_users)}';
        });

        // Save to Hive
        await _saveColorEntriesToHive(colorEntries);
      } else {
        throw Exception("HTTP error: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error loading color list: $e");
      setState(() {
        _response = '取得エラー: $e';
      });
    } finally {
      setState(() {
        _usersLoading = false;
      });
    }
  }

  Future<void> _saveColorEntriesToHive(List<ColorEntry> colorEntries) async {
    setState(() {
      _response = 'Hiveに保存中...';
      _colorWidgets = [];
    });
    try {
      final box = await Hive.openBox<ColorEntry>('colorEntryBox');
      await box.clear(); // Clear previous data
      for (var entry in colorEntries) {
        await box.add(entry); // Add each ColorEntry
      }
      setState(() {
        _response = 'Hiveに保存しました: ${colorEntries.length}件';
      });
    } catch (e) {
      setState(() {
        _response = 'Hive保存エラー: $e';
      });
    }
  }

  Future<void> _generateColorWidgets() async {
    setState(() {
      _isLoading = true;
      _response = '';
      _colorWidgets = [];
    });
    try {
      final box = await Hive.openBox<ColorEntry>('colorEntryBox');
      final List<ColorEntry> storedColorEntries = box.values.toList();
      final List<Widget> widgets = [];

      widgets.add(
        Text(
          "colorList stored in hive.\nAfter converting from the actual values to x0 format for easier viewing.\n",
        ),
      );

      for (final entry in storedColorEntries) {
        final String colorNum = entry.colorNum;
        final Color backColor = entry.backColor;
        final Color foreColor = entry.foreColor;

        widgets.add(
          Row(
            children: [
              Text('color_num: $colorNum'),
              const SizedBox(width: 4),
              WireColorBox(
                width: 14,
                height: 14,
                color: backColor,
                lineColor: foreColor,
              ),
            ],
          ),
        );
        widgets.add(
          Row(
            children: [
              Text(
                '  back_color: 0x${backColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
              ),
              const SizedBox(width: 4),
              WireColorBox(
                width: 14,
                height: 14,
                color: backColor,
                lineColor: backColor,
              ),
            ],
          ),
        );
        widgets.add(
          Row(
            children: [
              Text(
                '  fore_color: 0x${foreColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
              ),
              const SizedBox(width: 4),
              WireColorBox(
                width: 7,
                height: 14,
                color: foreColor,
                lineColor: foreColor,
              ),
            ],
          ),
        );
        widgets.add(const SizedBox(height: 16)); // Add space between entries
      }

      setState(() {
        _colorWidgets = widgets;
      });
    } catch (e) {
      setState(() {
        _response = 'Hive読み込みエラー: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'RobotoMono', // ← ここで指定
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('APIテスト')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading || _usersLoading
                        ? null
                        : () => _runApi(ApiService.sendPath01ToServerOld()),
                    child: const Text('sendPath01ToServerOld'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading || _usersLoading
                        ? null
                        : () => _runApi(ApiService.sendPath01ToServer()),
                    child: const Text('sendPath01ToServer'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading || _usersLoading
                        ? null
                        : () => _runApi(
                            ApiService.fetchProcessingConditions(
                              pNumber: '123', // テスト用の固定値
                              cfgNo: '456', // テスト用の固定値
                            ),
                          ),
                    child: const Text('fetchProcessingConditions (test)'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading || _usersLoading
                        ? null
                        : () => _runApi(
                            ApiService.searchChList(
                              thin: 'thin_val', // テスト用の固定値
                              fhin: 'fhin_val', // テスト用の固定値
                              hin1: 'hin1_val', // テスト用の固定値
                              size1: 'size1_val', // テスト用の固定値
                            ),
                          ),
                    child: const Text('searchChList (test)'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading || _usersLoading ? null : _fetchUsers,
                    child: const Text('Fetch Users'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading || _usersLoading
                        ? null
                        : _fetchColorList,
                    child: const Text('Fetch ColorList'),
                  ),

                  ElevatedButton(
                    onPressed: _isLoading || _usersLoading
                        ? null
                        : _generateColorWidgets,
                    child: const Text('Generate Color Widgets'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'response:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: (_isLoading)
                      ? const Center(child: CircularProgressIndicator())
                      : (_colorWidgets.isNotEmpty)
                      ? SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _colorWidgets,
                          ),
                        )
                      : SingleChildScrollView(child: Text(_response)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color convertIntToColor(int dbValue) {
  int r = dbValue & 0xFF;
  int g = (dbValue >> 8) & 0xFF;
  int b = (dbValue >> 16) & 0xFF;

  return Color.fromARGB(0xFF, r, g, b);
}
