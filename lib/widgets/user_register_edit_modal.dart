import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import "package:preharness/widgets/icon_picker_modal.dart";
import 'dart:convert';

class UserModal extends StatefulWidget {
  final bool isEdit; // 編集モードかどうか
  final Map<String, dynamic>? user; // 編集対象ユーザー情報（nullなら新規）

  const UserModal({super.key, this.isEdit = false, this.user});

  @override
  State<UserModal> createState() => _UserModalState();
}

class _UserModalState extends State<UserModal> {
  final _usernameController = TextEditingController();
  IconData? _selectedIcon;
  bool _loading = false;
  String? _usernameError;
  String? _iconError;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.user != null) {
      // 編集時は初期値セット
      _usernameController.text = widget.user!['username'] ?? '';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // アイコン選択関数
  Future<void> _pickImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nasIp = prefs.getString('main_path')?.replaceAll(r'\\', '') ?? '';
      final uri = Uri.parse('http://$nasIp:3000/api/users/icons');

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        final usedIcons = json.cast<String>();

        final selectedIcon = await showDialog<String>(
          context: context,
          builder: (_) => IconPickerModal(usedIcons: usedIcons),
        );

        if (selectedIcon != null) {
          setState(() => _selectedIcon = IconPickerModal.iconMap[selectedIcon]);
        }
      } else {
        throw Exception('アイコン一覧取得失敗');
      }
    } catch (e) {
      debugPrint('Error fetching used icons: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('アイコン一覧の取得に失敗しました')));
    }
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    bool hasError = false;

    setState(() {
      _usernameError = null;
      _iconError = null;
    });

    if (username.isEmpty) {
      setState(() => _usernameError = 'ユーザー名を入力してください');
      hasError = true;
    }

    if (_selectedIcon == null &&
        !(widget.isEdit && widget.user?['iconname'] != null)) {
      setState(() => _iconError = 'アイコンを選択してください');
      hasError = true;
    }

    if (hasError) return;

    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final nasIp = prefs.getString('main_path')?.replaceAll(r'\\', '') ?? '';
      if (nasIp.isEmpty) throw Exception('NASのIPが未設定です');

      // 登録と更新でエンドポイントとHTTPメソッドを切り替え
      final uri = widget.isEdit
          ? Uri.parse('http://$nasIp:3000/api/users/${widget.user!["id"]}')
          : Uri.parse('http://$nasIp:3000/api/register');

      final selectedName = _selectedIcon != null
          ? IconPickerModal.iconMap.entries
                .firstWhere((entry) => entry.value == _selectedIcon)
                .key
          : null;

      final response = await (widget.isEdit
          ? http.put(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'username': username,
                'iconname': selectedName,
              }),
            )
          : http.post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'username': username,
                'iconname': selectedName,
              }),
            ));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEdit ? '更新成功' : '登録成功')),
        );
        Navigator.of(context).pop(true); // 成功フラグを返してモーダル閉じる
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.isEdit ? '更新' : '登録'}失敗: ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('通信エラー')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEdit ? 'ユーザー更新' : 'ユーザー登録';
    final submitButtonText = widget.isEdit ? '更新する' : '登録する';

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'ユーザー名',
                errorText: _usernameError,
              ),
            ),
            const SizedBox(height: 8),
            _selectedIcon != null
                ? Icon(_selectedIcon, size: 100)
                : widget.isEdit &&
                      widget.user != null &&
                      widget.user!['iconname'] != null
                ? Icon(
                    IconPickerModal.iconMap[widget.user!['iconname']] ??
                        Icons.help_outline,
                    size: 100,
                  )
                : const Text('アイコン未選択'),
            if (_iconError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _iconError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ElevatedButton(onPressed: _pickImage, child: const Text('アイコンを選択')),
          ],
        ),
      ),
      actions: [
        _loading
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : TextButton(onPressed: _submit, child: Text(submitButtonText)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}
