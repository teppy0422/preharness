import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:preharness/core/constants/app_colors.dart';

class NasStatusIcon extends StatefulWidget {
  const NasStatusIcon({super.key});

  @override
  State<NasStatusIcon> createState() => _NasStatusIconState();
}

class _NasStatusIconState extends State<NasStatusIcon> {
  bool _isConnected = false;
  int? _statusCode;
  Timer? _timer;
  Uint8List? _okLottieBytes;
  Uint8List? _errorLottieBytes;

  @override
  void initState() {
    super.initState();
    _checkNasConnection();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-load the lottie files when the theme changes to update colors
    _loadLottieFiles();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadLottieFiles() {
    _loadAndColorOkLottie();
    _loadAndColorErrorLottie();
  }

  Future<void> _loadAndColorOkLottie() async {
    // Get theme-based colors from AppColors and convert them to Lottie format
    final Color targetColor = AppColors.getHighLightColor(context);

    final targetColorRgb = AppColors.colorToLottieRgb(targetColor);
    final targetColorRgba = AppColors.colorToLottieRgba(targetColor);

    const originalColorRgb = "[0.624, 0.945, 0.251]";
    const originalColorRgba = "[0.624, 0.945, 0.251, 1]";

    String jsonString = await rootBundle.loadString(
      'assets/lottie/network_ok.json',
    );

    jsonString = jsonString
        .replaceAll(originalColorRgb, targetColorRgb)
        .replaceAll(originalColorRgba, targetColorRgba);

    final bytes = Uint8List.fromList(utf8.encode(jsonString));

    if (mounted) {
      setState(() {
        _okLottieBytes = bytes;
      });
    }
  }

  Future<void> _loadAndColorErrorLottie() async {
    // --- Error Animation Colors ---
    final Color targetColor = AppColors.errorRed;
    // --- End Error Animation Colors ---

    final targetColorRgb = AppColors.colorToLottieRgb(targetColor);
    final targetColorRgba = AppColors.colorToLottieRgba(targetColor);

    // Assuming the error json uses the same original green color
    const originalColorRgb = "[0.624,0.945,0.251]";
    const originalColorRgba = "[0.624,0.945,0.251,1]";

    String jsonString = await rootBundle.loadString(
      'assets/lottie/network_error.json',
    );

    jsonString = jsonString
        .replaceAll(originalColorRgb, targetColorRgb)
        .replaceAll(originalColorRgba, targetColorRgba);

    final bytes = Uint8List.fromList(utf8.encode(jsonString));

    if (mounted) {
      setState(() {
        _errorLottieBytes = bytes;
      });
    }
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
    Widget lottieWidget;
    if (_isConnected) {
      lottieWidget = _okLottieBytes == null
          ? const Center(child: CircularProgressIndicator())
          : Lottie.memory(
              _okLottieBytes!,
              repeat: false,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Text('OKアニメーションの読み込みに失敗しました');
              },
            );
    } else {
      lottieWidget = _errorLottieBytes == null
          ? const Center(child: CircularProgressIndicator())
          : Lottie.memory(
              _errorLottieBytes!,
              repeat: true,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Text('Errorアニメーションの読み込みに失敗しました');
              },
            );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 24, height: 24, child: lottieWidget),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            _statusCode?.toString() ?? '---',
            style: TextStyle(
              fontSize: 9,
              color: AppColors.getLineColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
