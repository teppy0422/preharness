import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserLoginManager {
  static Future<String?> login(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nasIp = prefs.getString('main_path')?.replaceAll(r'\\', '') ?? '';

      if (nasIp.isEmpty) {
        return 'NASのIPアドレスが設定されていません';
      }

      final uri = Uri.parse('http://$nasIp:3000/api/users/$id');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        return 'HTTPエラー: ${response.statusCode}';
      }

      final user = jsonDecode(response.body);

      final userId = user['id']?.toString();
      final userName = user['username']?.toString(); // ←ここを修正
      final iconName = user['iconname']?.toString();

      if (userId == null || userId != id) {
        return 'ユーザーが見つかりません';
      }

      await prefs.setString('userId', userId);
      await prefs.setString('username', userName ?? '');
      await prefs.setString('iconname', iconName ?? '');

      return null; // 成功
    } catch (e) {
      debugPrint('Login error: $e');
      return '通信エラー: ${e.toString()}';
    }
  }

  static Future<Map<String, String>?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final username = prefs.getString('username');
    final iconname = prefs.getString('iconname');

    if (userId != null && username != null && iconname != null) {
      return {'userId': userId, 'username': username, 'iconname': iconname};
    }

    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('iconname');
  }
}
