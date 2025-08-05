import 'package:flutter/material.dart';
import 'package:preharness/constants/app_colors.dart';
import 'routes/app_routes.dart';
import 'package:preharness/widgets/user_icon_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:preharness/utils/user_login_manager.dart'; // ← あなたのloginコードをここに入れる想定

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() {
  runApp(
    ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MyApp(themeMode: currentMode);
      },
    ),
  );
}

class MyApp extends StatefulWidget {
  final ThemeMode themeMode;
  const MyApp({super.key, required this.themeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, dynamic>? loggedInUser;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final user = await UserLoginManager.getLoggedInUser();
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
      debugPrint("ログイン復元：${user['username']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PreHarnessPro',
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'NotoSansJP',
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontWeight: FontWeight.w900),
          bodyMedium: TextStyle(fontWeight: FontWeight.w600),
          labelLarge: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'NotoSansJP',
        scaffoldBackgroundColor: AppColors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
          labelLarge: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
      themeMode: widget.themeMode,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
