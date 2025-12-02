import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:preharness/core/constants/app_colors.dart';
import 'package:preharness/core/utils/color_utils.dart';
import 'package:preharness/core/utils/global.dart';

class EfuShieldPage extends StatelessWidget {
  final List<Map<String, dynamic>> shieldConditions;

  const EfuShieldPage({super.key, required this.shieldConditions});

  @override
  Widget build(BuildContext context) {
    if (shieldConditions.isEmpty) {
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
    final firstCondition = shieldConditions.first;
    final pNumber = firstCondition['p_number']?.toString() ?? '';
    final engChange = firstCondition['eng_change']?.toString() ?? '';
    final ybm = firstCondition['ybm']?.toString() ?? '';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBgColor = isDark ? AppColors.deepGreen : AppColors.lightGreen;
    final headerTextColor = isDark ? AppColors.paperWhite : AppColors.black;

    return Column(
      children: [
        // 固定ヘッダー（p_number, eng_change, ybm）
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 4, right: 8, left: 8, bottom: 2),
          margin: const EdgeInsets.only(top: 4, right: 1, left: 1, bottom: 4),
          decoration: BoxDecoration(
            color: headerBgColor,
            borderRadius: BorderRadius.circular(12),
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
                    '${shieldConditions.length}件',
                    style: TextStyle(
                      fontSize: 14,
                      color: headerTextColor.withValues(alpha: 1),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildHeaderItem('P/N', pNumber, headerTextColor),
                  ),
                  Expanded(
                    child: _buildHeaderItem('ENG', engChange, headerTextColor),
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

        // 条件リスト
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 4, right: 0, left: 0, bottom: 4),
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: shieldConditions.length,
              itemBuilder: (context, index) {
                final condition = shieldConditions[index];
                return _ShieldConditionCard(
                  condition: condition,
                  index: index + 1,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderItem(String label, String value, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   label,
        //   style: TextStyle(
        //     fontSize: 12,
        //     color: textColor.withValues(alpha: 0.7),
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),
        const SizedBox(height: 0),
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

  const _ShieldConditionCard({required this.condition, required this.index});

  @override
  State<_ShieldConditionCard> createState() => _ShieldConditionCardState();
}

class _ShieldConditionCardState extends State<_ShieldConditionCard> {
  Color? _wireColor;
  Color? _wireForeColor;
  Color? _markColor1;
  Color? _markForeColor1;
  Color? _markColor2;
  Color? _markForeColor2;

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
        final foreColor = await getColorFromHive(
          wireColorCode,
          getForeColor: true,
        );
        if (mounted) {
          setState(() {
            _wireColor = backColor ?? Colors.white;
            _wireForeColor = foreColor ?? Colors.black;
          });
        }
      }

      // マーク色1
      final markColor1Code = widget.condition['mark_color_1']?.toString() ?? '';
      if (markColor1Code.isNotEmpty) {
        final backColor = await getColorFromHive(markColor1Code);
        final foreColor = await getColorFromHive(
          markColor1Code,
          getForeColor: true,
        );
        if (mounted) {
          setState(() {
            _markColor1 = backColor ?? Colors.white;
            _markForeColor1 = foreColor ?? Colors.black;
          });
        }
      }

      // マーク色2
      final markColor2Code = widget.condition['mark_color_2']?.toString() ?? '';
      if (markColor2Code.isNotEmpty) {
        final backColor = await getColorFromHive(markColor2Code);
        final foreColor = await getColorFromHive(
          markColor2Code,
          getForeColor: true,
        );
        if (mounted) {
          setState(() {
            _markColor2 = backColor ?? Colors.white;
            _markForeColor2 = foreColor ?? Colors.black;
          });
        }
      }
    } catch (e) {
      log('Error loading colors: $e');
      if (mounted) {
        setState(() {
          _wireColor = Colors.white;
          _wireForeColor = Colors.black;
        });
      }
    }
  }

  String _getValue(String key) {
    return widget.condition[key]?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.paperBlack : Colors.white;
    final borderColor = isDark
        ? AppColors.paperWhite.withValues(alpha: 1)
        : AppColors.green.withValues(alpha: 0.2);
    final labelColor = isDark
        ? (Colors.grey[400] ?? Colors.grey)
        : AppColors.green;
    final valueColor = isDark ? AppColors.paperWhite : AppColors.black;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: .5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 電線情報
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(width: 24),
                    Flexible(
                      flex: 0,
                      child: _buildWireColorRowCompact(
                        '色',
                        _getValue('wire_color'),
                        labelColor,
                        valueColor,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Flexible(
                      flex: 0,
                      child: _buildInfoRowCompact(
                        '線長',
                        _getValue('wire_len'),
                        labelColor,
                        valueColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 10, thickness: 0.5),

            // 端子情報
            Row(
              children: [
                Expanded(
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
                              formatCode(_getValue('term_part_no_1'), '-'),
                              labelColor,
                              valueColor,
                            ),
                          ),
                          if (_getValue('mark_color_1') != '-' && _getValue('mark_color_1').isNotEmpty)
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
                const SizedBox(width: 16),
                Expanded(
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
                              formatCode(_getValue('term_part_no_2'), '-'),
                              labelColor,
                              valueColor,
                            ),
                          ),
                          if (_getValue('mark_color_2') != '-' && _getValue('mark_color_2').isNotEmpty)
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
              ],
            ),
          ],
        ),
      ),
    );
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

  Widget _buildWireColorRow(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                if (value.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _wireColor ?? Colors.white,
                      border: Border.all(
                        color: _wireForeColor ?? Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
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

  // 横並び用のコンパクト版
  Widget _buildInfoRowCompact(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        const SizedBox(height: 4),
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
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        const SizedBox(height: 4),
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
}
