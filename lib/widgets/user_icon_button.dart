// lib/widgets/user_icon_button.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_modal.dart';
import "package:preharness/utils/user_login_manager.dart";
import "package:preharness/widgets/icon_picker_modal.dart";

class UserIconButton extends StatefulWidget {
  const UserIconButton({super.key});
  @override
  State<UserIconButton> createState() => _UserIconButtonState();
}

class _UserIconButtonState extends State<UserIconButton> {
  String? _iconname;
  String? _username;
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _showModal() {
    showDialog(context: context, builder: (_) => const QrLoginModal())
        .then((result) {
          if (result == true) {
            _loadUserInfo();
          } else {
            // キャンセルや失敗時の処理（必要なら）
          }
        })
        .catchError((e) {
          debugPrint('Login dialog error: $e');
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

    if (user == null) {
      setState(() {
        _username = null;
        _iconname = null;
      });
      return;
    }

    setState(() {
      _username = user['username'];
      _iconname = user['iconname'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _iconname != null
        ? IconPickerModal.iconMap[_iconname!] ?? Icons.person
        : null;

    return GestureDetector(
      onTap: _showModal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Container(
              width: 34,
              height: 34,
              color: Colors.grey[300],
              child: iconData == null
                  ? const Icon(Icons.person, color: Colors.white, size: 32)
                  : Icon(iconData, size: 32, color: Colors.blueAccent),
            ),
          ),
          if (_username != null)
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Text(
                _username!,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
