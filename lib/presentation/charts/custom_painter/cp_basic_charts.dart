import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/data/pokemon_chart_data.dart';

// ─── Helper ────────────────────────────────────────────────────────────────────

Widget _chartTitle(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 12),
  child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
);

// ─── Painters ──────────────────────────────────────────────────────────────────

class _BarPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final List<Color> colors;
  final double maxValue;
  final double animProgress;
  final double? thresholdY;

  _BarPainter({
    required this.values,
    required this.labels,
    required this.colors,
    this.maxValue = 180,
    this.animProgress = 1.0,
    this.thresholdY,
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
      final tp = TextPainter(textDirection: TextDirection.ltr);
      tp.text = TextSpan(text: (maxValue * i / 4).toInt().toString(),
        style: const TextStyle(fontSize: 8, color: Colors.grey));
      tp.layout();
      canvas.save();
      canvas.translate(lp - tp.width - 4, y - tp.height / 2);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }

    for (int i = 0; i < n; i++) {
      final barH = chartH * (values[i] / maxValue).clamp(0, 1) * animProgress;
      final x = lp + i * gap + (gap - barW) / 2;
      final y = tp2 + chartH - barH;
      final color = i < colors.length ? colors[i] : Colors.blue;
      canvas.drawRRect(
        RRect.fromRectAndCorners(Rect.fromLTWH(x, y, barW, barH),
          topLeft: const Radius.circular(3), topRight: const Radius.circular(3)),
        Paint()..color = color,
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
    }

    if (thresholdY != null) {
      final ty = tp2 + chartH * (1 - (thresholdY! / maxValue).clamp(0, 1));
      canvas.drawLine(Offset(lp, ty), Offset(size.width - rp, ty),
        Paint()..color = Colors.red..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.animProgress != animProgress || old.values != values;
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
  bool shouldRepaint(_GroupedBarPainter old) => false;
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

  _LinePainter({
    required this.datasets,
    required this.xLabels,
    required this.lineColors,
    this.showArea = false,
    this.animProgress = 1.0,
    this.thresholdY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const lp = 38.0, tp2 = 10.0, rp = 12.0, bp = 28.0;
    final chartW = size.width - lp - rp;
    final chartH = size.height - tp2 - bp;
    final xN = xLabels.length;
    if (xN == 0) return;

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

      if (showArea) {
        final areaPath = Path();
        areaPath.moveTo(lp, tp2 + chartH);
        for (int i = 0; i < visible; i++) {
          final x = lp + (dsN > 1 ? i * chartW / (dsN - 1) : chartW / 2);
          final y = tp2 + chartH * (1 - ds[i] / maxY);
          areaPath.lineTo(x, y);
        }
        final lastX = lp + (dsN > 1 ? (visible - 1) * chartW / (dsN - 1) : chartW / 2);
        areaPath.lineTo(lastX, tp2 + chartH);
        areaPath.close();
        canvas.drawPath(areaPath, Paint()..color = color.withOpacity(0.2)..style = PaintingStyle.fill);
      }

      final path = Path();
      for (int i = 0; i < visible; i++) {
        final x = lp + (dsN > 1 ? i * chartW / (dsN - 1) : chartW / 2);
        final y = tp2 + chartH * (1 - ds[i] / maxY);
        if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      canvas.drawPath(path, Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

      for (int i = 0; i < visible; i++) {
        final x = lp + (dsN > 1 ? i * chartW / (dsN - 1) : chartW / 2);
        final y = tp2 + chartH * (1 - ds[i] / maxY);
        canvas.drawCircle(Offset(x, y), 3, Paint()..color = color);
      }
    }

    if (thresholdY != null) {
      final ty = tp2 + chartH * (1 - thresholdY! / maxY);
      canvas.drawLine(Offset(lp, ty), Offset(size.width - rp, ty),
        Paint()..color = Colors.red..strokeWidth = 1.5..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.animProgress != animProgress || old.datasets != old.datasets;
}

class _PiePainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final List<Color> colors;
  final double innerFraction;
  final double animProgress;
  final String centerText;
  final double startDeg;

  _PiePainter({
    required this.values,
    required this.labels,
    required this.colors,
    this.innerFraction = 0,
    this.animProgress = 1.0,
    this.centerText = '',
    this.startDeg = -90,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.shortestSide * 0.38;
    final innerR = outerR * innerFraction;
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
    double angle = startDeg * pi / 180;
    final maxSweep = 2 * pi * animProgress;

    for (int i = 0; i < values.length; i++) {
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
        final lr = outerR * 0.62 + innerR * 0.35;
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
      tp.layout(maxWidth: innerR * 1.6);
      canvas.save();
      canvas.translate(center.dx - tp.width / 2, center.dy - tp.height / 2);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) => old.animProgress != animProgress;
}

class _ScatterPainter extends CustomPainter {
  final List<List<double>> points;
  final List<Color>? pointColors;
  final double dotRadius;

  _ScatterPainter({required this.points, this.pointColors, this.dotRadius = 5});

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

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = lp + (p[0] / maxX) * chartW;
      final y = tp2 + (1 - p[1] / maxY) * chartH;
      final r = p.length > 2 ? (p[2] / 18).clamp(4.0, 22.0) : dotRadius.toDouble();
      final color = (pointColors != null && i < pointColors!.length) ? pointColors![i] : const Color(0xFF1565C0);
      canvas.drawCircle(Offset(x, y), r, Paint()..color = color.withOpacity(0.65));
    }
  }

  @override
  bool shouldRepaint(_ScatterPainter old) => old.points != points;
}

class _RadarPainter extends CustomPainter {
  final List<List<double>> datasets;
  final List<String> labels;
  final List<Color> colors;
  final double animProgress;

  _RadarPainter({required this.datasets, required this.labels, required this.colors, this.animProgress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.shortestSide * 0.34;
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
      canvas.drawPath(path, Paint()..color = color.withOpacity(0.25)..style = PaintingStyle.fill);
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
  bool shouldRepaint(_RadarPainter old) => old.animProgress != animProgress;
}

class _HeatmapPainter extends CustomPainter {
  final List<List<double>> data;
  final List<String> rowLabels;
  final List<String> colLabels;
  final Color lowColor;
  final Color highColor;

  _HeatmapPainter({
    required this.data,
    required this.rowLabels,
    required this.colLabels,
    this.lowColor = const Color(0xFFE3F2FD),
    this.highColor = const Color(0xFF0D47A1),
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
        canvas.drawRect(rect, Paint()..color = Color.lerp(lowColor, highColor, val)!);
        final tp = TextPainter(textDirection: TextDirection.ltr);
        tp.text = TextSpan(text: val.toStringAsFixed(2),
          style: const TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.w600));
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
  bool shouldRepaint(_HeatmapPainter old) => false;
}

// ─── Basic Charts (CpB01 – CpB43) ──────────────────────────────────────────────

class CpB01 extends StatelessWidget {
  const CpB01({super.key});
  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf('Bulbasaur').map((v) => v.toDouble()).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats de Bulbasaur'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _BarPainter(values: s, labels: PokemonChartData.statNames, colors: PokemonChartData.statColors))),
    ]);
  }
}

class CpB02 extends StatelessWidget {
  const CpB02({super.key});
  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf('Mewtwo').map((v) => v.toDouble()).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats de Mewtwo'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _BarPainter(values: s, labels: PokemonChartData.statNames, colors: PokemonChartData.statColors, maxValue: 200))),
    ]);
  }
}

class CpB03 extends StatelessWidget {
  const CpB03({super.key});
  @override
  Widget build(BuildContext context) {
    final bulba = PokemonChartData.statsOf('Bulbasaur').map((v) => v.toDouble()).toList();
    final charm = PokemonChartData.statsOf('Charmander').map((v) => v.toDouble()).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Bulbasaur vs Charmander'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _GroupedBarPainter(
          groupLabels: PokemonChartData.statNames,
          datasets: [bulba, charm],
          seriesColors: [const Color(0xFF78C850), const Color(0xFFF08030)],
        ))),
    ]);
  }
}

class CpB04 extends StatelessWidget {
  const CpB04({super.key});
  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(1, n: 5);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 5 por Ataque'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _HorizontalBarPainter(
          names: top.map((e) => e.key).toList(),
          values: top.map((e) => e.value.toDouble()).toList(),
          barColor: const Color(0xFFF44336),
        ))),
    ]);
  }
}

class CpB05 extends StatelessWidget {
  const CpB05({super.key});
  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(2, n: 5);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 5 por Defensa'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _HorizontalBarPainter(
          names: top.map((e) => e.key).toList(),
          values: top.map((e) => e.value.toDouble()).toList(),
          barColor: const Color(0xFF2196F3),
        ))),
    ]);
  }
}

class CpB06 extends StatelessWidget {
  const CpB06({super.key});
  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(0, n: 5);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 5 por HP'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _HorizontalBarPainter(
          names: top.map((e) => e.key).toList(),
          values: top.map((e) => e.value.toDouble()).toList(),
          barColor: const Color(0xFF4CAF50),
        ))),
    ]);
  }
}

class CpB07 extends StatelessWidget {
  const CpB07({super.key});
  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(5, n: 5);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 5 por Velocidad'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _HorizontalBarPainter(
          names: top.map((e) => e.key).toList(),
          values: top.map((e) => e.value.toDouble()).toList(),
          barColor: const Color(0xFFFF9800),
        ))),
    ]);
  }
}

class CpB08 extends StatelessWidget {
  const CpB08({super.key});
  @override
  Widget build(BuildContext context) {
    final fire = PokemonChartData.avgStatsOf(PokemonChartData.fireTypes);
    final water = PokemonChartData.avgStatsOf(PokemonChartData.waterTypes);
    final grass = PokemonChartData.avgStatsOf(PokemonChartData.grassTypes);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Fuego vs Agua vs Planta'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _GroupedBarPainter(
          groupLabels: PokemonChartData.statNames,
          datasets: [fire, water, grass],
          seriesColors: [const Color(0xFFF08030), const Color(0xFF6890F0), const Color(0xFF78C850)],
        ))),
    ]);
  }
}

class CpB09 extends StatelessWidget {
  const CpB09({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Evolución HP Bulbasaur'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [[45, 60, 80]],
          xLabels: const ['Bulbasaur', 'Ivysaur', 'Venusaur'],
          lineColors: [const Color(0xFF78C850)],
          showArea: true,
        ))),
    ]);
  }
}

class CpB10 extends StatelessWidget {
  const CpB10({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Evolución Ataque Charmander'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [[52, 64, 84]],
          xLabels: const ['Charmander', 'Charmeleon', 'Charizard'],
          lineColors: [const Color(0xFFF08030)],
          showArea: true,
        ))),
    ]);
  }
}

class CpB11 extends StatelessWidget {
  const CpB11({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Evolución Defensa Squirtle'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [[65, 80, 100]],
          xLabels: const ['Squirtle', 'Wartortle', 'Blastoise'],
          lineColors: [const Color(0xFF6890F0)],
          showArea: true,
        ))),
    ]);
  }
}

class CpB12 extends StatelessWidget {
  const CpB12({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP Primeros 20 Pokémon'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [PokemonChartData.first20HP.map((v) => v.toDouble()).toList()],
          xLabels: PokemonChartData.first20Names,
          lineColors: [const Color(0xFF4CAF50)],
        ))),
    ]);
  }
}

class CpB13 extends StatelessWidget {
  const CpB13({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Velocidad Primeros 20'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [PokemonChartData.first20Spd.map((v) => v.toDouble()).toList()],
          xLabels: PokemonChartData.first20Names,
          lineColors: [const Color(0xFFFF9800)],
        ))),
    ]);
  }
}

class CpB14 extends StatelessWidget {
  const CpB14({super.key});
  @override
  Widget build(BuildContext context) {
    final types = PokemonChartData.topTypes;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Distribución Tipos Gen I'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _PiePainter(
          values: types.values.map((v) => v.toDouble()).toList(),
          labels: types.keys.toList(),
          colors: types.keys.map((k) => PokemonChartData.typeColors[k] ?? Colors.grey).toList(),
        ))),
    ]);
  }
}

class CpB15 extends StatelessWidget {
  const CpB15({super.key});
  @override
  Widget build(BuildContext context) {
    const top5 = {'Agua': 28, 'Normal': 22, 'Veneno': 14, 'Psíquico': 14, 'Fuego': 12};
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 5 Tipos más Comunes'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _PiePainter(
          values: top5.values.map((v) => v.toDouble()).toList(),
          labels: top5.keys.toList(),
          colors: top5.keys.map((k) => PokemonChartData.typeColors[k] ?? Colors.grey).toList(),
        ))),
    ]);
  }
}

class CpB16 extends StatelessWidget {
  const CpB16({super.key});
  @override
  Widget build(BuildContext context) {
    final types = PokemonChartData.topTypes;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Tipos Gen I (Donut)'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _PiePainter(
          values: types.values.map((v) => v.toDouble()).toList(),
          labels: types.keys.toList(),
          colors: types.keys.map((k) => PokemonChartData.typeColors[k] ?? Colors.grey).toList(),
          innerFraction: 0.5,
        ))),
    ]);
  }
}

class CpB17 extends StatelessWidget {
  const CpB17({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('1 Tipo vs 2 Tipos'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _PiePainter(
          values: const [72, 79],
          labels: const ['1 Tipo', '2 Tipos'],
          colors: [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
          innerFraction: 0.5,
          centerText: '151',
        ))),
    ]);
  }
}

class CpB18 extends StatelessWidget {
  const CpB18({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Legendarios vs Normales'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _PiePainter(
          values: const [5, 146],
          labels: const ['Legendarios', 'Normales'],
          colors: [const Color(0xFFF8D030), const Color(0xFFA8A878)],
        ))),
    ]);
  }
}

class CpB19 extends StatelessWidget {
  const CpB19({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP de los Starters'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [[45, 60, 80, 39, 58, 78, 44, 59, 79]],
          xLabels: const ['Bulb', 'Ivys', 'Venus', 'Char', 'Charml', 'Chariz', 'Squi', 'Wart', 'Blast'],
          lineColors: [const Color(0xFF78C850)],
          showArea: true,
        ))),
    ]);
  }
}

class CpB20 extends StatelessWidget {
  const CpB20({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Ataque Primeros 15'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [PokemonChartData.first20Atk.take(15).map((v) => v.toDouble()).toList()],
          xLabels: PokemonChartData.first20Names.take(15).toList(),
          lineColors: [const Color(0xFFF44336)],
          showArea: true,
        ))),
    ]);
  }
}

class CpB21 extends StatelessWidget {
  const CpB21({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP Comparativa Starters'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [
            [45, 60, 80],
            [39, 58, 78],
            [44, 59, 79],
          ],
          xLabels: const ['Básico', 'Medio', 'Final'],
          lineColors: [const Color(0xFF78C850), const Color(0xFFF08030), const Color(0xFF6890F0)],
          showArea: true,
        ))),
    ]);
  }
}

class CpB22 extends StatelessWidget {
  const CpB22({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Defensa Primeros 20'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [PokemonChartData.first20Def.map((v) => v.toDouble()).toList()],
          xLabels: PokemonChartData.first20Names,
          lineColors: [const Color(0xFF2196F3)],
          showArea: true,
        ))),
    ]);
  }
}

class CpB23 extends StatelessWidget {
  const CpB23({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Sp. Ataque Primeros 20'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _LinePainter(
          datasets: [[65,80,100,60,80,109,50,65,85,20,25,90,50,90,85,40,65,45,110,100]],
          xLabels: PokemonChartData.first20Names,
          lineColors: [const Color(0xFF9C27B0)],
          showArea: true,
        ))),
    ]);
  }
}

class CpB24 extends StatelessWidget {
  const CpB24({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Distribución HP Gen I'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _BarPainter(
          values: PokemonChartData.hpBins.map((v) => v.toDouble()).toList(),
          labels: PokemonChartData.binLabels,
          colors: List.filled(9, const Color(0xFF4CAF50)),
          maxValue: 50,
        ))),
    ]);
  }
}

class CpB25 extends StatelessWidget {
  const CpB25({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Distribución Ataque'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _BarPainter(
          values: PokemonChartData.atkBins.map((v) => v.toDouble()).toList(),
          labels: PokemonChartData.binLabels,
          colors: List.filled(9, const Color(0xFFF44336)),
          maxValue: 50,
        ))),
    ]);
  }
}

class CpB26 extends StatelessWidget {
  const CpB26({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Distribución Defensa'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _BarPainter(
          values: PokemonChartData.defBins.map((v) => v.toDouble()).toList(),
          labels: PokemonChartData.binLabels,
          colors: List.filled(9, const Color(0xFF2196F3)),
          maxValue: 50,
        ))),
    ]);
  }
}

class CpB27 extends StatelessWidget {
  const CpB27({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Distribución Velocidad'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _BarPainter(
          values: PokemonChartData.speedBins.map((v) => v.toDouble()).toList(),
          labels: PokemonChartData.binLabels,
          colors: List.filled(9, const Color(0xFFFF9800)),
          maxValue: 50,
        ))),
    ]);
  }
}

class CpB28 extends StatelessWidget {
  const CpB28({super.key});
  @override
  Widget build(BuildContext context) {
    final pts = PokemonChartData.attackVsDefense.map((p) => [p[0].toDouble(), p[1].toDouble()]).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Ataque vs Defensa'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _ScatterPainter(points: pts, pointColors: List.filled(pts.length, const Color(0xFF1565C0))))),
    ]);
  }
}

class CpB29 extends StatelessWidget {
  const CpB29({super.key});
  @override
  Widget build(BuildContext context) {
    final pts = PokemonChartData.hpVsSpeed.map((p) => [p[0].toDouble(), p[1].toDouble()]).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP vs Velocidad'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _ScatterPainter(points: pts, pointColors: List.filled(pts.length, const Color(0xFF4CAF50))))),
    ]);
  }
}

class CpB30 extends StatelessWidget {
  const CpB30({super.key});
  @override
  Widget build(BuildContext context) {
    final pts = List.generate(PokemonChartData.first20Atk.length, (i) => [
      PokemonChartData.first20Atk[i].toDouble(),
      PokemonChartData.first20Spd[i].toDouble(),
    ]);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Ataque vs Velocidad'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _ScatterPainter(points: pts, pointColors: List.filled(pts.length, const Color(0xFFFF9800))))),
    ]);
  }
}

class CpB31 extends StatelessWidget {
  const CpB31({super.key});
  @override
  Widget build(BuildContext context) {
    final pts = PokemonChartData.spAtkVsSpDef.map((p) => [p[0].toDouble(), p[1].toDouble()]).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Sp.Atk vs Sp.Def'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _ScatterPainter(points: pts, pointColors: List.filled(pts.length, const Color(0xFF9C27B0))))),
    ]);
  }
}

class CpB32 extends StatelessWidget {
  const CpB32({super.key});
  @override
  Widget build(BuildContext context) {
    final pts = PokemonChartData.bubbleHpAtk.map((p) => [p[0].toDouble(), p[1].toDouble(), p[2].toDouble()]).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP vs Ataque (burbuja = Defensa)'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _ScatterPainter(points: pts, pointColors: List.filled(pts.length, const Color(0xFF1565C0).withOpacity(0.7))))),
    ]);
  }
}

class CpB33 extends StatelessWidget {
  const CpB33({super.key});
  @override
  Widget build(BuildContext context) {
    final pts = PokemonChartData.bubbleSpdAtk.map((p) => [p[0].toDouble(), p[1].toDouble(), p[2].toDouble()]).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Velocidad vs Ataque (burbuja = HP)'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _ScatterPainter(points: pts, pointColors: List.filled(pts.length, const Color(0xFFF44336).withOpacity(0.7))))),
    ]);
  }
}

class CpB34 extends StatelessWidget {
  const CpB34({super.key});
  @override
  Widget build(BuildContext context) {
    final pokes = ['Bulbasaur','Mewtwo','Pikachu','Charizard','Blastoise','Snorlax','Gengar','Lapras','Jolteon','Flareon'];
    final pts = pokes.map((n) {
      final s = PokemonChartData.statsOf(n);
      return [s[0].toDouble(), s[3].toDouble(), s[5].toDouble()];
    }).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP vs Sp.Atk (burbuja = Velocidad)'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _ScatterPainter(points: pts, pointColors: List.filled(pts.length, const Color(0xFF9C27B0).withOpacity(0.7))))),
    ]);
  }
}

class CpB35 extends StatelessWidget {
  const CpB35({super.key});
  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf('Pikachu').map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats de Pikachu'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _RadarPainter(datasets: [s], labels: PokemonChartData.statNames, colors: [const Color(0xFFF8D030)]))),
    ]);
  }
}

class CpB36 extends StatelessWidget {
  const CpB36({super.key});
  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf('Mewtwo').map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats de Mewtwo'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _RadarPainter(datasets: [s], labels: PokemonChartData.statNames, colors: [const Color(0xFFF85888)]))),
    ]);
  }
}

class CpB37 extends StatelessWidget {
  const CpB37({super.key});
  @override
  Widget build(BuildContext context) {
    final charizard = PokemonChartData.statsOf('Charizard').map((v) => v / 160.0).toList();
    final blastoise = PokemonChartData.statsOf('Blastoise').map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Charizard vs Blastoise'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _RadarPainter(
          datasets: [charizard, blastoise],
          labels: PokemonChartData.statNames,
          colors: [const Color(0xFFF08030), const Color(0xFF6890F0)],
        ))),
    ]);
  }
}

class CpB38 extends StatelessWidget {
  const CpB38({super.key});
  @override
  Widget build(BuildContext context) {
    final fire = PokemonChartData.avgStatsOf(PokemonChartData.fireTypes).map((v) => v / 160.0).toList();
    final water = PokemonChartData.avgStatsOf(PokemonChartData.waterTypes).map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Fuego avg vs Agua avg'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _RadarPainter(
          datasets: [fire, water],
          labels: PokemonChartData.statNames,
          colors: [const Color(0xFFF08030), const Color(0xFF6890F0)],
        ))),
    ]);
  }
}

class CpB39 extends StatelessWidget {
  const CpB39({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Correlación Stats Gen I'),
      SizedBox(height: 260, child: CustomPaint(size: const Size(double.infinity, 260),
        painter: _HeatmapPainter(
          data: PokemonChartData.correlationMatrix,
          rowLabels: PokemonChartData.statNames,
          colLabels: PokemonChartData.statNames,
        ))),
    ]);
  }
}

class CpB40 extends StatelessWidget {
  const CpB40({super.key});
  @override
  Widget build(BuildContext context) {
    final normalized = PokemonChartData.heatmapAvg.map((row) => row.map((v) => v / 130.0).toList()).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats Promedio por Tipo'),
      SizedBox(height: 260, child: CustomPaint(size: const Size(double.infinity, 260),
        painter: _HeatmapPainter(
          data: normalized,
          rowLabels: PokemonChartData.heatmapTypes,
          colLabels: PokemonChartData.statNames,
          lowColor: const Color(0xFFE8F5E9),
          highColor: const Color(0xFF1B5E20),
        ))),
    ]);
  }
}

class CpB41 extends StatelessWidget {
  const CpB41({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Pikachu').map((v) => v.toDouble()).toList();
    final avg = stats.fold(0.0, (a, b) => a + b) / stats.length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats + Línea Promedio'),
      SizedBox(height: 250, child: CustomPaint(size: const Size(double.infinity, 250),
        painter: _BarPainter(
          values: stats,
          labels: PokemonChartData.statNames,
          colors: PokemonChartData.statColors,
          thresholdY: avg,
        ))),
    ]);
  }
}

class CpB42 extends StatelessWidget {
  const CpB42({super.key});
  @override
  Widget build(BuildContext context) {
    final hpPts = PokemonChartData.hpVsSpeed.map((p) => [p[0].toDouble(), p[1].toDouble()]).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP Área + Velocidad Scatter'),
      SizedBox(height: 130, child: CustomPaint(size: const Size(double.infinity, 130),
        painter: _LinePainter(
          datasets: [PokemonChartData.first20HP.map((v) => v.toDouble()).toList()],
          xLabels: PokemonChartData.first20Names,
          lineColors: [const Color(0xFF4CAF50)],
          showArea: true,
        ))),
      const SizedBox(height: 4),
      SizedBox(height: 110, child: CustomPaint(size: const Size(double.infinity, 110),
        painter: _ScatterPainter(
          points: hpPts.take(20).toList(),
          pointColors: List.filled(20, const Color(0xFFFF9800)),
          dotRadius: 4,
        ))),
    ]);
  }
}

class CpB43 extends StatelessWidget {
  const CpB43({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Snorlax');
    final total = PokemonChartData.totalOf('Snorlax');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Dashboard Pokémon - Snorlax'),
      SizedBox(height: 200, child: CustomPaint(size: const Size(double.infinity, 200),
        painter: _BarPainter(
          values: stats.map((v) => v.toDouble()).toList(),
          labels: PokemonChartData.statNames,
          colors: PokemonChartData.statColors,
          maxValue: 180,
        ))),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8, runSpacing: 4,
        children: [
          for (int i = 0; i < 6; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: PokemonChartData.statColors[i].withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${PokemonChartData.statNames[i]}: ${stats[i]}',
                style: TextStyle(fontSize: 11, color: PokemonChartData.statColors[i], fontWeight: FontWeight.bold),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
            child: Text('Total: $total', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ]);
  }
}
