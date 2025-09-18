import 'package:flutter/material.dart';
import 'package:preharness/constants/app_colors.dart';

class SelectionOption {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? color;

  SelectionOption({
    required this.title,
    this.subtitle,
    this.icon,
    required this.onTap,
    this.color,
  });
}

class SelectionModal extends StatelessWidget {
  final String title;
  final List<SelectionOption> options;
  final double? width;
  final double? height;

  const SelectionModal({
    super.key,
    required this.title,
    required this.options,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: width ?? 320,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.getLineColor(context), width: 1),
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
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.getLineColor(context),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getLineColor(context),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      color: AppColors.getLineColor(context),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            // 選択肢リスト
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: options.length,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      option.onTap();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.getCardColor(context),
                        border: Border.all(
                          color:
                              option.color ?? AppColors.getLineColor(context),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          if (option.icon != null) ...[
                            Icon(
                              option.icon,
                              color:
                                  option.color ??
                                  AppColors.getLineColor(context),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        option.color ??
                                        AppColors.getLineColor(context),
                                  ),
                                ),
                                if (option.subtitle != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    option.subtitle!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.getLineSubColor(context),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.getLineSubColor(context),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 便利メソッド：モーダルを表示
  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<SelectionOption> options,
    double? width,
    double? height,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SelectionModal(
        title: title,
        options: options,
        width: width,
        height: height,
      ),
    );
  }
}
