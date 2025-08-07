import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class NasStatusIcon extends StatefulWidget {
  const NasStatusIcon({super.key});

  @override
  State<NasStatusIcon> createState() => _NasStatusIconState();
}

class _NasStatusIconState extends State<NasStatusIcon> {
  bool _isConnected = false;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _checkNasConnection();
  }

  Future<void> _checkNasConnection() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('main_path')?.replaceAll(r'\\', '') ?? '';
    final uri = Uri.parse('http://$ip:3000/api/ping');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      final success = response.statusCode == 200;

      if (!mounted) return;
      setState(() {
        _isConnected = success;
      });

      // 切断→接続成功でリトライを止める
      if (success) {
        _retryTimer?.cancel();
        _retryTimer = null;
      } else {
        _startRetry();
      }
    } catch (_) {
      setState(() => _isConnected = false);
      _startRetry();
    }
  }

  void _startRetry() {
    if (_retryTimer != null) return; // すでにリトライ中なら何もしない

    _retryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkNasConnection();
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: _isConnected
          ? Lottie.asset(
              'assets/lottie/network_ok.json',
              repeat: false,
              fit: BoxFit.contain,
              delegates: LottieDelegates(
                values: [
                  // JSON内のカラー名やパスは実際のJSONの構造によりますが、例として
                  ValueDelegate.color([
                    '.primary',
                    'Color',
                  ], value: Colors.blue),
                ],
              ),
              errorBuilder: (context, error, stackTrace) {
                return const Text('アニメーションの読み込みに失敗しました');
              },
            )
          : Lottie.asset(
              'assets/lottie/network_error.json',
              repeat: true,
              fit: BoxFit.contain,
              delegates: LottieDelegates(
                values: [
                  // JSON内のカラー名やパスは実際のJSONの構造によりますが、例として
                  ValueDelegate.color([
                    '.primary',
                    'Color',
                  ], value: Colors.blue),
                ],
              ),
              errorBuilder: (context, error, stackTrace) {
                return const Text('アニメーションの読み込みに失敗しました');
              },
            ),
    );
  }
}
