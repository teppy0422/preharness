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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomInputCard(
          title: 'マイクロメーター',
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
              },
            ),
          ],
        ),
        CustomInputCard(
          title: 'Applicator Serial',
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
          title: '端子リール',
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
