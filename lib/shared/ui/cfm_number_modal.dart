import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:preharness/core/constants/app_colors.dart';

class CfmNumberModal extends StatefulWidget {
  final String initialValue;
  final Function(String)? onConfirm;
  final VoidCallback? onCancel;

  const CfmNumberModal({
    super.key,
    this.initialValue = '001',
    this.onConfirm,
    this.onCancel,
  });

  @override
  State<CfmNumberModal> createState() => _CfmNumberModalState();
}

class _CfmNumberModalState extends State<CfmNumberModal> {
  late int selectedValue;
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // 初期値を設定（1-255の範囲）
    final initialNum = int.tryParse(widget.initialValue) ?? 1;
    selectedValue = initialNum.clamp(1, 255);

    // スクロールコントローラーを初期位置に設定
    _scrollController = FixedExtentScrollController(
      initialItem: selectedValue - 1, // 0-based index
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSelectedItemChanged(int index) {
    setState(() {
      selectedValue = index + 1; // 1-based value
    });
  }

  String _getFormattedValue() {
    return selectedValue.toString().padLeft(3, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.getLineColor(context),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ヘッダー
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.getHighLightColor(context).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.getLineColor(context),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                'CFM番号を選択',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getLineColor(context),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // 数字選択部分
            Container(
              height: 200,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: CupertinoPicker(
                scrollController: _scrollController,
                itemExtent: 40.0,
                onSelectedItemChanged: _onSelectedItemChanged,
                children: List<Widget>.generate(255, (int index) {
                  final value = index + 1; // 1-255
                  return Center(
                    child: Text(
                      value.toString().padLeft(3, '0'),
                      style: TextStyle(
                        fontSize: 22,
                        color: AppColors.getLineColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // 現在の値表示
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.getHighLightColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.getLineColor(context),
                    width: 1,
                  ),
                ),
                child: Text(
                  '選択値: ${_getFormattedValue()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getHighLightColor(context),
                  ),
                ),
              ),
            ),

            // ボタン部分
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onCancel?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('CANCEL'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onConfirm?.call(_getFormattedValue());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.getHighLightColor(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('OK'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  static Future<String?> show(
    BuildContext context, {
    String initialValue = '001',
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CfmNumberModal(
        initialValue: initialValue,
        onConfirm: (value) => Navigator.of(context).pop(value),
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}