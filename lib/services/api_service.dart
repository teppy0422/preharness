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

  static Future<Map<String, dynamic>?> fetchProcessingConditions({
    required String pNumber,
    required String cfgNo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final mainPath = prefs.getString('main_path');

    if (mainPath == null || mainPath.isEmpty) {
      log('main_path が設定されていません');
      throw Exception('サーバーパスが設定されていません。');
    }

    final ip = mainPath.replaceAll(r'\\', '').replaceAll('//', '');
    // サーバーの仕様に合わせてURLとクエリパラメータ名を修正
    final url = Uri.parse(
      'http://$ip:3000/api/m_processing_conditions/search?p_number=$pNumber&cfg_no=$cfgNo',
    );

    try {
      final response = await http.get(url);

      // レスポンスをデバッグ表示
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = jsonDecode(decodedBody);

        // レスポンスは配列なので、最初の要素を返す
        if (jsonList.isNotEmpty && jsonList.first is Map<String, dynamic>) {
          return jsonList.first;
        }
        return null; // データが見つからない、または形式が違う場合
      } else {
        log('サーバーエラー: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('通信エラー: $e');
      return null;
    }
  }
}
