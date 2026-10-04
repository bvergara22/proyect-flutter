import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../core/data/pokemon_chart_data.dart';

// ── Shared helpers ─────────────────────────────────────────────────────────────

class _CD {
  final String x;
  final double y;
  final double? y2;
  final Color? color;
  _CD(this.x, this.y, {this.y2, this.color});
}

Widget _t(String title) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Text(title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
);

List<_CD> _stats(String name) => List.generate(
    6,
    (i) => _CD(PokemonChartData.statNames[i],
        PokemonChartData.statsOf(name)[i].toDouble(),
        color: PokemonChartData.statColors[i]));

List<_CD> _topH(int statIdx) => PokemonChartData.topByStatIndex(statIdx, n: 5)
    .map((e) => _CD(e.key, e.value.toDouble()))
    .toList();

List<_CD> _pieTypes() => PokemonChartData.topTypes.entries
    .map((e) => _CD(e.key, e.value.toDouble(),
        color: PokemonChartData.typeColors[e.key] ?? Colors.grey))
    .toList();

SfCartesianChart _cartesian({
  required List<CartesianSeries> series,
  ChartAxis? xAxis,
  bool legend = false,
  double maxY = 160,
}) =>
    SfCartesianChart(
      primaryXAxis: xAxis ?? CategoryAxis(labelStyle: const TextStyle(fontSize: 10)),
      primaryYAxis: NumericAxis(minimum: 0, maximum: maxY, labelStyle: const TextStyle(fontSize: 10)),
      legend: Legend(isVisible: legend, position: LegendPosition.bottom, textStyle: const TextStyle(fontSize: 11)),
      series: series,
    );

// ── Radar Painter ─────────────────────────────────────────────────────────────

class _RP extends CustomPainter {
  final List<List<double>> datasets;
  final List<Color> colors;
  final List<String> labels;
  const _RP({required this.datasets, required this.colors, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.35;
    final n = labels.length;
    for (int g = 1; g <= 4; g++) {
      final rg = r * g / 4;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final a = i * 2 * pi / n - pi / 2;
        final p = Offset(c.dx + rg * cos(a), c.dy + rg * sin(a));
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(
          path, Paint()..color = Colors.grey.shade300..style = PaintingStyle.stroke..strokeWidth = 0.8);
    }
    for (int i = 0; i < n; i++) {
      final a = i * 2 * pi / n - pi / 2;
      canvas.drawLine(c, Offset(c.dx + r * cos(a), c.dy + r * sin(a)),
          Paint()..color = Colors.grey.shade400..strokeWidth = 1);
    }
    for (int d = 0; d < datasets.length; d++) {
      final vals = datasets[d];
      final col = colors[d % colors.length];
      final path = Path();
      for (int i = 0; i < n; i++) {
        final a = i * 2 * pi / n - pi / 2;
        final rv = r * vals[i];
        final p = Offset(c.dx + rv * cos(a), c.dy + rv * sin(a));
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = col.withOpacity(0.25)..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 2);
    }
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < n; i++) {
      final a = i * 2 * pi / n - pi / 2;
      final p = Offset(c.dx + (r + 22) * cos(a), c.dy + (r + 22) * sin(a));
      tp.text = TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87));
      tp.layout();
      canvas.save();
      canvas.translate(p.dx - tp.width / 2, p.dy - tp.height / 2);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_RP o) => false;
}

Widget _radar(List<List<double>> data, List<Color> colors) => SizedBox(
    height: 260,
    width: double.infinity,
    child: CustomPaint(
        painter: _RP(
            datasets: data, colors: colors, labels: PokemonChartData.statNames)));

Widget _heatGrid(List<List<double>> raw, double maxVal, Color base) {
  final cols = raw[0].length;
  return SizedBox(
    height: 180,
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols, childAspectRatio: cols / raw.length.toDouble()),
      itemCount: raw.length * cols,
      itemBuilder: (_, idx) {
        final row = idx ~/ cols;
        final col = idx % cols;
        final v = (raw[row][col] / maxVal).clamp(0.0, 1.0);
        return Container(
            margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
                color: Color.lerp(base.withOpacity(0.1), base, v),
                borderRadius: BorderRadius.circular(2)),
            child: Center(
                child: Text(raw[row][col].toStringAsFixed(1),
                    style: const TextStyle(fontSize: 6.5, color: Colors.white, fontWeight: FontWeight.bold))));
      },
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// B01 – B08 : BAR CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfB01 extends StatelessWidget {
  const SfB01({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Stats de Bulbasaur'),
        SizedBox(
            height: 250,
            child: _cartesian(
                series: [
                  ColumnSeries<_CD, String>(
                    dataSource: _stats('Bulbasaur'),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    pointColorMapper: (d, _) => d.color,
                    borderRadius: BorderRadius.circular(4),
                  )
                ],
                maxY: 160))
      ]);
}

class SfB02 extends StatelessWidget {
  const SfB02({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Stats de Mewtwo'),
        SizedBox(
            height: 250,
            child: _cartesian(
                series: [
                  ColumnSeries<_CD, String>(
                    dataSource: _stats('Mewtwo'),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    pointColorMapper: (d, _) => d.color,
                    borderRadius: BorderRadius.circular(4),
                  )
                ],
                maxY: 180))
      ]);
}

class SfB03 extends StatelessWidget {
  const SfB03({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Bulbasaur vs Charmander'),
        SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 130, labelStyle: TextStyle(fontSize: 10)),
              legend: const Legend(isVisible: true, position: LegendPosition.bottom),
              series: <CartesianSeries>[
                ColumnSeries<_CD, String>(
                    dataSource: _stats('Bulbasaur'),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    name: 'Bulbasaur',
                    color: const Color(0xFF78C850)),
                ColumnSeries<_CD, String>(
                    dataSource: _stats('Charmander'),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    name: 'Charmander',
                    color: const Color(0xFFF08030)),
              ],
            ))
      ]);
}

class SfB04 extends StatelessWidget {
  const SfB04({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Top 5 por Ataque'),
        SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 160, labelStyle: TextStyle(fontSize: 10)),
              series: <CartesianSeries>[
                BarSeries<_CD, String>(
                    dataSource: _topH(1),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    color: const Color(0xFFF44336),
                    borderRadius: BorderRadius.circular(4)),
              ],
            ))
      ]);
}

class SfB05 extends StatelessWidget {
  const SfB05({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Top 5 por Defensa'),
        SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 160, labelStyle: TextStyle(fontSize: 10)),
              series: <CartesianSeries>[
                BarSeries<_CD, String>(
                    dataSource: _topH(2),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(4)),
              ],
            ))
      ]);
}

class SfB06 extends StatelessWidget {
  const SfB06({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Top 5 por HP'),
        SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 180, labelStyle: TextStyle(fontSize: 10)),
              series: <CartesianSeries>[
                BarSeries<_CD, String>(
                    dataSource: _topH(0),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(4)),
              ],
            ))
      ]);
}

class SfB07 extends StatelessWidget {
  const SfB07({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Top 5 por Velocidad'),
        SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 160, labelStyle: TextStyle(fontSize: 10)),
              series: <CartesianSeries>[
                BarSeries<_CD, String>(
                    dataSource: _topH(5),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    color: const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(4)),
              ],
            ))
      ]);
}

class SfB08 extends StatelessWidget {
  const SfB08({super.key});

  static List<_CD> _avgFor(List<String> names, String label, Color color) {
    final avg = PokemonChartData.avgStatsOf(names);
    return List.generate(6,
        (i) => _CD(PokemonChartData.statNames[i], avg[i], color: color));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Fuego vs Agua vs Planta'),
      SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 130, labelStyle: TextStyle(fontSize: 10)),
            legend: const Legend(isVisible: true, position: LegendPosition.bottom),
            series: <CartesianSeries>[
              ColumnSeries<_CD, String>(
                  dataSource: _avgFor(PokemonChartData.fireTypes, 'Fuego', const Color(0xFFF08030)),
                  xValueMapper: (d, _) => d.x,
                  yValueMapper: (d, _) => d.y,
                  name: 'Fuego',
                  color: const Color(0xFFF08030)),
              ColumnSeries<_CD, String>(
                  dataSource: _avgFor(PokemonChartData.waterTypes, 'Agua', const Color(0xFF6890F0)),
                  xValueMapper: (d, _) => d.x,
                  yValueMapper: (d, _) => d.y,
                  name: 'Agua',
                  color: const Color(0xFF6890F0)),
              ColumnSeries<_CD, String>(
                  dataSource: _avgFor(PokemonChartData.grassTypes, 'Planta', const Color(0xFF78C850)),
                  xValueMapper: (d, _) => d.x,
                  yValueMapper: (d, _) => d.y,
                  name: 'Planta',
                  color: const Color(0xFF78C850)),
            ],
          ))
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// B09 – B13 : LINE CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfB09 extends StatelessWidget {
  const SfB09({super.key});
  @override
  Widget build(BuildContext context) {
    final names = ['Bulbasaur', 'Ivysaur', 'Venusaur'];
    final data = names.map((n) => _CD(n, PokemonChartData.statsOf(n)[0].toDouble())).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Evolución HP Bulbasaur'),
      SizedBox(
          height: 250,
          child: _cartesian(
              series: [
                LineSeries<_CD, String>(
                    dataSource: data,
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    color: const Color(0xFF78C850),
                    width: 3,
                    markerSettings: const MarkerSettings(isVisible: true, height: 8, width: 8))
              ],
              maxY: 100))
    ]);
  }
}

class SfB10 extends StatelessWidget {
  const SfB10({super.key});
  @override
  Widget build(BuildContext context) {
    final names = ['Charmander', 'Charmeleon', 'Charizard'];
    final data = names.map((n) => _CD(n, PokemonChartData.statsOf(n)[1].toDouble())).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Evolución Ataque Charmander'),
      SizedBox(
          height: 250,
          child: _cartesian(
              series: [
                LineSeries<_CD, String>(
                    dataSource: data,
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    color: const Color(0xFFF08030),
                    width: 3,
                    markerSettings: const MarkerSettings(isVisible: true, height: 8, width: 8))
              ],
              maxY: 100))
    ]);
  }
}

class SfB11 extends StatelessWidget {
  const SfB11({super.key});
  @override
  Widget build(BuildContext context) {
    final names = ['Squirtle', 'Wartortle', 'Blastoise'];
    final data = names.map((n) => _CD(n, PokemonChartData.statsOf(n)[2].toDouble())).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Evolución Defensa Squirtle'),
      SizedBox(
          height: 250,
          child: _cartesian(
              series: [
                LineSeries<_CD, String>(
                    dataSource: data,
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    color: const Color(0xFF6890F0),
                    width: 3,
                    markerSettings: const MarkerSettings(isVisible: true, height: 8, width: 8))
              ],
              maxY: 120))
    ]);
  }
}

class SfB12 extends StatelessWidget {
  const SfB12({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List.generate(
        20,
        (i) => _CD('P${i + 1}', PokemonChartData.first20HP[i].toDouble()));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('HP Primeros 20 Pokémon'),
      SizedBox(
          height: 250,
          child: _cartesian(
              series: [
                LineSeries<_CD, String>(
                    dataSource: data,
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    color: const Color(0xFF4CAF50),
                    width: 2,
                    markerSettings: const MarkerSettings(isVisible: true, height: 5, width: 5))
              ],
              maxY: 160))
    ]);
  }
}

class SfB13 extends StatelessWidget {
  const SfB13({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List.generate(
        20,
        (i) => _CD('P${i + 1}', PokemonChartData.first20Spd[i].toDouble()));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Velocidad Primeros 20'),
      SizedBox(
          height: 250,
          child: _cartesian(
              series: [
                LineSeries<_CD, String>(
                    dataSource: data,
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    color: const Color(0xFFFF9800),
                    width: 2,
                    markerSettings: const MarkerSettings(isVisible: true, height: 5, width: 5))
              ],
              maxY: 130))
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// B14 – B18 : PIE / DONUT CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfB14 extends StatelessWidget {
  const SfB14({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Distribución Tipos Gen I'),
        SizedBox(
            height: 260,
            child: SfCircularChart(
              legend: const Legend(isVisible: true, position: LegendPosition.bottom, textStyle: TextStyle(fontSize: 10)),
              series: <CircularSeries>[
                PieSeries<_CD, String>(
                    dataSource: _pieTypes(),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    pointColorMapper: (d, _) => d.color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.outside, textStyle: TextStyle(fontSize: 9)),
                    radius: '75%')
              ],
            ))
      ]);
}

class SfB15 extends StatelessWidget {
  const SfB15({super.key});
  @override
  Widget build(BuildContext context) {
    final top5 = _pieTypes().take(5).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Top 5 Tipos más Comunes'),
      SizedBox(
          height: 260,
          child: SfCircularChart(
            legend: const Legend(isVisible: true, position: LegendPosition.bottom),
            series: <CircularSeries>[
              PieSeries<_CD, String>(
                  dataSource: top5,
                  xValueMapper: (d, _) => d.x,
                  yValueMapper: (d, _) => d.y,
                  pointColorMapper: (d, _) => d.color,
                  dataLabelSettings: const DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.outside),
                  radius: '80%',
                  explode: true,
                  explodeIndex: 0)
            ],
          ))
    ]);
  }
}

class SfB16 extends StatelessWidget {
  const SfB16({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Tipos Gen I (Donut)'),
        SizedBox(
            height: 260,
            child: SfCircularChart(
              legend: const Legend(isVisible: true, position: LegendPosition.bottom, textStyle: TextStyle(fontSize: 10)),
              series: <CircularSeries>[
                DoughnutSeries<_CD, String>(
                    dataSource: _pieTypes(),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    pointColorMapper: (d, _) => d.color,
                    innerRadius: '50%',
                    radius: '80%')
              ],
            ))
      ]);
}

class SfB17 extends StatelessWidget {
  const SfB17({super.key});
  @override
  Widget build(BuildContext context) {
    final data = [
      _CD('1 Tipo', 75, color: const Color(0xFF2196F3)),
      _CD('2 Tipos', 76, color: const Color(0xFF4CAF50)),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('1 Tipo vs 2 Tipos'),
      SizedBox(
          height: 260,
          child: SfCircularChart(
            series: <CircularSeries>[
              DoughnutSeries<_CD, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.x,
                  yValueMapper: (d, _) => d.y,
                  pointColorMapper: (d, _) => d.color,
                  innerRadius: '45%',
                  radius: '80%',
                  dataLabelSettings: const DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.outside))
            ],
          ))
    ]);
  }
}

class SfB18 extends StatelessWidget {
  const SfB18({super.key});
  @override
  Widget build(BuildContext context) {
    final data = [
      _CD('Legendarios', 5, color: const Color(0xFF9C27B0)),
      _CD('Normales', 146, color: const Color(0xFF78C850)),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Legendarios vs Normales'),
      SizedBox(
          height: 260,
          child: SfCircularChart(
            series: <CircularSeries>[
              PieSeries<_CD, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.x,
                  yValueMapper: (d, _) => d.y,
                  pointColorMapper: (d, _) => d.color,
                  radius: '80%',
                  explode: true,
                  explodeIndex: 0,
                  dataLabelSettings: const DataLabelSettings(isVisible: true))
            ],
          ))
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// B19 – B23 : AREA CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfB19 extends StatelessWidget {
  const SfB19({super.key});
  @override
  Widget build(BuildContext context) {
    const names = ['Bulbasaur', 'Ivysaur', 'Venusaur', 'Charmander', 'Charmeleon', 'Charizard', 'Squirtle', 'Wartortle', 'Blastoise'];
    final data = names.map((n) => _CD(n.substring(0, min(7, n.length)), PokemonChartData.statsOf(n)[0].toDouble())).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('HP de los Starters'),
      SizedBox(
          height: 250,
          child: _cartesian(
              series: [
                SplineAreaSeries<_CD, String>(
                    dataSource: data,
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    borderColor: const Color(0xFF4CAF50),
                    borderWidth: 2)
              ],
              maxY: 110))
    ]);
  }
}

class SfB20 extends StatelessWidget {
  const SfB20({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List.generate(15, (i) => _CD('P${i + 1}', PokemonChartData.first20Atk[i].toDouble()));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Ataque Primeros 15'),
      SizedBox(
          height: 250,
          child: _cartesian(
              series: [
                SplineAreaSeries<_CD, String>(
                    dataSource: data,
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    color: const Color(0xFFF44336).withOpacity(0.3),
                    borderColor: const Color(0xFFF44336),
                    borderWidth: 2)
              ],
              maxY: 100))
    ]);
  }
}

class SfB21 extends StatelessWidget {
  const SfB21({super.key});
  @override
  Widget build(BuildContext context) {
    List<_CD> _evo(List<String> names, Color c) =>
        names.map((n) => _CD(n.substring(0, min(7, n.length)), PokemonChartData.statsOf(n)[0].toDouble())).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('HP Comparativa Starters'),
      SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 9)),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 100),
            legend: const Legend(isVisible: true, position: LegendPosition.bottom),
            series: <CartesianSeries>[
              SplineAreaSeries<_CD, String>(
                  dataSource: _evo(['Bulbasaur', 'Ivysaur', 'Venusaur'], const Color(0xFF78C850)),
                  xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y,
                  color: const Color(0xFF78C850).withOpacity(0.25), borderColor: const Color(0xFF78C850), borderWidth: 2, name: 'Planta'),
              SplineAreaSeries<_CD, String>(
                  dataSource: _evo(['Charmander', 'Charmeleon', 'Charizard'], const Color(0xFFF08030)),
                  xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y,
                  color: const Color(0xFFF08030).withOpacity(0.25), borderColor: const Color(0xFFF08030), borderWidth: 2, name: 'Fuego'),
              SplineAreaSeries<_CD, String>(
                  dataSource: _evo(['Squirtle', 'Wartortle', 'Blastoise'], const Color(0xFF6890F0)),
                  xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y,
                  color: const Color(0xFF6890F0).withOpacity(0.25), borderColor: const Color(0xFF6890F0), borderWidth: 2, name: 'Agua'),
            ],
          ))
    ]);
  }
}

class SfB22 extends StatelessWidget {
  const SfB22({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List.generate(20, (i) => _CD('P${i + 1}', PokemonChartData.first20Def[i].toDouble()));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Defensa Primeros 20'),
      SizedBox(
          height: 250,
          child: _cartesian(
              series: [
                SplineAreaSeries<_CD, String>(
                    dataSource: data,
                    xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y,
                    color: const Color(0xFF2196F3).withOpacity(0.3),
                    borderColor: const Color(0xFF2196F3), borderWidth: 2)
              ],
              maxY: 120))
    ]);
  }
}

class SfB23 extends StatelessWidget {
  const SfB23({super.key});
  @override
  Widget build(BuildContext context) {
    const names = ['Bulbasaur','Ivysaur','Venusaur','Charmander','Charmeleon','Charizard','Squirtle','Wartortle','Blastoise','Pikachu','Raichu','Jigglypuff','Gengar','Gyarados','Lapras','Eevee','Vaporeon','Jolteon','Flareon','Snorlax'];
    final data = List.generate(20, (i) => _CD('P${i + 1}', PokemonChartData.statsOf(names[i])[3].toDouble()));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Sp. Ataque Primeros 20'),
      SizedBox(
          height: 250,
          child: _cartesian(
              series: [
                SplineAreaSeries<_CD, String>(
                    dataSource: data,
                    xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y,
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
                    borderColor: const Color(0xFF9C27B0), borderWidth: 2)
              ],
              maxY: 160))
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// B24 – B27 : HISTOGRAM
// ─────────────────────────────────────────────────────────────────────────────

class SfB24 extends StatelessWidget {
  const SfB24({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List.generate(9, (i) => _CD(PokemonChartData.binLabels[i], PokemonChartData.hpBins[i].toDouble(), color: const Color(0xFF4CAF50)));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Distribución HP Gen I'),
      SizedBox(height: 250, child: _cartesian(series: [
        ColumnSeries<_CD, String>(dataSource: data, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y, pointColorMapper: (d, _) => d.color, borderRadius: BorderRadius.circular(4))
      ], maxY: 50))
    ]);
  }
}

class SfB25 extends StatelessWidget {
  const SfB25({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List.generate(9, (i) => _CD(PokemonChartData.binLabels[i], PokemonChartData.atkBins[i].toDouble(), color: const Color(0xFFF44336)));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Distribución Ataque'),
      SizedBox(height: 250, child: _cartesian(series: [
        ColumnSeries<_CD, String>(dataSource: data, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y, pointColorMapper: (d, _) => d.color, borderRadius: BorderRadius.circular(4))
      ], maxY: 50))
    ]);
  }
}

class SfB26 extends StatelessWidget {
  const SfB26({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List.generate(9, (i) => _CD(PokemonChartData.binLabels[i], PokemonChartData.defBins[i].toDouble(), color: const Color(0xFF2196F3)));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Distribución Defensa'),
      SizedBox(height: 250, child: _cartesian(series: [
        ColumnSeries<_CD, String>(dataSource: data, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y, pointColorMapper: (d, _) => d.color, borderRadius: BorderRadius.circular(4))
      ], maxY: 50))
    ]);
  }
}

class SfB27 extends StatelessWidget {
  const SfB27({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List.generate(9, (i) => _CD(PokemonChartData.binLabels[i], PokemonChartData.speedBins[i].toDouble(), color: const Color(0xFFFF9800)));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Distribución Velocidad'),
      SizedBox(height: 250, child: _cartesian(series: [
        ColumnSeries<_CD, String>(dataSource: data, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y, pointColorMapper: (d, _) => d.color, borderRadius: BorderRadius.circular(4))
      ], maxY: 50))
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// B28 – B31 : SCATTER CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfB28 extends StatelessWidget {
  const SfB28({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Ataque vs Defensa'),
        SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: const NumericAxis(minimum: 0, maximum: 160, title: AxisTitle(text: 'Ataque')),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 160, title: AxisTitle(text: 'Defensa')),
              series: <CartesianSeries>[
                ScatterSeries<List<int>, double>(
                    dataSource: PokemonChartData.attackVsDefense,
                    xValueMapper: (d, _) => d[0].toDouble(),
                    yValueMapper: (d, _) => d[1].toDouble(),
                    color: const Color(0xFF2196F3).withOpacity(0.7),
                    markerSettings: const MarkerSettings(isVisible: true, height: 8, width: 8))
              ],
            ))
      ]);
}

class SfB29 extends StatelessWidget {
  const SfB29({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('HP vs Velocidad'),
        SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: const NumericAxis(minimum: 0, maximum: 180, title: AxisTitle(text: 'HP')),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 140, title: AxisTitle(text: 'Velocidad')),
              series: <CartesianSeries>[
                ScatterSeries<List<int>, double>(
                    dataSource: PokemonChartData.hpVsSpeed,
                    xValueMapper: (d, _) => d[0].toDouble(),
                    yValueMapper: (d, _) => d[1].toDouble(),
                    color: const Color(0xFF4CAF50).withOpacity(0.7),
                    markerSettings: const MarkerSettings(isVisible: true, height: 8, width: 8))
              ],
            ))
      ]);
}

class SfB30 extends StatelessWidget {
  const SfB30({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List.generate(PokemonChartData.attackVsDefense.length,
        (i) => [PokemonChartData.attackVsDefense[i][0], PokemonChartData.hpVsSpeed[i < PokemonChartData.hpVsSpeed.length ? i : 0][1]]);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Ataque vs Velocidad'),
      SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: const NumericAxis(minimum: 0, maximum: 160, title: AxisTitle(text: 'Ataque')),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 140, title: AxisTitle(text: 'Velocidad')),
            series: <CartesianSeries>[
              ScatterSeries<List<int>, double>(
                  dataSource: data,
                  xValueMapper: (d, _) => d[0].toDouble(),
                  yValueMapper: (d, _) => d[1].toDouble(),
                  color: const Color(0xFFFF9800).withOpacity(0.7),
                  markerSettings: const MarkerSettings(isVisible: true, height: 8, width: 8))
            ],
          ))
    ]);
  }
}

class SfB31 extends StatelessWidget {
  const SfB31({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Sp.Atk vs Sp.Def'),
        SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: const NumericAxis(minimum: 0, maximum: 160, title: AxisTitle(text: 'Sp.Atk')),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 140, title: AxisTitle(text: 'Sp.Def')),
              series: <CartesianSeries>[
                ScatterSeries<List<int>, double>(
                    dataSource: PokemonChartData.spAtkVsSpDef,
                    xValueMapper: (d, _) => d[0].toDouble(),
                    yValueMapper: (d, _) => d[1].toDouble(),
                    color: const Color(0xFF9C27B0).withOpacity(0.7),
                    markerSettings: const MarkerSettings(isVisible: true, height: 8, width: 8))
              ],
            ))
      ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// B32 – B34 : BUBBLE CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfB32 extends StatelessWidget {
  const SfB32({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('HP vs Ataque (tamaño = Defensa)'),
        SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: const NumericAxis(minimum: 0, maximum: 180, title: AxisTitle(text: 'HP')),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 160, title: AxisTitle(text: 'Ataque')),
              series: <CartesianSeries>[
                BubbleSeries<List<int>, double>(
                    dataSource: PokemonChartData.bubbleHpAtk,
                    xValueMapper: (d, _) => d[0].toDouble(),
                    yValueMapper: (d, _) => d[1].toDouble(),
                    sizeValueMapper: (d, _) => d[2].toDouble(),
                    color: const Color(0xFF2196F3).withOpacity(0.6),
                    minimumRadius: 6, maximumRadius: 25)
              ],
            ))
      ]);
}

class SfB33 extends StatelessWidget {
  const SfB33({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Velocidad vs Ataque (tamaño = HP)'),
        SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: const NumericAxis(minimum: 0, maximum: 140, title: AxisTitle(text: 'Velocidad')),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 160, title: AxisTitle(text: 'Ataque')),
              series: <CartesianSeries>[
                BubbleSeries<List<int>, double>(
                    dataSource: PokemonChartData.bubbleSpdAtk,
                    xValueMapper: (d, _) => d[0].toDouble(),
                    yValueMapper: (d, _) => d[1].toDouble(),
                    sizeValueMapper: (d, _) => d[2].toDouble(),
                    color: const Color(0xFFFF9800).withOpacity(0.6),
                    minimumRadius: 6, maximumRadius: 25)
              ],
            ))
      ]);
}

class SfB34 extends StatelessWidget {
  const SfB34({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.bubbleHpAtk.map((d) => [d[0], PokemonChartData.statsOf(['Bulbasaur','Ivysaur','Venusaur','Charmander','Charmeleon','Charizard','Squirtle','Wartortle','Blastoise','Caterpie','Butterfree','Pikachu','Raichu','Jigglypuff','Wigglytuff','Meowth','Persian','Gengar','Gyarados','Lapras'][d[0] ~/ 10 < 20 ? d[0] ~/ 10 : 0])[3], d[2]]).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('HP vs Sp.Atk (tamaño = Velocidad)'),
      SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: const NumericAxis(minimum: 0, maximum: 180, title: AxisTitle(text: 'HP')),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 160, title: AxisTitle(text: 'Sp.Atk')),
            series: <CartesianSeries>[
              BubbleSeries<List<int>, double>(
                  dataSource: PokemonChartData.bubbleHpAtk,
                  xValueMapper: (d, _) => d[0].toDouble(),
                  yValueMapper: (d, _) => d[2].toDouble(),
                  sizeValueMapper: (d, _) => d[1].toDouble(),
                  color: const Color(0xFF9C27B0).withOpacity(0.6),
                  minimumRadius: 5, maximumRadius: 22)
            ],
          ))
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// B35 – B38 : RADAR CHARTS (via CustomPainter)
// ─────────────────────────────────────────────────────────────────────────────

class SfB35 extends StatelessWidget {
  const SfB35({super.key});
  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf('Pikachu').map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Stats de Pikachu'),
      _radar([s], [const Color(0xFFF8D030)]),
    ]);
  }
}

class SfB36 extends StatelessWidget {
  const SfB36({super.key});
  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf('Mewtwo').map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Stats de Mewtwo'),
      _radar([s], [const Color(0xFF9C27B0)]),
    ]);
  }
}

class SfB37 extends StatelessWidget {
  const SfB37({super.key});
  @override
  Widget build(BuildContext context) {
    final c = PokemonChartData.statsOf('Charizard').map((v) => v / 160.0).toList();
    final b = PokemonChartData.statsOf('Blastoise').map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Charizard vs Blastoise'),
      _radar([c, b], [const Color(0xFFF08030), const Color(0xFF6890F0)]),
    ]);
  }
}

class SfB38 extends StatelessWidget {
  const SfB38({super.key});
  @override
  Widget build(BuildContext context) {
    final fire = PokemonChartData.avgStatsOf(PokemonChartData.fireTypes).map((v) => v / 160.0).toList();
    final water = PokemonChartData.avgStatsOf(PokemonChartData.waterTypes).map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Fuego avg vs Agua avg'),
      _radar([fire, water], [const Color(0xFFF08030), const Color(0xFF6890F0)]),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// B39 – B40 : HEATMAP CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfB39 extends StatelessWidget {
  const SfB39({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Correlación Stats Gen I'),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Wrap(
            spacing: 4,
            children: PokemonChartData.statNames.map((s) =>
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.indigo.shade100, borderRadius: BorderRadius.circular(4)),
                child: Text(s, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)))).toList()),
        ),
        _heatGrid(PokemonChartData.correlationMatrix, 1.0, Colors.indigo),
      ]);
}

class SfB40 extends StatelessWidget {
  const SfB40({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Stats Promedio por Tipo'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: PokemonChartData.heatmapTypes.map((t) =>
            Text(t, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))).toList()),
        const SizedBox(height: 4),
        _heatGrid(PokemonChartData.heatmapAvg, 130.0, Colors.teal),
      ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// B41 – B43 : COMBINED CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfB41 extends StatelessWidget {
  const SfB41({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = _stats('Charizard');
    final avg = PokemonChartData.statsOf('Charizard').fold(0, (a, b) => a + b) / 6.0;
    final avgData = List.generate(6, (i) => _CD(PokemonChartData.statNames[i], avg));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Stats + Línea Promedio'),
      SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 130),
            series: <CartesianSeries>[
              ColumnSeries<_CD, String>(
                  dataSource: stats, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y,
                  pointColorMapper: (d, _) => d.color, borderRadius: BorderRadius.circular(4), name: 'Stat'),
              LineSeries<_CD, String>(
                  dataSource: avgData, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y,
                  color: Colors.red, width: 2, dashArray: [5, 5], name: 'Promedio'),
            ],
          ))
    ]);
  }
}

class SfB42 extends StatelessWidget {
  const SfB42({super.key});
  @override
  Widget build(BuildContext context) {
    final areaData = List.generate(20, (i) => _CD('P${i + 1}', PokemonChartData.first20HP[i].toDouble()));
    final scatData = PokemonChartData.hpVsSpeed.take(20).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('HP Área + Velocidad Scatter'),
      SizedBox(
          height: 200,
          child: _cartesian(series: [
            SplineAreaSeries<_CD, String>(dataSource: areaData, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y, color: const Color(0xFF4CAF50).withOpacity(0.3), borderColor: const Color(0xFF4CAF50), borderWidth: 2)
          ], maxY: 160)),
      const SizedBox(height: 8),
      SizedBox(
          height: 160,
          child: SfCartesianChart(
            primaryXAxis: const NumericAxis(minimum: 0, maximum: 180),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 140),
            series: <CartesianSeries>[
              ScatterSeries<List<int>, double>(dataSource: scatData, xValueMapper: (d, _) => d[0].toDouble(), yValueMapper: (d, _) => d[1].toDouble(), color: const Color(0xFFFF9800).withOpacity(0.7), markerSettings: const MarkerSettings(isVisible: true, height: 7, width: 7))
            ],
          )),
    ]);
  }
}

class SfB43 extends StatelessWidget {
  const SfB43({super.key});
  @override
  Widget build(BuildContext context) {
    const name = 'Dragonite';
    final stats = PokemonChartData.statsOf(name);
    final total = stats.fold(0, (a, b) => a + b);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Dashboard Pokémon — $name'),
      SizedBox(
          height: 200,
          child: _cartesian(series: [
            ColumnSeries<_CD, String>(dataSource: _stats(name), xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y, pointColorMapper: (d, _) => d.color, borderRadius: BorderRadius.circular(4))
          ], maxY: 160)),
      const SizedBox(height: 12),
      Row(children: [
        _InfoCard('Total', total.toString(), Colors.purple),
        const SizedBox(width: 8),
        _InfoCard('HP', stats[0].toString(), const Color(0xFF4CAF50)),
        const SizedBox(width: 8),
        _InfoCard('Atk', stats[1].toString(), const Color(0xFFF44336)),
      ]),
    ]);
  }
}

class _InfoCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _InfoCard(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3))),
          child: Column(children: [
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ]),
        ),
      );
}
