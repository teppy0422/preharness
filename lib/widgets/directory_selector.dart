// lib/widgets/directory_selector.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DirectorySelector extends StatefulWidget {
  final TextEditingController controller;

  const DirectorySelector({super.key, required this.controller});

  @override
  State<DirectorySelector> createState() => _DirectorySelectorState();
}

class _DirectorySelectorState extends State<DirectorySelector> {
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      // 入力が変わったらエラーを消す
      if (errorMessage != null) {
        setState(() {
          errorMessage = null;
        });
      }
    });
  }

  Future<void> _pickDirectory() async {
    try {
      final selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'フォルダを選択してください',
        initialDirectory: widget.controller.text.isNotEmpty
            ? widget.controller.text
            : null,
      );

      if (selectedDirectory != null) {
        setState(() {
          widget.controller.text = selectedDirectory;
        });
      }
    } catch (e) {
      setState(() {
        if (e.toString().contains('0x80070043')) {
          errorMessage = 'ネットワークパスが見つかりません';
        } else {
          errorMessage = 'フォルダを開けませんでした';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                decoration: const InputDecoration(labelText: 'サーバーパス'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(40, 40),
                ),
                onPressed: _pickDirectory,
                child: const Icon(Icons.folder_open),
              ),
            ),
          ],
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
