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

  final bool _hasInitialized = false;
  bool _isValidating = false;
  bool _hasTriggeredAutoTap = false;
  DateTime? _lastAutoTapTime;

  // SharedPrefs変更監視用
  VoidCallback? _sharedPrefsListener;

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
    _setupSharedPrefsListener();
  }

  @override
  void dispose() {
    _applicatorFocusNode.dispose();
    _terminalFocusNode.dispose();
    // SharedPrefs監視を解除
    if (_sharedPrefsListener != null) {
      SharedPrefsHelper.notifier.removeKeyListener(
        'block_terminals_0',
        _sharedPrefsListener!,
      );
      SharedPrefsHelper.notifier.removeKeyListener(
        'block_save_completed',
        _sharedPrefsListener!,
      );
    }
    super.dispose();
  }

  void _setupSharedPrefsListener() {
    print('🟢 crimp_condition: _setupSharedPrefsListener 開始');
    _sharedPrefsListener = () {
      if (mounted) {
        print('🟢 crimp_condition: 関連データ変更検知！バリデーション実行');
        // 関連するキーの変更時にバリデーションを実行
        _performValidation();
      }
    };

    // block保存完了のみを監視（efu_detailのデータ保存完了を検知）
    SharedPrefsHelper.notifier.addKeyListener(
      'block_save_completed',
      _sharedPrefsListener!,
    );

    print(
      '🟢 crimp_condition: リスナー登録完了（block_save_completed）',
    );
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

    // efu_detail.dartのデータ保存完了を待ってからバリデーション実行
    if (mounted) {
      // 少し遅延してからバリデーション（efu_detail.dartの保存完了を待つ）
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          print('🟢 crimp_condition: 遅延バリデーション実行');
          _performValidation();
        }
      });
    }
  }

  Future<void> _performValidation() async {
    if (_isValidating) return;

    _isValidating = true;

    // キャッシュから即座にデータを取得、なければSharedPrefsから読み込み
    final micrometerSerialNumber =
        SharedPrefsHelper.getCachedString('micrometer_serial_number') ??
        await SharedPrefsHelper.getString('micrometer_serial_number') ??
        '';
    final applicatorName =
        SharedPrefsHelper.getCachedString('applicator_name') ??
        await SharedPrefsHelper.getString('applicator_name') ??
        '';
    final terminalName =
        SharedPrefsHelper.getCachedString('terminal_name') ??
        await SharedPrefsHelper.getString('terminal_name') ??
        '';
    final blockTerminal0 =
        SharedPrefsHelper.getCachedString('block_terminals_0') ??
        await SharedPrefsHelper.getString('block_terminals_0');

    // メンバ変数も更新（表示用）
    _micrometerSerialNumber = micrometerSerialNumber;
    _applicatorName = applicatorName;
    _terminalName = terminalName;

    // デバッグ出力
    print('🔍 crimp_condition バリデーション:');
    print('  micrometerSerialNumber: "$micrometerSerialNumber"');
    print('  applicatorName: "$applicatorName"');
    print('  terminalName: "$terminalName"');
    print('  blockTerminal0: "$blockTerminal0"');
    print('  キャッシュの状態: ${SharedPrefsHelper.notifier.cache}');

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
      if (blockTerminal0 != null &&
          applicatorName.isNotEmpty &&
          applicatorName.length >= 8 &&
          blockTerminal0.length >= 8 &&
          applicatorName.substring(0, 8) == blockTerminal0.substring(0, 8)) {
        // ✅ 先頭8文字一致 → valid
        _applicatorValidation = ValidationState.valid;
      } else {
        // ❌ エラー
        _applicatorValidation = ValidationState.error;
        firstErrorKey ??= _applicatorCardKey; // まだエラーがなければ設定
      }

      // Terminalの検証（terminal0と比較）
      if (blockTerminal0 != null &&
          terminalName.isNotEmpty &&
          terminalName.length >= 8 &&
          blockTerminal0.length >= 8 &&
          terminalName.substring(0, 8) == blockTerminal0.substring(0, 8)) {
        // ✅ 先頭8文字一致 → valid（Applicatorと同じ比較ロジック）
        _terminalValidation = ValidationState.valid;
        print('  terminalValidation: VALID');
        print(
          '  terminalName.substring(0, 8): "${terminalName.substring(0, 8)}"',
        );
        print(
          '  blockTerminal0.substring(0, 8): "${blockTerminal0.substring(0, 8)}"',
        );
      } else {
        // ❌ エラー
        _terminalValidation = ValidationState.error;
        firstErrorKey ??= _terminalCardKey; // まだエラーがなければ設定
        print('  terminalValidation: ERROR');
        print('  条件チェック: blockTerminal0 != null = ${blockTerminal0 != null}');
        print('  条件チェック: terminalName.isNotEmpty = ${terminalName.isNotEmpty}');
        print(
          '  条件チェック: terminalName.length >= 8 = ${terminalName.length >= 8}',
        );
        print(
          '  条件チェック: blockTerminal0.length >= 8 = ${blockTerminal0?.length ?? 0 >= 8}',
        );
        if (terminalName.length >= 8 && (blockTerminal0?.length ?? 0) >= 8) {
          print(
            '  文字比較: "${terminalName.substring(0, 8)}" == "${blockTerminal0!.substring(0, 8)}" = ${terminalName.substring(0, 8) == blockTerminal0.substring(0, 8)}',
          );
        }
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
                await SharedPrefsHelper.saveStringWithNotify(
                  'micrometer_serial_number',
                  value,
                );
                setState(() {
                  _micrometerSerialNumber = value;
                  _hasTriggeredAutoTap = false; // 入力完了時にリセット
                });
                // 通知機能により自動的にバリデーション実行される
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
                  await SharedPrefsHelper.saveStringWithNotify(
                    'applicator_name',
                    applicatorName,
                  );
                  await SharedPrefsHelper.saveStringWithNotify(
                    'applicator_serial_number',
                    applicatorSerialNumber,
                  );
                  setState(() {
                    _applicatorName = applicatorName;
                    _applicatorSerialNumber = applicatorSerialNumber;
                    _hasTriggeredAutoTap = false; // 入力完了時にリセット
                  });
                  // 通知機能により自動的にバリデーション実行される
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
                  await SharedPrefsHelper.saveStringWithNotify(
                    'terminal_name',
                    terminalName,
                  );
                  await SharedPrefsHelper.saveStringWithNotify(
                    'terminal_serial_number',
                    terminalSerialNumber,
                  );
                  setState(() {
                    _terminalName = terminalName;
                    _terminalSerialNumber = terminalSerialNumber;
                    _hasTriggeredAutoTap = false; // 入力完了時にリセット
                  });
                  // 通知機能により自動的にバリデーション実行される
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
