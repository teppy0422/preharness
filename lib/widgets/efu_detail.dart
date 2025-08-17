import 'package:flutter/material.dart';
import 'package:preharness/services/local_db_service.dart';
import 'package:preharness/widgets/dial_selector.dart';
import 'package:drift/drift.dart' as drift;

class EfuDetailPage extends StatefulWidget {
  final Map<String, dynamic> processingConditions;
  final Map<String, dynamic> blockInfo;
  final VoidCallback onBack;

  const EfuDetailPage({
    super.key,
    required this.processingConditions,
    required this.blockInfo,
    required this.onBack,
  });

  @override
  State<EfuDetailPage> createState() => _EfuDetailPageState();
}

class _EfuDetailPageState extends State<EfuDetailPage> {
  late AppDatabase _db;
  bool _isLoading = true;
  String? _initialTopDial;
  String? _initialBottomDial;
  String? _initialHindDial;

  @override
  void initState() {
    super.initState();
    _db = db; // 共有インスタンスを使用
    _loadDialValues();
  }

  @override
  void dispose() {
    // _db.close(); // シングルトンのため不要
    super.dispose();
  }

  Future<void> _loadDialValues() async {
    final wireType = widget.processingConditions['wire_type']?.toString() ?? '';
    final wireSize = widget.processingConditions['wire_size']?.toString() ?? '';
    final termPartNo = widget.blockInfo['terminals'][0]?.toString() ?? '';
    final addParts = widget.blockInfo['terminals'][2]?.toString() ?? '';

    final existingData = await _db.getCondition(
      wireType: wireType,
      wireSize: wireSize,
      termPartNo: termPartNo,
      addParts: addParts,
    );

    if (mounted) {
      setState(() {
        if (existingData != null) {
          _initialTopDial = existingData.topDial;
          _initialBottomDial = existingData.bottomDial;
          _initialHindDial = existingData.hindDial;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDialValues(String top, String bottom, String hind) async {
    final wireType = widget.processingConditions['wire_type']?.toString() ?? '';
    final wireSize = widget.processingConditions['wire_size']?.toString() ?? '';
    final termPartNo = widget.blockInfo['terminals'][0]?.toString() ?? '';
    final addParts = widget.blockInfo['terminals'][2]?.toString() ?? '';

    final entry = LocalProcessingConditionsCompanion(
      wireType: drift.Value(wireType),
      wireSize: drift.Value(wireSize),
      termPartNo: drift.Value(termPartNo),
      addParts: drift.Value(addParts),
      topDial: drift.Value(top),
      bottomDial: drift.Value(bottom),
      hindDial: drift.Value(hind),
    );

    await _db.createOrUpdateCondition(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ダイヤル値を保存しました。'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '■ 加工条件詳細',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('戻る'),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              DialSelectorPage(
                initialTopDialOptions: _initialTopDial != null
                    ? [_initialTopDial!]
                    : null,
                initialBottomDialOptions: _initialBottomDial != null
                    ? [_initialBottomDial!]
                    : null,
                initialHindDialOptions: _initialHindDial != null
                    ? [_initialHindDial!]
                    : null,
                onChanged: _saveDialValues,
              ),
            const Divider(height: 20, thickness: 1),
            const Text('全体情報:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('電線タイプ: ${widget.processingConditions['wire_type']}'),
            Text('電線サイズ: ${widget.processingConditions['wire_size']}'),
            const Divider(height: 20, thickness: 1),
            const Text(
              'ブロック詳細:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('端子部品番号: ${widget.blockInfo['terminals'][0]}'),
            Text('付加部品: ${widget.blockInfo['terminals'][2]}'),
          ],
        ),
      ),
    );
  }
}
