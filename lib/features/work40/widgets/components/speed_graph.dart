import 'package:flutter/material.dart';

/// スピードデータを表示するグラフウィジェット
class SpeedGraph extends StatelessWidget {
  final List<MapEntry<DateTime, double>> speedData;
  final Color color;
  final Color lineColor;
  final double height;
  final double width;

  const SpeedGraph({
    super.key,
    required this.speedData,
    required this.color,
    required this.lineColor,
    this.height = 60,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CustomPaint(
        painter: SpeedGraphPainter(
          speedData: speedData,
          color: color,
          lineColor: lineColor,
        ),
      ),
    );
  }
}

/// スピードグラフを描画するカスタムペインター
class SpeedGraphPainter extends CustomPainter {
  final List<MapEntry<DateTime, double>> speedData;
  final Color color;
  final Color lineColor;

  SpeedGraphPainter({
    required this.speedData,
    required this.color,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (speedData.isEmpty) return;

    // 表示するポイント数を制限（最大30ポイント）
    const maxPoints = 30;
    final displayData = speedData.length > maxPoints
        ? speedData.skip(speedData.length - maxPoints).toList()
        : speedData;

    if (displayData.isEmpty) return;

    // 平均値を計算
    final averageSpeed =
        displayData.map((e) => e.value).reduce((a, b) => a + b) /
            displayData.length;

    // 速度の最小値と最大値を取得（グラフ範囲決定用）
    final speeds = displayData.map((e) => e.value).toList();
    final minSpeed = speeds.reduce((a, b) => a < b ? a : b);
    final maxSpeed = speeds.reduce((a, b) => a > b ? a : b);

    // 最小値と最大値の差が小さい場合の調整
    final speedRange = (maxSpeed - minSpeed) == 0 ? 1.0 : (maxSpeed - minSpeed);
    final margin = speedRange * 0.1; // 上下10%のマージンで余裕を持たせる

    // Y軸の範囲を設定
    final yMin = minSpeed - margin;
    final yMax = maxSpeed + margin;
    final yRange = yMax - yMin;

    // X軸の左右マージン
    final xMargin = size.width * 0.01; // 左右1%のマージン
    final drawingWidth = size.width - (xMargin * 2);

    // 平均線を描画
    _drawAverageLine(canvas, size, averageSpeed, yMin, yRange);

    // データポイントの座標を計算
    final points = _calculatePoints(displayData, size, xMargin, drawingWidth, yMin, yRange);

    // グラフの線を描画
    _drawGraphLine(canvas, points);

    // データポイントを描画
    _drawDataPoints(canvas, points);
  }

  /// 平均線を描画
  void _drawAverageLine(Canvas canvas, Size size, double averageSpeed, double yMin, double yRange) {
    final averageLinePaint = Paint()
      ..color = lineColor.withAlpha(180)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final averageY = size.height - ((averageSpeed - yMin) / yRange) * size.height;
    canvas.drawLine(
      Offset(0, averageY),
      Offset(size.width, averageY),
      averageLinePaint,
    );
  }

  /// データポイントの座標を計算
  List<Offset> _calculatePoints(
    List<MapEntry<DateTime, double>> displayData,
    Size size,
    double xMargin,
    double drawingWidth,
    double yMin,
    double yRange,
  ) {
    final points = <Offset>[];
    for (int i = 0; i < displayData.length; i++) {
      final speed = displayData[i].value;

      // X座標: 等間隔に配置（マージン考慮）
      final x = displayData.length == 1
          ? size.width / 2
          : xMargin + (i / (displayData.length - 1)) * drawingWidth;

      // Y座標: 速度に応じて配置（範囲内に収まるように）
      final y = size.height - ((speed - yMin) / yRange) * size.height;

      // Y座標が範囲内に収まるようにクランプ
      final clampedY = y.clamp(0.0, size.height);

      points.add(Offset(x, clampedY));
    }
    return points;
  }

  /// グラフの線を描画
  void _drawGraphLine(Canvas canvas, List<Offset> points) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    if (points.isNotEmpty) {
      final path = Path();

      if (points.length == 1) {
        // 1点の場合は点のみ（ポイント描画で対応）
      } else if (points.length == 2) {
        // 2点の場合は直線
        path.moveTo(points[0].dx, points[0].dy);
        path.lineTo(points[1].dx, points[1].dy);
      } else {
        // 3点以上の場合はスムーズな曲線（Catmull-Rom風）
        path.moveTo(points[0].dx, points[0].dy);

        for (int i = 0; i < points.length - 1; i++) {
          final current = points[i];
          final next = points[i + 1];

          // 前後の点を取得（境界では現在の点を使用）
          final prev = i > 0 ? points[i - 1] : current;
          final afterNext = i < points.length - 2 ? points[i + 2] : next;

          // 制御点を計算（tangentベース）
          const tension = 0.3; // 張力（0.0-1.0、小さいほどスムーズ）

          final cp1x = current.dx + (next.dx - prev.dx) * tension;
          final cp1y = current.dy + (next.dy - prev.dy) * tension;

          final cp2x = next.dx - (afterNext.dx - current.dx) * tension;
          final cp2y = next.dy - (afterNext.dy - current.dy) * tension;

          path.cubicTo(cp1x, cp1y, cp2x, cp2y, next.dx, next.dy);
        }
      }

      if (points.length > 1) {
        canvas.drawPath(path, linePaint);
      }
    }
  }

  /// データポイントを描画
  void _drawDataPoints(Canvas canvas, List<Offset> points) {
    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      // 最新のポイントは大きく、古いポイントは小さく
      final isLatest = i == points.length - 1;
      final radius = isLatest ? 4.0 : 2.5;
      final alpha = isLatest ? 1.0 : 0.7;

      final pointPaint = Paint()
        ..color = color.withOpacity(alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point, radius, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 常に再描画してリアルタイム更新
  }
}