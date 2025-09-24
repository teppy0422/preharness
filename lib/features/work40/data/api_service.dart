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

  static Future<List<Map<String, dynamic>>?> searchChList({
    required String thin,
    required String fhin,
    required String hin1,
    required String size1,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final mainPath = prefs.getString('main_path');

    if (mainPath == null || mainPath.isEmpty) {
      log('main_path が設定されていません');
      throw Exception('サーバーパスが設定されていません。');
    }

    final ip = mainPath.replaceAll(r'\\', '').replaceAll('//', '');
    final url = Uri.parse(
      'http://$ip:3000/api/ch_list/search?thin=$thin&fhin=$fhin&hin1=$hin1&size1=$size1',
    );

    try {
      final response = await http.get(url);

      log('Response status for ch_list: ${response.statusCode}');
      log('Response body for ch_list: ${response.body}');

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> jsonList = jsonDecode(decodedBody);

        if (jsonList.isNotEmpty && jsonList.first is Map<String, dynamic>) {
          return List<Map<String, dynamic>>.from(jsonList);
        }
        return []; // Return empty list if no data or wrong format
      } else {
        log('サーバーエラー (ch_list): ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('通信エラー (ch_list): $e');
      return null;
    }
  }
}
