// lib/widgets/user_icon_button.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_modal.dart';
import "package:preharness/utils/user_login_manager.dart";
import "package:preharness/widgets/icon_picker_modal.dart";
import "package:preharness/constants/app_colors.dart";

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
              decoration: BoxDecoration(
                // 形を円に指定
                shape: BoxShape.circle,
                // 背景色（元のContainerのcolorプロパティから移動）
                color: AppColors.getCardColor(context),
                // 枠線の設定
                border: Border.all(
                  color: AppColors.getLineColor(context), // ここで枠線の色を指定
                  width: 0.5, // ここで枠線の太さを指定
                ),
              ),
              child: iconData == null
                  ? const Icon(Icons.person, color: Colors.red, size: 28)
                  : Icon(
                      iconData,
                      size: 28,
                      color: AppColors.getLineColor(context),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Text(
              _username == null ? "未ログイン" : _username!,
              style: TextStyle(
                fontSize: _username == null ? 7 : 8,
                color: AppColors.getLineColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
