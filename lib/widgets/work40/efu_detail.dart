import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preharness/services/work_results_service.dart';
import 'package:preharness/widgets/work40/dial_selector_with_db.dart';
import 'package:preharness/widgets/work40/measurement.dart';
import 'package:preharness/utils/color_utils.dart';
import 'package:preharness/constants/app_colors.dart';
import 'package:preharness/widgets/terminal_info_card.dart';
import 'package:preharness/widgets/interactive_image_viewer.dart';
import 'package:preharness/widgets/work40/product_info_card.dart';
import 'package:preharness/widgets/work40/crimp_condition.dart';
import 'package:preharness/utils/shared_prefs_helper.dart';
import 'package:preharness/models/workflow_state.dart';
import 'package:preharness/widgets/ui/pattern_button.dart';
import 'package:preharness/widgets/ui/cfm_number_modal.dart';

class EfuDetailPage extends StatefulWidget {
  final Map<String, dynamic> processingConditions;
  final Map<String, dynamic> blockInfo;
  final VoidCallback onBack;
  final VoidCallback? onCfmTap;
  final List<Map<String, dynamic>>? chListData;
  final bool isLoadingChList;
  final String? chListError;

  const EfuDetailPage({
    super.key,
    required this.processingConditions,
    required this.blockInfo,
    required this.onBack,
    this.onCfmTap,
    this.chListData,
    this.isLoadingChList = false,
    this.chListError,
  });

  @override
  State<EfuDetailPage> createState() => _EfuDetailPageState();
}

class _EfuDetailPageState extends State<EfuDetailPage> {
  Color? _containerColor; // Added
  Color? _containerForeColor; // Added
  String? _recommendedHindDial; // 推奨後足ダイヤル値
  String _currentHindDial = '5'; // 現在の後足ダイヤル値
  String? _recommendedTopDial; // 推奨上ダイヤル値
  String? _recommendedBottomDial; // 推奨下ダイヤル値
  String _currentTopDial = '0.5'; // 現在の上ダイヤル値
  String _currentBottomDial = '1'; // 現在の下ダイヤル値
  int _f13KeyCount = 0; // F13キーカウンター
  int _previousF13Count = -1; // フリップ用の前の値（初回は確実に変化を検出するため-1）
  final List<MapEntry<DateTime, double>> _speedData = []; // 速度データ（時刻、速度）
  DateTime? _lastCountTime; // 最後にカウントした時刻
  double _currentSpeed = 0.0; // 現在の速度（カウント/分）
  bool _showComparisonFormula = false; // 比較式表示フラグ（デフォルトで比較式を表示）

  // フォーカスノードを追加
  late final FocusNode _focusNode;

  // Arduino対応：見えないTextFieldでキーボード入力を初期化
  late final TextEditingController _dummyController;
  late final FocusNode _dummyFocusNode;

  // 生産中F1キー専用FocusNode
  late final FocusNode _productionFocusNode;

  // ★★★ リアクティブな状態管理のための変更点 ★★★
  Map<String, String?>? _comparisonData; // 比較データを保持する状態変数
  VoidCallback? _prefsListener; // リスナーを保持するための変数
  // ★★★ ここまで ★★★

  // ワークフロー状態管理
  final WorkflowState _workflowState = WorkflowState();

  // フォーカス管理用
  late FocusNode _measurementFocusNode;

  // 測定値の初期値管理
  Map<String, String>? _initialMeasurements;

  // アニメーション制御
  bool _isZooming = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _measurementFocusNode = FocusNode(); // FocusNodeをここで初期化

    // Arduino対応：ダミーコントローラーとフォーカスノードを初期化
    _dummyController = TextEditingController();
    _dummyFocusNode = FocusNode();

    // 生産中F1キー専用FocusNode初期化
    _productionFocusNode = FocusNode();

    _loadColor(); // Call a method to load the color

    // WorkflowStateを初期化
    debugPrint(
      '🔧 [efu_detail] WorkflowState初期化: crimpConditionComplete=${_workflowState.crimpConditionComplete}, measurementComplete=${_workflowState.measurementComplete}, canStartProduction=${_workflowState.canStartProduction}',
    );

    // ★★★ リアクティブな状態管理のための変更点 ★★★
    _updateComparisonData(); // 初期データをロード
    _setupPrefsListener(); // SharedPrefsの変更をリッスン
    // ★★★ ここまで ★★★

    // 初期化完了後に実行
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _saveCurrentDataToPrefs(); // データ保存を確実に完了
      await _checkMeasurementInitialValues(); // 測定値の初期値をチェック

      // フォーカスを確実に取得
      if (mounted) {
        _focusNode.requestFocus();
        debugPrint(
          '🎯 [efu_detail] 初期フォーカス要求: hasFocus=${_focusNode.hasFocus}',
        );

        // Arduino Leonardo等の外部デバイス対応：キーボード入力システムを初期化
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            debugPrint(
              '🎯 [efu_detail] フォーカス確認: hasFocus=${_focusNode.hasFocus}',
            );
            if (!_focusNode.hasFocus) {
              _focusNode.requestFocus();
              debugPrint('🎯 [efu_detail] 再フォーカス要求');
            }

            // キーボード入力システムを強制的に初期化（Arduino対応）
            FocusScope.of(context).requestFocus(_focusNode);

            // Arduino対応：既に全て照合完了している場合は即座に実行
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted && _workflowState.canStartProduction) {
                debugPrint('🎯 [efu_detail] 既に照合完了状態 - Arduino対応を自動実行');
                _activateArduinoKeyboardSupport();
              } else {
                debugPrint('🎯 [efu_detail] Arduino対応は測定完了後に実行予定');
              }
            });

            debugPrint(
              '🎯 [efu_detail] Arduino対応：FocusScope経由でフォーカス設定 (緑ボーダー確認用)',
            );
          }
        });
      }
    });
  }

  Future<void> _saveCurrentDataToPrefs() async {
    print('🔥 efu_detail: _saveCurrentDataToPrefs 開始');
    print('🔥 efu_detail: widget.blockInfo全体: ${widget.blockInfo}');
    print('🔥 efu_detail: terminals配列: ${widget.blockInfo['terminals']}');
    print(
      '🔥 efu_detail: terminals[0] = "${widget.blockInfo['terminals']?[0]}"',
    );

    // processingConditions を efu_ プレフィックスで通知機能付き保存
    await SharedPrefsHelper.saveMapWithNotify(
      'efu',
      widget.processingConditions,
    );

    // blockInfo を block_ プレフィックスで通知機能付き保存
    await SharedPrefsHelper.saveMapWithNotify('block', widget.blockInfo);

    print(
      '🔥 efu_detail: block_terminals_0 保存後キャッシュ確認: "${SharedPrefsHelper.getCachedString('block_terminals_0')}"',
    );

    // 保存完了を通知
    await SharedPrefsHelper.saveStringWithNotify(
      'block_save_completed',
      DateTime.now().toIso8601String(),
    );
    print('🔥 efu_detail: block_save_completed を通知');

    print('🔥 efu_detail: _saveCurrentDataToPrefs 完了');
  }

  // Arduino対応：全て照合OK時のみキーボード入力を初期化
  void _activateArduinoKeyboardSupport() {
    debugPrint('🎯 [efu_detail] Arduino対応開始（全て照合OK時）');

    // キーボード入力システムを初期化してからメインFocusNodeにフォーカス
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 1. まずダミーTextFieldで一時的にキーボードシステムを初期化
        _dummyFocusNode.requestFocus();

        // 2. キーボード入力システムを「刺激」
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            _dummyController.text = ' '; // 空白文字で刺激
            Future.delayed(const Duration(milliseconds: 50), () {
              if (mounted) {
                _dummyController.clear(); // すぐクリア

                // 3. メインのFocusNode（F1キーハンドラーがある）にフォーカスを移す
                Future.delayed(const Duration(milliseconds: 50), () {
                  if (mounted) {
                    // より強力にメインFocusNodeにフォーカス
                    FocusScope.of(context).unfocus(); // 全てのフォーカスをクリア
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) {
                        _focusNode.requestFocus();
                        FocusScope.of(context).requestFocus(_focusNode);
                        debugPrint(
                          '🎯 [efu_detail] メインFocusNodeにフォーカス完了 - Arduino F1キー準備OK',
                        );

                        // 追加でフォーカスを確実に維持
                        Future.delayed(const Duration(milliseconds: 200), () {
                          if (mounted && !_focusNode.hasFocus) {
                            debugPrint(
                              '🔄 [efu_detail] フォーカス最終確認: Arduino F1キー対応',
                            );
                            _focusNode.requestFocus();
                            FocusScope.of(context).requestFocus(_focusNode);
                          }
                        });
                      }
                    });
                  }
                });
              }
            });
          }
        });
      }
    });
  }

  // フォールバック：別の方法でフォーカスをアクティブ化
  void _fallbackFocusActivation() {
    // 複数回のフォーカス要求でシステムを刺激
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(_focusNode);
          _focusNode.requestFocus();
        }
      });
    }
    debugPrint('🎯 [efu_detail] フォールバック：複数回フォーカス要求実行');
  }

  // 作業完了処理（PostgreSQL保存）
  Future<void> _handleWorkCompletion() async {
    try {
      // 平均速度計算
      final averageSpeed = _speedData.isNotEmpty
          ? _speedData.map((e) => e.value).reduce((a, b) => a + b) /
                _speedData.length
          : 0.0;

      // PostgreSQLに保存（SharedPreferences全項目を自動取得）
      final result = await WorkResultsService.saveWorkResult(
        actualCount: _f13KeyCount,
        averageSpeed: averageSpeed,
      );

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? '作業完了しました！データを保存しました。'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // エラーの詳細を表示
          final errors = result['errors'] as List<String>? ?? [];
          final errorMessage = errors.isNotEmpty
              ? errors.join('\n')
              : result['message'] ?? 'データ保存でエラーが発生しました';

          // ユーザー名がない場合は特別な警告
          final hasUsernameError = errors.any(
            (error) => error.contains('ユーザー名'),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasUsernameError) ...[
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'ユーザーログインが必要です',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('設定画面でユーザー情報を登録してください。'),
                    const SizedBox(height: 8),
                  ],
                  Text('詳細エラー:\n$errorMessage'),
                ],
              ),
              backgroundColor: hasUsernameError ? Colors.red : Colors.orange,
              duration: const Duration(seconds: 7), // 警告を読む時間を確保
              action: hasUsernameError
                  ? SnackBarAction(
                      label: '設定へ',
                      textColor: Colors.white,
                      onPressed: () {
                        // 設定画面に遷移する処理（必要に応じて実装）
                      },
                    )
                  : null,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ 作業完了処理エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('作業完了！（保存処理でエラーが発生しました）'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _measurementFocusNode.dispose();

    // Arduino対応：ダミーリソースをクリーンアップ
    _dummyController.dispose();
    _dummyFocusNode.dispose();

    // 生産中F1キー専用FocusNode dispose
    _productionFocusNode.dispose();
    // ★★★ リアクティブな状態管理のための変更点 ★★★
    // リスナーをクリーンアップ
    if (_prefsListener != null) {
      SharedPrefsHelper.notifier.removeKeyListener(
        'micrometer_serial_number',
        _prefsListener!,
      );
      SharedPrefsHelper.notifier.removeKeyListener(
        'applicator_name',
        _prefsListener!,
      );
      SharedPrefsHelper.notifier.removeKeyListener(
        'terminal_name',
        _prefsListener!,
      );
      SharedPrefsHelper.notifier.removeKeyListener(
        'block_save_completed',
        _prefsListener!,
      );
    }
    // ★★★ ここまで ★★★
    super.dispose();
  }

  // ★★★ リアクティブな状態管理のための変更点 ★★★
  // データ取得とUI更新を行うメソッド
  Future<void> _updateComparisonData() async {
    final data = await _getComparisonDataWithCache();
    if (mounted) {
      setState(() {
        _comparisonData = data;
      });
    }
  }

  // 変更通知リスナーを設定するメソッド
  void _setupPrefsListener() {
    _prefsListener = () {
      // 変更があったらデータを再取得してUIを更新
      _updateComparisonData();
    };
    // 関連するキーの変更を監視
    SharedPrefsHelper.notifier.addKeyListener(
      'micrometer_serial_number',
      _prefsListener!,
    );
    SharedPrefsHelper.notifier.addKeyListener(
      'applicator_name',
      _prefsListener!,
    );
    SharedPrefsHelper.notifier.addKeyListener('terminal_name', _prefsListener!);
    SharedPrefsHelper.notifier.addKeyListener(
      'block_save_completed',
      _prefsListener!,
    );
  }
  // ★★★ ここまで ★★★

  // 測定値の初期値チェック
  Future<void> _checkMeasurementInitialValues() async {
    try {
      // 現在のblock_terminals値を取得
      final currentBlockTerminal0 = await SharedPrefsHelper.getString(
        'block_terminals_0',
      );
      final currentBlockTerminal1 = await SharedPrefsHelper.getString(
        'block_terminals_1',
      );

      // 保存済みのblock_terminals値を取得
      final measuredBlockTerminal0 = await SharedPrefsHelper.getString(
        'measured_block_terminals_0',
      );
      final measuredBlockTerminal1 = await SharedPrefsHelper.getString(
        'measured_block_terminals_1',
      );

      debugPrint(
        '🔍 block_terminals比較: 現在0=$currentBlockTerminal0, 保存済み0=$measuredBlockTerminal0',
      );
      debugPrint(
        '🔍 block_terminals比較: 現在1=$currentBlockTerminal1, 保存済み1=$measuredBlockTerminal1',
      );

      // 両方が一致する場合のみ測定値を取得
      if (currentBlockTerminal0 == measuredBlockTerminal0 &&
          currentBlockTerminal1 == measuredBlockTerminal1 &&
          currentBlockTerminal0 != null &&
          currentBlockTerminal1 != null) {
        debugPrint('✅ block_terminals一致 → 測定値を取得');

        // 保存済みの測定値を取得
        final measuredFrontCh = await SharedPrefsHelper.getString(
          'measured_front_ch',
        );
        final measuredBackCh = await SharedPrefsHelper.getString(
          'measured_back_ch',
        );
        final measuredFrontCw = await SharedPrefsHelper.getString(
          'measured_front_cw',
        );
        final measuredBackCw = await SharedPrefsHelper.getString(
          'measured_back_cw',
        );

        // 測定値が全て存在する場合のみ初期値として設定
        if (measuredFrontCh != null &&
            measuredBackCh != null &&
            measuredFrontCw != null &&
            measuredBackCw != null) {
          setState(() {
            _initialMeasurements = {
              'front_ch': measuredFrontCh,
              'back_ch': measuredBackCh,
              'front_cw': measuredFrontCw,
              'back_cw': measuredBackCw,
            };
          });

          debugPrint('📋 測定値初期値設定: $_initialMeasurements');
        }
      } else {
        debugPrint('❌ block_terminals不一致 → 測定値クリア');
        setState(() {
          _initialMeasurements = null;
        });
      }
    } catch (e) {
      debugPrint('❌ 測定値初期値チェックエラー: $e');
    }
  }

  // ワークフロー制御メソッド
  void _onCrimpConditionValidationChanged(bool isValid) {
    debugPrint(
      '🔧 部材照合バリデーション変更: $isValid (previous: ${_workflowState.crimpConditionComplete})',
    );

    // 状態を更新
    if (_workflowState.crimpConditionComplete != isValid) {
      setState(() {
        _workflowState.crimpConditionComplete = isValid;
      });
      debugPrint('🔧 ワークフロー状態更新: crimpConditionComplete = $isValid');
    }

    // 端子交換後の生産復帰チェック
    if (isValid && _f13KeyCount > 0 && !_workflowState.productionStarted) {
      debugPrint('🔄 端子照合OK + カウント>0 → 生産状態復帰');
      setState(() {
        _workflowState.productionStarted = true;
      });
      // 生産状態復帰時にF1キー専用TextFieldにフォーカス
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _productionFocusNode.requestFocus();
          debugPrint('🎯 生産復帰 → F1キー専用TextFieldにフォーカス設定');
        }
      });
    }

    // isValidがtrueで、測定がまだ完了していない場合はフォーカス移動
    if (isValid && !_workflowState.measurementComplete) {
      debugPrint('🔧 部材照合完了 → 測定にフォーカス移動');
      _moveToMeasurement();
    } else if (!isValid) {
      debugPrint('🔧 部材照合未完了 → CustomInputCardのValidationState制御でフォーカス管理');
      // CustomInputCardのValidationStateによる自動フォーカス制御に任せる
    } else {
      debugPrint('🔧 測定完了済みのため、フォーカス移動スキップ');
    }
  }

  // 端子交換時の処理
  void _onTerminalExchange() async {
    if (_f13KeyCount > 0) {
      debugPrint('🔄 端子交換前の作業実績保存: カウント=$_f13KeyCount');

      // 現在の平均速度を計算
      double averageSpeed = 0.0;
      if (_speedData.isNotEmpty) {
        averageSpeed =
            _speedData.map((e) => e.value).reduce((a, b) => a + b) /
            _speedData.length;
      }

      try {
        // PostgreSQLに作業実績を保存
        final result = await WorkResultsService.saveWorkResult(
          actualCount: _f13KeyCount,
          averageSpeed: averageSpeed,
        );

        if (result['success'] == true) {
          debugPrint('✅ 端子交換前の作業実績保存完了: ID=${result['id']}');
          // カウンターはリセットしない（継続して使用）
          debugPrint('🔄 カウンターは継続: $_f13KeyCount');
          // 生産開始フラグをリセット（端子再照合まで生産停止）
          setState(() {
            _workflowState.productionStarted = false;
          });
          debugPrint('🔄 生産開始フラグリセット: 端子再照合まで生産停止');
        } else {
          debugPrint('❌ 端子交換前の作業実績保存失敗: ${result['error']}');
        }
      } catch (e) {
        debugPrint('❌ 端子交換前の作業実績保存エラー: $e');
      }
    } else {
      debugPrint('🔄 端子交換: カウント=0のため保存スキップ');
      // カウント=0でも生産開始フラグはリセット
      setState(() {
        _workflowState.productionStarted = false;
      });
      debugPrint('🔄 生産開始フラグリセット: 端子再照合まで生産停止');
    }
  }

  // F1キー専用処理メソッド
  void _handleF1KeyPress() {
    debugPrint('🎯 F1キー専用処理実行');

    // 重複実行防止のため短時間内の連続実行をチェック
    final now = DateTime.now();
    if (_lastCountTime != null) {
      final timeSinceLastCount = now.difference(_lastCountTime!).inMilliseconds;
      if (timeSinceLastCount < 100) {
        // 100ms以内の連続実行は無視
        debugPrint('⚠️ 重複F1キー検出: ${timeSinceLastCount}ms前に実行済み');
        return;
      }
    }

    // 速度計算（カウント/分）
    if (_lastCountTime != null) {
      final timeDiff = now.difference(_lastCountTime!).inMilliseconds;
      if (timeDiff > 0) {
        final speed = 60000.0 / timeDiff; // カウント/分
        _speedData.add(MapEntry(now, speed));

        // データ数を制限（直近50件のみ保持）
        if (_speedData.length > 50) {
          _speedData.removeAt(0);
        }

        // 平均速度計算
        if (_speedData.isNotEmpty) {
          final averageSpeed =
              _speedData.map((e) => e.value).reduce((a, b) => a + b) /
              _speedData.length;
          _currentSpeed = averageSpeed;
          debugPrint(
            '⚡ 速度更新: ${speed.toStringAsFixed(1)}個/分, 平均: ${averageSpeed.toStringAsFixed(1)}個/分',
          );
        }
      }
    }

    setState(() {
      _previousF13Count = _f13KeyCount;
      _f13KeyCount++;
      _lastCountTime = now;
      // 生産開始フラグも設定
      if (!_workflowState.productionStarted) {
        _workflowState.productionStarted = true;
        debugPrint('🚀 生産開始！初回カウント');
      }
    });
    debugPrint('✅ カウント実行: $_f13KeyCount');
  }

  void _onMeasurementValidationChanged(bool isValid) {
    debugPrint('📏 測定バリデーション結果受信: isValid=$isValid');
    setState(() {
      _workflowState.measurementComplete = isValid;
      debugPrint(
        '📏 WorkflowState更新: measurementComplete=${_workflowState.measurementComplete}, canStartProduction=${_workflowState.canStartProduction}',
      );
    });

    if (isValid && _workflowState.canStartProduction) {
      // 全工程完了 → 生産開始準備
      debugPrint('📏 全工程完了 → 生産開始準備実行');
      _prepareForProduction();

      // 測定完了後、Arduino対応のキーボード初期化を実行
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _activateArduinoKeyboardSupport();

          // さらに確実にメインFocusNodeにフォーカスを戻す
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && !_focusNode.hasFocus) {
              debugPrint('🔄 [efu_detail] 測定完了後のフォーカス復旧');
              FocusScope.of(context).unfocus(); // 一度すべてクリア
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  _focusNode.requestFocus();
                  FocusScope.of(context).requestFocus(_focusNode);
                }
              });
            }
          });
        }
      });
    }
  }

  void _moveToMeasurement() {
    // 測定セクションにフォーカス移動
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        debugPrint('[efu_detail] 測定セクションへのフォーカスを要求します。');
        debugPrint(
          '[efu_detail] requestFocus 前: _measurementFocusNode.hasFocus = ${_measurementFocusNode.hasFocus}',
        );

        // FocusScopeを使用してより確実にフォーカス移動
        FocusScope.of(context).requestFocus(_measurementFocusNode);

        // requestFocusが非同期に処理される場合を考慮し、少し待ってから状態を再確認
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            debugPrint(
              '[efu_detail] requestFocus 後: _measurementFocusNode.hasFocus = ${_measurementFocusNode.hasFocus}',
            );
          }
        });
      }
    });
  }

  void _prepareForProduction() {
    // 生産開始準備 - zoomアニメーション実行
    _triggerZoomAnimation();

    // F1キー専用TextFieldにフォーカス設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _productionFocusNode.requestFocus();
        debugPrint('🎯 初回生産開始準備 → F1キー専用TextFieldにフォーカス設定');
      }
    });
  }

  void _triggerZoomAnimation() {
    setState(() {
      _isZooming = true;
    });

    // 1秒後にアニメーション終了
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isZooming = false;
        });
      }
    });

    debugPrint('🎊 生産準備完了 - zoomアニメーション実行');
  }

  // ステータスカードの表示制御
  String _getStatusCardText() {
    if (_workflowState.productionStarted) {
      return "生産中";
    } else if (_workflowState.canStartProduction) {
      return "圧着準備OK";
    } else if (_workflowState.crimpConditionComplete) {
      return "測定確認中";
    } else {
      return "部材照合中";
    }
  }

  Color _getStatusCardColor() {
    if (_workflowState.productionStarted) {
      return AppColors.getCardColor(context);
    } else if (_workflowState.canStartProduction) {
      return AppColors.getCardColor(context);
    } else if (_workflowState.crimpConditionComplete) {
      return AppColors.getCardColor(context);
    } else {
      return AppColors.getCardColor(context);
    }
  }

  Color _getStatusTextColor() {
    if (_workflowState.productionStarted) {
      return AppColors.getHighLightColor(context);
    } else if (_workflowState.canStartProduction) {
      return AppColors.getHighLightColor(context);
    } else if (_workflowState.crimpConditionComplete) {
      return Colors.orange.shade800;
    } else {
      return Colors.grey.shade600;
    }
  }

  Future<void> _loadColor() async {
    try {
      final String colorNum = widget.processingConditions['wire_color'] ?? '';
      if (colorNum.isEmpty) {
        // print('wire_color is empty in efu_detail');
        return;
      }

      final Color? loadedBackColor = await getColorFromHive(colorNum);
      final Color? loadedForeColor = await getColorFromHive(
        colorNum,
        getForeColor: true,
      );

      if (mounted) {
        setState(() {
          _containerColor = loadedBackColor;
          _containerForeColor = loadedForeColor;
        });
      }
    } catch (e) {
      // print('Error in _loadColor (efu_detail): $e');
      // エラー時はデフォルト色を設定
      if (mounted) {
        setState(() {
          _containerColor = Colors.white;
          _containerForeColor = Colors.black;
        });
      }
    }
  }

  void _onHindDialRecommendation(String? recommendedDial) {
    setState(() {
      _recommendedHindDial = recommendedDial;
    });
  }

  void _onDialChanged(String top, String bottom, String hind) {
    setState(() {
      _currentTopDial = top;
      _currentBottomDial = bottom;
      _currentHindDial = hind;
    });
  }

  void _onFrontDialRecommendation(
    String? recommendedTopDial,
    String? recommendedBottomDial,
  ) {
    setState(() {
      _recommendedTopDial = recommendedTopDial;
      _recommendedBottomDial = recommendedBottomDial;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color baseLineColor = AppColors.getLineColor(context);
    return Stack(
      children: [
        // Arduino対応：見えないTextFieldでキーボード入力システムを初期化
        Positioned(
          left: -1000, // 画面外に配置
          top: -1000,
          child: SizedBox(
            width: 1,
            height: 1,
            child: TextField(
              controller: _dummyController,
              focusNode: _dummyFocusNode,
              style: const TextStyle(color: Colors.transparent),
              keyboardType: TextInputType.none, // ソフトキーボードを完全に無効化
              enableInteractiveSelection: false, // 選択を無効化
              showCursor: false, // カーソルを非表示
              autofocus: false, // 自動フォーカスしない
              readOnly: false, // ハードウェアキー入力は受け付ける
              onChanged: (text) {
                // キーボード入力をテストしてログ出力
                debugPrint('🎯 [efu_detail] ダミーTextField入力検出: "$text"');
                if (text.isNotEmpty) {
                  _dummyController.clear(); // 入力内容をクリア
                }
              },
              onSubmitted: (text) {
                debugPrint('🎯 [efu_detail] ダミーTextField送信検出: "$text"');
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),

        // メインのFocusウィジェット
        Focus(
          focusNode: _focusNode,
          autofocus: true,
          onFocusChange: (hasFocus) {
            debugPrint('🎯 [efu_detail] フォーカス変更: hasFocus=$hasFocus');
          },
          onKeyEvent: (node, event) {
            debugPrint(
              '🎹 [efu_detail] キーイベント受信: ${event.runtimeType}, フォーカス状態: ${_focusNode.hasFocus}',
            );
            if (event is KeyDownEvent) {
              debugPrint(
                '🎹 キー押下検出: logical=${event.logicalKey}, physical=${event.physicalKey}',
              );
              // F13、F1、またはInsertキーをチェック（Android対応）
              if (event.logicalKey == LogicalKeyboardKey.f13 ||
                  event.logicalKey == LogicalKeyboardKey.f1 ||
                  event.logicalKey == LogicalKeyboardKey.insert ||
                  event.physicalKey == PhysicalKeyboardKey.f13) {
                debugPrint('🎯 対象キー検出: ${event.logicalKey}');

                // 生産中は専用TextFieldでF1キーを処理するため、既存処理をスキップ
                if (_workflowState.productionStarted) {
                  debugPrint('🔄 生産中につき、F1キー専用TextFieldで処理');
                  return KeyEventResult.handled;
                }

                // 生産準備OKの時のみカウント有効
                debugPrint(
                  '🔍 カウント判定: crimpConditionComplete=${_workflowState.crimpConditionComplete}, measurementComplete=${_workflowState.measurementComplete}, canStartProduction=${_workflowState.canStartProduction}',
                );

                if (!_workflowState.canStartProduction) {
                  debugPrint('⚠️ 生産準備未完了のため、カウント無効');
                  return KeyEventResult.handled;
                }

                final now = DateTime.now();
                // 速度計算（カウント/分）
                if (_lastCountTime != null) {
                  final timeDiff = now
                      .difference(_lastCountTime!)
                      .inMilliseconds;
                  if (timeDiff > 0) {
                    _currentSpeed = 60000.0 / timeDiff; // 1分間あたりのカウント数
                    // データを追加（最大60秒分保持）
                    _speedData.add(MapEntry(now, _currentSpeed));

                    // 60秒より古いデータを削除
                    final cutoff = now.subtract(const Duration(seconds: 60));
                    _speedData.removeWhere(
                      (entry) => entry.key.isBefore(cutoff),
                    );
                  }
                }

                setState(() {
                  _previousF13Count = _f13KeyCount;
                  _f13KeyCount++;
                  _lastCountTime = now;
                  // 生産開始フラグも設定
                  if (!_workflowState.productionStarted) {
                    _workflowState.productionStarted = true;
                    debugPrint('🚀 生産開始！初回カウント');
                  }
                });

                debugPrint('✅ カウント実行: $_f13KeyCount');
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },

          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      height: 1,
                      thickness: .5,
                      color: AppColors.getLineColor(context),
                    ),
                    SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Rowで左右に分割
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 左側: 情報グループ
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        ProductInfoCard(
                                          processingConditions:
                                              widget.processingConditions,
                                          onBack: widget.onBack,
                                          containerColor: _containerColor,
                                          containerForeColor:
                                              _containerForeColor,
                                        ),
                                        CrimpCondition(
                                          onValidationComplete:
                                              _onCrimpConditionValidationChanged,
                                          onTerminalExchange:
                                              _onTerminalExchange,
                                          isProductionStarted:
                                              _workflowState.productionStarted,
                                        ),
                                        const SizedBox(width: 0), // 左右の間隔
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 8,
                                              child: TerminalInfoCard(
                                                terminal1:
                                                    widget
                                                        .blockInfo['terminals']?[0] ??
                                                    "",
                                                wireType:
                                                    widget
                                                        .processingConditions['wire_type']
                                                        ?.toString() ??
                                                    '',
                                                wireSize:
                                                    widget
                                                        .processingConditions['wire_size']
                                                        ?.toString() ??
                                                    '',
                                                terminal2:
                                                    widget
                                                        .blockInfo['terminals']?[1] ??
                                                    "",
                                                cfgNo: widget
                                                    .processingConditions['cfg_no']
                                                    ?.toString(),
                                                onCfmTap: () async {
                                                  final result = await showDialog<String>(
                                                    context: context,
                                                    builder: (context) =>
                                                        CfmNumberModal(
                                                          initialValue:
                                                              widget
                                                                  .processingConditions['cfg_no']
                                                                  ?.toString() ??
                                                              '001',
                                                          onConfirm: (value) =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(value),
                                                          onCancel: () =>
                                                              Navigator.of(
                                                                context,
                                                              ).pop(),
                                                        ),
                                                  );
                                                  if (result != null) {
                                                    debugPrint(
                                                      'CFM番号選択: $result',
                                                    );
                                                    widget.onCfmTap?.call();
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),

                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  DialSelectorWithDb(
                                                    processingConditions: widget
                                                        .processingConditions,
                                                    blockInfo: widget.blockInfo,
                                                    recommendedHindDial:
                                                        _recommendedHindDial,
                                                    recommendedTopDial:
                                                        _recommendedTopDial,
                                                    recommendedBottomDial:
                                                        _recommendedBottomDial,
                                                    onDialChanged:
                                                        _onDialChanged,
                                                  ),
                                                  InteractiveImageViewer(
                                                    imagePath:
                                                        'assets/images/71144020-2.jpg',
                                                    scale: 2.4,
                                                    panX: 0.168,
                                                    panY: 0.35,
                                                    height: 255,
                                                    width: 500,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Column(
                                              children: [
                                                SizedBox(height: 4),
                                                Builder(
                                                  builder: (context) {
                                                    debugPrint(
                                                      '📏 [efu_detail] Measurementウィジェット作成: focusNode=${_measurementFocusNode.hashCode}, initialMeasurements=$_initialMeasurements',
                                                    );
                                                    return Measurement(
                                                      key: ValueKey(
                                                        _initialMeasurements,
                                                      ), // キーを追加して再構築を制御
                                                      chListData:
                                                          widget.chListData,
                                                      onHindDialRecommendation:
                                                          _onHindDialRecommendation,
                                                      onFrontDialRecommendation:
                                                          _onFrontDialRecommendation,
                                                      currentHindDial:
                                                          _currentHindDial,
                                                      currentTopDial:
                                                          _currentTopDial,
                                                      currentBottomDial:
                                                          _currentBottomDial,
                                                      onValidationComplete:
                                                          _onMeasurementValidationChanged,
                                                      focusNode:
                                                          _measurementFocusNode,
                                                      initialMeasurements:
                                                          _initialMeasurements,
                                                    );
                                                  },
                                                ),
                                                const SizedBox(height: 25),
                                                AnimatedScale(
                                                  scale: _isZooming ? 1.2 : 1.0,
                                                  duration: const Duration(
                                                    milliseconds: 500,
                                                  ),
                                                  curve: Curves.elasticOut,
                                                  child: SizedBox(
                                                    width: 190,
                                                    height: 50,
                                                    child: Card(
                                                      color:
                                                          _getStatusCardColor(),
                                                      elevation: 4,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8.0,
                                                            ),
                                                        side: BorderSide(
                                                          // ←ここでボーダー指定
                                                          color:
                                                              AppColors.getLineColor(
                                                                context,
                                                              ),
                                                          width: .5,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          _getStatusCardText(),
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                _getStatusTextColor(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 10, thickness: 0.5, color: baseLineColor),
                  ],
                ),

                Positioned(
                  bottom: 1,
                  right: 0,
                  left: 0, // 左端の位置を指定してスペースを確保
                  child: Row(
                    children: [
                      Expanded(child: _buildSpeedGraph()),
                      const SizedBox(width: 16),
                      _buildAnimatedCounter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ], // Stack の children 閉じ
    ); // Stack 閉じ
  }

  Widget _buildAnimatedCounter() {
    final targetCount =
        int.tryParse(widget.processingConditions['wire_cnt'].toString()) ?? 0;
    final isCompleted = _f13KeyCount >= targetCount && targetCount > 0;

    return Column(
      children: [
        // 生産中の場合はF1キー受信可能なカウンターにする
        _workflowState.productionStarted
            ? RawKeyboardListener(
                focusNode: _productionFocusNode,
                onKey: (RawKeyEvent event) {
                  if (event is RawKeyDownEvent) {
                    debugPrint('🎯 カウンター F1キー検出: ${event.logicalKey}');
                    if (event.logicalKey == LogicalKeyboardKey.f13 ||
                        event.logicalKey == LogicalKeyboardKey.f1 ||
                        event.logicalKey == LogicalKeyboardKey.insert) {
                      _handleF1KeyPress();
                    }
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    // カウンターをタップしたときにフォーカス取得
                    _productionFocusNode.requestFocus();
                    debugPrint('🎯 カウンタータップ → フォーカス取得');
                  },
                  child: _buildCounterDisplay(targetCount, isCompleted),
                ),
              )
            : _buildCounterDisplay(targetCount, isCompleted),
      ],
    );
  }

  Widget _buildCounterDisplay(int targetCount, bool isCompleted) {
    final counterString = "$_f13KeyCount/$targetCount";

    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.getHighLightColor(context)
                : AppColors.getCardColor(context),
            border: Border.all(
              color: AppColors.getLineColor(context),
              width: 1,
            ),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (!isCompleted) ...[
                  const SizedBox(height: 10),
                  _buildFlipCounter(),
                  Divider(
                    color: AppColors.getLineColor(context),
                    thickness: 0.5,
                    height: 10,
                  ),
                  Text(
                    '$targetCount',
                    style: TextStyle(
                      fontSize: 28,
                      height: 0.8,
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getHighLightColor(context),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () async {
                      await _handleWorkCompletion();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.getHighLightColor(context),
                      elevation: 2,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: Center(
                        child: Text(
                          '完了',
                          style: TextStyle(
                            color: AppColors.paperBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (isCompleted)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.getCardColor(context).withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.getLineColor(context).withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Text(
                isCompleted ? counterString : '',
                style: TextStyle(
                  color: AppColors.getHighLightColor(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        // const SizedBox(height: 10),
      ],
    );
  }

  Future<Map<String, String?>> _getComparisonDataWithCache() async {
    // すべての関連データでキャッシュを優先的に使用する
    return {
      'micrometer':
          SharedPrefsHelper.getCachedString('micrometer_serial_number') ??
          await SharedPrefsHelper.getString('micrometer_serial_number') ??
          '',
      'applicator':
          SharedPrefsHelper.getCachedString('applicator_name') ??
          await SharedPrefsHelper.getString('applicator_name') ??
          '',
      'terminal':
          SharedPrefsHelper.getCachedString('terminal_name') ??
          await SharedPrefsHelper.getString('terminal_name') ??
          '',
      'blockTerminal0':
          SharedPrefsHelper.getCachedString('block_terminals_0') ??
          await SharedPrefsHelper.getString('block_terminals_0'),
    };
  }

  Widget _buildComparisonFormula() {
    // ★★★ リアクティブな状態管理のための変更点 ★★★
    // FutureBuilderをやめて、状態(_comparisonData)を直接使用する
    if (_comparisonData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = _comparisonData!;
    final micrometerSerialNumber = data['micrometer'] ?? '';
    final applicatorName = data['applicator'] ?? '';
    final terminalName = data['terminal'] ?? '';
    final blockTerminal0 = data['blockTerminal0'] ?? '';

    // バリデーション結果（crimp_condition.dartと完全に同じロジック）
    final micrometerValid = micrometerSerialNumber.isNotEmpty;
    final applicatorValid =
        blockTerminal0.isNotEmpty &&
        applicatorName.isNotEmpty &&
        applicatorName.length >= 8 &&
        blockTerminal0.length >= 8 &&
        applicatorName.substring(0, 8) == blockTerminal0.substring(0, 8);
    final terminalValid =
        blockTerminal0.isNotEmpty &&
        terminalName.isNotEmpty &&
        terminalName.length >= 8 &&
        blockTerminal0.length >= 8 &&
        terminalName.substring(0, 8) == blockTerminal0.substring(0, 8);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.getLineColor(context), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '比較式チェック',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.getLineColor(context),
            ),
          ),
          const SizedBox(height: 4),
          _buildComparisonRow(
            '✓ マイクロメーター:',
            micrometerSerialNumber.isEmpty ? '未入力' : micrometerSerialNumber,
            micrometerValid,
          ),
          _buildComparisonRow(
            '✓ Applicator(前8文字):',
            '(${blockTerminal0.isEmpty ? "未設定" : "設定済"}&&${applicatorName.isEmpty ? "未入力" : "入力済"}&&${applicatorName.length >= 8 ? "長さ>=8" : "長さ<8"}&&${blockTerminal0.length >= 8 ? "T0長さ>=8" : "T0長さ<8"}) → ${applicatorName.isEmpty || applicatorName.length < 8 ? "入力不足" : applicatorName.substring(0, 8)} == ${blockTerminal0.isEmpty || blockTerminal0.length < 8 ? "T0不足" : blockTerminal0.substring(0, 8)}',
            applicatorValid,
          ),
          _buildComparisonRow(
            '✓ Terminal(前8文字):',
            '(${blockTerminal0.isEmpty ? "未設定" : "設定済"}&&${terminalName.isEmpty ? "未入力" : "入力済"}&&${terminalName.length >= 8 ? "長さ>=8" : "長さ<8"}&&${blockTerminal0.length >= 8 ? "T0長さ>=8" : "T0長さ<8"}) → ${terminalName.isEmpty || terminalName.length < 8 ? "入力不足" : terminalName.substring(0, 8)} == ${blockTerminal0.isEmpty || blockTerminal0.length < 8 ? "T0不足" : blockTerminal0.substring(0, 8)}',
            terminalValid,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String comparison, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid
                ? AppColors.getLineSubColor(context)
                : AppColors.getErrorColor(context),
            size: 12,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.getLineColor(context),
                  ),
                ),
                Text(
                  comparison,
                  style: TextStyle(
                    fontSize: 11,
                    color: isValid
                        ? AppColors.getLineSubColor(context)
                        : AppColors.getErrorColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedGraph() {
    return SizedBox(
      height: 174,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Stack(
            children: [
              // グラフまたは比較式を表示
              _showComparisonFormula
                  ? _buildComparisonFormula()
                  : _speedData.isEmpty
                  ? Center(
                      child: Text(
                        'データなし',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.getLineSubColor(context),
                        ),
                      ),
                    )
                  : CustomPaint(
                      size: Size.infinite,
                      painter: SpeedGraphPainter(
                        speedData: _speedData,
                        color: AppColors.getHighLightColor(context),
                        lineColor: AppColors.getLineColor(context),
                      ),
                    ),
              // 平均値テキストを前面に表示（高さを取らない）（比較式表示時は非表示）
              if (_speedData.isNotEmpty && !_showComparisonFormula)
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.getCardColor(context),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.getLineColor(context),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      '${(_speedData.map((e) => e.value).reduce((a, b) => a + b) / _speedData.length).toStringAsFixed(1)} /分',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.getLineColor(context),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              // 切り替えスイッチを右上に表示
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showComparisonFormula = !_showComparisonFormula;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.getCardColor(context),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.getLineColor(context),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showComparisonFormula
                              ? Icons.show_chart
                              : Icons.search,
                          size: 12,
                          color: AppColors.getLineColor(context),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _showComparisonFormula ? 'グラフ' : '式',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.getLineColor(context),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlipCounter() {
    return Row(mainAxisSize: MainAxisSize.min, children: _buildDigitWidgets());
  }

  List<Widget> _buildDigitWidgets() {
    final currentStr = _f13KeyCount.toString();
    final previousStr = _previousF13Count >= 0
        ? _previousF13Count.toString()
        : '';

    // print('Building digits: $previousStr -> $currentStr');

    // 現在の数字をベースに、桁ごとに処理
    List<Widget> digits = [];

    // 0の場合は特別処理
    if (_f13KeyCount == 0) {
      print('Special handling for zero: count=$_f13KeyCount');
      digits.add(
        _buildSingleDigit(
          currentDigit: '0',
          previousDigit: '',
          shouldAnimate: false,
          digitIndex: 0,
          isNewDigit: false,
        ),
      );
      return digits;
    }

    for (int i = 0; i < currentStr.length; i++) {
      final currentDigit = currentStr[i];

      // 右から左に桁を対応させる
      final currentFromRight = currentStr.length - 1 - i; // 右から何番目か
      final previousLen = previousStr.length;

      String previousDigit = '';
      bool isNewDigit = false;

      if (currentFromRight < previousLen) {
        // 前の数字の右からcurrentFromRight番目の桁
        final previousIndex = previousLen - 1 - currentFromRight;
        previousDigit = previousStr[previousIndex];
      } else {
        // 新しく追加される桁（桁数が増えた場合）
        isNewDigit = true;
        previousDigit = ''; // 空文字のままにして新しい桁として扱う
      }

      final hasChanged = currentDigit != previousDigit || isNewDigit;

      // print(
      //   'Position $i (right-$currentFromRight): prev="$previousDigit" -> cur="$currentDigit", changed: $hasChanged, isNew: $isNewDigit',
      // );

      digits.add(
        _buildSingleDigit(
          currentDigit: currentDigit,
          previousDigit: isNewDigit ? '' : previousDigit,
          shouldAnimate: hasChanged,
          digitIndex: i,
          isNewDigit: isNewDigit,
        ),
      );
    }
    return digits;
  }

  Widget _buildSingleDigit({
    required String currentDigit,
    required String previousDigit,
    required bool shouldAnimate,
    required int digitIndex,
    bool isNewDigit = false,
  }) {
    if (!shouldAnimate) {
      // 変化なし：静的表示
      return SizedBox(
        width: 20,
        height: 24, // 高さを統一
        child: Center(
          child: Text(
            currentDigit,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              height: 0.8,
              fontWeight: FontWeight.bold,
              color: AppColors.getHighLightColor(context),
            ),
          ),
        ),
      );
    }

    // 変化あり：アニメーション
    return SizedBox(
      width: 20,
      height: 24, // 高さを統一
      child: ClipRect(
        child: SlidingNumber(
          key: ValueKey('$digitIndex-$currentDigit-$previousDigit-$isNewDigit'),
          currentChild: Text(
            currentDigit,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              height: 0.8,
              fontWeight: FontWeight.bold,
              color: AppColors.getHighLightColor(context),
            ),
          ),
          previousChild: !isNewDigit && previousDigit.isNotEmpty
              ? Text(
                  previousDigit,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    height: 0.8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getHighLightColor(context),
                  ),
                )
              : null,
          isNewDigit: isNewDigit,
        ),
      ),
    );
  }
}

class SlidingNumber extends StatefulWidget {
  final Widget currentChild;
  final Widget? previousChild;
  final bool isNewDigit;

  const SlidingNumber({
    super.key,
    required this.currentChild,
    this.previousChild,
    this.isNewDigit = false,
  });

  @override
  State<SlidingNumber> createState() => _SlidingNumberState();
}

class _SlidingNumberState extends State<SlidingNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideInAnim;
  late Animation<double> _slideOutAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideInAnim = Tween<double>(
      begin: 40.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideOutAnim = Tween<double>(
      begin: 0.0,
      end: -40.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnim = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // 数字が切り替わるたびにアニメーションを再生
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.previousChild != null || widget.isNewDigit) {
        _controller.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.hardEdge,
      children: [
        // 古い数字を上にスライドアウト
        if (widget.previousChild != null)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(0.0, _slideOutAnim.value),
                child: Opacity(
                  opacity: _opacityAnim.value,
                  child: widget.previousChild,
                ),
              );
            },
          ),
        // 新しい数字を下からスライドイン
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Transform.translate(
              offset: Offset(0.0, _slideInAnim.value),
              child: widget.currentChild,
            );
          },
        ),
      ],
    );
  }
}

class SpeedGraphPainter extends CustomPainter {
  final List<MapEntry<DateTime, double>> speedData;
  final Color color;
  final Color lineColor;
  SpeedGraphPainter({
    required this.speedData,
    required this.color,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (speedData.isEmpty) return;

    // 表示するポイント数を制限（最大30ポイント）
    const maxPoints = 30;
    final displayData = speedData.length > maxPoints
        ? speedData.skip(speedData.length - maxPoints).toList()
        : speedData;

    if (displayData.isEmpty) return;

    // 平均値を計算
    final averageSpeed =
        displayData.map((e) => e.value).reduce((a, b) => a + b) /
        displayData.length;

    // 速度の最小値と最大値を取得（グラフ範囲決定用）
    final speeds = displayData.map((e) => e.value).toList();
    final minSpeed = speeds.reduce((a, b) => a < b ? a : b);
    final maxSpeed = speeds.reduce((a, b) => a > b ? a : b);

    // 最小値と最大値の差が小さい場合の調整
    final speedRange = (maxSpeed - minSpeed) == 0 ? 1.0 : (maxSpeed - minSpeed);
    final margin = speedRange * 0.1; // 上下15%のマージンで余裕を持たせる

    // Y軸の範囲を設定
    final yMin = minSpeed - margin;
    final yMax = maxSpeed + margin;
    final yRange = yMax - yMin;

    // X軸の左右マージン
    final xMargin = size.width * 0.01; // 左右5%のマージン
    final drawingWidth = size.width - (xMargin * 2);

    // 平均線を描画
    final averageLinePaint = Paint()
      ..color = lineColor.withAlpha(180)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final averageY =
        size.height - ((averageSpeed - yMin) / yRange) * size.height;
    canvas.drawLine(
      Offset(0, averageY),
      Offset(size.width, averageY),
      averageLinePaint,
    );

    // 各ポイントの座標を計算（等間隔配置）
    final points = <Offset>[];
    for (int i = 0; i < displayData.length; i++) {
      final speed = displayData[i].value;

      // X座標: 等間隔に配置（マージン考慮）
      final x = displayData.length == 1
          ? size.width / 2
          : xMargin + (i / (displayData.length - 1)) * drawingWidth;

      // Y座標: 速度に応じて配置（範囲内に収まるように）
      final y = size.height - ((speed - yMin) / yRange) * size.height;

      // Y座標が範囲内に収まるようにクランプ
      final clampedY = y.clamp(0.0, size.height);

      points.add(Offset(x, clampedY));
    }

    // スムーズな曲線を描画
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    if (points.isNotEmpty) {
      final path = Path();

      if (points.length == 1) {
        // 1点の場合は点のみ
        // ポイント描画で対応
      } else if (points.length == 2) {
        // 2点の場合は直線
        path.moveTo(points[0].dx, points[0].dy);
        path.lineTo(points[1].dx, points[1].dy);
      } else {
        // 3点以上の場合はスムーズな曲線（Catmull-Rom風）
        path.moveTo(points[0].dx, points[0].dy);

        for (int i = 0; i < points.length - 1; i++) {
          final current = points[i];
          final next = points[i + 1];

          // 前後の点を取得（境界では現在の点を使用）
          final prev = i > 0 ? points[i - 1] : current;
          final afterNext = i < points.length - 2 ? points[i + 2] : next;

          // 制御点を計算（tangentベース）
          final tension = 0.3; // 張力（0.0-1.0、小さいほどスムーズ）

          final cp1x = current.dx + (next.dx - prev.dx) * tension;
          final cp1y = current.dy + (next.dy - prev.dy) * tension;

          final cp2x = next.dx - (afterNext.dx - current.dx) * tension;
          final cp2y = next.dy - (afterNext.dy - current.dy) * tension;

          path.cubicTo(cp1x, cp1y, cp2x, cp2y, next.dx, next.dy);
        }
      }

      if (points.length > 1) {
        canvas.drawPath(path, linePaint);
      }
    }

    // ポイントを描画
    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      // 最新のポイントは大きく、古いポイントは小さく
      final isLatest = i == points.length - 1;
      final radius = isLatest ? 4.0 : 2.5;
      final alpha = isLatest ? 1.0 : 0.7;

      final pointPaint = Paint()
        ..color = color.withOpacity(alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, radius, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 常に再描画してリアルタイム更新
  }
}

void showCustomDialog(BuildContext context, Widget child) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: GestureDetector(onTap: () {}, child: child),
        ),
      );
    },
  );
}
