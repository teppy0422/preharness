import 'package:flutter/material.dart';
import "package:file_picker/file_picker.dart";
import '../services/settings_service.dart';
import 'package:preharness/widgets/responsive_scaffold.dart';
import 'package:preharness/routes/app_routes.dart';

import "package:preharness/widgets/directory_selector.dart";

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'フォルダ選択テスト',
      currentPage: AppRoutes.settings,
      child: const Center(child: FolderPage()),
    );
  }
}

class FolderPage extends StatefulWidget {
  const FolderPage({super.key});
  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final TextEditingController _serverPathController = TextEditingController();

  @override
  void dispose() {
    _serverPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('サーバーパス選択')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: DirectorySelector(controller: _serverPathController),
      ),
    );
  }
}

class _SettingsPageState extends State<SettingsPage> {
  final _mainController = TextEditingController();
  final _pathController = TextEditingController();
  final _typeController = TextEditingController();
  final _serialController = TextEditingController();
  final _workNameController = TextEditingController();

  final _service = SettingsService();
  String? _serverPathErrorText; // サーバーパス用エラーメッセージ

  @override
  void initState() {
    super.initState();
    _loadSettings();
    // 入力が変更されたらエラーを消す
    _mainController.addListener(() {
      if (_serverPathErrorText != null) {
        setState(() {
          _serverPathErrorText = null;
        });
      }
    });
  }

  String withDefault(String? value, String defaultValue) {
    if (value == null || value.trim().isEmpty) return defaultValue;
    return value;
  }

  Future<void> _loadSettings() async {
    final settings = await _service.loadSettings();

    _mainController.text = withDefault(
      settings['main_path'],
      r'\\192.168.11.11',
    );
    _pathController.text = withDefault(
      settings['path_01'],
      r'\\192.168.11.11\g\projects\PreHarnessPro\data',
    );
    _typeController.text = withDefault(settings['machine_type'], 'CM20');
    _serialController.text = withDefault(settings['machine_serial'], '0000');
    _workNameController.text = withDefault(settings['work_name'], '手圧着');
  }

  Future<void> _saveSettings() async {
    await _service.saveSettings(
      mainPath: _mainController.text,
      path01: _pathController.text,
      machineType: _typeController.text,
      machineSerial: _serialController.text,
      workName: _workNameController.text,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('保存しました')));
  }

  Widget _buildLabeledField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool enableFolderPicker = false,
    String? errorText, // ← 追加
  }) {
    return Column(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 300, maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ラベルとエラーテキスト
                Row(
                  children: [
                    Text(label),
                    const SizedBox(width: 8),
                    if (errorText != null)
                      Text(
                        errorText,
                        style: const TextStyle(color: Colors.red),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: hint,
                          hintStyle: TextStyle(
                            color: Theme.of(context).hintColor,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    if (enableFolderPicker) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            minimumSize: const Size(40, 40),
                          ),
                          onPressed: () async {
                            try {
                              String? selectedDirectory = await FilePicker
                                  .platform
                                  .getDirectoryPath(
                                    dialogTitle: 'フォルダを選択してください',
                                    initialDirectory:
                                        _mainController.text.isNotEmpty
                                        ? _mainController.text
                                        : null,
                                  );
                              if (selectedDirectory != null) {
                                controller.text = selectedDirectory;
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setState(() {
                                  _serverPathErrorText =
                                      e.toString().contains('0x80070043')
                                      ? 'ネットワークパスが見つかりません。'
                                      : 'フォルダを開けませんでした。';
                                });
                              }
                            }
                          },
                          child: const Icon(Icons.folder_open),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: '設定',
      currentPage: AppRoutes.settings,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLabeledField(
                  label: 'サーバーパス',
                  hint: '例: \\192.168.11.11',
                  controller: _mainController,
                  errorText: _serverPathErrorText,
                ),
                _buildLabeledField(
                  label: '製造指示データ読み込みパス',
                  hint: '例: C:/data/instruction',
                  controller: _pathController,
                  enableFolderPicker: true,
                ),
                _buildLabeledField(
                  label: '機種',
                  hint: '例: CM20',
                  controller: _typeController,
                ),
                _buildLabeledField(
                  label: '管理ナンバー',
                  hint: '例: 1234',
                  controller: _serialController,
                ),
                _buildLabeledField(
                  label: '作業名',
                  hint: '例: 圧着',
                  controller: _workNameController,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton.icon(
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.save),
                    label: const Text('保存'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
