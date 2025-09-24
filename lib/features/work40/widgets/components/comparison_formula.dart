import 'package:flutter/material.dart';
import 'package:preharness/core/constants/app_colors.dart';

/// 比較式チェック結果を表示するウィジェット
class ComparisonFormula extends StatelessWidget {
  final Map<String, dynamic>? comparisonData;
  final bool isLoading;

  const ComparisonFormula({
    super.key,
    required this.comparisonData,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || comparisonData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = comparisonData!;
    final micrometerSerialNumber = data['micrometer'] ?? '';
    final applicatorName = data['applicator'] ?? '';
    final terminalName = data['terminal'] ?? '';
    final blockTerminal0 = data['blockTerminal0'] ?? '';

    // バリデーション結果（crimp_condition.dartと完全に同じロジック）
    final micrometerValid = micrometerSerialNumber.isNotEmpty;
    final applicatorValid = _validateApplicator(blockTerminal0, applicatorName);
    final terminalValid = _validateTerminal(blockTerminal0, terminalName);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.getLineColor(context), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '比較式チェック',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.getLineColor(context),
            ),
          ),
          const SizedBox(height: 4),
          ComparisonRow(
            label: '✓ マイクロメーター:',
            comparison: micrometerSerialNumber.isEmpty ? '未入力' : micrometerSerialNumber,
            isValid: micrometerValid,
          ),
          ComparisonRow(
            label: '✓ Applicator(前8文字):',
            comparison: _buildApplicatorComparison(blockTerminal0, applicatorName),
            isValid: applicatorValid,
          ),
          ComparisonRow(
            label: '✓ Terminal(前8文字):',
            comparison: _buildTerminalComparison(blockTerminal0, terminalName),
            isValid: terminalValid,
          ),
        ],
      ),
    );
  }

  bool _validateApplicator(String blockTerminal0, String applicatorName) {
    return blockTerminal0.isNotEmpty &&
        applicatorName.isNotEmpty &&
        applicatorName.length >= 8 &&
        blockTerminal0.length >= 8 &&
        applicatorName.substring(0, 8) == blockTerminal0.substring(0, 8);
  }

  bool _validateTerminal(String blockTerminal0, String terminalName) {
    return blockTerminal0.isNotEmpty &&
        terminalName.isNotEmpty &&
        terminalName.length >= 8 &&
        blockTerminal0.length >= 8 &&
        terminalName.substring(0, 8) == blockTerminal0.substring(0, 8);
  }

  String _buildApplicatorComparison(String blockTerminal0, String applicatorName) {
    final blockSet = blockTerminal0.isEmpty ? "未設定" : "設定済";
    final applicatorSet = applicatorName.isEmpty ? "未入力" : "入力済";
    final applicatorLength = applicatorName.length >= 8 ? "長さ>=8" : "長さ<8";
    final blockLength = blockTerminal0.length >= 8 ? "T0長さ>=8" : "T0長さ<8";

    final applicatorSub = applicatorName.isEmpty || applicatorName.length < 8
        ? "入力不足"
        : applicatorName.substring(0, 8);
    final blockSub = blockTerminal0.isEmpty || blockTerminal0.length < 8
        ? "T0不足"
        : blockTerminal0.substring(0, 8);

    return '($blockSet&&$applicatorSet&&$applicatorLength&&$blockLength) → $applicatorSub == $blockSub';
  }

  String _buildTerminalComparison(String blockTerminal0, String terminalName) {
    final blockSet = blockTerminal0.isEmpty ? "未設定" : "設定済";
    final terminalSet = terminalName.isEmpty ? "未入力" : "入力済";
    final terminalLength = terminalName.length >= 8 ? "長さ>=8" : "長さ<8";
    final blockLength = blockTerminal0.length >= 8 ? "T0長さ>=8" : "T0長さ<8";

    final terminalSub = terminalName.isEmpty || terminalName.length < 8
        ? "入力不足"
        : terminalName.substring(0, 8);
    final blockSub = blockTerminal0.isEmpty || blockTerminal0.length < 8
        ? "T0不足"
        : blockTerminal0.substring(0, 8);

    return '($blockSet&&$terminalSet&&$terminalLength&&$blockLength) → $terminalSub == $blockSub';
  }
}

/// 比較式チェック結果の個別行を表示するウィジェット
class ComparisonRow extends StatelessWidget {
  final String label;
  final String comparison;
  final bool isValid;

  const ComparisonRow({
    super.key,
    required this.label,
    required this.comparison,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.getLineColor(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              comparison,
              style: TextStyle(
                fontSize: 10,
                color: isValid
                    ? AppColors.getHighLightColor(context)
                    : AppColors.getErrorColor(context),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}