import 'package:flutter/material.dart';

/// スライディングアニメーション付きの数字表示ウィジェット
///
/// 数字が変更される際に、前の数字がスライドアウトし、
/// 新しい数字がスライドインするアニメーションを提供します。
class SlidingNumber extends StatefulWidget {
  /// 現在表示する子ウィジェット
  final Widget currentChild;

  /// 前に表示していた子ウィジェット（アニメーション用）
  final Widget? previousChild;

  /// 新しい桁かどうか
  final bool isNewDigit;

  const SlidingNumber({
    super.key,
    required this.currentChild,
    this.previousChild,
    this.isNewDigit = false,
  });

  @override
  State<SlidingNumber> createState() => _SlidingNumberState();
}

class _SlidingNumberState extends State<SlidingNumber>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideInAnim;
  late Animation<double> _slideOutAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideInAnim = Tween<double>(
      begin: 40.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideOutAnim = Tween<double>(
      begin: 0.0,
      end: -40.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnim = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // 数字が切り替わるたびにアニメーションを再生
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.previousChild != null || widget.isNewDigit) {
        _controller.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.hardEdge,
      children: [
        // 古い数字を上にスライドアウト
        if (widget.previousChild != null)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(0.0, _slideOutAnim.value),
                child: Opacity(
                  opacity: _opacityAnim.value,
                  child: widget.previousChild,
                ),
              );
            },
          ),
        // 新しい数字を下からスライドイン
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Transform.translate(
              offset: Offset(0.0, _slideInAnim.value),
              child: widget.currentChild,
            );
          },
        ),
      ],
    );
  }
}