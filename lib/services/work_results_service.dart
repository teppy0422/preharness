import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preharness/services/settings_service.dart';

class WorkResultsService {
  // settings_serviceのmain_pathを参照してbaseUrlを取得
  static Future<String> _getBaseUrl() async {
    final settingsService = SettingsService();
    final settings = await settingsService.loadSettings();
    final mainPath = settings['main_path'] ?? '';

    if (mainPath.isNotEmpty) {
      // パスを正規化してhttpプレフィックスを追加
      String normalizedPath = mainPath
          .replaceAll(r'\\', '')
          .replaceAll('//', '');
      return 'http://$normalizedPath:3000';
    } else {
      // フォールバック用のデフォルトURL
      return 'http://192.168.1.100:3000';
    }
  }

  /// バリデーション: 必須項目をチェック
  static Map<String, dynamic> _validateWorkResult({
    required int actualCount,
    required double averageSpeed,
    required Map<String, String?> workData,
  }) {
    List<String> errors = [];
    Map<String, dynamic> result = {'isValid': true, 'errors': errors};

    // 基本データのバリデーション
    if (actualCount < 0) {
      errors.add('実際のカウント数は0以上である必要があります');
    }

    if (averageSpeed < 0) {
      errors.add('平均速度は0以上である必要があります');
    }

    // 必須項目のチェック
    final requiredFields = {
      'username': 'ユーザー名',
      'machine_type': 'マシンタイプ',
      'work_name': '作業名',
    };

    for (final entry in requiredFields.entries) {
      final value = workData[entry.key];
      if (value == null || value.trim().isEmpty) {
        errors.add('${entry.value}が設定されていません');
      }
    }

    // EFU関連の必須項目チェック
    final efuRequiredFields = {
      'efu_p_number': '品番',
      'efu_cfg_no': 'CFG番号',
      'efu_wire_type': 'ワイヤータイプ',
      'efu_wire_size': 'ワイヤーサイズ',
    };

    for (final entry in efuRequiredFields.entries) {
      final value = workData[entry.key];
      if (value == null || value.trim().isEmpty) {
        errors.add('${entry.value}が設定されていません');
      }
    }

    // データ整合性チェック
    if (workData['efu_save_completed'] == null ||
        workData['efu_save_completed']!.isEmpty) {
      errors.add('EFUデータが保存されていません');
    }

    if (workData['block_save_completed'] == null ||
        workData['block_save_completed']!.isEmpty) {
      errors.add('ブロックデータが保存されていません');
    }

    result['isValid'] = errors.isEmpty;
    return result;
  }

  /// 作業実績をPostgreSQLに保存（SharedPreferences全項目を個別カラムで送信）
  static Future<Map<String, dynamic>> saveWorkResult({
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
        'machine_number': prefs.getString('machine_number'),
        'machine_serial': prefs.getString('machine_serial'),
        'work_name': prefs.getString('work_name'),

        // UserLoginManager関連
        'username': prefs.getString('username'),

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

      // バリデーション実行
      final validation = _validateWorkResult(
        actualCount: actualCount,
        averageSpeed: averageSpeed,
        workData: workResult.map(
          (key, value) => MapEntry(key, value?.toString()),
        ),
      );

      if (!validation['isValid']) {
        print('❌ バリデーションエラー: ${validation['errors']}');
        return {
          'success': false,
          'errors': validation['errors'],
          'message': 'データ検証に失敗しました',
        };
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/work_results'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(workResult),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ 作業実績保存成功: ${response.body}');
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': '作業実績を保存しました',
          'id': responseData['id'],
        };
      } else {
        print('❌ 作業実績保存失敗: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'errors': ['サーバーエラー: HTTP ${response.statusCode}'],
          'message': 'サーバーへの保存に失敗しました',
        };
      }
    } catch (e) {
      print('❌ 作業実績保存エラー: $e');
      return {
        'success': false,
        'errors': ['通信エラー: $e'],
        'message': '通信エラーが発生しました',
      };
    }
  }

  /// 保存前のデータ検証（UI用）
  static Future<Map<String, dynamic>> validateBeforeSave({
    required int actualCount,
    required double averageSpeed,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final workData = {
      'username': prefs.getString('username'),
      'machine_type': prefs.getString('machine_type'),
      'work_name': prefs.getString('work_name'),
      'efu_p_number': prefs.getString('efu_p_number'),
      'efu_cfg_no': prefs.getString('efu_cfg_no'),
      'efu_wire_type': prefs.getString('efu_wire_type'),
      'efu_wire_size': prefs.getString('efu_wire_size'),
      'efu_save_completed': prefs.getString('efu_save_completed'),
      'block_save_completed': prefs.getString('block_save_completed'),
    };

    return _validateWorkResult(
      actualCount: actualCount,
      averageSpeed: averageSpeed,
      workData: workData,
    );
  }
}
