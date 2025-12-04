import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preharness/core/constants/app_colors.dart';
import 'package:preharness/features/work40/widgets/components/sliding_number.dart';

/// フリップアニメーション付きのカウンター表示ウィジェット
class AnimatedCounter extends StatefulWidget {
  /// 現在のカウント値
  final int currentCount;

  /// 前回のカウント値（アニメーション用）
  final int previousCount;

  /// 目標カウント値
  final int targetCount;

  /// カウンターがアクティブかどうか
  final bool isActive;

  /// キーボードフォーカスノード
  final FocusNode focusNode;

  /// カウンターがタップされたときのコールバック
  final VoidCallback? onTap;

  /// F1キーが押されたときのコールバック
  final VoidCallback? onF1KeyPress;

  const AnimatedCounter({
    super.key,
    required this.currentCount,
    required this.previousCount,
    required this.targetCount,
    this.isActive = false,
    required this.focusNode,
    this.onTap,
    this.onF1KeyPress,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> {
  @override
  Widget build(BuildContext context) {
    final isCompleted =
        widget.currentCount >= widget.targetCount && widget.targetCount > 0;

    return Column(
      children: [
        // アクティブな場合はキーボード入力を受け付ける
        widget.isActive
            ? RawKeyboardListener(
                focusNode: widget.focusNode,
                onKey: (RawKeyEvent event) {
                  if (event is RawKeyDownEvent) {
                    debugPrint('🎯 カウンター F1キー検出: ${event.logicalKey}');
                    if (event.logicalKey == LogicalKeyboardKey.f13 ||
                        event.logicalKey == LogicalKeyboardKey.f1 ||
                        event.logicalKey == LogicalKeyboardKey.insert) {
                      widget.onF1KeyPress?.call();
                    }
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    widget.focusNode.requestFocus();
                    widget.onTap?.call();
                    debugPrint('🎯 カウンタータップ → フォーカス取得');
                  },
                  child: _buildCounterDisplay(isCompleted),
                ),
              )
            : _buildCounterDisplay(isCompleted),
      ],
    );
  }

  Widget _buildCounterDisplay(bool isCompleted) {
    final counterString = "${widget.currentCount}/${widget.targetCount}";

    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.getHighLightColor(context)
                : AppColors.getCardColor(context),
            border: Border.all(
              color: AppColors.getLineColor(context),
              width: 1,
            ),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (!isCompleted) ...[
                  const SizedBox(height: 10),
                  FlipCounter(
                    currentCount: widget.currentCount,
                    previousCount: widget.previousCount,
                  ),
                ] else ...[
                  const SizedBox(height: 22),
                  Icon(
                    Icons.check_circle,
                    size: 36,
                    color: isCompleted
                        ? Colors.white
                        : AppColors.getLineColor(context),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  counterString,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? Colors.white
                        : AppColors.getLineColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// フリップアニメーション付きの数字カウンター
class FlipCounter extends StatelessWidget {
  final int currentCount;
  final int previousCount;

  const FlipCounter({
    super.key,
    required this.currentCount,
    required this.previousCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _buildDigitWidgets(context),
    );
  }

  List<Widget> _buildDigitWidgets(BuildContext context) {
    final currentStr = currentCount.toString();
    final previousStr = previousCount >= 0 ? previousCount.toString() : '';

    List<Widget> digits = [];

    // 0の場合は特別処理
    if (currentCount == 0) {
      digits.add(
        _buildSingleDigit(
          context,
          currentDigit: '0',
          previousDigit: '',
          shouldAnimate: false,
          digitIndex: 0,
          isNewDigit: false,
        ),
      );
      return digits;
    }

    for (int i = 0; i < currentStr.length; i++) {
      final currentDigit = currentStr[i];

      // 右から左に桁を対応させる
      final currentFromRight = currentStr.length - 1 - i;
      final previousLen = previousStr.length;

      String previousDigit = '';
      bool isNewDigit = false;

      if (currentFromRight < previousLen) {
        final previousIndex = previousLen - 1 - currentFromRight;
        previousDigit = previousStr[previousIndex];
      } else {
        isNewDigit = true;
        previousDigit = '';
      }

      final shouldAnimate = previousDigit != currentDigit || isNewDigit;

      digits.add(
        _buildSingleDigit(
          context,
          currentDigit: currentDigit,
          previousDigit: previousDigit,
          shouldAnimate: shouldAnimate,
          digitIndex: i,
          isNewDigit: isNewDigit,
        ),
      );
    }

    return digits;
  }

  Widget _buildSingleDigit(
    BuildContext context, {
    required String currentDigit,
    required String previousDigit,
    required bool shouldAnimate,
    required int digitIndex,
    required bool isNewDigit,
  }) {
    final currentChild = Text(
      currentDigit,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28,
        height: 0.8,
        fontWeight: FontWeight.bold,
        color: AppColors.getHighLightColor(context),
      ),
    );

    final previousChild = previousDigit.isNotEmpty
        ? Text(
            previousDigit,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              height: 0.8,
              fontWeight: FontWeight.bold,
              color: AppColors.getHighLightColor(context),
            ),
          )
        : null;

    if (shouldAnimate) {
      return SizedBox(
        width: 15,
        height: 24,
        child: SlidingNumber(
          key: ValueKey('${digitIndex}_$currentDigit'),
          currentChild: currentChild,
          previousChild: previousChild,
          isNewDigit: isNewDigit,
        ),
      );
    } else {
      return SizedBox(width: 15, height: 24, child: currentChild);
    }
  }
}
