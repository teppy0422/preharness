import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:preharness/widgets/user_register_edit_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:preharness/widgets/user_card_modal.dart";

class UserListModal extends StatefulWidget {
  const UserListModal({super.key});

  @override
  State<UserListModal> createState() => _UserListModalState();
}

class _UserListModalState extends State<UserListModal> {
  List<Map<String, dynamic>> users = [];
  bool loading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 忘れずに破棄
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nasIp = prefs.getString('main_path')?.replaceAll(r'\\', '') ?? '';
      final url = Uri.parse('http://$nasIp:3000/api/users');

      final res = await http.get(url);
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          users = List<Map<String, dynamic>>.from(data);
          loading = false;
        });
      } else {
        throw Exception("HTTP error: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Error loading users: $e");
      setState(() => loading = false);
    }
  }

  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ユーザー削除'),
        content: Text('${user["username"]} を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user['id']);
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nasIp = prefs.getString('main_path')?.replaceAll(r'\\', '') ?? '';
      final url = Uri.parse('http://$nasIp:3000/api/users/$id');

      final res = await http.delete(url);
      if (res.statusCode == 200) {
        setState(() {
          users.removeWhere((u) => u['id'] == id);
        });
      } else {
        throw Exception('削除失敗: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint("削除エラー: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('削除に失敗しました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ユーザー一覧'),
      content: SizedBox(
        width: 300,
        height: 400,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : users.isEmpty
            ? const Text('ユーザーが見つかりません')
            : Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final iconPath = user['iconPath']?.toString();
                    final hasIcon = iconPath != null && iconPath.isNotEmpty;
                    // NAS IPとファイル名からURLを組み立て
                    final fileName =
                        iconPath?.split(RegExp(r'[\\/]')).last ?? '';
                    final imageUrl =
                        'http://${user["nasIp"]}:3000/uploads/$fileName';

                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => UserLoginCardModal(user: user),
                        );
                      },

                      child: Row(
                        children: [
                          hasIcon
                              ? Image.network(
                                  imageUrl,
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 40,
                                  ), // fallback
                                )
                              : const Icon(Icons.person, size: 40),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${user['username']}"),
                                Text("ID: ${user['id']}"),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final updated = await showDialog<bool>(
                                context: context,
                                builder: (_) =>
                                    UserModal(isEdit: true, user: user),
                              );

                              if (updated == true) {
                                _fetchUsers(); // 編集後、ユーザー一覧を再取得
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(user),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => const UserModal(),
                );
              },
              child: const Text('新規ユーザー'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        ),
      ],
    );
  }
}
