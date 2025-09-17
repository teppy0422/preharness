import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preharness/services/settings_service.dart';

class DatabaseService {
  // settings_serviceのmain_pathを参照してbaseUrlを取得
  static Future<String> _getBaseUrl() async {
    final settingsService = SettingsService();
    final settings = await settingsService.loadSettings();
    final mainPath = settings['main_path'] ?? '';

    if (mainPath.isNotEmpty) {
      // パスを正規化してhttpプレフィックスを追加
      String normalizedPath = mainPath.replaceAll(r'\\', '').replaceAll('//', '');
      return 'http://$normalizedPath:3000';
    } else {
      // フォールバック用のデフォルトURL
      return 'http://192.168.1.100:3000';
    }
  }

  /// 作業実績をPostgreSQLに保存（SharedPreferences全項目を個別カラムで送信）
  static Future<bool> saveWorkResult({
    required int actualCount,
    required double averageSpeed,
  }) async {
    try {
      // settings_serviceからbaseUrlを動的に取得
      final baseUrl = await _getBaseUrl();

      // SharedPreferencesから全項目を取得
      final prefs = await SharedPreferences.getInstance();

      final workResult = {
        // 作業完了時の追加データ
        'actual_count': actualCount,
        'average_speed': averageSpeed,

        // SettingsService関連
        'machine_type': prefs.getString('machine_type'),
        'machine_serial': prefs.getString('machine_serial'),
        'work_name': prefs.getString('work_name'),

        // UserLoginManager関連
        // 'userId': prefs.getString('userId'),
        'username': prefs.getString('username'),
        // 'iconname': prefs.getString('iconname'),

        // efu_プレフィックス系（processingConditions）
        'efu_lot_num': prefs.getString('efu_lot_num'),
        'efu_p_number': prefs.getString('efu_p_number'),
        'efu_eng_change': prefs.getString('efu_eng_change'),
        'efu_cfg_no': prefs.getString('efu_cfg_no'),
        'efu_sub_assy': prefs.getString('efu_sub_assy'),
        'efu_wire_type': prefs.getString('efu_wire_type'),
        'efu_wire_size': prefs.getString('efu_wire_size'),
        'efu_wire_color': prefs.getString('efu_wire_color'),
        'efu_wire_len': prefs.getString('efu_wire_len'),
        'efu_cut_code': prefs.getString('efu_cut_code'),
        'efu_wire_cnt': prefs.getString('efu_wire_cnt'),
        'efu_delivery_date': prefs.getString('efu_delivery_date'),
        'efu_save_completed': prefs.getString('efu_save_completed'),

        // block関連
        'block_terminals_0': prefs.getString('block_terminals_0'),
        'block_terminals_1': prefs.getString('block_terminals_1'),
        'block_terminals_length': prefs.getString('block_terminals_length'),
        'block_save_completed': prefs.getString('block_save_completed'),
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/work_results'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(workResult),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ 作業実績保存成功: ${response.body}');
        return true;
      } else {
        print('❌ 作業実績保存失敗: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ 作業実績保存エラー: $e');
      return false;
    }
  }
}
