import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preharness/constants/app_colors.dart';
import 'package:preharness/utils/global.dart';

class ProductInfoCard extends StatefulWidget {
  final Map<String, dynamic> processingConditions;
  final VoidCallback onBack;
  final Color? containerColor;
  final Color? containerForeColor;

  const ProductInfoCard({
    super.key,
    required this.processingConditions,
    required this.onBack,
    this.containerColor,
    this.containerForeColor,
  });

  @override
  State<ProductInfoCard> createState() => _ProductInfoCardState();
}

class _ProductInfoCardState extends State<ProductInfoCard> {
  final _micrometerFocusNode = FocusNode();
  final _micrometerController = TextEditingController();
  String _inputText = '';
  bool _justSearched = false;

  @override
  void initState() {
    super.initState();
    _micrometerFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _micrometerFocusNode.removeListener(() {});
    _micrometerFocusNode.dispose();
    _micrometerController.dispose();
    super.dispose();
  }

  void _handleQRInput() {
    // QR入力処理
    setState(() {
      _micrometerController.text = _inputText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 5,
              child: _buildLabelValue(
                '製品品番:',
                widget.processingConditions['p_number'],
                valueFont: 28,
              ),
            ),
            Expanded(
              flex: 3,
              child: _buildLabelValue(
                'ロットNo:',
                widget.processingConditions['lot_num'],
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
                widget.processingConditions['eng_change'],
              ),
            ),
            Expanded(
              flex: 3,
              child: _buildLabelValue(
                '構成No:',
                widget.processingConditions['cfg_no'],
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            _buildLabelValue('色:', widget.processingConditions['wire_color']),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: _buildLabelValue(
                '準完日:',
                widget.processingConditions['delivery_date'],
              ),
            ),
            Expanded(
              flex: 3,
              child: _buildLabelValue(
                '数量:',
                widget.processingConditions['wire_cnt'],
                valueFont: 30,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                try {
                  widget.onBack();
                } catch (e) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('戻る'),
            ),
          ],
        ),
        Divider(
          height: 10,
          thickness: 0.5,
          color: AppColors.getLineColor(context),
        ),
        KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (KeyEvent event) {
            if (_micrometerFocusNode.hasFocus) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.enter) {
                  _handleQRInput();
                  _micrometerFocusNode.unfocus();
                  return;
                }
                if (event.logicalKey == LogicalKeyboardKey.backspace) {
                  _justSearched = false;
                  if (_inputText.isNotEmpty) {
                    setState(() {
                      _inputText = _inputText.substring(
                        0,
                        _inputText.length - 1,
                      );
                      _micrometerController.text = _inputText;
                    });
                  }
                  return;
                }
                final char = event.character;
                if (char != null && char.isNotEmpty) {
                  if (_justSearched) {
                    setState(() {
                      _inputText = char;
                      _micrometerController.text = char;
                      _justSearched = false;
                    });
                  } else {
                    setState(() {
                      _inputText += char;
                      _micrometerController.text = _inputText;
                    });
                  }
                }
              }
            }
          },
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(_micrometerFocusNode);
                },
                child: Card(
                  color: AppColors.getCardColor(context),
                  elevation: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.getLineColor(context), // ボーダー色
                        width: .5, // ボーダーの太さ
                      ),
                      borderRadius: BorderRadius.circular(8), // Card に合わせて角丸
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // タイトル付き入力フィールド
                                Row(
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          TextField(
                                            focusNode: _micrometerFocusNode,
                                            showCursor: true,
                                            textAlign: TextAlign.right,
                                            keyboardType: TextInputType.none,
                                            onTap: () {
                                              // テキストフィールドタップ時に全選択
                                            },
                                            style: TextStyle(
                                              color: AppColors.getLineColor(
                                                context,
                                              ),
                                              fontSize: 14,
                                            ),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              filled: true,
                                              fillColor: AppColors.getCardColor(
                                                context,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 8,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AppColors.getLineColor(
                                                    context,
                                                  ),
                                                  width: 1.0,
                                                ),
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color:
                                                      AppColors.getHighLightColor(
                                                        context,
                                                      ),
                                                  width: 2.0,
                                                ),
                                              ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          AppColors.getLineColor(
                                                            context,
                                                          ),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          // フィールドタイトルを浮かせて表示
                                          Positioned(
                                            top: -16,
                                            left: -12,
                                            height: 13,
                                            child: Container(
                                              color: AppColors.getCardColor(
                                                context,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              child: Text(
                                                'マイクロメーター',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.getLineColor(
                                                    context,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.check_circle,
                                      color: AppColors.getHighLightColor(
                                        context,
                                      ),
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // ラベル＋値のRow
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: _buildLabelValue(
                                        '管理No:',
                                        "7116-4727",
                                        valueFont: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // 2つ目のCardのタップ処理（必要に応じて実装）
                },
                child: Card(
                  color: AppColors.getCardColor(context),
                  elevation: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.getLineColor(context), // ボーダー色
                        width: .5, // ボーダーの太さ
                      ),
                      borderRadius: BorderRadius.circular(8), // Card に合わせて角丸
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // タイトル付き入力フィールド
                                Row(
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          TextField(
                                            showCursor: true,
                                            textAlign: TextAlign.right,
                                            keyboardType: TextInputType.none,
                                            onTap: () {
                                              // テキストフィールドタップ時に全選択
                                            },
                                            style: TextStyle(
                                              color: AppColors.getLineColor(
                                                context,
                                              ),
                                              fontSize: 14,
                                            ),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              filled: true,
                                              fillColor: AppColors.getCardColor(
                                                context,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 8,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: AppColors.getLineColor(
                                                    context,
                                                  ),
                                                  width: 1.0,
                                                ),
                                              ),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color:
                                                      AppColors.getHighLightColor(
                                                        context,
                                                      ),
                                                  width: 2.0,
                                                ),
                                              ),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          AppColors.getLineColor(
                                                            context,
                                                          ),
                                                      width: 1.0,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                          // フィールドタイトルを浮かせて表示
                                          Positioned(
                                            top: -16,
                                            left: -12,
                                            height: 13,
                                            child: Container(
                                              color: AppColors.getCardColor(
                                                context,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              child: Text(
                                                'Applicator Serial',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.getLineColor(
                                                    context,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.check_circle,
                                      color: AppColors.getHighLightColor(
                                        context,
                                      ),
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // ラベル＋値のRow
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: _buildLabelValue(
                                        'アプリ品番:',
                                        "7116-4727",
                                        valueFont: 20,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: _buildLabelValue(
                                        '加締形状:',
                                        "2",
                                        valueFont: 20,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: _buildLabelValue(
                                        'シリアルNo:',
                                        "17150",
                                        valueFont: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                color: AppColors.getCardColor(context),
                elevation: 3,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.getLineColor(context), // ボーダー色
                      width: .5, // ボーダーの太さ
                    ),
                    borderRadius: BorderRadius.circular(8), // Card に合わせて角丸
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // タイトル付き入力フィールド
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          showCursor: true,
                                          textAlign: TextAlign.right,
                                          keyboardType: TextInputType.none,
                                          onTap: () {
                                            // テキストフィールドタップ時に全選択
                                          },
                                          style: TextStyle(
                                            color: AppColors.getLineColor(
                                              context,
                                            ),
                                            fontSize: 14,
                                          ),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            filled: true,
                                            fillColor: AppColors.getCardColor(
                                              context,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 8,
                                                ),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: AppColors.getLineColor(
                                                  context,
                                                ),
                                                width: 1.0,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    AppColors.getHighLightColor(
                                                      context,
                                                    ),
                                                width: 2.0,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: AppColors.getLineColor(
                                                  context,
                                                ),
                                                width: 1.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.check_circle,
                                        color: AppColors.getHighLightColor(
                                          context,
                                        ),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  // フィールドタイトルを浮かせて表示
                                  Positioned(
                                    top: -16,
                                    left: -12,
                                    height: 13,
                                    child: Container(
                                      color: AppColors.getCardColor(context),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Text(
                                        '端子リール',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.getLineColor(
                                            context,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // ラベル＋値のRow
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildLabelValue(
                                      '端子品番:',
                                      "7116-4727-02",
                                      valueFont: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildLabelValue(
                                      'ロットNo:',
                                      "P2J5E6",
                                      valueFont: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
      ],
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
                color: widget.containerColor ?? Colors.transparent,
                lineColor: widget.containerForeColor ?? Colors.transparent,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
