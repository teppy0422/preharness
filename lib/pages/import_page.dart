// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:preharness/widgets/responsive_scaffold.dart';
import 'package:preharness/routes/app_routes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import "package:preharness/widgets/user_list_modal.dart";
import 'dart:async';

double? freeSpaceGB;

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  String? mainPath;
  String? path01;
  double? freeSpaceGB;
  double? totalSpaceGB;
  bool _isFetchingSpace = false;
  bool _isImporting = false;
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadPaths();
    await _fetchFreeSpace();
  }

  Future<void> _loadPaths() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      mainPath = prefs.getString('main_path') ?? '未設定';
      path01 = prefs.getString('path_01') ?? '未設定';
    });
  }

  Future<void> _fetchFreeSpace() async {
    setState(() {
      _isFetchingSpace = true;
    });

    if (mainPath == null || mainPath == '未設定') {
      setState(() {
        freeSpaceGB = null;
        totalSpaceGB = null;
        _isFetchingSpace = false;
      });
      return;
    }

    final regex = RegExp(r'\\\\([\d\.]+)');
    final match = regex.firstMatch(mainPath!);

    if (match == null) {
      setState(() {
        freeSpaceGB = null;
        totalSpaceGB = null;
        _isFetchingSpace = false;
      });
      return;
    }

    final ip = match.group(1);

    try {
      final response = await http.get(
        Uri.parse('http://$ip:3000/api/free-space'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          freeSpaceGB = _parseToDouble(data['freeGB']);
          totalSpaceGB = _parseToDouble(data['totalGB']);
        });
      } else {
        setState(() {
          freeSpaceGB = null;
          totalSpaceGB = null;
        });
      }
    } catch (e) {
      setState(() {
        freeSpaceGB = null;
        totalSpaceGB = null;
      });
    } finally {
      setState(() {
        _isFetchingSpace = false;
      });
    }
  }

  String _messageFromCode(int code) {
    switch (code) {
      case 0:
        return 'インポート成功しました';
      case 1:
        return '保存パスが設定されていません';
      case 2:
        return 'サーバーエラーが発生しました';
      case 3:
        return '通信エラーが発生しました';
      case 4:
        return 'インポートするファイルがありませんでした';
      default:
        return '不明なエラーが発生しました';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'import',
      currentPage: AppRoutes.import,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Main Path: ${mainPath ?? '読み込み中...'}'),
            Text(
              'NAS 容量: ${_isFetchingSpace ? '取得中...' : _formatSpace(freeSpaceGB, totalSpaceGB)}',
            ),
            if (freeSpaceGB != null && totalSpaceGB != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final ratio = freeSpaceGB! / totalSpaceGB!;
                            return Container(
                              height: 20,
                              width: constraints.maxWidth * ratio,
                              decoration: BoxDecoration(
                                color: ratio > 0.2 ? Colors.blue : Colors.red,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(freeSpaceGB! / totalSpaceGB! * 100).toStringAsFixed(1)}% 空き',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text('Path01: ${path01 ?? '読み込み中...'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isImporting
                  ? null
                  : () async {
                      setState(() {
                        _isImporting = true;
                        _elapsedSeconds = 0;
                      });
                      _timer = Timer.periodic(const Duration(seconds: 1), (
                        timer,
                      ) {
                        setState(() {
                          _elapsedSeconds++;
                        });
                      });
                      try {
                        final code = await ApiService.sendPath01ToServer();
                        final message = _messageFromCode(code);

                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                        }
                      } finally {
                        _timer?.cancel();
                        setState(() {
                          _isImporting = false;
                          _elapsedSeconds = 0;
                        });
                      }
                    },
              child: _isImporting
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        Text(
                          '$_elapsedSeconds s',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    )
                  : const Text('ファイルインポート実行'),
            ),
            Text("CH→ch_list"),
            Text("Rlg29*→m_processing_confitions"),
            Text("kanban*→m_processing_confitions"),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => const UserListModal(),
                );
              },
              child: const Text('ユーザー一覧'),
            ),
          ],
        ),
      ),
    );
  }
}

double? _parseToDouble(dynamic value) {
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value);
  return null;
}

String _formatSpace(double? free, double? total) {
  if (free == null || total == null) return '取得不可';
  return '${free.toStringAsFixed(2)} GB / ${total.toStringAsFixed(2)} GB';
}
