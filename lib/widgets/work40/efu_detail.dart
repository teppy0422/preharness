import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class EfuDetailPage extends StatefulWidget {
  final Map<String, dynamic> processingConditions;
  final Map<String, dynamic> blockInfo;
  final VoidCallback onBack;
  final List<Map<String, dynamic>>? chListData;
  final bool isLoadingChList;
  final String? chListError;

  const EfuDetailPage({
    super.key,
    required this.processingConditions,
    required this.blockInfo,
    required this.onBack,
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
  bool _showComparisonFormula = true; // 比較式表示フラグ（デフォルトで比較式を表示）

  // フォーカスノードを追加
  late final FocusNode _focusNode;

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
    _loadColor(); // Call a method to load the color

    // WorkflowStateを初期化（画面再表示時のリセット）
    _workflowState.reset();

    // ★★★ リアクティブな状態管理のための変更点 ★★★
    _updateComparisonData(); // 初期データをロード
    _setupPrefsListener(); // SharedPrefsの変更をリッスン
    // ★★★ ここまで ★★★

    // 初期化完了後に実行
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _saveCurrentDataToPrefs(); // データ保存を確実に完了
      await _checkMeasurementInitialValues(); // 測定値の初期値をチェック
      _focusNode.requestFocus();
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

  @override
  void dispose() {
    _focusNode.dispose();
    _measurementFocusNode.dispose();
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
      final currentBlockTerminal0 = await SharedPrefsHelper.getString('block_terminals_0');
      final currentBlockTerminal1 = await SharedPrefsHelper.getString('block_terminals_1');
      
      // 保存済みのblock_terminals値を取得
      final measuredBlockTerminal0 = await SharedPrefsHelper.getString('measured_block_terminals_0');
      final measuredBlockTerminal1 = await SharedPrefsHelper.getString('measured_block_terminals_1');
      
      debugPrint('🔍 block_terminals比較: 現在0=$currentBlockTerminal0, 保存済み0=$measuredBlockTerminal0');
      debugPrint('🔍 block_terminals比較: 現在1=$currentBlockTerminal1, 保存済み1=$measuredBlockTerminal1');
      
      // 両方が一致する場合のみ測定値を取得
      if (currentBlockTerminal0 == measuredBlockTerminal0 && 
          currentBlockTerminal1 == measuredBlockTerminal1 &&
          currentBlockTerminal0 != null && currentBlockTerminal1 != null) {
        
        debugPrint('✅ block_terminals一致 → 測定値を取得');
        
        // 保存済みの測定値を取得
        final measuredFrontCh = await SharedPrefsHelper.getString('measured_front_ch');
        final measuredBackCh = await SharedPrefsHelper.getString('measured_back_ch');
        final measuredFrontCw = await SharedPrefsHelper.getString('measured_front_cw');
        final measuredBackCw = await SharedPrefsHelper.getString('measured_back_cw');
        
        // 測定値が全て存在する場合のみ初期値として設定
        if (measuredFrontCh != null && measuredBackCh != null && 
            measuredFrontCw != null && measuredBackCw != null) {
          
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

    // isValidがtrueで、測定がまだ完了していない場合はフォーカス移動
    if (isValid && !_workflowState.measurementComplete) {
      debugPrint('🔧 部材照合完了 → 測定にフォーカス移動');
      _moveToMeasurement();
    } else if (!isValid) {
      debugPrint('🔧 部材照合未完了のため、フォーカス移動なし');
    } else {
      debugPrint('🔧 測定完了済みのため、フォーカス移動スキップ');
    }
  }

  void _onMeasurementValidationChanged(bool isValid) {
    setState(() {
      _workflowState.measurementComplete = isValid;
    });

    if (isValid && _workflowState.canStartProduction) {
      // 全工程完了 → 生産開始準備
      _prepareForProduction();
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

  void _startProduction() {
    setState(() {
      _workflowState.productionStarted = true;
    });
    debugPrint('🚀 生産開始！');
    // 生産カウント開始
    _focusNode.requestFocus(); // F13キー入力にフォーカス戻す
  }

  // ステータスカードの表示制御
  String _getStatusCardText() {
    if (_workflowState.productionStarted) {
      return "生産中";
    } else if (_workflowState.canStartProduction) {
      return "生産準備OK";
    } else if (_workflowState.crimpConditionComplete) {
      return "測定確認中";
    } else {
      return "部材照合中";
    }
  }

  Color _getStatusCardColor() {
    if (_workflowState.productionStarted) {
      return Colors.green.shade100;
    } else if (_workflowState.canStartProduction) {
      return Colors.blue.shade100;
    } else if (_workflowState.crimpConditionComplete) {
      return Colors.orange.shade100;
    } else {
      return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor() {
    if (_workflowState.productionStarted) {
      return Colors.green.shade800;
    } else if (_workflowState.canStartProduction) {
      return Colors.blue.shade800;
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
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          // F13、F1、またはInsertキーをチェック（Android対応）
          if (event.logicalKey == LogicalKeyboardKey.f13 ||
              event.logicalKey == LogicalKeyboardKey.f1 ||
              event.logicalKey == LogicalKeyboardKey.insert ||
              event.physicalKey == PhysicalKeyboardKey.f13) {
            final now = DateTime.now();
            // 速度計算（カウント/分）
            if (_lastCountTime != null) {
              final timeDiff = now.difference(_lastCountTime!).inMilliseconds;
              if (timeDiff > 0) {
                _currentSpeed = 60000.0 / timeDiff; // 1分間あたりのカウント数
                // データを追加（最大60秒分保持）
                _speedData.add(MapEntry(now, _currentSpeed));

                // 60秒より古いデータを削除
                final cutoff = now.subtract(const Duration(seconds: 60));
                _speedData.removeWhere((entry) => entry.key.isBefore(cutoff));
              }
            }

            setState(() {
              _previousF13Count = _f13KeyCount;
              _f13KeyCount++;
              _lastCountTime = now;
            });

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
                                      containerForeColor: _containerForeColor,
                                    ),
                                    CrimpCondition(
                                      onValidationComplete:
                                          _onCrimpConditionValidationChanged,
                                    ),
                                    const SizedBox(width: 0), // 左右の間隔
                                  ],
                                ),
                              ),

                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    TerminalInfoCard(
                                      terminal1:
                                          widget.blockInfo['terminals']?[0] ??
                                          "",
                                      terminal2:
                                          widget.blockInfo['terminals']?[1] ??
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
                                    ),

                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              DialSelectorWithDb(
                                                processingConditions:
                                                    widget.processingConditions,
                                                blockInfo: widget.blockInfo,
                                                recommendedHindDial:
                                                    _recommendedHindDial,
                                                recommendedTopDial:
                                                    _recommendedTopDial,
                                                recommendedBottomDial:
                                                    _recommendedBottomDial,
                                                onDialChanged: _onDialChanged,
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
                                                  key: ValueKey(_initialMeasurements), // キーを追加して再構築を制御
                                                  chListData: widget.chListData,
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
                                                  initialMeasurements: _initialMeasurements,
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 25),
                                            AnimatedScale(
                                              scale: _isZooming ? 1.2 : 1.0,
                                              duration: const Duration(milliseconds: 500),
                                              curve: Curves.elasticOut,
                                              child: SizedBox(
                                                width: 180,
                                                height: 50,
                                                child: Card(
                                                  color: _getStatusCardColor(),
                                                  elevation: 4,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8.0,
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
              bottom: -40,
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
    );
  }

  Widget _buildAnimatedCounter() {
    final targetCount =
        int.tryParse(widget.processingConditions['wire_cnt'].toString()) ?? 0;
    final isCompleted = _f13KeyCount >= targetCount && targetCount > 0;
    final counterString = "$_f13KeyCount/$targetCount";
    return Stack(
      clipBehavior: Clip.none, // ❗ Containerの外にはみ出させたい場合必要
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.getCardColor(context),
            border: Border.all(
              color: AppColors.getLineColor(context),
              width: 0.5,
            ),
          ),
          child: ClipOval(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isCompleted) ...[
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
                    ElevatedButton(
                      onPressed: () {
                        // 完了処理をここに実装
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('作業完了しました！')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.getHighLightColor(
                          context,
                        ), // 背景色
                        elevation: 2, // 影の高さ
                        padding: EdgeInsets.zero, // SizedBoxでサイズ管理するので余白はゼロ
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // 角丸
                        ),
                      ),
                      child: SizedBox(
                        width: 78,
                        height: 78,
                        child: Center(
                          // ← これでTextが縦横中央
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
        ),
        if (isCompleted) ...[
          Positioned(
            bottom: -10,
            right: -20,
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // ✅ 右寄せ
              children: [
                Text(
                  counterString,
                  style: TextStyle(
                    color: AppColors.getHighLightColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      height: 210,
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
                        color: AppColors.getHighLightColor(context),
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
                top: 0,
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

    // 平均値を計算
    final averageSpeed =
        speedData.map((e) => e.value).reduce((a, b) => a + b) /
        speedData.length;

    // 平均値からの差分の最大値を計算（上下対称にするため）
    final maxDiff = speedData
        .map((e) => (e.value - averageSpeed).abs())
        .reduce((a, b) => a > b ? a : b);

    if (maxDiff == 0) {
      // 全て同じ値の場合は平均線のみ描画
      final averageLinePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        averageLinePaint,
      );
      return;
    }

    // 時間範囲を取得
    final now = DateTime.now();
    final startTime = now.subtract(const Duration(seconds: 60));

    // 平均線を描画（中央に水平線）
    final averageLinePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      averageLinePaint,
    );

    // 差分グラフのパスを作成
    final path = Path();
    final fillPathAbove = Path(); // 平均より上（速い）
    final fillPathBelow = Path(); // 平均より下（遅い）

    bool hasAbove = false;
    bool hasBelow = false;

    // すべての点の座標を事前に計算
    List<Offset> points = [];
    for (int i = 0; i < speedData.length; i++) {
      final entry = speedData[i];
      final timeProgress =
          entry.key.difference(startTime).inMilliseconds / 60000.0;
      final speedDiff = entry.value - averageSpeed;

      // 差分を-1.0〜1.0にノーマライズ（平均が0）
      final normalizedDiff = speedDiff / maxDiff;

      final x = timeProgress * size.width;
      final y = centerY - (normalizedDiff * size.height * 0.4); // ±40%の範囲で表示

      points.add(Offset(x, y));
    }

    // スムーズな曲線を作成
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        path.moveTo(points[i].dx, points[i].dy);
      } else {
        // ベジェ曲線で滑らかに接続
        final prev = points[i - 1];
        final current = points[i];

        if (i == 1) {
          // 最初の線分は直線
          path.lineTo(current.dx, current.dy);
        } else {
          // 制御点を計算してスムーズな曲線を作成
          final prevPrev = i >= 2 ? points[i - 2] : prev;
          final next = i < points.length - 1 ? points[i + 1] : current;

          // 制御点を前後の点を使って滑らかに計算
          final controlPoint1 = Offset(
            prev.dx + (current.dx - prevPrev.dx) * 0.05,
            prev.dy + (current.dy - prevPrev.dy) * 0.05,
          );
          final controlPoint2 = Offset(
            current.dx - (next.dx - prev.dx) * 0.05,
            current.dy - (next.dy - prev.dy) * 0.05,
          );

          path.cubicTo(
            controlPoint1.dx,
            controlPoint1.dy,
            controlPoint2.dx,
            controlPoint2.dy,
            current.dx,
            current.dy,
          );
        }
      }

      // 塗りつぶし用パスの処理
      final entry = speedData[i];
      final speedDiff = entry.value - averageSpeed;
      final x = points[i].dx;
      final y = points[i].dy;

      // 平均より上（速い）の塗りつぶし用パス
      if (speedDiff > 0) {
        if (!hasAbove) {
          fillPathAbove.moveTo(x, centerY);
          fillPathAbove.lineTo(x, y);
          hasAbove = true;
        } else {
          fillPathAbove.lineTo(x, y);
        }
      } else if (hasAbove) {
        fillPathAbove.lineTo(x, centerY);
        hasAbove = false;
      }

      // 平均より下（遅い）の塗りつぶし用パス
      if (speedDiff < 0) {
        if (!hasBelow) {
          fillPathBelow.moveTo(x, centerY);
          fillPathBelow.lineTo(x, y);
          hasBelow = true;
        } else {
          fillPathBelow.lineTo(x, y);
        }
      } else if (hasBelow) {
        fillPathBelow.lineTo(x, centerY);
        hasBelow = false;
      }
    }

    // パスを閉じる
    if (hasAbove && speedData.isNotEmpty) {
      final lastEntry = speedData.last;
      final lastTimeProgress =
          lastEntry.key.difference(startTime).inMilliseconds / 60000.0;
      final lastX = lastTimeProgress * size.width;
      fillPathAbove.lineTo(lastX, centerY);
      fillPathAbove.close();
    }

    if (hasBelow && speedData.isNotEmpty) {
      final lastEntry = speedData.last;
      final lastTimeProgress =
          lastEntry.key.difference(startTime).inMilliseconds / 60000.0;
      final lastX = lastTimeProgress * size.width;
      fillPathBelow.lineTo(lastX, centerY);
      fillPathBelow.close();
    }

    // 線を描画
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // 点は描画しない（スムーズな線のみ）
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
