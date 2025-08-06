import 'package:flutter/material.dart';
import 'package:preharness/utils/user_login_manager.dart';
import "package:preharness/widgets/icon_picker_modal.dart";

class QrLoginModal extends StatefulWidget {
  const QrLoginModal({super.key});

  @override
  State<QrLoginModal> createState() => _QrLoginModalState();
}

class _QrLoginModalState extends State<QrLoginModal> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _loading = false;
  String? _error;
  Map<String, String>? _user;

  @override
  void initState() {
    super.initState();
    _loadLoggedInUser();
  }

  Future<void> _loadLoggedInUser() async {
    final user = await UserLoginManager.getLoggedInUser();
    setState(() {
      _user = user;
    });
  }

  Future<void> _handleLogin(String id) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await UserLoginManager.login(id);
    if (!mounted) return;
    if (error == null) {
      await _loadLoggedInUser();
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _error = 'ログインに失敗しました'; // 日本語メッセージ
        _loading = false;
      });
      // 入力内容を選択状態にする
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
      _focusNode.requestFocus();
    }
  }

  Future<void> _handleLogout() async {
    await UserLoginManager.logout();
    if (!mounted) return;
    setState(() {
      _user = null;
    });
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ユーザー認証'),
      content: _user != null ? _buildUserInfo() : _buildLoginForm(),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('閉じる'),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(hintText: 'ユーザーIDを入力'),
        ),
        ElevatedButton.icon(
          onPressed: _loading
              ? null
              : () => _handleLogin(_controller.text.trim()),
          icon: const Icon(Icons.login),
          label: const Text('ログイン'),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: CircularProgressIndicator(),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  Widget _buildUserInfo() {
    final iconData =
        IconPickerModal.iconMap[_user!['iconname']] ?? Icons.person;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData),
        const SizedBox(height: 8),
        Text(
          _user!['username']!,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout),
          label: const Text('ログアウト'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    );
  }
}
