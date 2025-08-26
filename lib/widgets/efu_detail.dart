import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preharness/widgets/dial_selector_with_db.dart';
import 'package:preharness/widgets/measurement.dart';
import 'package:preharness/utils/global.dart';
import 'package:preharness/utils/color_utils.dart';
import 'package:preharness/constants/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    _loadColor(); // Call a method to load the color
  }

  Future<void> _loadColor() async {
    try {
      final String colorNum = widget.processingConditions['wire_color'] ?? '';
      if (colorNum.isEmpty) {
        print('wire_color is empty in efu_detail');
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
      print('Error in _loadColor (efu_detail): $e');
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
      autofocus: true,
      onKeyEvent: (node, event) {
        print(
          'Key event: ${event.runtimeType}, logicalKey: ${event.logicalKey}, physicalKey: ${event.physicalKey}',
        );

        if (event is KeyDownEvent) {
          // F13、F1、またはInsertキーをチェック（Android対応）
          if (event.logicalKey == LogicalKeyboardKey.f13 ||
              event.logicalKey == LogicalKeyboardKey.f1 ||
              event.logicalKey == LogicalKeyboardKey.insert ||
              event.physicalKey == PhysicalKeyboardKey.f13) {
            print('Target key detected: ${event.logicalKey}');
            if (!mounted) return KeyEventResult.ignored;

            print(
              'Before update: previous=$_previousF13Count, current=$_f13KeyCount',
            );
            setState(() {
              _previousF13Count = _f13KeyCount;
              _f13KeyCount++;
            });
            print(
              'After update: previous=$_previousF13Count, current=$_f13KeyCount',
            );

            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },

      child: Card(
        color: Colors.transparent,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, thickness: .5, color: Colors.white),
                  SizedBox(height: 10),
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
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: _buildLabelValue(
                                              '製品品番:',
                                              widget
                                                  .processingConditions['p_number'],
                                              valueFont: 28,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: _buildLabelValue(
                                              'ロットNo:',
                                              widget
                                                  .processingConditions['lot_num'],
                                              valueFont: 28,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: _buildLabelValue(
                                              '設変:',
                                              widget
                                                  .processingConditions['eng_change'],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: _buildLabelValue(
                                              '構成No:',
                                              widget
                                                  .processingConditions['cfg_no'],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          _buildLabelValue(
                                            '色:',
                                            widget
                                                .processingConditions['wire_color'],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: _buildLabelValue(
                                              '準完日:',
                                              widget
                                                  .processingConditions['delivery_date'],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: _buildLabelValue(
                                              '数量:',
                                              widget
                                                  .processingConditions['wire_cnt'],
                                              valueFont: 30,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              try {
                                                widget.onBack();
                                              } catch (e) {
                                                print('Error in onBack: $e');
                                                // エラーが発生した場合、Navigatorで直接戻る
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            icon: const Icon(Icons.arrow_back),
                                            label: const Text('戻る'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 0), // 左右の間隔

                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    children: [
                                      DialSelectorWithDb(
                                        processingConditions:
                                            widget.processingConditions,
                                        blockInfo: widget.blockInfo,
                                        recommendedHindDial:
                                            _recommendedHindDial,
                                        recommendedTopDial: _recommendedTopDial,
                                        recommendedBottomDial:
                                            _recommendedBottomDial,
                                        onDialChanged: _onDialChanged,
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              formatCode(
                                                widget
                                                    .blockInfo['terminals'][0],
                                                "-",
                                              ),
                                              style: TextStyle(
                                                color: AppColors.getLineColor(
                                                  context,
                                                ),
                                                fontSize: 20,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${widget.processingConditions['wire_type']} / ${widget.processingConditions['wire_size']}',
                                              style: TextStyle(
                                                color: AppColors.getLineColor(
                                                  context,
                                                ),
                                                fontSize: 20,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              formatCode(
                                                widget
                                                    .blockInfo['terminals'][1],
                                                "-",
                                              ),
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: AppColors.getLineColor(
                                                  context,
                                                ),
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                          Expanded(child: Text("")),
                                        ],
                                      ),
                                      Divider(
                                        height: 20,
                                        thickness: 0.5,
                                        color: AppColors.getLineColor(context),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            PageRouteBuilder(
                                              pageBuilder:
                                                  (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                  ) {
                                                    return _FullScreenImageView(
                                                      imagePath:
                                                          'assets/images/71144020-2.jpg',
                                                    );
                                                  },
                                              transitionsBuilder:
                                                  (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child,
                                                  ) {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: child,
                                                    );
                                                  },
                                            ),
                                          );
                                        },
                                        child: SizedBox(
                                          height: 250,
                                          child: InteractiveViewer(
                                            minScale: 0.5,
                                            maxScale: 3.0,
                                            child: Image.asset(
                                              'assets/images/71144020-2.jpg',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Stack(
                        children: [
                          Column(
                            children: [
                              Measurement(
                                chListData: widget.chListData,
                                onHindDialRecommendation:
                                    _onHindDialRecommendation,
                                onFrontDialRecommendation:
                                    _onFrontDialRecommendation,
                                currentHindDial: _currentHindDial,
                                currentTopDial: _currentTopDial,
                                currentBottomDial: _currentBottomDial,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(height: 20, thickness: 0.5, color: baseLineColor),
                ],
              ),
              Positioned(bottom: 10, right: 0, child: _buildAnimatedCounter()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelValue(
    String label,
    String value, {
    double labelFont = 11,
    double valueFont = 24,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: labelFont, height: 1.0)),
        Row(
          children: [
            Text(value, style: TextStyle(fontSize: valueFont, height: 1.0)),
            SizedBox(width: 2),
            if (label == '色:') ...[
              WireColorBox(
                width: 22,
                height: 22,
                color: _containerColor ?? Colors.transparent,
                lineColor: _containerForeColor ?? Colors.transparent,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedCounter() {
    final targetCount = widget.processingConditions['wire_cnt'];

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.getHighLightColor(context).withOpacity(0.1),
        border: Border.all(
          color: AppColors.getHighLightColor(context).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFlipCounter(),
              Divider(
                color: AppColors.getHighLightColor(context),
                thickness: 0.5,
                height: 10,
              ),
              Text(
                '$targetCount',
                style: TextStyle(
                  fontSize: 28,
                  height: 0.8,
                  letterSpacing: 3.0, // ← 文字の間隔を広げる
                  fontWeight: FontWeight.bold,
                  color: AppColors.getHighLightColor(context),
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

    print('Building digits: $previousStr -> $currentStr');

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

      print(
        'Position $i (right-$currentFromRight): prev="$previousDigit" -> cur="$currentDigit", changed: $hasChanged, isNew: $isNewDigit',
      );

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

class _FullScreenImageView extends StatelessWidget {
  final String imagePath;

  const _FullScreenImageView({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(child: Image.asset(imagePath, fit: BoxFit.contain)),
            ),
          ),
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Text(
              'タップして戻る / ピンチで拡大縮小',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
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
