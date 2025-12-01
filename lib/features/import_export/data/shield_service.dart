import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ShieldService {
  /// IPアドレスを取得するヘルパー関数
  static Future<String?> _getIpAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final mainPath = prefs.getString('main_path');

    if (mainPath == null || mainPath.isEmpty) {
      log('main_path が設定されていません');
      return null;
    }

    // "\\192.168.11.8" のような形式から IP を抽出
    final regex = RegExp(r'\\\\([\d\.]+)');
    final match = regex.firstMatch(mainPath);

    if (match == null) {
      log('IPアドレスの抽出に失敗しました: $mainPath');
      return null;
    }

    return match.group(1);
  }

  /// p_number と eng_change のユニークな組み合わせを取得
  static Future<List<ShieldGroup>> getShieldGroups() async {
    final ip = await _getIpAddress();
    if (ip == null) return [];

    try {
      final url = Uri.parse('http://$ip:3000/api/shield-groups');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ShieldGroup.fromJson(json)).toList();
      } else {
        log('shield-groups取得失敗: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('shield-groups取得エラー: $e');
      return [];
    }
  }

  /// 特定の p_number + eng_change に紐づく、ybm を含むユニークなデータを取得
  static Future<List<ShieldQrData>> getShieldQrData(
    String pNumber,
    String engChange,
  ) async {
    final ip = await _getIpAddress();
    if (ip == null) return [];

    try {
      final url = Uri.parse(
        'http://$ip:3000/api/shield-qr-data?p_number=$pNumber&eng_change=$engChange',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ShieldQrData.fromJson(json)).toList();
      } else {
        log('shield-qr-data取得失敗: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('shield-qr-data取得エラー: $e');
      return [];
    }
  }
}

/// p_number + eng_change のグループ
class ShieldGroup {
  final String pNumber;
  final String engChange;

  ShieldGroup({
    required this.pNumber,
    required this.engChange,
  });

  factory ShieldGroup.fromJson(Map<String, dynamic> json) {
    return ShieldGroup(
      pNumber: json['p_number'] ?? '',
      engChange: json['eng_change'] ?? '',
    );
  }
}

/// QRコード生成用のデータ (p_number + eng_change + ybm)
class ShieldQrData {
  final String pNumber;
  final String engChange;
  final String ybm;

  ShieldQrData({
    required this.pNumber,
    required this.engChange,
    required this.ybm,
  });

  factory ShieldQrData.fromJson(Map<String, dynamic> json) {
    return ShieldQrData(
      pNumber: json['p_number'] ?? '',
      engChange: json['eng_change'] ?? '',
      ybm: json['ybm'] ?? '',
    );
  }

  /// QRコード用の文字列を生成（シールド図面用）
  String toQrString() {
    return 'S-$pNumber-$engChange-$ybm';
  }
}
