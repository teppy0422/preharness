import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:preharness/core/constants/app_colors.dart';
import 'package:preharness/core/utils/color_utils.dart';
import 'package:preharness/core/utils/global.dart';
import 'package:preharness/core/utils/shared_prefs_helper.dart';
import 'package:preharness/shared/ui/pattern_button.dart';
import 'package:preharness/widgets/info/info_icon_button.dart';

class EfuShieldPage extends StatefulWidget {
  final List<Map<String, dynamic>> shieldConditions;
  final String? quantity;
  final Function(Map<String, dynamic>)? onBlockTapped;

  const EfuShieldPage({
    super.key,
    required this.shieldConditions,
    this.quantity,
    this.onBlockTapped,
  });

  @override
  State<EfuShieldPage> createState() => _EfuShieldPageState();
}

class _EfuShieldPageState extends State<EfuShieldPage> {
  String _terminalName = '';
  String _efuWireType = '';
  String _measuredTerminal0 = '';
  String _measuredTerminal1 = '';
  String _measuredWireType = '';
  String _measuredWireSize = '';
  String _measuredAddParts1 = '';
  String _measuredAddParts2 = '';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final terminalName =
        await SharedPrefsHelper.getString('terminal_name') ?? '';
    final efuWireType =
        await SharedPrefsHelper.getString('efu_wire_type') ?? '';
    final measuredTerminal0 =
        await SharedPrefsHelper.getString('measured_block_terminals_0') ?? '';
    final measuredTerminal1 =
        await SharedPrefsHelper.getString('measured_block_terminals_1') ?? '';
    final measuredWireType =
        await SharedPrefsHelper.getString('measured_efu_wire_type') ?? '';
    final measuredWireSize =
        await SharedPrefsHelper.getString('measured_efu_wire_size') ?? '';
    final measuredAddParts1 =
        await SharedPrefsHelper.getString('measured_efu_add_parts_1') ?? '';
    final measuredAddParts2 =
        await SharedPrefsHelper.getString('measured_efu_add_parts_2') ?? '';

    if (mounted) {
      setState(() {
        _terminalName = terminalName;
        _efuWireType = efuWireType;
        _measuredTerminal0 = measuredTerminal0;
        _measuredTerminal1 = measuredTerminal1;
        _measuredWireType = measuredWireType;
        _measuredWireSize = measuredWireSize;
        _measuredAddParts1 = measuredAddParts1;
        _measuredAddParts2 = measuredAddParts2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shieldConditions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'シールド条件が見つかりません',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // 最初のレコードから共通情報を取得
    final firstCondition = widget.shieldConditions.first;
    final pNumber = firstCondition['p_number']?.toString() ?? '';
    final engChange = firstCondition['eng_change']?.toString() ?? '';
    final ybm = firstCondition['ybm']?.toString() ?? '';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBgColor = isDark ? AppColors.black : AppColors.paperWhite;
    final headerTextColor = isDark ? AppColors.paperWhite : AppColors.black;
    final borderColor = isDark ? AppColors.paperWhite : AppColors.paperWhite;

    return Column(
      children: [
        // ヘッダー部分（横並び）
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左側: シールド加工条件ヘッダー
            Expanded(
              flex: 3,
              child: Container(
                height: 60,
                padding: const EdgeInsets.only(
                  top: 4,
                  right: 8,
                  left: 8,
                  bottom: 2,
                ),
                margin: const EdgeInsets.only(
                  top: 4,
                  right: 4,
                  left: 1,
                  bottom: 4,
                ),
                decoration: BoxDecoration(
                  color: headerBgColor,
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(color: borderColor, width: .5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'シールド加工条件',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: headerTextColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.shieldConditions.length}件',
                          style: TextStyle(
                            fontSize: 14,
                            color: headerTextColor.withValues(alpha: 1),
                          ),
                        ),
                        if (widget.quantity != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '数量: ${widget.quantity}本',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildHeaderItem(
                            'P/N',
                            pNumber,
                            headerTextColor,
                          ),
                        ),
                        Expanded(
                          child: _buildHeaderItem(
                            'ENG',
                            engChange,
                            headerTextColor,
                          ),
                        ),
                        Expanded(
                          child: _buildHeaderItem('YBM', ybm, headerTextColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                  ],
                ),
              ),
            ),

            // 右側: 前回の加工条件ヘッダー
            Expanded(
              flex: 2,
              child: Container(
                height: 60,
                padding: const EdgeInsets.only(
                  top: 4,
                  right: 8,
                  left: 8,
                  bottom: 2,
                ),
                margin: const EdgeInsets.only(
                  top: 4,
                  right: 1,
                  left: 4,
                  bottom: 4,
                ),
                decoration: BoxDecoration(
                  color: headerBgColor,
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(color: borderColor, width: .5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '前回の加工条件',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: headerTextColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InfoIconButton(
                          title: '前回の加工条件について',
                          content:
                              '前回測定した加工条件が表示されます。\n\n'
                              '端子品番、電線品種/サイズ、付属部品がすべて一致する場合、'
                              '該当する条件に斜線パターンが表示されます。',
                          iconSize: 18,
                        ),
                      ],
                    ),
                    if (_measuredTerminal0.isNotEmpty ||
                        _measuredWireType.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (_measuredTerminal0.isNotEmpty)
                            Flexible(
                              child: Text(
                                formatCode(_measuredTerminal0, "-"),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: headerTextColor.withValues(alpha: 1),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (_measuredWireType.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            Text(
                              '$_measuredWireType/${_measuredWireSize.isNotEmpty ? _measuredWireSize : ''}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: headerTextColor.withValues(alpha: 1),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (_measuredTerminal1.isNotEmpty)
                            const SizedBox(width: 16),
                          Flexible(
                            child: Text(
                              formatCode(_measuredTerminal1, "-"),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: headerTextColor.withValues(alpha: 1),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 2),
                  ],
                ),
              ),
            ),
          ],
        ),

        // コンテンツ部分（横並び）
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左側: 条件リスト
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 4,
                    right: 4,
                    left: 0,
                    bottom: 4,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: widget.shieldConditions.length,
                    itemBuilder: (context, index) {
                      final condition = widget.shieldConditions[index];
                      return _ShieldConditionCard(
                        condition: condition,
                        index: index + 1,
                        onTap: widget.onBlockTapped,
                        measuredTerminal0: _measuredTerminal0,
                        measuredTerminal1: _measuredTerminal1,
                        measuredWireType: _measuredWireType,
                        measuredWireSize: _measuredWireSize,
                        measuredAddParts1: _measuredAddParts1,
                        measuredAddParts2: _measuredAddParts2,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderItem(String label, String value, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class _ShieldConditionCard extends StatefulWidget {
  final Map<String, dynamic> condition;
  final int index;
  final Function(Map<String, dynamic>)? onTap;
  final String measuredTerminal0;
  final String measuredTerminal1;
  final String measuredWireType;
  final String measuredWireSize;
  final String measuredAddParts1;
  final String measuredAddParts2;

  const _ShieldConditionCard({
    required this.condition,
    required this.index,
    this.onTap,
    this.measuredTerminal0 = '',
    this.measuredTerminal1 = '',
    this.measuredWireType = '',
    this.measuredWireSize = '',
    this.measuredAddParts1 = '',
    this.measuredAddParts2 = '',
  });

  @override
  State<_ShieldConditionCard> createState() => _ShieldConditionCardState();
}

class _ShieldConditionCardState extends State<_ShieldConditionCard> {
  Color? _wireColor;
  Color? _markColor1;
  Color? _markColor2;

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  Future<void> _loadColors() async {
    try {
      // 電線色
      final wireColorCode = widget.condition['wire_color']?.toString() ?? '';
      if (wireColorCode.isNotEmpty) {
        final backColor = await getColorFromHive(wireColorCode);
        if (mounted) {
          setState(() {
            _wireColor = backColor ?? Colors.white;
          });
        }
      }

      // マーク色1
      final markColor1Code = widget.condition['mark_color_1']?.toString() ?? '';
      if (markColor1Code.isNotEmpty) {
        final backColor = await getColorFromHive(markColor1Code);
        if (mounted) {
          setState(() {
            _markColor1 = backColor ?? Colors.white;
          });
        }
      }

      // マーク色2
      final markColor2Code = widget.condition['mark_color_2']?.toString() ?? '';
      if (markColor2Code.isNotEmpty) {
        final backColor = await getColorFromHive(markColor2Code);
        if (mounted) {
          setState(() {
            _markColor2 = backColor ?? Colors.white;
          });
        }
      }
    } catch (e) {
      log('Error loading colors: $e');
      if (mounted) {
        setState(() {
          _wireColor = Colors.white;
        });
      }
    }
  }

  String _getValue(String key) {
    return widget.condition[key]?.toString() ?? '';
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Color labelColor,
    required Color valueColor,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [const SizedBox(height: 0), ...items],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: labelColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBoxRow(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
    Color? boxColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outerBorderColor = isDark ? Colors.white : AppColors.grayWhite;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: labelColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(
                  value.isEmpty ? '-' : value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
                if (value.isNotEmpty && boxColor != null) ...[
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/tearDrop.svg',
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            outerBorderColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/images/tearDrop.svg',
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(
                            boxColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowCompact(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        // const SizedBox(height: 4),
        Text(
          value.isEmpty ? '-' : value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildWireColorRowCompact(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outerBorderColor = isDark ? Colors.white : AppColors.grayWhite;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        // const SizedBox(height: 4),
        Row(
          children: [
            Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
            if (value.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 18,
                decoration: BoxDecoration(
                  color: _wireColor ?? Colors.white,
                  border: Border.all(color: outerBorderColor, width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  bool _isTerminal1Matching() {
    // 端子1が前回の端子品番0、wire_type、wire_size、add_parts_1と一致するかチェック
    final terminal1 = _getValue('term_part_no_1');
    final wireType = _getValue('wire_type');
    final wireSize = _getValue('wire_size');
    final addParts1 = _getValue('add_parts_1');
    final result =
        widget.measuredTerminal0.isNotEmpty &&
        terminal1.isNotEmpty &&
        terminal1 == widget.measuredTerminal0 &&
        wireType.isNotEmpty &&
        wireType == widget.measuredWireType &&
        wireSize.isNotEmpty &&
        wireSize == widget.measuredWireSize &&
        addParts1.isNotEmpty &&
        addParts1 == widget.measuredAddParts1;
    return result;
  }

  bool _isTerminal2Matching() {
    // 端子2が前回の端子品番1、wire_type、wire_size、add_parts_2と一致するかチェック
    final terminal2 = _getValue('term_part_no_2');
    final wireType = _getValue('wire_type');
    final wireSize = _getValue('wire_size');
    final addParts2 = _getValue('add_parts_2');
    final result =
        widget.measuredTerminal1.isNotEmpty &&
        terminal2.isNotEmpty &&
        terminal2 == widget.measuredTerminal1 &&
        wireType.isNotEmpty &&
        wireType == widget.measuredWireType &&
        wireSize.isNotEmpty &&
        wireSize == widget.measuredWireSize &&
        addParts2.isNotEmpty &&
        addParts2 == widget.measuredAddParts2;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTerminal1Matching = _isTerminal1Matching();
    final isTerminal2Matching = _isTerminal2Matching();

    final cardColor = isDark ? AppColors.paperBlack : Colors.white;

    final labelColor = isDark
        ? (Colors.grey[400] ?? Colors.grey)
        : AppColors.green;
    final valueColor = isDark ? AppColors.paperWhite : AppColors.black;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(width: .5),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 2, right: 8, bottom: 4, left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 電線情報
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _getValue('cfg_no'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: labelColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 0,
                      child: _buildInfoRowCompact(
                        '品種/サイズ',
                        '${_getValue('wire_type')} / ${_getValue('wire_size')}',
                        labelColor,
                        valueColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 0,
                      child: _buildWireColorRowCompact(
                        '色',
                        _getValue('wire_color'),
                        labelColor,
                        valueColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_getValue("wire_len").isEmpty)
                            Text(
                              '-',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: valueColor,
                              ),
                            )
                          else
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: _getValue("wire_len"),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: valueColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' mm',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: valueColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // const Divider(height: 10, thickness: 0.5),
            const SizedBox(height: 0),
            // 端子情報（左右でタップ可能）
            Row(
              children: [
                // 端子1（左側）
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(0),
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isTerminal1Matching
                            ? AppColors.getHighLightColor(
                                context,
                              ).withValues(alpha: 1)
                            : AppColors.getLineColor(context),
                        width: isDark ? .5 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          if (isTerminal1Matching)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: DiagonalStripesPainter(
                                  color: AppColors.getHighLightColor(context),
                                  alpha: isDark ? 30 : 40,
                                  animationOffset: 0.0,
                                ),
                              ),
                            ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                if (widget.onTap != null) {
                                  final blockInfo = {
                                    'strip': _getValue('strip_len_1'),
                                    'directives': [
                                      _getValue('term_proc_inst_1'),
                                      '',
                                      '',
                                      '',
                                      '',
                                    ],
                                    'terminals': [
                                      _getValue('term_part_no_1'),
                                      _getValue('add_parts_1'),
                                      _getValue('mark_color_1'),
                                      '',
                                      '',
                                    ],
                                  };
                                  widget.onTap!(blockInfo);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 2,
                                  bottom: 2,
                                  left: 8,
                                  right: 8,
                                ),
                                child: _buildSection(
                                  context,
                                  title: '端子1',
                                  labelColor: labelColor,
                                  valueColor: valueColor,
                                  items: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoRow(
                                            '端子品番',
                                            formatCode(
                                              _getValue('term_part_no_1'),
                                              '-',
                                            ),
                                            labelColor,
                                            valueColor,
                                          ),
                                        ),
                                        if (_getValue('mark_color_1') != '-' &&
                                            _getValue(
                                              'mark_color_1',
                                            ).isNotEmpty)
                                          Expanded(
                                            child: _buildColorBoxRow(
                                              'マジック色',
                                              _getValue('mark_color_1'),
                                              labelColor,
                                              valueColor,
                                              _markColor1,
                                            ),
                                          ),
                                      ],
                                    ),
                                    _buildInfoRow(
                                      '付属部品',
                                      formatCode(_getValue('add_parts_1'), "-"),
                                      labelColor,
                                      valueColor,
                                    ),
                                    _buildInfoRow(
                                      '回路',
                                      _getValue('circuit_1'),
                                      labelColor,
                                      valueColor,
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
                ),
                const SizedBox(width: 16),
                // 端子2（右側）
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(0),
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isTerminal2Matching
                            ? AppColors.getHighLightColor(
                                context,
                              ).withValues(alpha: 1)
                            : AppColors.getLineColor(context),
                        width: isDark ? .5 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          if (isTerminal2Matching)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: DiagonalStripesPainter(
                                  color: AppColors.getHighLightColor(context),
                                  alpha: isDark ? 100 : 40,
                                  animationOffset: 0.0,
                                ),
                              ),
                            ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                if (widget.onTap != null) {
                                  final blockInfo = {
                                    'strip': _getValue('strip_len_2'),
                                    'directives': [
                                      _getValue('term_proc_inst_2'),
                                      '',
                                      '',
                                      '',
                                      '',
                                    ],
                                    'terminals': [
                                      _getValue('term_part_no_2'),
                                      _getValue('add_parts_2'),
                                      _getValue('mark_color_2'),
                                      '',
                                      '',
                                    ],
                                  };
                                  widget.onTap!(blockInfo);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 2,
                                  bottom: 2,
                                  left: 8,
                                  right: 8,
                                ),
                                child: _buildSection(
                                  context,
                                  title: '端子2',
                                  labelColor: labelColor,
                                  valueColor: valueColor,
                                  items: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoRow(
                                            '端子品番',
                                            formatCode(
                                              _getValue('term_part_no_2'),
                                              '-',
                                            ),
                                            labelColor,
                                            valueColor,
                                          ),
                                        ),
                                        if (_getValue('mark_color_2') != '-' &&
                                            _getValue(
                                              'mark_color_2',
                                            ).isNotEmpty)
                                          Expanded(
                                            child: _buildColorBoxRow(
                                              'マジック色',
                                              _getValue('mark_color_2'),
                                              labelColor,
                                              valueColor,
                                              _markColor2,
                                            ),
                                          ),
                                      ],
                                    ),
                                    _buildInfoRow(
                                      '付属部品',
                                      formatCode(_getValue('add_parts_2'), "-"),
                                      labelColor,
                                      valueColor,
                                    ),
                                    _buildInfoRow(
                                      '回路',
                                      _getValue('circuit_2'),
                                      labelColor,
                                      valueColor,
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
