// lib/services/api_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<int> sendPath01ToServerOld() async {
    final prefs = await SharedPreferences.getInstance();
    final path01 = prefs.getString('path_01') ?? ''; // 製造指示データ読み込みパス
    final mainPath = prefs.getString('main_path'); // サーバーパス

    if (path01.isEmpty) {
      log('path_01 が設定されていません');
      return 1; // 1: パス未設定
    }
    if (mainPath == null || mainPath.isEmpty) {
      log('main_path が設定されていません');
      return 1; // 1: パス未設定
    }

    //"\\192.168.11.8" のような形式なら、http://192.168.11.8 に変換
    final ip = mainPath.replaceAll('\\', '').replaceAll('//', '');
    final url = Uri.parse('http://$ip:3000/import');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'path_01': path01}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final code = json['code'] ?? 9;
        log('送信成功: $code');
        return code;
      } else {
        log('送信失敗: ${response.statusCode}');
        return 2; // 2: サーバー側エラー
      }
    } catch (e) {
      log('通信エラー: $e');
      return 3; // 3: 通信エラー
    }
  }

  static Future<int> sendPath01ToServer() async {
    final prefs = await SharedPreferences.getInstance();
    final path01 = prefs.getString('path_01') ?? ''; // 製造指示データ読み込みパス
    final mainPath = prefs.getString('main_path'); // サーバーパス

    if (path01.isEmpty) {
      log('path_01 が設定されていません');
      return 1; // 1: パス未設定
    }
    if (mainPath == null || mainPath.isEmpty) {
      log('main_path が設定されていません');
      return 1; // 1: パス未設定
    }

    //"\\192.168.11.8" のような形式なら、http://192.168.11.8 に変換
    final ip = mainPath.replaceAll('\\', '').replaceAll('//', '');
    final url = Uri.parse('http://$ip:3000/import/test');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'path_01': path01}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final code = json['code'] ?? 9;
        log('送信成功: $code');
        return code;
      } else {
        log('送信失敗: ${response.statusCode}');
        return 2; // 2: サーバー側エラー
      }
    } catch (e) {
      log('通信エラー: $e');
      return 3; // 3: 通信エラー
    }
  }
}
