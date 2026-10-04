import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/data/pokemon_chart_data.dart';

// ─── Helper ────────────────────────────────────────────────────────────────────

Widget _chartTitle(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 12),
  child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
);

// ─── Painters (re-declared for this file) ────────────────────────────────────

class _BarPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final List<Color> colors;
  final double maxValue;
  final double animProgress;
  final double? thresholdY;
  final int? highlightIndex;

  _BarPainter({
    required this.values,
    required this.labels,
    required this.colors,
    this.maxValue = 180,
    this.animProgress = 1.0,
    this.thresholdY,
    this.highlightIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n == 0) return;
    const lp = 40.0, tp2 = 12.0, rp = 10.0, bp = 28.0;
    final chartW = size.width - lp - rp;
    final chartH = size.height - tp2 - bp;
    final gap = chartW / n;
    final barW = gap * 0.65;

    for (int i = 0; i <= 4; i++) {
      final y = tp2 + chartH * (1 - i / 4);
      canvas.drawLine(Offset(lp, y), Offset(size.width - rp, y),
        Paint()..color = Colors.grey.withOpacity(0.2)..strokeWidth = 1);
    }

    for (int i = 0; i < n; i++) {
      final barH = chartH * (values[i] / maxValue).clamp(0, 1) * animProgress;
      final x = lp + i * gap + (gap - barW) / 2;
      final y = tp2 + chartH - barH;
      final isHighlight = highlightIndex == null || highlightIndex == i;
      final color = i < colors.length ? colors[i] : Colors.blue;
      canvas.drawRRect(
        RRect.fromRectAndCorners(Rect.fromLTWH(x, y, barW, barH),
          topLeft: const Radius.circular(3), topRight: const Radius.circular(3)),
        Paint()..color = isHighlight ? color : color.withOpacity(0.3),
      );
      final tp = TextPainter(textDirection: TextDirection.ltr);
      tp.text = TextSpan(
        text: i < labels.length ? labels[i] : '',
        style: const TextStyle(fontSize: 8, color: Colors.black54));
      tp.layout();
      canvas.save();
      canvas.translate(x + barW / 2 - tp.width / 2, tp2 + chartH + 4);
      tp.paint(canvas, Offset.zero);
      canvas.restore();

      if (isHighlight || highlightIndex == null) {
        final vtp = TextPainter(textDirection: TextDirection.ltr);
        vtp.text = TextSpan(text: values[i].toInt().toString(),
          style: const TextStyle(fontSize: 8, color: Colors.black87, fontWeight: FontWeight.bold));
        vtp.layout();
        canvas.save();
        canvas.translate(x + barW / 2 - vtp.width / 2, y - vtp.height - 2);
        vtp.paint(canvas, Offset.zero);
        canvas.restore();
      }
    }

    if (thresholdY != null) {
      final ty = tp2 + chartH * (1 - (thresholdY! / maxValue).clamp(0, 1));
      canvas.drawLine(Offset(lp, ty), Offset(size.width - rp, ty),
        Paint()..color = Colors.red..strokeWidth = 2..style = PaintingStyle.stroke);
      final tp = TextPainter(textDirection: TextDirection.ltr);
      tp.text = const TextSpan(text: 'avg', style: TextStyle(fontSize: 8, color: Colors.red));
      tp.layout();
      canvas.save();
      canvas.translate(size.width - rp + 2, ty - tp.height / 2);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.animProgress != animProgress || old.values != values || old.highlightIndex != highlightIndex;
}

class _GroupedBarPainter extends CustomPainter {
  final List<String> groupLabels;
  final List<List<double>> datasets;
  final List<Color> seriesColors;
  final double maxValue;

  _GroupedBarPainter({
    required this.groupLabels,
    required this.datasets,
    required this.seriesColors,
    this.maxValue = 180,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = groupLabels.length;
    final nSeries = datasets.length;
    if (n == 0 || nSeries == 0) return;
    const lp = 40.0, tp2 = 12.0, rp = 10.0, bp = 28.0;
    final chartW = size.width - lp - rp;
    final chartH = size.height - tp2 - bp;
    final groupW = chartW / n;
    final barW = groupW * 0.7 / nSeries;

    for (int i = 0; i <= 4; i++) {
      final y = tp2 + chartH * (1 - i / 4);
      canvas.drawLine(Offset(lp, y), Offset(size.width - rp, y),
        Paint()..color = Colors.grey.withOpacity(0.2));
    }

    for (int i = 0; i < n; i++) {
      for (int s = 0; s < nSeries; s++) {
        if (s >= datasets.length || i >= datasets[s].length) continue;
        final v = datasets[s][i];
        final barH = chartH * (v / maxValue).clamp(0, 1);
        final x = lp + i * groupW + groupW * 0.15 + s * barW;
        final y = tp2 + chartH - barH;
        canvas.drawRRect(
          RRect.fromRectAndCorners(Rect.fromLTWH(x, y, barW - 1, barH),
            topLeft: const Radius.circular(2), topRight: const Radius.circular(2)),
          Paint()..color = s < seriesColors.length ? seriesColors[s] : Colors.grey,
        );
      }
      final lbl = groupLabels[i];
      final tp = TextPainter(textDirection: TextDirection.ltr);
      tp.text = TextSpan(text: lbl.length > 4 ? lbl.substring(0, 4) : lbl,
        style: const TextStyle(fontSize: 8, color: Colors.black54));
      tp.layout();
      canvas.save();
      canvas.translate(lp + i * groupW + groupW / 2 - tp.width / 2, tp2 + chartH + 4);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_GroupedBarPainter old) => old.datasets != datasets;
}

class _HorizontalBarPainter extends CustomPainter {
  final List<String> names;
  final List<double> values;
  final Color barColor;

  _HorizontalBarPainter({required this.names, required this.values, this.barColor = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n == 0) return;
    const lp = 85.0, tp2 = 8.0, rp = 40.0, bp = 8.0;
    final chartW = size.width - lp - rp;
    final rowH = (size.height - tp2 - bp) / n;
    final barH = rowH * 0.55;
    final mv = values.reduce(max);

    for (int i = 0; i < n; i++) {
      final barW = mv > 0 ? chartW * values[i] / mv : 0.0;
      final y = tp2 + i * rowH + (rowH - barH) / 2;
      canvas.drawRRect(
        RRect.fromRectAndCorners(Rect.fromLTWH(lp, y, barW, barH),
          topRight: const Radius.circular(3), bottomRight: const Radius.circular(3)),
        Paint()..color = barColor.withOpacity(0.85),
      );
      final ntp = TextPainter(textDirection: TextDirection.ltr);
      ntp.text = TextSpan(text: i < names.length ? names[i] : '',
        style: const TextStyle(fontSize: 9, color: Colors.black87, fontWeight: FontWeight.w500));
      ntp.layout();
      canvas.save();
      canvas.translate(lp - ntp.width - 6, y + barH / 2 - ntp.height / 2);
      ntp.paint(canvas, Offset.zero);
      canvas.restore();

      final vtp = TextPainter(textDirection: TextDirection.ltr);
      vtp.text = TextSpan(text: values[i].toInt().toString(),
        style: const TextStyle(fontSize: 9, color: Colors.black54));
      vtp.layout();
      canvas.save();
      canvas.translate(lp + barW + 4, y + barH / 2 - vtp.height / 2);
      vtp.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_HorizontalBarPainter old) => old.values != values;
}

class _LinePainter extends CustomPainter {
  final List<List<double>> datasets;
  final List<String> xLabels;
  final List<Color> lineColors;
  final bool showArea;
  final double animProgress;
  final double? thresholdY;
  final List<String> seriesNames;

  _LinePainter({
    required this.datasets,
    required this.xLabels,
    required this.lineColors,
    this.showArea = false,
    this.animProgress = 1.0,
    this.thresholdY,
    this.seriesNames = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    const lp = 38.0, tp2 = 10.0, rp = 12.0, bp = 28.0;
    final chartW = size.width - lp - rp;
    final chartH = size.height - tp2 - bp;
    final xN = xLabels.length;
    if (xN == 0 && datasets.isEmpty) return;

    double maxY = 10;
    for (final ds in datasets) {
      for (final v in ds) if (v > maxY) maxY = v;
    }
    if (thresholdY != null && thresholdY! > maxY) maxY = thresholdY!;
    maxY *= 1.1;

    for (int i = 0; i <= 4; i++) {
      final y = tp2 + chartH * (1 - i / 4);
      canvas.drawLine(Offset(lp, y), Offset(size.width - rp, y),
        Paint()..color = Colors.grey.withOpacity(0.2)..strokeWidth = 1);
    }

    for (int i = 0; i < xN; i++) {
      if (xN > 1 && i % max(1, xN ~/ 5) != 0) continue;
      final x = lp + (xN > 1 ? i * chartW / (xN - 1) : chartW / 2);
      final lbl = xLabels[i];
      final tp = TextPainter(textDirection: TextDirection.ltr);
      tp.text = TextSpan(text: lbl.length > 5 ? lbl.substring(0, 5) : lbl,
        style: const TextStyle(fontSize: 8, color: Colors.grey));
      tp.layout();
      canvas.save();
      canvas.translate(x - tp.width / 2, tp2 + chartH + 4);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }

    for (int d = 0; d < datasets.length; d++) {
      final ds = datasets[d];
      if (ds.isEmpty) continue;
      final color = d < lineColors.length ? lineColors[d] : Colors.blue;
      final visible = (ds.length * animProgress).round().clamp(1, ds.length);
      final dsN = ds.length;
      final effectiveXN = max(dsN, 1);

      if (showArea) {
        final areaPath = Path();
        areaPath.moveTo(lp, tp2 + chartH);
        for (int i = 0; i < visible; i++) {
          final x = lp + (effectiveXN > 1 ? i * chartW / (effectiveXN - 1) : chartW / 2);
          final y = tp2 + chartH * (1 - ds[i] / maxY);
          areaPath.lineTo(x, y);
        }
        final lastX = lp + (effectiveXN > 1 ? (visible - 1) * chartW / (effectiveXN - 1) : chartW / 2);
        areaPath.lineTo(lastX, tp2 + chartH);
        areaPath.close();
        canvas.drawPath(areaPath, Paint()..color = color.withOpacity(0.18)..style = PaintingStyle.fill);
      }

      final path = Path();
      for (int i = 0; i < visible; i++) {
        final x = lp + (effectiveXN > 1 ? i * chartW / (effectiveXN - 1) : chartW / 2);
        final y = tp2 + chartH * (1 - ds[i] / maxY);
        if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      canvas.drawPath(path, Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

      for (int i = 0; i < visible; i++) {
        final x = lp + (effectiveXN > 1 ? i * chartW / (effectiveXN - 1) : chartW / 2);
        final y = tp2 + chartH * (1 - ds[i] / maxY);
        canvas.drawCircle(Offset(x, y), 3, Paint()..color = color);
        canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }
    }

    if (thresholdY != null) {
      final ty = tp2 + chartH * (1 - thresholdY! / maxY);
      canvas.drawLine(Offset(lp, ty), Offset(size.width - rp, ty),
        Paint()..color = Colors.red.withOpacity(0.7)..strokeWidth = 1.5..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.animProgress != animProgress || old.datasets != datasets;
}

class _PiePainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final List<Color> colors;
  final double innerFraction;
  final double animProgress;
  final String centerText;
  final double startDeg;
  final Set<int> hiddenIndices;

  _PiePainter({
    required this.values,
    required this.labels,
    required this.colors,
    this.innerFraction = 0,
    this.animProgress = 1.0,
    this.centerText = '',
    this.startDeg = -90,
    this.hiddenIndices = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.shortestSide * 0.38;
    final innerR = outerR * innerFraction;
    double total = 0;
    for (int i = 0; i < values.length; i++) {
      if (!hiddenIndices.contains(i)) total += values[i];
    }
    if (total == 0) return;
    double angle = startDeg * pi / 180;
    final maxSweep = 2 * pi * animProgress;

    for (int i = 0; i < values.length; i++) {
      if (hiddenIndices.contains(i)) continue;
      final sweep = (values[i] / total) * maxSweep;
      final color = i < colors.length ? colors[i] : Colors.grey;

      if (innerFraction > 0) {
        final path = Path()
          ..moveTo(center.dx + innerR * cos(angle), center.dy + innerR * sin(angle));
        path.arcTo(Rect.fromCircle(center: center, radius: outerR), angle, sweep, false);
        path.arcTo(Rect.fromCircle(center: center, radius: innerR), angle + sweep, -sweep, false);
        path.close();
        canvas.drawPath(path, Paint()..color = color);
        canvas.drawPath(path, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
      } else {
        canvas.drawArc(Rect.fromCircle(center: center, radius: outerR), angle, sweep, true, Paint()..color = color);
        canvas.drawArc(Rect.fromCircle(center: center, radius: outerR), angle, sweep, true,
          Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }
      if (sweep > 0.12) {
        final mid = angle + sweep / 2;
        final lr = outerR * 0.65 + innerR * 0.3;
        final lp2 = Offset(center.dx + lr * cos(mid), center.dy + lr * sin(mid));
        final lbl = i < labels.length ? labels[i] : '';
        if (lbl.isNotEmpty) {
          final tp = TextPainter(textDirection: TextDirection.ltr);
          tp.text = TextSpan(text: lbl.length > 6 ? lbl.substring(0, 6) : lbl,
            style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold));
          tp.layout();
          canvas.save();
          canvas.translate(lp2.dx - tp.width / 2, lp2.dy - tp.height / 2);
          tp.paint(canvas, Offset.zero);
          canvas.restore();
        }
      }
      angle += sweep;
    }

    if (centerText.isNotEmpty) {
      final tp = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      tp.text = TextSpan(text: centerText,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87));
      tp.layout(maxWidth: innerR * 1.8);
      canvas.save();
      canvas.translate(center.dx - tp.width / 2, center.dy - tp.height / 2);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) => old.animProgress != animProgress || old.hiddenIndices != hiddenIndices;
}

class _ScatterPainter extends CustomPainter {
  final List<List<double>> points;
  final List<Color>? pointColors;
  final double dotRadius;
  final List<double>? regressionLine;

  _ScatterPainter({required this.points, this.pointColors, this.dotRadius = 5, this.regressionLine});

  @override
  void paint(Canvas canvas, Size size) {
    const lp = 38.0, tp2 = 10.0, rp = 10.0, bp = 28.0;
    final chartW = size.width - lp - rp;
    final chartH = size.height - tp2 - bp;
    if (points.isEmpty) return;

    double maxX = 10, maxY = 10;
    for (final p in points) {
      if (p[0] > maxX) maxX = p[0];
      if (p[1] > maxY) maxY = p[1];
    }
    maxX *= 1.1; maxY *= 1.1;

    for (int i = 0; i <= 4; i++) {
      final y = tp2 + chartH * i / 4;
      canvas.drawLine(Offset(lp, y), Offset(size.width - rp, y),
        Paint()..color = Colors.grey.withOpacity(0.2)..strokeWidth = 1);
    }
    canvas.drawLine(Offset(lp, tp2), Offset(lp, tp2 + chartH), Paint()..color = Colors.grey..strokeWidth = 1);
    canvas.drawLine(Offset(lp, tp2 + chartH), Offset(size.width - rp, tp2 + chartH), Paint()..color = Colors.grey..strokeWidth = 1);

    if (regressionLine != null && regressionLine!.length >= 2) {
      final slope = regressionLine![0];
      final intercept = regressionLine![1];
      final x1 = 0.0;
      final y1 = slope * x1 + intercept;
      final x2 = maxX;
      final y2 = slope * x2 + intercept;
      final rx1 = lp + (x1 / maxX) * chartW;
      final ry1 = tp2 + (1 - (y1 / maxY).clamp(0, 2)) * chartH;
      final rx2 = lp + chartW;
      final ry2 = tp2 + (1 - (y2 / maxY).clamp(0, 2)) * chartH;
      canvas.drawLine(Offset(rx1, ry1), Offset(rx2, ry2),
        Paint()..color = Colors.red.withOpacity(0.6)..strokeWidth = 2..style = PaintingStyle.stroke);
    }

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = lp + (p[0] / maxX) * chartW;
      final y = tp2 + (1 - (p[1] / maxY).clamp(0, 1)) * chartH;
      final r = p.length > 2 ? (p[2] / 18).clamp(4.0, 22.0) : dotRadius.toDouble();
      final color = (pointColors != null && i < pointColors!.length) ? pointColors![i] : const Color(0xFF1565C0);
      canvas.drawCircle(Offset(x, y), r, Paint()..color = color.withOpacity(0.65));
      canvas.drawCircle(Offset(x, y), r, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(_ScatterPainter old) => old.points != points;
}

class _RadarPainter extends CustomPainter {
  final List<List<double>> datasets;
  final List<String> labels;
  final List<Color> colors;
  final List<String> legendNames;
  final double animProgress;

  _RadarPainter({
    required this.datasets,
    required this.labels,
    required this.colors,
    this.legendNames = const [],
    this.animProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.shortestSide * 0.32;
    final n = labels.length;
    if (n == 0) return;

    for (int g = 1; g <= 4; g++) {
      final r = maxR * g / 4;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final a = i * 2 * pi / n - pi / 2;
        final pt = Offset(center.dx + r * cos(a), center.dy + r * sin(a));
        if (i == 0) path.moveTo(pt.dx, pt.dy); else path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = Colors.grey.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = 1);
    }

    for (int i = 0; i < n; i++) {
      final a = i * 2 * pi / n - pi / 2;
      canvas.drawLine(center, Offset(center.dx + maxR * cos(a), center.dy + maxR * sin(a)),
        Paint()..color = Colors.grey.withOpacity(0.3)..strokeWidth = 1);
    }

    for (int d = 0; d < datasets.length; d++) {
      final ds = datasets[d];
      if (ds.length < n) continue;
      final color = d < colors.length ? colors[d] : Colors.blue;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final a = i * 2 * pi / n - pi / 2;
        final r = maxR * ds[i].clamp(0, 1) * animProgress;
        final pt = Offset(center.dx + r * cos(a), center.dy + r * sin(a));
        if (i == 0) path.moveTo(pt.dx, pt.dy); else path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = color.withOpacity(0.2)..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);
    }

    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < n; i++) {
      final a = i * 2 * pi / n - pi / 2;
      final lr = maxR + 16;
      final pt = Offset(center.dx + lr * cos(a), center.dy + lr * sin(a));
      tp.text = TextSpan(text: labels[i],
        style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w600));
      tp.layout();
      canvas.save();
      canvas.translate(pt.dx - tp.width / 2, pt.dy - tp.height / 2);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.animProgress != animProgress || old.datasets != datasets;
}

class _HeatmapPainter extends CustomPainter {
  final List<List<double>> data;
  final List<String> rowLabels;
  final List<String> colLabels;
  final Color lowColor;
  final Color highColor;
  final int? highlightRow;
  final int? highlightCol;

  _HeatmapPainter({
    required this.data,
    required this.rowLabels,
    required this.colLabels,
    this.lowColor = const Color(0xFFE3F2FD),
    this.highColor = const Color(0xFF0D47A1),
    this.highlightRow,
    this.highlightCol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || data[0].isEmpty) return;
    final rows = data.length;
    final cols = data[0].length;
    const lp = 62.0, tp2 = 18.0, rp = 10.0, bp = 28.0;
    final cellW = (size.width - lp - rp) / cols;
    final cellH = (size.height - tp2 - bp) / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final val = data[r][c].clamp(0.0, 1.0);
        final rect = Rect.fromLTWH(lp + c * cellW, tp2 + r * cellH, cellW - 1, cellH - 1);
        final isHl = (highlightRow == r || highlightCol == c);
        canvas.drawRect(rect, Paint()..color = Color.lerp(lowColor, highColor, val)!
          ..style = PaintingStyle.fill);
        if (isHl) {
          canvas.drawRect(rect, Paint()..color = Colors.yellow..style = PaintingStyle.stroke..strokeWidth = 2);
        }
        final tp = TextPainter(textDirection: TextDirection.ltr);
        tp.text = TextSpan(text: val.toStringAsFixed(2),
          style: TextStyle(fontSize: 7, color: val > 0.5 ? Colors.white : Colors.black87, fontWeight: FontWeight.w600));
        tp.layout();
        canvas.save();
        canvas.translate(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2);
        tp.paint(canvas, Offset.zero);
        canvas.restore();
      }
      if (r < rowLabels.length) {
        final tp = TextPainter(textDirection: TextDirection.ltr);
        final lbl = rowLabels[r];
        tp.text = TextSpan(text: lbl.length > 7 ? lbl.substring(0, 7) : lbl,
          style: const TextStyle(fontSize: 8, color: Colors.black54));
        tp.layout();
        canvas.save();
        canvas.translate(2, tp2 + r * cellH + cellH / 2 - tp.height / 2);
        tp.paint(canvas, Offset.zero);
        canvas.restore();
      }
    }
    for (int c = 0; c < cols && c < colLabels.length; c++) {
      final tp = TextPainter(textDirection: TextDirection.ltr);
      tp.text = TextSpan(text: colLabels[c],
        style: const TextStyle(fontSize: 8, color: Colors.black54));
      tp.layout();
      canvas.save();
      canvas.translate(lp + c * cellW + cellW / 2 - tp.width / 2, tp2 + rows * cellH + 4);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) => old.highlightRow != highlightRow || old.highlightCol != highlightCol;
}

class _WaterfallPainter extends CustomPainter {
  final List<double> deltas;
  final List<String> labels;
  final double animProgress;

  _WaterfallPainter({required this.deltas, required this.labels, this.animProgress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    const lp = 40.0, tp2 = 12.0, rp = 10.0, bp = 28.0;
    final chartW = size.width - lp - rp;
    final chartH = size.height - tp2 - bp;
    final n = deltas.length;
    if (n == 0) return;

    double maxAbs = 10;
    double running = 0;
    double minV = 0, maxV = 0;
    for (final d in deltas) {
      running += d;
      if (running > maxV) maxV = running;
      if (running < minV) minV = running;
    }
    maxAbs = (maxV - minV).abs();
    if (maxAbs == 0) maxAbs = 1;
    final range = maxV - minV + maxAbs * 0.2;
    final baseY = tp2 + chartH * (1 - (-minV / range).clamp(0, 1));

    for (int i = 0; i <= 4; i++) {
      final y = tp2 + chartH * i / 4;
      canvas.drawLine(Offset(lp, y), Offset(size.width - rp, y),
        Paint()..color = Colors.grey.withOpacity(0.2)..strokeWidth = 1);
    }

    final gap = chartW / n;
    final barW = gap * 0.65;
    double cumulative = 0;
    for (int i = 0; i < n; i++) {
      final delta = deltas[i] * animProgress;
      final startV = cumulative;
      final endV = cumulative + delta;
      final color = delta >= 0 ? const Color(0xFF43A047) : const Color(0xFFE53935);
      final y1 = tp2 + chartH * (1 - (startV - minV) / range);
      final y2 = tp2 + chartH * (1 - (endV - minV) / range);
      final top = min(y1, y2);
      final h = (y1 - y2).abs().clamp(1.0, double.infinity);
      final x = lp + i * gap + (gap - barW) / 2;
      canvas.drawRRect(
        RRect.fromRectAndCorners(Rect.fromLTWH(x, top, barW, h),
          topLeft: const Radius.circular(2), topRight: const Radius.circular(2)),
        Paint()..color = color,
      );
      if (i < n - 1) {
        canvas.drawLine(Offset(x + barW, y2), Offset(x + gap, y2),
          Paint()..color = Colors.grey..strokeWidth = 1..style = PaintingStyle.stroke);
      }
      final tp = TextPainter(textDirection: TextDirection.ltr);
      final lbl = i < labels.length ? labels[i] : '';
      tp.text = TextSpan(text: lbl.length > 4 ? lbl.substring(0, 4) : lbl,
        style: const TextStyle(fontSize: 8, color: Colors.black54));
      tp.layout();
      canvas.save();
      canvas.translate(x + barW / 2 - tp.width / 2, tp2 + chartH + 4);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
      cumulative += deltas[i];
    }
    canvas.drawLine(Offset(lp, baseY), Offset(size.width - rp, baseY),
      Paint()..color = Colors.black38..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(_WaterfallPainter old) => old.animProgress != animProgress;
}

// ─── Advanced Charts (CpA01 – CpA36) ──────────────────────────────────────────

class CpA01 extends StatefulWidget {
  const CpA01({super.key});
  @override
  State<CpA01> createState() => _CpA01State();
}

class _CpA01State extends State<CpA01> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  String _selected = 'Pikachu';
  static const _options = ['Pikachu', 'Mewtwo', 'Charizard', 'Snorlax', 'Gengar'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf(_selected).map((v) => v.toDouble()).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Barras Animadas'),
      DropdownButton<String>(
        value: _selected,
        items: _options.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
        onChanged: (v) { if (v != null) { setState(() { _selected = v; _ctrl.forward(from: 0); }); } },
      ),
      AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => SizedBox(height: 220, child: CustomPaint(
          size: const Size(double.infinity, 220),
          painter: _BarPainter(values: stats, labels: PokemonChartData.statNames,
            colors: PokemonChartData.statColors, animProgress: _anim.value),
        )),
      ),
    ]);
  }
}

class CpA02 extends StatefulWidget {
  const CpA02({super.key});
  @override
  State<CpA02> createState() => _CpA02State();
}

class _CpA02State extends State<CpA02> {
  String _selected = 'Bulbasaur';
  static const _options = ['Bulbasaur','Charmander','Squirtle','Pikachu','Mewtwo','Snorlax','Gengar','Lapras','Dragonite'];

  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf(_selected).map((v) => v.toDouble()).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Selector de Pokémon'),
      DropdownButton<String>(
        value: _selected,
        items: _options.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
        onChanged: (v) { if (v != null) setState(() => _selected = v); },
      ),
      SizedBox(height: 220, child: CustomPaint(
        size: const Size(double.infinity, 220),
        painter: _BarPainter(values: stats, labels: PokemonChartData.statNames,
          colors: PokemonChartData.statColors, maxValue: 180),
      )),
    ]);
  }
}

class CpA03 extends StatefulWidget {
  const CpA03({super.key});
  @override
  State<CpA03> createState() => _CpA03State();
}

class _CpA03State extends State<CpA03> {
  int? _tappedIndex;

  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Dragonite').map((v) => v.toDouble()).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Barras con Tooltip — Dragonite'),
      GestureDetector(
        onTapDown: (d) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final local = box.globalToLocal(d.globalPosition);
          const lp = 40.0, tp2 = 12.0 + 32.0;
          const rp = 10.0;
          final chartW = box.size.width - lp - rp;
          final n = stats.length;
          final gap = chartW / n;
          final i = ((local.dx - lp) / gap).floor();
          if (i >= 0 && i < n) setState(() => _tappedIndex = i);
        },
        child: Column(children: [
          if (_tappedIndex != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: PokemonChartData.statColors[_tappedIndex!].withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${PokemonChartData.statNames[_tappedIndex!]}: ${stats[_tappedIndex!].toInt()}',
                style: TextStyle(color: PokemonChartData.statColors[_tappedIndex!], fontWeight: FontWeight.bold),
              ),
            ),
          SizedBox(height: 220, child: CustomPaint(
            size: const Size(double.infinity, 220),
            painter: _BarPainter(values: stats, labels: PokemonChartData.statNames,
              colors: PokemonChartData.statColors, highlightIndex: _tappedIndex),
          )),
        ]),
      ),
    ]);
  }
}

class CpA04 extends StatelessWidget {
  const CpA04({super.key});
  @override
  Widget build(BuildContext context) {
    const pokes = ['Pikachu','Charizard','Mewtwo','Snorlax','Dragonite'];
    final totals = pokes.map((n) => PokemonChartData.totalOf(n).toDouble()).toList();
    final avg = totals.fold(0.0, (a, b) => a + b) / totals.length;
    final diffs = totals.map((v) => v - avg).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Diferencia vs Promedio'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _WaterfallPainter(deltas: diffs, labels: pokes))),
    ]);
  }
}

class CpA05 extends StatelessWidget {
  const CpA05({super.key});
  @override
  Widget build(BuildContext context) {
    const groups = ['Fuego', 'Agua', 'Planta'];
    final fire = PokemonChartData.avgStatsOf(PokemonChartData.fireTypes);
    final water = PokemonChartData.avgStatsOf(PokemonChartData.waterTypes);
    final grass = PokemonChartData.avgStatsOf(PokemonChartData.grassTypes);
    final totals = [
      fire.fold(0.0, (a, b) => a + b),
      water.fold(0.0, (a, b) => a + b),
      grass.fold(0.0, (a, b) => a + b),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Total Stats 100% por Tipo'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _BarPainter(values: totals, labels: groups,
          colors: [const Color(0xFFF08030), const Color(0xFF6890F0), const Color(0xFF78C850)],
          maxValue: 420))),
    ]);
  }
}

class CpA06 extends StatefulWidget {
  const CpA06({super.key});
  @override
  State<CpA06> createState() => _CpA06State();
}

class _CpA06State extends State<CpA06> {
  int _statIdx = 0;

  @override
  Widget build(BuildContext context) {
    final statNames = ['HP', 'Atk', 'Def', 'SpA', 'SpD', 'Spe'];
    final top = PokemonChartData.topByStatIndex(_statIdx, n: 5);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Ranking Dinámico Top 5'),
      Wrap(
        spacing: 6,
        children: List.generate(6, (i) => GestureDetector(
          onTap: () => setState(() => _statIdx = i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statIdx == i ? PokemonChartData.statColors[i] : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(statNames[i], style: TextStyle(
              color: _statIdx == i ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        )),
      ),
      const SizedBox(height: 8),
      SizedBox(height: 220, child: CustomPaint(size: const Size(double.infinity, 220),
        painter: _HorizontalBarPainter(
          names: top.map((e) => e.key).toList(),
          values: top.map((e) => e.value.toDouble()).toList(),
          barColor: PokemonChartData.statColors[_statIdx],
        ))),
    ]);
  }
}

class CpA07 extends StatelessWidget {
  const CpA07({super.key});
  @override
  Widget build(BuildContext context) {
    final hpFull = PokemonChartData.first20HP.map((v) => v.toDouble()).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Línea HP — Scroll Horizontal'),
      SizedBox(
        height: 250,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 600,
            child: CustomPaint(
              size: const Size(600, 250),
              painter: _LinePainter(datasets: [hpFull], xLabels: PokemonChartData.first20Names,
                lineColors: [const Color(0xFF4CAF50)]),
            ),
          ),
        ),
      ),
    ]);
  }
}

class CpA08 extends StatelessWidget {
  const CpA08({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('6 Stats — Líneas Multiserie'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [
            PokemonChartData.first20HP.map((v) => v.toDouble()).toList(),
            PokemonChartData.first20Atk.map((v) => v.toDouble()).toList(),
            PokemonChartData.first20Def.map((v) => v.toDouble()).toList(),
            PokemonChartData.first20Spd.map((v) => v.toDouble()).toList(),
          ],
          xLabels: PokemonChartData.first20Names,
          lineColors: [
            const Color(0xFF4CAF50), const Color(0xFFF44336),
            const Color(0xFF2196F3), const Color(0xFFFF9800),
          ],
        ))),
    ]);
  }
}

class CpA09 extends StatelessWidget {
  const CpA09({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Línea con Área Gradiente'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [
            PokemonChartData.first20HP.map((v) => v.toDouble()).toList(),
            PokemonChartData.first20Atk.map((v) => v.toDouble()).toList(),
          ],
          xLabels: PokemonChartData.first20Names,
          lineColors: [const Color(0xFF1565C0), const Color(0xFFE53935)],
          showArea: true,
        ))),
    ]);
  }
}

class CpA10 extends StatefulWidget {
  const CpA10({super.key});
  @override
  State<CpA10> createState() => _CpA10State();
}

class _CpA10State extends State<CpA10> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final spd = PokemonChartData.first20Spd.map((v) => v.toDouble()).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Velocidad — Animación Continua'),
      AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => SizedBox(height: 250, child: CustomPaint(
          size: const Size(double.infinity, 250),
          painter: _LinePainter(datasets: [spd], xLabels: PokemonChartData.first20Names,
            lineColors: [const Color(0xFFFF9800)], animProgress: _anim.value, showArea: true),
        )),
      ),
    ]);
  }
}

class CpA11 extends StatelessWidget {
  const CpA11({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Líneas Evolutivas HP'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [
            [45, 60, 80],
            [39, 58, 78],
            [44, 59, 79],
          ],
          xLabels: const ['Básico', 'Medio', 'Final'],
          lineColors: [const Color(0xFF78C850), const Color(0xFFF08030), const Color(0xFF6890F0)],
          seriesNames: const ['Grass', 'Fire', 'Water'],
        ))),
      const SizedBox(height: 8),
      Row(children: const [
        _LegendDot(color: Color(0xFF78C850), label: 'Planta'),
        SizedBox(width: 12),
        _LegendDot(color: Color(0xFFF08030), label: 'Fuego'),
        SizedBox(width: 12),
        _LegendDot(color: Color(0xFF6890F0), label: 'Agua'),
      ]),
    ]);
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11)),
    ]);
  }
}

class CpA12 extends StatefulWidget {
  const CpA12({super.key});
  @override
  State<CpA12> createState() => _CpA12State();
}

class _CpA12State extends State<CpA12> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final types = PokemonChartData.topTypes;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Tipos — Pie Animado'),
      AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => SizedBox(height: 250, child: CustomPaint(
          size: const Size(double.infinity, 250),
          painter: _PiePainter(
            values: types.values.map((v) => v.toDouble()).toList(),
            labels: types.keys.toList(),
            colors: types.keys.map((k) => PokemonChartData.typeColors[k] ?? Colors.grey).toList(),
            animProgress: _anim.value,
          ),
        )),
      ),
    ]);
  }
}

class CpA13 extends StatefulWidget {
  const CpA13({super.key});
  @override
  State<CpA13> createState() => _CpA13State();
}

class _CpA13State extends State<CpA13> {
  final _hidden = <int>{};

  @override
  Widget build(BuildContext context) {
    final types = PokemonChartData.topTypes;
    final keys = types.keys.toList();
    final values = types.values.map((v) => v.toDouble()).toList();
    final colors = keys.map((k) => PokemonChartData.typeColors[k] ?? Colors.grey).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Pie con Leyenda Interactiva'),
      SizedBox(height: 220, child: CustomPaint(size: const Size(double.infinity, 220),
        painter: _PiePainter(values: values, labels: keys, colors: colors, hiddenIndices: _hidden))),
      const SizedBox(height: 6),
      Wrap(
        spacing: 8, runSpacing: 4,
        children: List.generate(keys.length, (i) => GestureDetector(
          onTap: () => setState(() => _hidden.contains(i) ? _hidden.remove(i) : _hidden.add(i)),
          child: Opacity(
            opacity: _hidden.contains(i) ? 0.3 : 1.0,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(keys[i], style: const TextStyle(fontSize: 11)),
            ]),
          ),
        )),
      ),
    ]);
  }
}

class CpA14 extends StatelessWidget {
  const CpA14({super.key});
  @override
  Widget build(BuildContext context) {
    final total = PokemonChartData.totalOf('Mewtwo');
    final stats = PokemonChartData.statsOf('Mewtwo').map((v) => v.toDouble()).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Donut con Total Central — Mewtwo'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _PiePainter(
          values: stats,
          labels: PokemonChartData.statNames,
          colors: PokemonChartData.statColors,
          innerFraction: 0.5,
          centerText: '$total\nTotal',
        ))),
    ]);
  }
}

class CpA15 extends StatelessWidget {
  const CpA15({super.key});
  @override
  Widget build(BuildContext context) {
    final fire = PokemonChartData.avgStatsOf(PokemonChartData.fireTypes);
    final water = PokemonChartData.avgStatsOf(PokemonChartData.waterTypes);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Donut Doble — Fuego vs Agua'),
      SizedBox(height: 250, child: Stack(children: [
        CustomPaint(size: const Size(double.infinity, 250),
          painter: _PiePainter(
            values: fire,
            labels: PokemonChartData.statNames,
            colors: PokemonChartData.statColors,
            innerFraction: 0.52,
            startDeg: -90,
          )),
        CustomPaint(size: const Size(double.infinity, 250),
          painter: _DonutRingPainter(
            values: water,
            colors: PokemonChartData.statColors.map((c) => c.withOpacity(0.45)).toList(),
            outerFraction: 0.48,
            innerFraction: 0.3,
          )),
      ])),
    ]);
  }
}

class _DonutRingPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double outerFraction;
  final double innerFraction;

  _DonutRingPainter({required this.values, required this.colors,
    required this.outerFraction, required this.innerFraction});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final base = size.shortestSide * 0.38;
    final outerR = base * outerFraction / 0.38;
    final innerR = base * innerFraction / 0.38;
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
    double angle = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi;
      final color = i < colors.length ? colors[i] : Colors.grey;
      final path = Path()
        ..moveTo(center.dx + innerR * cos(angle), center.dy + innerR * sin(angle));
      path.arcTo(Rect.fromCircle(center: center, radius: outerR), angle, sweep, false);
      path.arcTo(Rect.fromCircle(center: center, radius: innerR), angle + sweep, -sweep, false);
      path.close();
      canvas.drawPath(path, Paint()..color = color);
      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutRingPainter old) => false;
}

class CpA16 extends StatelessWidget {
  const CpA16({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Snorlax');
    final hp = stats[0];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Semi-Donut Gauge — HP Snorlax'),
      SizedBox(height: 200, child: CustomPaint(size: const Size(double.infinity, 200),
        painter: _GaugePainter(value: hp / 255.0, maxLabel: '255', label: 'HP $hp',
          color: const Color(0xFF4CAF50)))),
    ]);
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final String label;
  final String maxLabel;
  final Color color;

  _GaugePainter({required this.value, required this.label, required this.maxLabel, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.72);
    final r = size.width * 0.35;
    const startAngle = pi;
    const sweepMax = pi;
    canvas.drawArc(Rect.fromCircle(center: center, radius: r), startAngle, sweepMax, false,
      Paint()..color = Colors.grey.shade200..strokeWidth = 24..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r), startAngle, sweepMax * value.clamp(0, 1), false,
      Paint()..color = color..strokeWidth = 24..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    final tp = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    tp.text = TextSpan(text: label,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87));
    tp.layout();
    canvas.save();
    canvas.translate(center.dx - tp.width / 2, center.dy - tp.height / 2 - 10);
    tp.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GaugePainter old) => false;
}

class CpA17 extends StatelessWidget {
  const CpA17({super.key});
  @override
  Widget build(BuildContext context) {
    final typeColorList = [
      const Color(0xFFF08030), const Color(0xFF6890F0), const Color(0xFF78C850),
      const Color(0xFFEE99AC), const Color(0xFFA040A0), const Color(0xFF98D8D8),
    ];
    final pts = [
      ...PokemonChartData.fireTypes.take(3).map((n) {
        final s = PokemonChartData.statsOf(n);
        return ([s[1].toDouble(), s[2].toDouble()], typeColorList[0]);
      }),
      ...PokemonChartData.waterTypes.take(3).map((n) {
        final s = PokemonChartData.statsOf(n);
        return ([s[1].toDouble(), s[2].toDouble()], typeColorList[1]);
      }),
      ...PokemonChartData.grassTypes.take(3).map((n) {
        final s = PokemonChartData.statsOf(n);
        return ([s[1].toDouble(), s[2].toDouble()], typeColorList[2]);
      }),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Scatter por Tipo — Atk vs Def'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _ScatterPainter(
          points: pts.map((e) => e.$1).toList(),
          pointColors: pts.map((e) => e.$2).toList(),
        ))),
      const SizedBox(height: 6),
      Row(children: [
        _LegendDot(color: typeColorList[0], label: 'Fuego'),
        const SizedBox(width: 10),
        _LegendDot(color: typeColorList[1], label: 'Agua'),
        const SizedBox(width: 10),
        _LegendDot(color: typeColorList[2], label: 'Planta'),
      ]),
    ]);
  }
}

class CpA18 extends StatefulWidget {
  const CpA18({super.key});
  @override
  State<CpA18> createState() => _CpA18State();
}

class _CpA18State extends State<CpA18> {
  int? _selectedPoint;
  static const _names = ['Pikachu','Charizard','Mewtwo','Snorlax','Gengar','Lapras','Dragonite','Mew','Blastoise','Venusaur'];

  @override
  Widget build(BuildContext context) {
    final pts = _names.map((n) {
      final s = PokemonChartData.statsOf(n);
      return [s[1].toDouble(), s[5].toDouble()];
    }).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Scatter con Detalle — Atk vs Vel'),
      if (_selectedPoint != null)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(8)),
          child: Text('${_names[_selectedPoint!]}: Atk=${pts[_selectedPoint!][0].toInt()} Vel=${pts[_selectedPoint!][1].toInt()}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      GestureDetector(
        onTapDown: (d) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final local = box.globalToLocal(d.globalPosition);
          const lp = 38.0; const tp2 = 10.0;
          final chartW = box.size.width - lp - 10;
          final chartH = 250.0 - tp2 - 28;
          double maxX = 10, maxY = 10;
          for (final p in pts) {
            if (p[0] > maxX) maxX = p[0];
            if (p[1] > maxY) maxY = p[1];
          }
          maxX *= 1.1; maxY *= 1.1;
          int? best;
          double bestDist = double.infinity;
          for (int i = 0; i < pts.length; i++) {
            final px = lp + (pts[i][0] / maxX) * chartW;
            final py = tp2 + (1 - pts[i][1] / maxY) * chartH;
            final dist = (local.dx - px) * (local.dx - px) + (local.dy - py) * (local.dy - py);
            if (dist < bestDist) { bestDist = dist; best = i; }
          }
          if (best != null && bestDist < 1600) setState(() => _selectedPoint = best);
        },
        child: SizedBox(height: 250, child: CustomPaint(
          size: const Size(double.infinity, 250),
          painter: _ScatterPainter(
            points: pts,
            pointColors: List.generate(pts.length, (i) => i == _selectedPoint ? Colors.red : const Color(0xFF1565C0)),
          ),
        )),
      ),
    ]);
  }
}

class CpA19 extends StatefulWidget {
  const CpA19({super.key});
  @override
  State<CpA19> createState() => _CpA19State();
}

class _CpA19State extends State<CpA19> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final pts = PokemonChartData.attackVsDefense.map((p) => [p[0].toDouble(), p[1].toDouble()]).toList();
    final visible = (pts.length * _anim.value).round().clamp(1, pts.length);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Scatter Animado — Atk vs Def'),
      AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => SizedBox(height: 250, child: CustomPaint(
          size: const Size(double.infinity, 250),
          painter: _ScatterPainter(
            points: pts.take(visible).toList(),
            pointColors: List.filled(visible, const Color(0xFF9C27B0)),
          ),
        )),
      ),
    ]);
  }
}

class CpA20 extends StatelessWidget {
  const CpA20({super.key});
  @override
  Widget build(BuildContext context) {
    final pts = PokemonChartData.hpVsSpeed.map((p) => [p[0].toDouble(), p[1].toDouble()]).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Scatter con Zoom (scroll)'),
      SizedBox(height: 250, child: InteractiveViewer(
        minScale: 0.5, maxScale: 5,
        child: CustomPaint(size: const Size(double.infinity, 250),
          painter: _ScatterPainter(
            points: pts,
            pointColors: List.filled(pts.length, const Color(0xFF00897B)),
          )),
      )),
    ]);
  }
}

class CpA21 extends StatelessWidget {
  const CpA21({super.key});
  @override
  Widget build(BuildContext context) {
    final pts = PokemonChartData.attackVsDefense.map((p) => [p[0].toDouble(), p[1].toDouble()]).toList();
    final n = pts.length.toDouble();
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (final p in pts) { sumX += p[0]; sumY += p[1]; sumXY += p[0] * p[1]; sumX2 += p[0] * p[0]; }
    final denom = n * sumX2 - sumX * sumX;
    final slope = denom != 0 ? (n * sumXY - sumX * sumY) / denom : 0.0;
    final intercept = (sumY - slope * sumX) / n;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Scatter + Regresión Lineal'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _ScatterPainter(
          points: pts,
          pointColors: List.filled(pts.length, const Color(0xFF1565C0)),
          regressionLine: [slope, intercept],
        ))),
    ]);
  }
}

class CpA22 extends StatefulWidget {
  const CpA22({super.key});
  @override
  State<CpA22> createState() => _CpA22State();
}

class _CpA22State extends State<CpA22> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Charizard').map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Radar Animado — Charizard'),
      AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => SizedBox(height: 260, child: CustomPaint(
          size: const Size(double.infinity, 260),
          painter: _RadarPainter(datasets: [stats], labels: PokemonChartData.statNames,
            colors: [const Color(0xFFF08030)], animProgress: _anim.value),
        )),
      ),
    ]);
  }
}

class CpA23 extends StatelessWidget {
  const CpA23({super.key});
  @override
  Widget build(BuildContext context) {
    final c = PokemonChartData.statsOf('Charizard').map((v) => v / 160.0).toList();
    final b = PokemonChartData.statsOf('Blastoise').map((v) => v / 160.0).toList();
    final v = PokemonChartData.statsOf('Venusaur').map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Triple Radar — Starters Finales'),
      SizedBox(height: 260, child: CustomPaint(size: const Size(double.infinity, 260),
        painter: _RadarPainter(
          datasets: [c, b, v],
          labels: PokemonChartData.statNames,
          colors: [const Color(0xFFF08030), const Color(0xFF6890F0), const Color(0xFF78C850)],
        ))),
      const SizedBox(height: 4),
      Row(children: const [
        _LegendDot(color: Color(0xFFF08030), label: 'Charizard'),
        SizedBox(width: 10),
        _LegendDot(color: Color(0xFF6890F0), label: 'Blastoise'),
        SizedBox(width: 10),
        _LegendDot(color: Color(0xFF78C850), label: 'Venusaur'),
      ]),
    ]);
  }
}

class CpA24 extends StatelessWidget {
  const CpA24({super.key});
  @override
  Widget build(BuildContext context) {
    final fire = PokemonChartData.avgStatsOf(PokemonChartData.fireTypes).map((v) => v / 120.0).toList();
    final water = PokemonChartData.avgStatsOf(PokemonChartData.waterTypes).map((v) => v / 120.0).toList();
    final psych = PokemonChartData.avgStatsOf(['Mewtwo','Mew','Gengar','Jolteon','Vaporeon']).map((v) => v / 120.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Radar por Tipo — 3 Grupos'),
      SizedBox(height: 260, child: CustomPaint(size: const Size(double.infinity, 260),
        painter: _RadarPainter(
          datasets: [fire, water, psych],
          labels: PokemonChartData.statNames,
          colors: [const Color(0xFFF08030), const Color(0xFF6890F0), const Color(0xFFF85888)],
        ))),
    ]);
  }
}

class CpA25 extends StatefulWidget {
  const CpA25({super.key});
  @override
  State<CpA25> createState() => _CpA25State();
}

class _CpA25State extends State<CpA25> {
  String _a = 'Pikachu', _b = 'Mewtwo';
  static const _opts = ['Pikachu','Mewtwo','Charizard','Blastoise','Venusaur','Snorlax','Gengar','Lapras','Dragonite','Mew'];

  @override
  Widget build(BuildContext context) {
    final sa = PokemonChartData.statsOf(_a).map((v) => v / 160.0).toList();
    final sb = PokemonChartData.statsOf(_b).map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Radar Interactivo — Selección'),
      Row(children: [
        Expanded(child: DropdownButton<String>(
          value: _a, isExpanded: true,
          items: _opts.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (v) { if (v != null) setState(() => _a = v); },
        )),
        const SizedBox(width: 8),
        Expanded(child: DropdownButton<String>(
          value: _b, isExpanded: true,
          items: _opts.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (v) { if (v != null) setState(() => _b = v); },
        )),
      ]),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _RadarPainter(
          datasets: [sa, sb],
          labels: PokemonChartData.statNames,
          colors: [const Color(0xFF1565C0), const Color(0xFFE53935)],
        ))),
    ]);
  }
}

class CpA26 extends StatefulWidget {
  const CpA26({super.key});
  @override
  State<CpA26> createState() => _CpA26State();
}

class _CpA26State extends State<CpA26> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final pts = PokemonChartData.bubbleHpAtk.map((p) => [p[0].toDouble(), p[1].toDouble(), p[2].toDouble()]).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Burbujas Escalonadas — HP vs Atk'),
      AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final visible = (pts.length * _anim.value).round().clamp(1, pts.length);
          return SizedBox(height: 250, child: CustomPaint(
            size: const Size(double.infinity, 250),
            painter: _ScatterPainter(
              points: pts.take(visible).toList(),
              pointColors: List.filled(visible, const Color(0xFF1565C0)),
            ),
          ));
        },
      ),
    ]);
  }
}

class CpA27 extends StatefulWidget {
  const CpA27({super.key});
  @override
  State<CpA27> createState() => _CpA27State();
}

class _CpA27State extends State<CpA27> {
  int? _selected;
  static const _names = ['Bulbasaur','Mewtwo','Pikachu','Snorlax','Gengar','Lapras','Dragonite','Mew','Charizard','Blastoise'];

  @override
  Widget build(BuildContext context) {
    final pts = _names.map((n) {
      final s = PokemonChartData.statsOf(n);
      return [s[0].toDouble(), s[1].toDouble(), s[2].toDouble()];
    }).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Burbujas Interactivas — HP vs Atk'),
      if (_selected != null)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
          child: Text('${_names[_selected!]}: HP=${pts[_selected!][0].toInt()} Atk=${pts[_selected!][1].toInt()}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      GestureDetector(
        onTapDown: (d) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final local = box.globalToLocal(d.globalPosition);
          const lp = 38.0; const tp2 = 10.0;
          final chartW = box.size.width - lp - 10;
          const chartH = 250.0 - tp2 - 28;
          double maxX = 10, maxY = 10;
          for (final p in pts) { if (p[0] > maxX) maxX = p[0]; if (p[1] > maxY) maxY = p[1]; }
          maxX *= 1.1; maxY *= 1.1;
          int? best;
          double bestDist = double.infinity;
          for (int i = 0; i < pts.length; i++) {
            final px = lp + (pts[i][0] / maxX) * chartW;
            final py = tp2 + (1 - pts[i][1] / maxY) * chartH;
            final dist = (local.dx - px) * (local.dx - px) + (local.dy - py) * (local.dy - py);
            if (dist < bestDist) { bestDist = dist; best = i; }
          }
          if (best != null) setState(() => _selected = best);
        },
        child: SizedBox(height: 250, child: CustomPaint(
          size: const Size(double.infinity, 250),
          painter: _ScatterPainter(
            points: pts,
            pointColors: List.generate(pts.length, (i) => i == _selected ? Colors.red : const Color(0xFF1565C0)),
          ),
        )),
      ),
    ]);
  }
}

class CpA28 extends StatelessWidget {
  const CpA28({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = [const Color(0xFFF08030), const Color(0xFF6890F0), const Color(0xFF78C850), const Color(0xFFEE99AC)];
    final ptsData = [
      ...PokemonChartData.fireTypes.map((n) { final s = PokemonChartData.statsOf(n); return (p: [s[0].toDouble(), s[1].toDouble(), s[2].toDouble()], c: colors[0]); }),
      ...PokemonChartData.waterTypes.map((n) { final s = PokemonChartData.statsOf(n); return (p: [s[0].toDouble(), s[1].toDouble(), s[2].toDouble()], c: colors[1]); }),
      ...PokemonChartData.grassTypes.map((n) { final s = PokemonChartData.statsOf(n); return (p: [s[0].toDouble(), s[1].toDouble(), s[2].toDouble()], c: colors[2]); }),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Burbujas por Tipo'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _ScatterPainter(
          points: ptsData.map((e) => e.p).toList(),
          pointColors: ptsData.map((e) => e.c).toList(),
        ))),
      const SizedBox(height: 4),
      Row(children: [
        _LegendDot(color: colors[0], label: 'Fuego'),
        const SizedBox(width: 10),
        _LegendDot(color: colors[1], label: 'Agua'),
        const SizedBox(width: 10),
        _LegendDot(color: colors[2], label: 'Planta'),
      ]),
    ]);
  }
}

class CpA29 extends StatefulWidget {
  const CpA29({super.key});
  @override
  State<CpA29> createState() => _CpA29State();
}

class _CpA29State extends State<CpA29> {
  int? _hlRow, _hlCol;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Heatmap Interactivo — Correlación'),
      GestureDetector(
        onTapDown: (d) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final local = box.globalToLocal(d.globalPosition);
          const lp = 62.0; const tp2 = 18.0;
          final cellW = (box.size.width - lp - 10) / 6;
          const cellH = (270.0 - tp2 - 28) / 6;
          final r = ((local.dy - tp2) / cellH).floor().clamp(0, 5);
          final c = ((local.dx - lp) / cellW).floor().clamp(0, 5);
          setState(() { _hlRow = r; _hlCol = c; });
        },
        child: SizedBox(height: 270, child: CustomPaint(
          size: const Size(double.infinity, 270),
          painter: _HeatmapPainter(
            data: PokemonChartData.correlationMatrix,
            rowLabels: PokemonChartData.statNames,
            colLabels: PokemonChartData.statNames,
            highlightRow: _hlRow,
            highlightCol: _hlCol,
          ),
        )),
      ),
      if (_hlRow != null && _hlCol != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '${PokemonChartData.statNames[_hlRow!]} ↔ ${PokemonChartData.statNames[_hlCol!]}: '
            '${PokemonChartData.correlationMatrix[_hlRow!][_hlCol!].toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
    ]);
  }
}

class CpA30 extends StatelessWidget {
  const CpA30({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Heatmap Gradiente — Stats Tipo'),
      SizedBox(height: 270, child: CustomPaint(size: const Size(double.infinity, 270),
        painter: _HeatmapPainter(
          data: PokemonChartData.heatmapAvg.map((row) => row.map((v) => v / 130.0).toList()).toList(),
          rowLabels: PokemonChartData.heatmapTypes,
          colLabels: PokemonChartData.statNames,
          lowColor: const Color(0xFFFFF9C4),
          highColor: const Color(0xFFE65100),
        ))),
    ]);
  }
}

class CpA31 extends StatelessWidget {
  const CpA31({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Área Apilada — HP+Atk+Vel'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [
            PokemonChartData.first20HP.map((v) => v.toDouble()).toList(),
            PokemonChartData.first20Atk.map((v) => v.toDouble()).toList(),
            PokemonChartData.first20Spd.map((v) => v.toDouble()).toList(),
          ],
          xLabels: PokemonChartData.first20Names,
          lineColors: [const Color(0xFF4CAF50), const Color(0xFFF44336), const Color(0xFFFF9800)],
          showArea: true,
        ))),
    ]);
  }
}

class CpA32 extends StatelessWidget {
  const CpA32({super.key});
  @override
  Widget build(BuildContext context) {
    final hp = PokemonChartData.first20HP.map((v) => v.toDouble()).toList();
    final avg = hp.fold(0.0, (a, b) => a + b) / hp.length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Área HP + Umbral Promedio'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [hp],
          xLabels: PokemonChartData.first20Names,
          lineColors: [const Color(0xFF1565C0)],
          showArea: true,
          thresholdY: avg,
        ))),
    ]);
  }
}

class CpA33 extends StatefulWidget {
  const CpA33({super.key});
  @override
  State<CpA33> createState() => _CpA33State();
}

class _CpA33State extends State<CpA33> {
  String _poke = 'Mewtwo';
  static const _opts = ['Pikachu','Mewtwo','Charizard','Snorlax','Dragonite','Mew'];

  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf(_poke).map((v) => v.toDouble()).toList();
    final normalized = stats.map((v) => v / 160.0).toList();
    final total = PokemonChartData.totalOf(_poke);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Dashboard Completo'),
      DropdownButton<String>(
        value: _poke,
        items: _opts.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
        onChanged: (v) { if (v != null) setState(() => _poke = v); },
      ),
      Row(children: [
        Expanded(child: SizedBox(height: 180, child: CustomPaint(
          size: const Size(double.infinity, 180),
          painter: _BarPainter(values: stats, labels: PokemonChartData.statNames, colors: PokemonChartData.statColors),
        ))),
        Expanded(child: SizedBox(height: 180, child: CustomPaint(
          size: const Size(double.infinity, 180),
          painter: _RadarPainter(datasets: [normalized], labels: PokemonChartData.statNames,
            colors: [const Color(0xFF1565C0)]),
        ))),
      ]),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_poke, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text('Total: $total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueGrey)),
        ]),
      ),
    ]);
  }
}

class CpA34 extends StatefulWidget {
  const CpA34({super.key});
  @override
  State<CpA34> createState() => _CpA34State();
}

class _CpA34State extends State<CpA34> {
  String _a = 'Charizard', _b = 'Blastoise';
  static const _opts = ['Bulbasaur','Charmander','Squirtle','Charizard','Blastoise','Venusaur','Pikachu','Mewtwo','Snorlax','Gengar','Lapras','Dragonite','Mew'];

  @override
  Widget build(BuildContext context) {
    final sa = PokemonChartData.statsOf(_a).map((v) => v.toDouble()).toList();
    final sb = PokemonChartData.statsOf(_b).map((v) => v.toDouble()).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Comparador Lado a Lado'),
      Row(children: [
        Expanded(child: DropdownButton<String>(
          value: _a, isExpanded: true,
          items: _opts.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (v) { if (v != null) setState(() => _a = v); },
        )),
        const SizedBox(width: 8),
        Expanded(child: DropdownButton<String>(
          value: _b, isExpanded: true,
          items: _opts.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (v) { if (v != null) setState(() => _b = v); },
        )),
      ]),
      SizedBox(height: 220, child: CustomPaint(size: const Size(double.infinity, 220),
        painter: _GroupedBarPainter(
          groupLabels: PokemonChartData.statNames,
          datasets: [sa, sb],
          seriesColors: [const Color(0xFFF08030), const Color(0xFF6890F0)],
        ))),
      const SizedBox(height: 6),
      Row(children: [
        _LegendDot(color: const Color(0xFFF08030), label: _a),
        const SizedBox(width: 10),
        _LegendDot(color: const Color(0xFF6890F0), label: _b),
      ]),
    ]);
  }
}

class CpA35 extends StatelessWidget {
  const CpA35({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Timeline Evolutivo — Stats Totales'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [
            [318, 405, 525],
            [309, 405, 534],
            [314, 405, 530],
          ],
          xLabels: const ['Base', 'Medio', 'Final'],
          lineColors: [const Color(0xFF78C850), const Color(0xFFF08030), const Color(0xFF6890F0)],
          seriesNames: const ['Planta', 'Fuego', 'Agua'],
          showArea: false,
        ))),
      const SizedBox(height: 4),
      Row(children: const [
        _LegendDot(color: Color(0xFF78C850), label: 'Planta (Bulba)'),
        SizedBox(width: 10),
        _LegendDot(color: Color(0xFFF08030), label: 'Fuego (Char)'),
        SizedBox(width: 10),
        _LegendDot(color: Color(0xFF6890F0), label: 'Agua (Squi)'),
      ]),
    ]);
  }
}

class CpA36 extends StatefulWidget {
  const CpA36({super.key});
  @override
  State<CpA36> createState() => _CpA36State();
}

class _CpA36State extends State<CpA36> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final snorlax = PokemonChartData.statsOf('Snorlax');
    final pikachu = PokemonChartData.statsOf('Pikachu');
    final deltas = List.generate(6, (i) => (snorlax[i] - pikachu[i]).toDouble());
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Waterfall — Snorlax vs Pikachu'),
      Text('Diferencias por stat (Snorlax − Pikachu)',
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      const SizedBox(height: 8),
      AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => SizedBox(height: 250, child: CustomPaint(
          size: const Size(double.infinity, 250),
          painter: _WaterfallPainter(
            deltas: deltas,
            labels: PokemonChartData.statNames,
            animProgress: _anim.value,
          ),
        )),
      ),
      const SizedBox(height: 4),
      Row(children: const [
        _LegendDot(color: Color(0xFF43A047), label: 'Snorlax > Pikachu'),
        SizedBox(width: 12),
        _LegendDot(color: Color(0xFFE53935), label: 'Pikachu > Snorlax'),
      ]),
    ]);
  }
}
