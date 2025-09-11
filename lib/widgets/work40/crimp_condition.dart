import 'dart:async';
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
  
  bool _hasInitialized = false;
  bool _isValidating = false;
  bool _hasTriggeredAutoTap = false;
  DateTime? _lastAutoTapTime;

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
    // 画面遷移から戻ってきた時のためにフラグをリセット
    _hasTriggeredAutoTap = false;
    _lastAutoTapTime = null;
    
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
    
    // efu_detailのデータ保存完了を確実に待つ
    // 複数回チェックして、データが安定するまで待つ
    await _waitForDataStability();
    
    if (mounted) {
      _performValidation();
    }
  }
  
  Future<void> _waitForDataStability() async {
    String? previousTerminal0;
    int stableCount = 0;
    
    // 最大3秒間、データの安定性をチェック
    for (int i = 0; i < 30; i++) {
      final currentTerminal0 = await SharedPrefsHelper.getString('block_terminals_0');
      
      if (currentTerminal0 == previousTerminal0) {
        stableCount++;
        // 3回連続で同じ値なら安定とみなす
        if (stableCount >= 3) {
          break;
        }
      } else {
        stableCount = 0;
      }
      
      previousTerminal0 = currentTerminal0;
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  Future<void> _performValidation() async {
    if (_isValidating) return;
    
    // 自動タップ直後（1秒以内）はバリデーション処理をスキップ
    if (_lastAutoTapTime != null && 
        DateTime.now().difference(_lastAutoTapTime!).inMilliseconds < 1000) {
      return;
    }
    
    _isValidating = true;
    
    // バリデーション前に最新データをSharedPrefsから再読み込み
    final micrometerSerialNumber = await SharedPrefsHelper.getString('micrometer_serial_number') ?? '';
    final applicatorName = await SharedPrefsHelper.getString('applicator_name') ?? '';
    final terminalName = await SharedPrefsHelper.getString('terminal_name') ?? '';
    final currentTerminal0 = await SharedPrefsHelper.getString('block_terminals_0');

    // メンバ変数も更新（表示用）
    _micrometerSerialNumber = micrometerSerialNumber;
    _applicatorName = applicatorName;
    _terminalName = terminalName;

    // デバッグ出力
    print('🔍 crimp_condition バリデーション:');
    print('  micrometerSerialNumber: "$micrometerSerialNumber"');
    print('  applicatorName: "$applicatorName"');
    print('  terminalName: "$terminalName"');
    print('  currentTerminal0: "$currentTerminal0"');

    GlobalKey<CustomInputCardState>? firstErrorKey;

    setState(() {
      // Micrometerの検証（nullじゃなければOK）
      if (micrometerSerialNumber.isNotEmpty) {
        _micrometerValidation = ValidationState.valid;
      } else {
        _micrometerValidation = ValidationState.error;
        firstErrorKey = _micromertorKey; // 最初のエラー
      }

      // Applicatorの検証（terminal0と比較）
      if (currentTerminal0 != null &&
          applicatorName.isNotEmpty &&
          applicatorName.length >= 8 &&
          currentTerminal0.length >= 8 &&
          applicatorName.substring(0, 8) == currentTerminal0.substring(0, 8)) {
        // ✅ 先頭8文字一致 → valid
        _applicatorValidation = ValidationState.valid;
        print('  applicatorValidation: VALID');
        print('  applicatorName.substring(0, 8): "${applicatorName.substring(0, 8)}"');
        print('  currentTerminal0.substring(0, 8): "${currentTerminal0.substring(0, 8)}"');
      } else {
        // ❌ エラー
        _applicatorValidation = ValidationState.error;
        firstErrorKey ??= _applicatorCardKey; // まだエラーがなければ設定
        print('  applicatorValidation: ERROR');
        print('  条件チェック: currentTerminal0 != null = ${currentTerminal0 != null}');
        print('  条件チェック: applicatorName.isNotEmpty = ${applicatorName.isNotEmpty}');
        print('  条件チェック: applicatorName.length >= 8 = ${applicatorName.length >= 8}');
        print('  条件チェック: currentTerminal0.length >= 8 = ${currentTerminal0?.length ?? 0 >= 8}');
        if (applicatorName.length >= 8 && (currentTerminal0?.length ?? 0) >= 8) {
          print('  文字比較: "${applicatorName.substring(0, 8)}" == "${currentTerminal0!.substring(0, 8)}" = ${applicatorName.substring(0, 8) == currentTerminal0.substring(0, 8)}');
        }
      }

      // Terminalの検証（terminal0と比較）
      if (currentTerminal0 != null &&
          terminalName.isNotEmpty &&
          terminalName == currentTerminal0) {
        // ✅ 完全一致 → valid
        _terminalValidation = ValidationState.valid;
      } else {
        // ❌ エラー
        _terminalValidation = ValidationState.error;
        firstErrorKey ??= _terminalCardKey; // まだエラーがなければ設定
      }
    });

    // setState完了後に遅延してから自動タップを実行
    if (firstErrorKey != null && !_hasTriggeredAutoTap) {
      _hasTriggeredAutoTap = true;
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          _lastAutoTapTime = DateTime.now(); // 自動タップ実行時刻を記録
          firstErrorKey!.currentState?.triggerTap();
        }
      });
    }
    
    _isValidating = false;
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
                  _hasTriggeredAutoTap = false; // 入力完了時にリセット
                });

                // 入力完了後は少し遅延してから再検証
                Future.delayed(Duration(milliseconds: 200), () {
                  if (mounted) {
                    _performValidation();
                  }
                });
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
                    _hasTriggeredAutoTap = false; // 入力完了時にリセット
                  });

                  // 入力完了後は少し遅延してから再検証
                  Future.delayed(Duration(milliseconds: 200), () {
                    if (mounted) {
                      _performValidation();
                    }
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
                    _hasTriggeredAutoTap = false; // 入力完了時にリセット
                  });

                  // 入力完了後は少し遅延してから再検証
                  Future.delayed(Duration(milliseconds: 200), () {
                    if (mounted) {
                      _performValidation();
                    }
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
