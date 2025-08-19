import 'package:flutter/material.dart';
import 'package:preharness/services/local_db_service.dart';
import 'package:preharness/widgets/dial_selector.dart';
import 'package:drift/drift.dart' as drift;

class DialSelectorWithDb extends StatefulWidget {
  final Map<String, dynamic> processingConditions;
  final Map<String, dynamic> blockInfo;

  const DialSelectorWithDb({
    super.key,
    required this.processingConditions,
    required this.blockInfo,
  });

  @override
  State<DialSelectorWithDb> createState() => _DialSelectorWithDbState();
}

class _DialSelectorWithDbState extends State<DialSelectorWithDb> {
  late AppDatabase _db;
  bool _isLoading = true;
  String? _initialTopDial;
  String? _initialBottomDial;
  String? _initialHindDial;
  bool _hasExistingData = false;

  @override
  void initState() {
    super.initState();
    _db = db; // 共有インスタンスを使用
    _loadDialValues();
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
          _hasExistingData = true;
        } else {
          _hasExistingData = false;
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return DialSelectorPage(
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
      valuesAreFromDb: _hasExistingData,
    );
  }
}
