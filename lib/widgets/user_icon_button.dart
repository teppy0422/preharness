// lib/widgets/user_icon_button.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_modal.dart';
import "package:preharness/utils/user_login_manager.dart";

class UserIconButton extends StatefulWidget {
  const UserIconButton({super.key});

  @override
  State<UserIconButton> createState() => _UserIconButtonState();
}

class _UserIconButtonState extends State<UserIconButton> {
  String? _iconPath;
  String? _username;
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _showModal() {
    showDialog(context: context, builder: (_) => const QrLoginModal()).then((
      result,
    ) {
      if (result == true) {
        _loadUserInfo(); // ← ログイン・ログアウト後に状態を更新！
      }
    });
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const QrLoginModal(),
      );

      if (result == true) {
        // ログイン成功時の処理（UI更新など）
      }
    }
  }

  Future<void> _loadUserInfo() async {
    final user = await UserLoginManager.getLoggedInUser();
    setState(() {
      _username = user?['username'];
      _iconPath = user?['iconPath'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showModal,
      child: ClipOval(
        child: _iconPath == null
            ? Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white),
                ),
              )
            : Container(
                width: 40,
                height: 40,
                color: Colors.red[500],
                child: _username != null ? Text(_username!) : null,
              ),
      ),
    );
  }
}
