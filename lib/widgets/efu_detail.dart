import 'package:flutter/material.dart';
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

  void _onHindDialRecommendation(String recommendedDial) {
    setState(() {
      _recommendedHindDial = recommendedDial;
    });
  }

  void _onDialChanged(String top, String bottom, String hind) {
    setState(() {
      _currentHindDial = hind;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(
                      height: 1,
                      thickness: .5,
                      color: Colors.white,
                    ),
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
                                              icon: const Icon(
                                                Icons.arrow_back,
                                              ),
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
                                                style: TextStyle(fontSize: 20),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${widget.processingConditions['wire_type']} / ${widget.processingConditions['wire_size']}',
                                                style: TextStyle(fontSize: 20),
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
                                                style: TextStyle(fontSize: 20),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            Expanded(child: Text("")),
                                          ],
                                        ),
                                        Divider(
                                          height: 20,
                                          thickness: 0.5,
                                          color: AppColors.getLineColor(
                                            context,
                                          ),
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
                        Column(
                          children: [
                            Measurement(
                              chListData: widget.chListData,
                              onHindDialRecommendation:
                                  _onHindDialRecommendation,
                              currentHindDial: _currentHindDial,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    const Divider(height: 10, thickness: 1),
                  ],
                ),
              ],
            ),
          ],
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
