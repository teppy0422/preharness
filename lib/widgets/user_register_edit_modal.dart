import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class UserModal extends StatefulWidget {
  final bool isEdit; // 編集モードかどうか
  final Map<String, dynamic>? user; // 編集対象ユーザー情報（nullなら新規）

  const UserModal({super.key, this.isEdit = false, this.user});

  @override
  State<UserModal> createState() => _UserModalState();
}

class _UserModalState extends State<UserModal> {
  final _usernameController = TextEditingController();
  File? _selectedImage;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.user != null) {
      // 編集時は初期値セット
      _usernameController.text = widget.user!['username'] ?? '';
      // 画像はファイルでなくURLだから画像選択は空のままにするか、別途処理する
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ユーザー名を入力してください')));
      return;
    }

    setState(() => _loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final nasIp = prefs.getString('main_path')?.replaceAll(r'\\', '') ?? '';
      if (nasIp.isEmpty) throw Exception('NASのIPが未設定です');

      // 登録と更新でエンドポイントとHTTPメソッドを切り替え
      final uri = widget.isEdit
          ? Uri.parse('http://$nasIp:3000/api/users/${widget.user!["id"]}')
          : Uri.parse('http://$nasIp:3000/api/register');

      final request = http.MultipartRequest(
        widget.isEdit ? 'PUT' : 'POST',
        uri,
      );

      request.fields['username'] = username;

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'icon',
            _selectedImage!.path,
            filename: p.basename(_selectedImage!.path),
          ),
        );
      }

      final response = await request.send();

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
              decoration: const InputDecoration(labelText: 'ユーザー名'),
            ),
            const SizedBox(height: 8),
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 100)
                : widget.isEdit &&
                      widget.user != null &&
                      widget.user!['iconPath'] != null
                ? Image.network(
                    // 編集時は既存のアイコン画像URLを表示
                    'http://${widget.user!["nasIp"]}:3000/uploads/${widget.user!["iconPath"].toString().split(RegExp(r"[\\/]")).last}',
                    height: 100,
                  )
                : const Text('画像未選択'),
            ElevatedButton(onPressed: _pickImage, child: const Text('画像を選択')),
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
