import 'package:flutter/material.dart';
import 'package:preharness/widgets/dial_selector_with_db.dart';
import 'package:preharness/widgets/measurement.dart';
import 'package:preharness/utils/global.dart';
import 'package:preharness/utils/color_utils.dart'; // Added

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

  @override
  void initState() {
    super.initState();
    _loadColor(); // Call a method to load the color
  }

  Future<void> _loadColor() async {
    final String colorNum = widget.processingConditions['wire_color'];
    final Color? loadedBackColor = await getColorFromHive(colorNum);
    final Color? loadedForeColor = await getColorFromHive(
      colorNum,
      getForeColor: true,
    );
    if (mounted) {
      setState(() {
        _containerColor =
            loadedBackColor; // Assign backColor to _containerColor
        _containerForeColor =
            loadedForeColor; // Assign foreColor to _containerForeColor
      });
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
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '■ 加工条件詳細',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('戻る'),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 20, thickness: 1),
                      // Rowで左右に分割
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 左側: 情報グループ
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _buildLabelValue(
                                      '製品品番:',
                                      widget.processingConditions['p_number'],
                                      valueFont: 28,
                                    ),
                                    _buildLabelValue(
                                      'ロットNo:',
                                      widget.processingConditions['lot_num'],
                                      valueFont: 28,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    _buildLabelValue(
                                      '設変:',
                                      widget.processingConditions['eng_change'],
                                    ),
                                    _buildLabelValue(
                                      '構成No:',
                                      widget.processingConditions['cfg_no'],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    _buildLabelValue(
                                      '色:',
                                      widget.processingConditions['wire_color'],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    _buildLabelValue(
                                      '準完日:',
                                      widget
                                          .processingConditions['delivery_date'],
                                    ),
                                    _buildLabelValue(
                                      '数量:',
                                      widget.processingConditions['wire_cnt'],
                                      valueFont: 30,
                                    ),
                                  ],
                                ),
                                Row(children: [
                               
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 0), // 左右の間隔
                          // 右側: DialSelectorWithDb
                          Expanded(
                            child: DialSelectorWithDb(
                              processingConditions: widget.processingConditions,
                              blockInfo: widget.blockInfo,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 20, thickness: 1),
                      const Text(
                        'ブロック詳細:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '端子部品番号: ${formatCode(widget.blockInfo['terminals'][0], "-")}',
                      ),
                      Text(
                        '付加部品: ${formatCode(widget.blockInfo['terminals'][1], "-")}',
                      ),
                      const Divider(height: 20, thickness: 1),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    Text(
                      formatCode(widget.blockInfo['terminals'][0], "-"),
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      '${widget.processingConditions['wire_type']} / ${widget.processingConditions['wire_size']}',
                      style: TextStyle(fontSize: 20),
                    ),
                    Measurement(chListData: widget.chListData),
                  ],
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            const Text(
              'CH List Data:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (widget.isLoadingChList)
              const CircularProgressIndicator()
            else if (widget.chListError != null)
              Text('Error: ${widget.chListError}')
            else if (widget.chListData != null && widget.chListData!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.chListData!
                    .map(
                      (item) => Text(item.toString()),
                    ) // Adjust display as needed
                    .toList(),
              )
            else
              const Text('No CH list data found.'),
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
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: labelFont, height: 1.0)),
          Row(
            children: [
              Text(value, style: TextStyle(fontSize: valueFont, height: 1.0)),
              SizedBox(width: 2),
              if (label == '色:') ...[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // 背景色
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _containerColor ?? Colors.red,
                        border: Border.all(color: Colors.white, width: 0.5),
                      ),
                    ),
                    // 斜め線を描画
                    ClipRect(
                      child: CustomPaint(
                        size: const Size(22, 22),
                        painter: DiagonalLinePainter(
                          lineColor: _containerForeColor ?? Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class DiagonalLinePainter extends CustomPainter {
  final Color lineColor;

  DiagonalLinePainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // 左上から右下に線を引く
    canvas.drawLine(
      Offset(size.width, 0), // 右上
      Offset(0, size.height), // 左下
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
