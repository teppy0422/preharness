// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:preharness/widgets/responsive_scaffold.dart';
import 'package:preharness/routes/app_routes.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  String? mainPath;
  String? path01;

  @override
  void initState() {
    super.initState();
    _loadPaths();
  }

  Future<void> _loadPaths() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      mainPath = prefs.getString('main_path') ?? '未設定';
      path01 = prefs.getString('path_01') ?? '未設定';
    });
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
            const SizedBox(height: 8),
            Text('Path01: ${path01 ?? '読み込み中...'}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final code = await ApiService.sendPath01ToServer();
                final message = _messageFromCode(code);

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                }
              },
              child: const Text('ファイルインポート実行'),
            ),
          ],
        ),
      ),
    );
  }
}
