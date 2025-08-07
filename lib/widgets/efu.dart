import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "package:preharness/constants/app_colors.dart";
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async'; // ← これを追加

Color getLineColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Colors.grey : AppColors.green;
}

Color getLabelColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Colors.grey : AppColors.green;
}

Color getValueColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.paperWhite : AppColors.black;
}

Color getLightColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.paperBlack : AppColors.lightGreen;
}

Color getDarkColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.darkGreen : AppColors.deepGreen;
}

Color getHighLightColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.neonGreen : AppColors.red;
}

class InstructionSheetHeader extends StatelessWidget {
  final String lotNo;
  final String structureNo;
  final String subAssy;

  const InstructionSheetHeader({
    super.key,
    required this.lotNo,
    required this.structureNo,
    required this.subAssy,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 高さ固定（例: 400）にしたい場合
        final double height = 350;
        // 例えば アスペクト比 3:2（幅 = 高さ × 1.5）
        final double aspectRatio = 2.1;
        final double width = height * aspectRatio;

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Center(
          // 中央揃え（任意）
          child: SizedBox(
            height: height,
            width: width,
            child: Container(
              color: isDark ? AppColors.black : AppColors.paperWhite, // ← ここで分岐
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // グリッド部
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: _buildCell(
                                    context: context,
                                    label: '製造指示書',
                                    showBorder: false,
                                    labelFontSize: 20,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: _buildCell(
                                    context: context,
                                    label: 'ロットNo.',
                                    cellBgColor: getLightColor(context),
                                    value: lotNo,
                                    right: BorderSide.none,
                                    bottom: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _buildCell(
                                    context: context,
                                    label: '構 成 No.',
                                    labelColor: Colors.white,
                                    labelBgColor: getDarkColor(context),
                                    labelAlignment: Alignment.center,
                                    value: structureNo,
                                    valueBgColor: getLightColor(context),
                                    right: BorderSide.none,
                                    bottom: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: _buildCell(
                                    context: context,
                                    label: '追 番',
                                    labelAlignment: Alignment.center,
                                    value: "",
                                    right: BorderSide.none,
                                    bottom: BorderSide.none,
                                  ),
                                ),
                                // 日連番
                                Expanded(
                                  flex: 1,
                                  child: _buildCell(
                                    context: context,
                                    label: '日 連 番',
                                    labelAlignment: Alignment.center,
                                    value: "17807",
                                    valueFontSize: 14,
                                    overFlowTop: 0,
                                    right: BorderSide.none,
                                    bottom: BorderSide.none,
                                  ),
                                ),
                                // 全量
                                Expanded(
                                  flex: 1,
                                  child: _buildCell(
                                    context: context,
                                    label: '全 量',
                                    labelAlignment: Alignment.center,
                                    value: "",
                                    bottom: BorderSide.none,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // 空きセル
                                Expanded(
                                  flex: 4,
                                  child: _buildCell(
                                    context: context,
                                    label: '',
                                    value: "",
                                    showBorder: false,
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: _buildCell(
                                    context: context,
                                    label: '製 品 品 番',
                                    value: '8211126L04    D01',
                                    bottom: BorderSide.none,
                                    right: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: _buildCell(
                                    context: context,
                                    label: 'ジョイントアッシー',
                                    labelAlignment: Alignment.center,
                                    value: '',
                                    bottom: BorderSide.none,
                                    right: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: _buildCell(
                                    context: context,
                                    label: 'サブアッシー',
                                    labelAlignment: Alignment.center,
                                    value: '',
                                    bottom: BorderSide.none,
                                    right: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: _buildCell(
                                    context: context,
                                    label: '切断機種号機',
                                    labelAlignment: Alignment.center,
                                    value: '',
                                    bottom: BorderSide.none,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // 空きセル
                                Expanded(
                                  flex: 4,
                                  child: _buildCell(
                                    context: context,
                                    label: '',
                                    value: "",
                                    showBorder: false,
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: _buildCell(
                                    context: context,
                                    label: '品 種',
                                    labelAlignment: Alignment.center,
                                    value: '184',
                                    bottom: BorderSide.none,
                                    right: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: _buildCell(
                                    context: context,
                                    label: 'サイズ',
                                    labelAlignment: Alignment.center,
                                    value: '039',
                                    bottom: BorderSide.none,
                                    left: BorderSide.none,
                                    right: BorderSide.none,
                                    lefthalfborder: true,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: _buildCell(
                                    context: context,
                                    label: '色',
                                    labelAlignment: Alignment.center,
                                    value: '91',
                                    valueFontSize: 30,
                                    overFlowTop: -12,
                                    left: BorderSide.none,
                                    bottom: BorderSide.none,
                                    lefthalfborder: true,
                                    right: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: _buildCell(
                                    context: context,
                                    label: '切 断 線 長',
                                    labelAlignment: Alignment.center,
                                    value: '325',
                                    bottom: BorderSide.none,
                                    right: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: _buildCell(
                                    context: context,
                                    label: '数 量',
                                    labelAlignment: Alignment.center,
                                    value: '1',
                                    valueFontSize: 24,
                                    valueAlignment: MainAxisAlignment.end,
                                    overFlowTop: -10,
                                    bottom: BorderSide.none,
                                    right: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 12,
                                  child: _buildCell(
                                    context: context,
                                    label: ' ',
                                    labelAlignment: Alignment.center,
                                    value: "302  152",
                                    valueColor: Colors.grey,
                                    bottom: BorderSide.none,
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: _buildOneBlock(
                                    strip: "4.5",
                                    directives: ["Y", "", "", "", ""],
                                    terminals: ["7116 2891 02", "", "", "", ""],
                                    tubeinfo: ["", "", "", ""],
                                    context: context,
                                  ), // ← 1セット目
                                ),
                                Expanded(
                                  flex: 4,
                                  child: _buildOneBlock(
                                    strip: "4.5",
                                    directives: ["YAC", "ﾏｼﾞｯｸ", "", "", ""],
                                    terminals: [
                                      "7116 4231 02",
                                      "7406 5000",
                                      "7406 3000",
                                      "7406 3001",
                                      "",
                                    ],
                                    tubeinfo: ["500", "100", "209", "325"],
                                    context: context,
                                  ), // ← 1セット目
                                ),
                                Expanded(flex: 3, child: _buildQr(context)),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildCell(
                                    context: context,
                                    label: '工程',
                                    labelFontSize: 12,
                                    value: '',
                                    right: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: _buildCell(
                                    context: context,
                                    label: '切断',
                                    labelFontSize: 12,
                                    value: '',
                                    right: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: _buildCell(
                                    context: context,
                                    label: '集中',
                                    labelFontSize: 12,
                                    value: '',
                                    cellBgColor: getLightColor(context),
                                    right: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: _buildCell(
                                    context: context,
                                    label: '前1',
                                    labelFontSize: 12,
                                    value: '',
                                    right: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: _buildCell(
                                    context: context,
                                    label: '前2',
                                    labelFontSize: 12,
                                    value: '',
                                    cellBgColor: getLightColor(context),
                                    right: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: _buildCell(
                                    context: context,
                                    label: 'ジョイント',
                                    labelFontSize: 12,
                                    value: "",
                                    right: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: _buildCell(
                                    context: context,
                                    label: '準完',
                                    labelFontSize: 12,
                                    value: "12/9",
                                    cellBgColor: getLightColor(context),
                                    right: BorderSide.none,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _buildCell(
                                    context: context,
                                    label: '組立',
                                    labelFontSize: 12,
                                    value: "N9",
                                  ),
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
          ),
        );
      },
    );
  }

  Widget _buildQr(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCell(
                context: context,
                label: '準 完 日',
                value: null,
                bottom: BorderSide.none,
                lefthalfborder: true,
                horizontal: true,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 145,
                child: _buildCell(
                  context: context,
                  label: null,
                  value: " ",
                  top: BorderSide(color: getLineColor(context), width: 0.5),
                  bottom: BorderSide.none,
                  horizontal: true,
                  showQR: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOneBlock({
    String strip = "",
    required List<String> terminals, // terminal1~5
    required List<String> directives, // directives1~5
    required List<String> tubeinfo,
    required BuildContext context, // ← 追加（SnackBar用に必要）
  }) {
    assert(terminals.length == 5 && directives.length == 5); // 安全チェック
    // ヘッダー行を追加
    List<Widget> rows = [];

    rows.add(
      Row(
        children: [
          Expanded(
            flex: 4,
            child: _buildCell(
              context: context,
              label: '同時共有',
              value: null,
              bottom: BorderSide.none,
              right: BorderSide.none,
              lefthalfborder: true,
              horizontal: true,
            ),
          ),
          Expanded(
            flex: 4,
            child: _buildCell(
              context: context,
              label: '皮',
              value: strip,
              bottom: BorderSide.none,
              left: BorderSide(color: getLineColor(context), width: 0.5),
              right: BorderSide.none,
              lefthalfborder: true,
              horizontal: true,
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildCell(
              context: context,
              label: '作',
              cellBgColor: getLightColor(context),
              value: null,
              left: BorderSide(color: getLineColor(context), width: 0.5),
              right: BorderSide.none,
              bottom: BorderSide.none,
              horizontal: true,
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildCell(
              context: context,
              label: '穴位置',
              value: null,
              left: BorderSide(color: getLineColor(context), width: 0.5),
              bottom: BorderSide.none,
              right: BorderSide.none,
              horizontal: true,
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildCell(
              context: context,
              label: '',
              value: null,
              left: BorderSide(color: getLineColor(context), width: 0.5),
              bottom: BorderSide.none,
              right: BorderSide.none,
              horizontal: true,
            ),
          ),
        ],
      ),
    );

    // 2〜6行目：データ行（1〜5回）
    for (int i = 0; i < 5; i++) {
      rows.add(
        Row(
          children: [
            Expanded(
              flex: 4,
              child: _buildCell(
                context: context,
                label: null,
                value: "",
                top: BorderSide(color: getLineColor(context), width: 0.5),
                bottom: BorderSide.none,
                right: BorderSide.none,
                horizontal: true,
              ),
            ),
            Expanded(
              flex: 4,
              child: _buildCell(
                context: context,
                label: null,
                value: directives[i],
                top: BorderSide(color: getLineColor(context), width: 0.5),
                bottom: BorderSide.none,
                left: BorderSide(color: getLineColor(context), width: 0.5),
                right: BorderSide.none,
                horizontal: true,
              ),
            ),
            Expanded(
              flex: 9,
              child: _buildCell(
                context: context,
                label: null,
                value: terminals[i],
                top: BorderSide(color: getLineColor(context), width: 0.5),
                left: BorderSide(color: getLineColor(context), width: 0.5),
                right: BorderSide.none,
                bottom: BorderSide.none,
                horizontal: true,
              ),
            ),
          ],
        ),
      );
    }
    // チューブ
    bool isBlinking = tubeinfo[0].isNotEmpty;
    rows.add(
      Row(
        children: [
          Expanded(
            flex: 4,
            child: _buildCell(
              context: context,
              label: "チューブ",
              value: null,
              top: BorderSide(color: getLineColor(context), width: 0.5),
              bottom: BorderSide.none,
              right: BorderSide.none,
              horizontal: true,
            ),
          ),
          Expanded(
            flex: 4,
            child: _buildCell(
              context: context,
              label: null,
              value: tubeinfo[0],
              top: BorderSide(color: getLineColor(context), width: 0.5),
              bottom: BorderSide.none,
              left: BorderSide(color: getLineColor(context), width: 0.5),
              right: BorderSide.none,
              horizontal: true,
              blinking: isBlinking,
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildCell(
              context: context,
              label: null,
              value: tubeinfo[1],
              top: BorderSide(color: getLineColor(context), width: 0.5),
              left: BorderSide.none,
              right: BorderSide.none,
              bottom: BorderSide.none,
              horizontal: true,
              lefthalfborder: true,
              blinking: isBlinking,
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildCell(
              context: context,
              label: null,
              value: tubeinfo[2],
              top: BorderSide(color: getLineColor(context), width: 0.5),
              left: BorderSide.none,
              right: BorderSide.none,
              bottom: BorderSide.none,
              horizontal: true,
              lefthalfborder: true,
              blinking: isBlinking,
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildCell(
              context: context,
              label: null,
              value: tubeinfo[3],
              top: BorderSide(color: getLineColor(context), width: 0.5),
              left: BorderSide.none,
              right: BorderSide.none,
              bottom: BorderSide.none,
              horizontal: true,
              lefthalfborder: true,
              blinking: isBlinking,
            ),
          ),
        ],
      ),
    );
    // チューブ長さ
    rows.add(
      Row(
        children: [
          Expanded(
            flex: 6,
            child: _buildCell(
              context: context,
              label: "長さ",
              value: null,
              top: BorderSide(color: getLineColor(context), width: 0.5),
              bottom: BorderSide.none,
              right: BorderSide.none,
              horizontal: true,
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildCell(
              context: context,
              label: null,
              value: "",
              top: BorderSide(color: getLineColor(context), width: 0.5),
              left: BorderSide.none,
              right: BorderSide.none,
              bottom: BorderSide.none,
              horizontal: true,
              lefthalfborder: true,
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildCell(
              context: context,
              label: null,
              value: "",
              top: BorderSide(color: getLineColor(context), width: 0.5),
              left: BorderSide.none,
              right: BorderSide.none,
              bottom: BorderSide.none,
              horizontal: true,
              lefthalfborder: true,
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildCell(
              context: context,
              label: null,
              value: "",
              top: BorderSide(color: getLineColor(context), width: 0.5),
              left: BorderSide.none,
              right: BorderSide.none,
              bottom: BorderSide.none,
              horizontal: true,
              lefthalfborder: true,
            ),
          ),
        ],
      ),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click, // ← マウスオーバーでポインターに
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('ブロックがクリックされました')));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        ),
      ),
    );
  }

  Widget _buildCell({
    required BuildContext context,
    String? label,
    String? value,
    bool showBorder = true,
    BorderSide? top,
    BorderSide? right,
    BorderSide? bottom,
    BorderSide? left,
    Alignment labelAlignment = Alignment.centerLeft,
    double labelFontSize = 12,
    Color labelBgColor = Colors.transparent,
    Color? labelColor,
    MainAxisAlignment valueAlignment = MainAxisAlignment.center,
    double valueFontSize = 15,
    Color valueBgColor = Colors.transparent,
    Color? valueColor,
    Color? cellBgColor,
    bool horizontal = false,
    bool lefthalfborder = false,
    double overFlowTop = 0,
    bool showQR = false,
    bool blinking = false, // ← 新しく追加
  }) {
    final Color effectiveLabelColor = labelColor ?? getLabelColor(context);
    final Color effectiveValueColor = valueColor ?? getValueColor(context);
    // felt-pen
    Color? feltColor;
    bool showFelt = false;
    if (value != null && value.startsWith("7406")) {
      showFelt = true;
      if (value.contains("3000")) {
        feltColor = AppColors.black;
      } else if (value.contains("5000")) {
        feltColor = AppColors.red;
      }
    }

    final borderDecoration = showBorder
        ? Border(
            top: top ?? BorderSide(color: getLineColor(context), width: 1),
            right: right ?? BorderSide(color: getLineColor(context), width: 1),
            bottom:
                bottom ?? BorderSide(color: getLineColor(context), width: 1),
            left: left ?? BorderSide(color: getLineColor(context), width: 1),
          )
        : null;
    // ラベル用
    final labelWidget = label != null
        ? Container(
            width: double.infinity,
            alignment: labelAlignment,
            color: labelBgColor,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: labelFontSize,
                color: effectiveLabelColor,
              ),
            ),
          )
        : (null);
    // 値用
    final valueWidget = value != null
        ? Stack(
            clipBehavior: Clip.none, // ← これが重要！
            children: [
              if (blinking)
                _BlinkWrapper(
                  child: Container(
                    width: double.infinity,
                    height: 20, // ← 親の高さを固定
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    decoration: BoxDecoration(
                      color: getHighLightColor(context),
                      border: Border.all(
                        color: getHighLightColor(context),
                        width: 1,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 20, // ← 親の高さを固定
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(color: valueBgColor),
                ),
              // Text を Positioned にすればはみ出し表示できる
              Positioned(
                top: overFlowTop, // ここで位置を調整（htmlの top:-4px 相当）
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: valueAlignment, // ここは調整可
                  children: [
                    Text(
                      value,
                      textAlign: TextAlign.center,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontSize: valueFontSize,
                        color: effectiveValueColor,
                        fontFamily: "Inter",
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (feltColor != null)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/tearDrop.svg',
                            width: 28, // 少し大きめに
                            height: 28,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/images/tearDrop.svg',
                            width: 26,
                            height: 26,
                            colorFilter: ColorFilter.mode(
                              feltColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    if (feltColor == null && showFelt)
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            colors: [
                              Colors.red,
                              Colors.red,
                              Colors.blue,
                              Colors.yellow,
                              Colors.deepPurple,
                              Colors.green,
                              Colors.orange,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcIn,
                        child: SvgPicture.asset(
                          'assets/images/tearDrop.svg',
                          width: 28,
                          height: 28,
                        ),
                      ),
                  ],
                ),
              ),
              if (showQR)
                SizedBox(
                  child: Align(
                    alignment: Alignment.center,
                    child: QrImageView(
                      data:
                          "N712/5M392009917807001868211126L04D011N712/94.54.5325184039",
                      version: QrVersions.auto,
                      size: 100,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              // leftborder
              if (!horizontal && lefthalfborder)
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    width: 0.5,
                    height: 16, // 例: minHeight 46 の 50%
                    color: getLineColor(context),
                  ),
                ),
              if (horizontal && lefthalfborder)
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    width: 0.5,
                    height: 10, // 例: minHeight 46 の 50%
                    color: getLineColor(context),
                  ),
                ),
            ],
          )
        : null;

    return Container(
      decoration: BoxDecoration(color: cellBgColor, border: borderDecoration),
      constraints: BoxConstraints(minHeight: horizontal == true ? 20 : 38),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      clipBehavior: Clip.none, // ← ここが重要！！
      child: horizontal
          ? Row(
              children: [
                if (labelWidget != null) Expanded(child: labelWidget),
                if (valueWidget != null) Expanded(child: valueWidget),
              ],
            )
          : Column(
              children: [
                if (labelWidget != null) ...[labelWidget],
                if (valueWidget != null) ...[valueWidget],
              ],
            ),
    );
  }
}

// 点滅用
class _BlinkWrapper extends StatefulWidget {
  final Widget child;
  const _BlinkWrapper({required this.child});

  @override
  State<_BlinkWrapper> createState() => _BlinkWrapperState();
}

class _BlinkWrapperState extends State<_BlinkWrapper> {
  double _opacity = 1.0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    // タイマーでゆっくり点滅（高頻度アニメーションを避ける）
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      setState(() {
        _opacity = _opacity == 1.0 ? 0.3 : 1.0;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 600),
      child: SizedBox(
        width: double.infinity,
        height: 20, // 明示的に高さを指定しておく
        child: widget.child,
      ),
    );
  }
}
