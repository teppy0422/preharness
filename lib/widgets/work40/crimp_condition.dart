import 'package:flutter/material.dart';
import 'package:preharness/utils/global.dart';
import 'package:preharness/utils/shared_prefs_helper.dart';
import 'package:preharness/widgets/custom_input_card.dart';

class CrimpCondition extends StatefulWidget {
  const CrimpCondition({super.key});

  @override
  State<CrimpCondition> createState() => _CrimpConditionState();
}

class _CrimpConditionState extends State<CrimpCondition> {
  String _micrometerSerialNumber = "";

  String _applicatorName = "";
  String _applicatorSerialNumber = "";

  String _terminalName = "";
  String _terminalSerialNumber = "";

  ValidationState _micrometerValidation = ValidationState.none;
  ValidationState _applicatorValidation = ValidationState.none;
  ValidationState _terminalValidation = ValidationState.none;

  final FocusNode _applicatorFocusNode = FocusNode();
  final FocusNode _terminalFocusNode = FocusNode();

  // CustomInputCard用のGlobalKey
  final GlobalKey<CustomInputCardState> _micromertorKey =
      GlobalKey<CustomInputCardState>();
  final GlobalKey<CustomInputCardState> _applicatorCardKey =
      GlobalKey<CustomInputCardState>();
  final GlobalKey<CustomInputCardState> _terminalCardKey =
      GlobalKey<CustomInputCardState>();

  Future<void> _loadStringPref(String key, Function(String) setter) async {
    final value = await SharedPrefsHelper.getString(key);
    if (value != null) {
      setState(() => setter(value));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAllPreferences();
  }

  @override
  void dispose() {
    _applicatorFocusNode.dispose();
    _terminalFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadAllPreferences() async {
    await _loadStringPref(
      'micrometer_serial_number',
      (value) => _micrometerSerialNumber = value,
    );
    await _loadStringPref(
      'applicator_name',
      (value) => _applicatorName = value,
    );
    await _loadStringPref(
      'applicator_serial_number',
      (value) => _applicatorSerialNumber = value,
    );
    await _loadStringPref('terminal_name', (value) => _terminalName = value);
    await _loadStringPref(
      'terminal_serial_number',
      (value) => _terminalSerialNumber = value,
    );

    // 初回バリデーション
    await _performValidation();
  }

  Future<void> _performValidation() async {
    // SharedPrefsから現在の端子値を取得
    final currentTerminal0 = await SharedPrefsHelper.getString(
      'block_terminals_0',
    );
    final currentTerminal1 = await SharedPrefsHelper.getString(
      'block_terminals_1',
    );

    setState(() {
      // Micrometerの検証（nullじゃなければOK）
      if (_micrometerSerialNumber.isNotEmpty) {
        _micrometerValidation = ValidationState.valid;
      } else {
        _micrometerValidation = ValidationState.error;
        // 空の場合はタップ処理をトリガー
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _micromertorKey.currentState?.triggerTap();
        });
      }

      // Applicatorの検証（terminal0と比較）
      if (_applicatorName.isEmpty) {
        _applicatorValidation = ValidationState.error;
      } else if (currentTerminal0 != null &&
          _applicatorName.substring(0, 8) == currentTerminal0.substring(0, 8)) {
        _applicatorValidation = ValidationState.valid;
      } else if (currentTerminal0 != null &&
          _applicatorName != currentTerminal0) {
        _applicatorValidation = ValidationState.error;
        // 値が異なる場合はタップ処理をトリガー
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _applicatorCardKey.currentState?.triggerTap();
        });
      } else {
        _applicatorValidation = ValidationState.none;
      }

      // Terminalの検証（terminal1と比較）
      if (_terminalName.isEmpty) {
        _terminalValidation = ValidationState.error;
      } else if (currentTerminal0 != null &&
          _terminalName == currentTerminal0) {
        _terminalValidation = ValidationState.valid;
      } else if (currentTerminal0 != null &&
          _terminalName != currentTerminal0) {
        _terminalValidation = ValidationState.error;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _terminalCardKey.currentState?.triggerTap();
        });
      } else {
        _terminalValidation = ValidationState.none;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomInputCard(
          key: _micromertorKey,
          title: 'マイクロメーター',
          externalValidation: _micrometerValidation,
          subItems: [
            SubItem(
              label: '管理No:',
              value: _micrometerSerialNumber,
              valueFont: 20,
              flex: 5,
              prefsKey: 'micrometer_serial_number',
              onInputComplete: (value) async {
                await SharedPrefsHelper.saveString(
                  'micrometer_serial_number',
                  value,
                );
                setState(() {
                  _micrometerSerialNumber = value;
                });

                // 保存後に再検証
                await _performValidation();
              },
            ),
          ],
        ),
        CustomInputCard(
          key: _applicatorCardKey,
          title: 'Applicator Serial',
          externalValidation: _applicatorValidation,
          subItems: [
            SubItem(
              label: 'アプリ品番:',
              value: formatCode(_applicatorName, "-"),
              valueFont: 20,
              flex: 5,
              prefsKey: 'applicator_name',
              onInputComplete: (value) async {
                if (value.length > 10) {
                  final applicatorName = value
                      .substring(0, 10)
                      .replaceAll(RegExp(r'\s'), '');
                  final applicatorSerialNumber = value.substring(10);

                  await SharedPrefsHelper.saveString(
                    'applicator_name',
                    applicatorName,
                  );
                  await SharedPrefsHelper.saveString(
                    'applicator_serial_number',
                    applicatorSerialNumber,
                  );

                  setState(() {
                    _applicatorName = applicatorName;
                    _applicatorSerialNumber = applicatorSerialNumber;
                  });

                  // 保存後に再検証
                  await _performValidation();
                }
              },
            ),
            SubItem(label: '加締形状:', value: '-', valueFont: 20, flex: 2),
            SubItem(
              label: 'シリアルNo:',
              value: _applicatorSerialNumber,
              valueFont: 20,
              flex: 3,
            ),
          ],
        ),
        CustomInputCard(
          key: _terminalCardKey,
          title: '端子リール',
          externalValidation: _terminalValidation,
          subItems: [
            SubItem(
              label: '端子品番:',
              value: formatCode(_terminalName, "-"),
              valueFont: 20,
              flex: 5,
              prefsKey: 'terminal_name',
              onInputComplete: (value) async {
                if (value.length > 10) {
                  final terminalName = value.substring(0, 10);
                  final terminalSerialNumber = value.substring(10);
                  await SharedPrefsHelper.saveString(
                    'terminal_name',
                    terminalName,
                  );
                  await SharedPrefsHelper.saveString(
                    'terminal_serial_number',
                    terminalSerialNumber,
                  );
                  setState(() {
                    _terminalName = terminalName;
                    _terminalSerialNumber = terminalSerialNumber;
                  });

                  // 保存後に再検証
                  await _performValidation();
                }
              },
            ),
            SubItem(
              label: 'ロットNo:',
              value: _terminalSerialNumber,
              valueFont: 20,
              flex: 5,
            ),
          ],
        ),
      ],
    );
  }
}
