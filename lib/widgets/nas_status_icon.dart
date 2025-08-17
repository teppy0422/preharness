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
  int? _statusCode;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkNasConnection();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkNasConnection() async {
    int? statusCode;
    try {
      final prefs = await SharedPreferences.getInstance();
      final ip = prefs.getString('main_path')?.replaceAll(r'\\', '') ?? '';
      final uri = Uri.parse('http://$ip:3000/api/ping');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      statusCode = response.statusCode;
    } catch (_) {
      statusCode = null;
    }

    if (!mounted) return;

    setState(() {
      _isConnected = (statusCode == 200);
      _statusCode = statusCode;
    });

    // Schedule the next check.
    // Online: 120 seconds, Offline: 30 seconds.
    final duration = _isConnected
        ? const Duration(seconds: 120)
        : const Duration(seconds: 30);
    _timer = Timer(duration, _checkNasConnection);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: _isConnected
              ? Lottie.asset(
                  'assets/lottie/network_ok.json',
                  repeat: false,
                  fit: BoxFit.contain,
                  delegates: LottieDelegates(
                    values: [
                      ValueDelegate.color(
                        ['.primary', 'Color'],
                        value: Colors.blue,
                      ),
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
                      ValueDelegate.color(
                        ['.primary', 'Color'],
                        value: Colors.blue,
                      ),
                    ],
                  ),
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('アニメーションの読み込みに失敗しました');
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            _statusCode?.toString() ?? '---',
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
