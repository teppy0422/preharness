import 'package:flutter/material.dart';
import 'package:preharness/constants/app_colors.dart';

class DialSelectorPage extends StatefulWidget {
  final Function(String, String, String) onChanged;
  final List<String>? initialTopDialOptions;
  final List<String>? initialBottomDialOptions;
  final List<String>? initialHindDialOptions;
  final bool valuesAreFromDb;
  final String? recommendedHindDial;

  const DialSelectorPage({
    super.key,
    required this.onChanged,
    this.initialTopDialOptions,
    this.initialBottomDialOptions,
    this.initialHindDialOptions,
    this.valuesAreFromDb = true,
    this.recommendedHindDial,
  });

  @override
  State<DialSelectorPage> createState() => _DialSelectorPageState();
}

class _DialSelectorPageState extends State<DialSelectorPage> {
  // ダイヤル選択肢
  final List<String> topDialOptions = ['0.2/0.3', '0.5', '0.85', '1.25', '2.0'];
  final List<String> bottomDialOptions = ['1', '2', '3', '4'];
  final List<String> hindDialOptions = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
  ];

  // 選択状態
  late String selectedTopDial;
  late String selectedBottomDial;
  late String selectedHindDial;
  late bool _isInitialState;

  @override
  void initState() {
    super.initState();
    selectedTopDial = widget.initialTopDialOptions?.first ?? topDialOptions[0];
    selectedBottomDial =
        widget.initialBottomDialOptions?.first ?? bottomDialOptions[0];
    selectedHindDial =
        widget.initialHindDialOptions?.first ?? hindDialOptions[0];
    _isInitialState = true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.black : AppColors.paperWhite;
    final labelColor = isDark ? Colors.white70 : Colors.black87;
    return Center(
      child: SizedBox(
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            border: Border.all(color: Colors.white, width: .5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialSection(
                  title: "上ダイヤル",
                  options: topDialOptions,
                  selectedValue: selectedTopDial,
                  onTap: (val) {
                    if (_isInitialState) {
                      setState(() {
                        _isInitialState = false;
                      });
                    }
                    setState(() {
                      selectedTopDial = val;
                    });
                    widget.onChanged(
                      selectedTopDial,
                      selectedBottomDial,
                      selectedHindDial,
                    );
                  },
                  labelColor: labelColor,
                ),
                const SizedBox(height: 8),
                _buildDialSection(
                  title: "下ダイヤル",
                  options: bottomDialOptions,
                  selectedValue: selectedBottomDial,
                  onTap: (val) {
                    if (_isInitialState) {
                      setState(() {
                        _isInitialState = false;
                      });
                    }
                    setState(() {
                      selectedBottomDial = val;
                    });
                    widget.onChanged(
                      selectedTopDial,
                      selectedBottomDial,
                      selectedHindDial,
                    );
                  },
                  labelColor: labelColor,
                ),
                const Divider(thickness: 1, color: Colors.grey),
                _buildDialSection(
                  title: "後足",
                  options: hindDialOptions,
                  selectedValue: selectedHindDial,
                  onTap: (val) {
                    if (_isInitialState) {
                      setState(() {
                        _isInitialState = false;
                      });
                    }
                    setState(() {
                      selectedHindDial = val;
                    });
                    widget.onChanged(
                      selectedTopDial,
                      selectedBottomDial,
                      selectedHindDial,
                    );
                  },
                  labelColor: labelColor,
                  recommendedValue: widget.recommendedHindDial,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialSection({
    required String title,
    required List<String> options,
    required String selectedValue,
    required void Function(String) onTap,
    required Color labelColor,
    String? recommendedValue,
  }) {
    return Column(
      children: [
        // Text(
        //   title,
        //   style: TextStyle(
        //     fontSize: 14,
        //     fontFamily: "NotoSansJP",
        //     fontWeight: FontWeight.w900,
        //     color: labelColor,
        //   ),
        // ),
        const SizedBox(height: 2),
        Wrap(
          spacing: 12,
          children: options.map((val) {
            final isSelected = selectedValue == val;
            final isRecommended = recommendedValue == val;
            final Color buttonColor;
            final Color borderColor;
            final Color fontColor;

            if (isSelected) {
              buttonColor = widget.valuesAreFromDb
                  ? AppColors.getHighLightColor(context)
                  : AppColors.red;
              borderColor = AppColors.getHighLightColor(context);
              fontColor = AppColors.paperBlack;
            } else if (isRecommended) {
              buttonColor = Colors.grey[900]!;
              borderColor = AppColors.getHighLightColor(context);
              fontColor = AppColors.paperWhite;
            } else {
              buttonColor = Colors.grey[300]!;
              borderColor = Colors.grey[300]!;
              fontColor = AppColors.paperBlack;
            }

            return GestureDetector(
              onTap: () => onTap(val),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor,
                    width: isRecommended ? 3.0 : 3.0,
                  ),
                ),
                child: Text(
                  val,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w900,
                    color: fontColor,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
