import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import "package:preharness/constants/app_colors.dart";
import 'package:preharness/utils/global.dart';
import 'package:preharness/utils/color_utils.dart'; // getColorFromHive関数のため
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

int? safeSubstringToInt(String source, int start, int end) {
  if (source.length < end) return null; // 範囲外
  final part = source.substring(start, end);
  if (int.tryParse(part) != null) {
    return int.parse(part);
  }
  return null;
}

Map<String, dynamic> parseDateCode(String dateCode) {
  final year = safeSubstringToInt(dateCode, 0, 2);
  final month = safeSubstringToInt(dateCode, 2, 4);
  final day = safeSubstringToInt(dateCode, 4, 6);
  if (year == null || month == null || day == null) {
    throw ArgumentError("日付コードが不正です$dateCode");
  }
  final fullYear = 2000 + year;
  final date = DateTime(fullYear, month, day);
  return {"year": fullYear, "month": month, "day": day, "date": date};
}

String convertCode(String input) {
  if (input == "Z") {
    return "Y";
  } else if (input == "2") {
    return "YAC";
  }
  return input; // その他はそのまま返す
}

String mmToCm(String mm) {
  final value = int.tryParse(mm);
  if (value == null) return mm; // 数字じゃない場合はそのまま返す
  return (value / 10).toStringAsFixed(1);
}

List<String> buildFixedList(List<String?> values, {int length = 5}) {
  final list = <String>[];
  for (var v in values) {
    list.add(v ?? ""); // null は "" に変換して追加
  }
  while (list.length < length) {
    list.add("");
  }
  return list.take(length).toList();
}

class EfuPage extends StatefulWidget {
  final String lot_num;
  final String p_number;
  final String eng_change;
  final String cfg_no;
  final String subAssy;
  final String wire_type;
  final String wire_size;
  final String wire_color;
  final String wire_len;
  final String circuit_1;
  final String circuit_2;
  final String term_proc_inst_1;
  final String term_proc_inst_2;
  final String mark_color_1;
  final String mark_color_2;
  final String strip_len_1;
  final String strip_len_2;
  final String term_part_no_1;
  final String term_part_no_2;
  final String add_parts_1;
  final String add_parts_2;
  final String cut_code;
  final String wire_cnt;
  final String delivery_date;
  final Function(Map<String, dynamic>) onBlockTapped; // コールバックを追加

  const EfuPage({
    super.key,
    this.lot_num = "",
    this.p_number = "",
    this.eng_change = "",
    this.cfg_no = "",
    this.subAssy = "",
    this.wire_type = "",
    this.wire_size = "",
    this.wire_color = "",
    this.wire_len = "",
    this.circuit_1 = "",
    this.circuit_2 = "",
    this.term_proc_inst_1 = "",
    this.term_proc_inst_2 = "",
    this.mark_color_1 = "",
    this.mark_color_2 = "",
    this.strip_len_1 = "",
    this.strip_len_2 = "",
    this.term_part_no_1 = "",
    this.term_part_no_2 = "",
    this.add_parts_1 = "",
    this.add_parts_2 = "",
    this.cut_code = "",
    this.wire_cnt = "",
    this.delivery_date = "",
    required this.onBlockTapped, // コールバックを必須引数に
  });

  @override
  State<EfuPage> createState() => _EfuPageState();
}

class _EfuPageState extends State<EfuPage> {
  Color? _containerColor; // 背景色
  Color? _containerForeColor; // 線色

  @override
  void initState() {
    super.initState();
    _loadColor(); // efu_detail.dartと同じメソッド名
  }

  Future<void> _loadColor() async {
    try {
      final String colorNum = widget.wire_color;
      if (colorNum.isEmpty) {
        print('wire_color is empty in efu');
        if (mounted) {
          setState(() {
            _containerColor = Colors.white;
            _containerForeColor = Colors.black;
          });
        }
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
      print('Error in _loadColor (efu): $e');
      // エラー時はデフォルト色を設定
      if (mounted) {
        setState(() {
          _containerColor = Colors.white;
          _containerForeColor = Colors.black;
        });
      }
    }
  }

  String normalizeNumberString(String input) {
    if (input.isEmpty) return "0"; // 空文字は"0"

    final numValue = int.tryParse(input) ?? 0; // 数値に変換（失敗したら0）
    return numValue.toString(); // 文字列に戻す
  }

  @override
  Widget build(BuildContext context) {
    try {
      final deliveryParse = parseDateCode(widget.delivery_date);
      final deliveryParseMonth = deliveryParse["month"];
      final deliveryParseDay = deliveryParse["day"];

      final termProcInt1 = convertCode(widget.term_proc_inst_1);
      final termProcInt2 = convertCode(widget.term_proc_inst_2);

      final stripLen1 = mmToCm(widget.strip_len_1);
      final stripLen2 = mmToCm(widget.strip_len_2);

      final termPartNo1 = widget.term_part_no_1;
      final termPartNo2 = widget.term_part_no_2;

      final addParts1 = widget.add_parts_1;
      final addParts2 = widget.add_parts_2;

      final wireLen = normalizeNumberString(widget.wire_len);

      String markString1 = "";
      if (widget.mark_color_1 != "") {
        markString1 = "ﾏｼﾞｯｸ";
      }
      String markString2 = "";
      if (widget.mark_color_2 != "") {
        markString2 = "ﾏｼﾞｯｸ";
      }
      final blockList1_1 = buildFixedList([termProcInt1, "", markString1]);
      final blockList1_2 = buildFixedList([
        termPartNo1,
        addParts1,
        widget.mark_color_1,
      ]);
      final blockList2_1 = buildFixedList([termProcInt2, "", markString2]);
      final blockList2_2 = buildFixedList([
        termPartNo2,
        addParts2,
        widget.mark_color_2,
      ]);
      return LayoutBuilder(
        builder: (context, constraints) {
          // 高さ固定（例: 400）にしたい場合
          final double height = 400;
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
                color: isDark
                    ? AppColors.black
                    : AppColors.paperWhite, // ← ここで分岐
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
                                      labelFontSize: 20,
                                      valueHeight: 0,
                                      showBorder: false,
                                      value: "",
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: _buildCell(
                                      context: context,
                                      label: 'ロットNo.',
                                      cellBgColor: getLightColor(context),
                                      value: widget.lot_num,
                                      valueFontSize: 24,
                                      overFlowTop: -10,
                                      right: BorderSide.none,
                                      bottom: BorderSide.none,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: _buildCell(
                                      context: context,
                                      label: '構成No.',
                                      labelColor: Colors.white,
                                      labelBgColor: getDarkColor(context),
                                      value: widget.cfg_no,
                                      valueFontSize: 20,
                                      overFlowTop: -6,
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
                                      value: "",
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
                                      value:
                                          "${widget.p_number}    ${widget.eng_change}",
                                      valueFontSize: 16,
                                      bottom: BorderSide.none,
                                      right: BorderSide.none,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 8,
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
                                      value: widget.wire_type,
                                      valueFontSize: 18,
                                      overFlowTop: -2,
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
                                      value: widget.wire_size,
                                      valueFontSize: 18,
                                      overFlowTop: -2,
                                      bottom: BorderSide.none,
                                      left: BorderSide.none,
                                      right: BorderSide.none,
                                      lefthalfborder: true,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 8,
                                    child: _buildCell(
                                      context: context,
                                      label: '色',
                                      labelAlignment: Alignment.center,
                                      value: widget.wire_color,
                                      valueFontSize: 30,
                                      overFlowTop: -12,
                                      left: BorderSide.none,
                                      bottom: BorderSide.none,
                                      lefthalfborder: true,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: WireColorBox(
                                      width: 22,
                                      height: 22,
                                      color:
                                          _containerColor ?? Colors.transparent,
                                      lineColor:
                                          _containerForeColor ??
                                          Colors.transparent,
                                    ),
                                  ),

                                  Expanded(
                                    flex: 7,
                                    child: _buildCell(
                                      context: context,
                                      label: '切 断 線 長',
                                      labelAlignment: Alignment.center,
                                      value: wireLen,
                                      valueFontSize: 22,
                                      overFlowTop: -6,
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
                                      value: widget.wire_cnt,
                                      valueFontSize: 24,
                                      valueAlignment: MainAxisAlignment.end,
                                      overFlowTop: -10,
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
                                      strip: stripLen1,
                                      directives: blockList1_1,
                                      terminals: blockList1_2,
                                      context: context,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: _buildOneBlock(
                                      strip: stripLen2,
                                      directives: blockList2_1,
                                      terminals: blockList2_2,
                                      context: context,
                                    ),
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
                                      value: widget.cut_code,
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
                                      value:
                                          "$deliveryParseMonth/$deliveryParseDay",
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
    } catch (e) {
      print('Error in build method: $e');
      return Container(
        color: Colors.red,
        child: Center(
          child: Text(
            'Build Error: $e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
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
    required BuildContext context, // ← 追加（SnackBar用に必要）
  }) {
    assert(terminals.length == 5 && directives.length == 5); // 安全チェック

    bool targetFlag = directives[0] == "Y";
    BorderSide highLightLine = BorderSide(
      color: AppColors.getHighLightColor(context),
      width: 2,
    );
    BorderSide baseLine = BorderSide(color: getLineColor(context), width: 1);
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
              top: targetFlag ? highLightLine : baseLine,
              right: BorderSide.none,
              bottom: BorderSide.none,
              left: targetFlag ? highLightLine : baseLine,
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
              top: targetFlag ? highLightLine : baseLine,
              right: BorderSide.none,
              bottom: BorderSide.none,
              left: BorderSide(color: getLineColor(context), width: 0.5),
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
              top: targetFlag ? highLightLine : baseLine,
              right: BorderSide.none,
              bottom: BorderSide.none,
              left: BorderSide(color: getLineColor(context), width: 0.5),
              horizontal: true,
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildCell(
              context: context,
              label: '穴位置',
              value: null,
              top: targetFlag ? highLightLine : baseLine,
              right: BorderSide.none,
              bottom: BorderSide.none,
              left: BorderSide(color: getLineColor(context), width: 0.5),
              horizontal: true,
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildCell(
              context: context,
              label: '',
              value: null,
              top: targetFlag ? highLightLine : baseLine,
              right: targetFlag ? highLightLine : baseLine,
              bottom: BorderSide.none,
              left: BorderSide(color: getLineColor(context), width: 0.5),
              horizontal: true,
            ),
          ),
        ],
      ),
    );

    // 2〜6行目：データ行（1〜5回）
    for (int i = 0; i < 4; i++) {
      rows.add(
        Row(
          children: [
            Expanded(
              flex: 4,
              child: _buildCell(
                context: context,
                label: null,
                value: "",
                valueHeight: 35.5,
                top: BorderSide(color: getLineColor(context), width: 0.5),
                right: BorderSide.none,
                bottom: (i == 3 && targetFlag == true)
                    ? highLightLine
                    : BorderSide.none,
                left: targetFlag ? highLightLine : baseLine,
                horizontal: true,
              ),
            ),
            Expanded(
              flex: 4,
              child: _buildCell(
                context: context,
                label: null,
                value: directives[i],
                valueHeight: 35.5,
                valueFontSize: 22,
                overFlowTop: 3,
                top: BorderSide(color: getLineColor(context), width: 0.5),
                bottom: (i == 3 && targetFlag == true)
                    ? highLightLine
                    : BorderSide.none,
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
                valueHeight: 35.5,
                valueFontSize: 22,
                overFlowTop: 3,
                top: BorderSide(color: getLineColor(context), width: 0.5),
                right: targetFlag ? highLightLine : baseLine,
                bottom: (i == 3 && targetFlag == true)
                    ? highLightLine
                    : BorderSide.none,
                left: BorderSide(color: getLineColor(context), width: 0.5),
                horizontal: true,
                useFormatCode: true,
              ),
            ),
          ],
        ),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click, // ← マウスオーバーでポインターに
      child: GestureDetector(
        onTap: () {
          // `terminals` リストの全ての要素が空文字列かチェック
          if (terminals.every((t) => t.trim().isEmpty)) {
            // 空の場合、SnackBarを表示
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('データがありません'),
                duration: Duration(seconds: 1),
              ),
            );
          } else {
            // 情報がある場合、blockInfoを作成してコールバックを呼び出す
            final blockInfo = {
              'strip': strip,
              'directives': directives,
              'terminals': terminals,
            };
            // コールバックを呼び出して親ウィジェットに通知
            widget.onBlockTapped(blockInfo);
          }
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
    double valueHeight = 20,
    bool useFormatCode = false,
  }) {
    final Color effectiveLabelColor = labelColor ?? getLabelColor(context);
    final Color effectiveValueColor = valueColor ?? getValueColor(context);
    // felt-pen
    Color? feltColor = Colors.transparent;
    bool showFelt = false;
    if (value != null && value.startsWith("ﾏｼﾞｯｸ_")) {
      showFelt = true;
      value = value.replaceFirst("ﾏｼﾞｯｸ_", "");
      if (value.contains("30")) {
        feltColor = AppColors.black;
      } else if (value.contains("50")) {
        feltColor = AppColors.red;
      } else if (value.contains("60")) {
        feltColor = AppColors.deepGreen;
      }
    }
    if (useFormatCode) {
      value = formatCode(value.toString(), "-");
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
            height: horizontal ? valueHeight : null, // horizontalの場合は固定高さ
            alignment: labelAlignment,
            color: labelBgColor,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            child: Text(
              label,
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
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: valueHeight, // ← 親の高さを固定
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

                    if (feltColor != Colors.transparent)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/tearDrop.svg',
                            width: 28, // 少し大きめに
                            height: 28,
                            colorFilter: ColorFilter.mode(
                              AppColors.getLineColor(context),
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
                    if (feltColor == Colors.transparent && showFelt)
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
        : Container(
            width: double.infinity, // 横幅を持たせる
            height: valueHeight, // 高さを確保
            color: Colors.transparent, // 透明だけど存在する
          );

    return Container(
      decoration: BoxDecoration(color: cellBgColor, border: borderDecoration),
      constraints: BoxConstraints(minHeight: horizontal == true ? 20 : 38),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      clipBehavior: Clip.none, // ← ここが重要！！
      child: horizontal
          ? Row(
              children: [
                if (labelWidget != null) Expanded(child: labelWidget),
                if (value != null) Expanded(child: valueWidget),
              ],
            )
          : Column(
              children: [
                if (labelWidget != null) ...[labelWidget],
                ...[valueWidget],
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
