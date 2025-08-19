import 'package:flutter/material.dart';
import 'package:preharness/services/api_service.dart';
import 'package:http/http.dart' as http; // Added missing import
import 'package:shared_preferences/shared_preferences.dart'; // Added
import 'dart:convert'; // Added
import 'dart:developer'; // Added for debugPrint

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

  Future<void> _runApi(Future<dynamic> apiCall) async {
    setState(() {
      _isLoading = true;
      _response = '実行中...';
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
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final nasIp = prefs.getString('main_path')?.replaceAll(r'\', '') ?? '';
      final url = Uri.parse('http://$nasIp:3000/api/color_list');

      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          _users = List<Map<String, dynamic>>.from(data);
          _response =
              'color_list:\n${const JsonEncoder.withIndent('  ').convert(_users)}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              ],
            ),
            const SizedBox(height: 20),
            const Text('レスポンス:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: SingleChildScrollView(
                  child: (_isLoading || _usersLoading)
                      ? const Center(child: CircularProgressIndicator())
                      : Text(_response),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
