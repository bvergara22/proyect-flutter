import 'dart:async';
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
  child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
);

List<_CD> _stats(String name) => List.generate(6, (i) => _CD(
    PokemonChartData.statNames[i], PokemonChartData.statsOf(name)[i].toDouble(),
    color: PokemonChartData.statColors[i]));

// ── Radar Painter ──────────────────────────────────────────────────────────────

class _RP extends CustomPainter {
  final List<List<double>> datasets;
  final List<Color> colors;
  final List<String> labels;
  final double progress;
  const _RP({required this.datasets, required this.colors, required this.labels, this.progress = 1.0});

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
      canvas.drawPath(path, Paint()..color = Colors.grey.shade300..style = PaintingStyle.stroke..strokeWidth = 0.8);
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
        final rv = r * vals[i] * progress;
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
      tp.text = TextSpan(text: labels[i], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87));
      tp.layout();
      canvas.save();
      canvas.translate(p.dx - tp.width / 2, p.dy - tp.height / 2);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_RP o) => o.progress != progress;
}

Widget _heatGrid(List<List<double>> raw, double maxVal, Color base,
    {void Function(int r, int c, double v)? onTap}) {
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
        return GestureDetector(
          onTap: onTap == null ? null : () => onTap(row, col, raw[row][col]),
          child: Container(
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                  color: Color.lerp(base.withOpacity(0.1), base, v),
                  borderRadius: BorderRadius.circular(2)),
              child: Center(
                  child: Text(raw[row][col].toStringAsFixed(1),
                      style: const TextStyle(fontSize: 6.5, color: Colors.white, fontWeight: FontWeight.bold)))),
        );
      },
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// A01 – A06 : ADVANCED BAR CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfA01 extends StatelessWidget {
  const SfA01({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Barras Animadas'),
        SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 160),
              series: <CartesianSeries>[
                ColumnSeries<_CD, String>(
                    dataSource: _stats('Venusaur'),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    pointColorMapper: (d, _) => d.color,
                    borderRadius: BorderRadius.circular(6),
                    animationDuration: 1500)
              ],
            ))
      ]);
}

class SfA02 extends StatefulWidget {
  const SfA02({super.key});
  @override
  State<SfA02> createState() => _SfA02State();
}

class _SfA02State extends State<SfA02> {
  String _selected = 'Pikachu';
  static const _options = ['Pikachu', 'Mewtwo', 'Charizard', 'Blastoise', 'Snorlax', 'Gengar'];

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Selector de Pokémon'),
        DropdownButton<String>(
            value: _selected,
            items: _options.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
            onChanged: (v) => setState(() => _selected = v!)),
        SizedBox(
            height: 220,
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 170),
              series: <CartesianSeries>[
                ColumnSeries<_CD, String>(
                    dataSource: _stats(_selected),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    pointColorMapper: (d, _) => d.color,
                    borderRadius: BorderRadius.circular(4),
                    animationDuration: 800)
              ],
            )),
      ]);
}

class SfA03 extends StatelessWidget {
  const SfA03({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Barras con Tooltip'),
        SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 160),
              tooltipBehavior: TooltipBehavior(enable: true, format: 'Stat: point.x\nValor: point.y'),
              series: <CartesianSeries>[
                ColumnSeries<_CD, String>(
                    dataSource: _stats('Dragonite'),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    pointColorMapper: (d, _) => d.color,
                    borderRadius: BorderRadius.circular(4))
              ],
            ))
      ]);
}

class SfA04 extends StatelessWidget {
  const SfA04({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Pikachu');
    final avg = stats.fold(0, (a, b) => a + b) / 6.0;
    final data = List.generate(6, (i) {
      final diff = stats[i] - avg;
      return _CD(PokemonChartData.statNames[i], diff, color: diff >= 0 ? Colors.green : Colors.red);
    });
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Diferencia vs Promedio'),
      SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
            series: <CartesianSeries>[
              ColumnSeries<_CD, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.x,
                  yValueMapper: (d, _) => d.y,
                  pointColorMapper: (d, _) => d.color,
                  borderRadius: BorderRadius.circular(4))
            ],
          ))
    ]);
  }
}

class SfA05 extends StatelessWidget {
  const SfA05({super.key});
  @override
  Widget build(BuildContext context) {
    List<_CD> _evo(List<String> names, Color c, String label) {
      return List.generate(6, (i) {
        final avg = PokemonChartData.avgStatsOf(names)[i];
        return _CD(PokemonChartData.statNames[i], avg, color: c);
      });
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Composición 100%'),
      SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 100, labelFormat: '{value}%'),
            legend: const Legend(isVisible: true, position: LegendPosition.bottom),
            series: <CartesianSeries>[
              StackedColumn100Series<_CD, String>(
                  dataSource: _evo(PokemonChartData.fireTypes, const Color(0xFFF08030), 'Fuego'),
                  xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y, name: 'Fuego'),
              StackedColumn100Series<_CD, String>(
                  dataSource: _evo(PokemonChartData.waterTypes, const Color(0xFF6890F0), 'Agua'),
                  xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y, name: 'Agua'),
              StackedColumn100Series<_CD, String>(
                  dataSource: _evo(PokemonChartData.grassTypes, const Color(0xFF78C850), 'Planta'),
                  xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y, name: 'Planta'),
            ],
          ))
    ]);
  }
}

class SfA06 extends StatefulWidget {
  const SfA06({super.key});
  @override
  State<SfA06> createState() => _SfA06State();
}

class _SfA06State extends State<SfA06> {
  int _statIdx = 1;
  static const _labels = ['HP', 'Atk', 'Def', 'SpA', 'SpD', 'Spe'];

  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(_statIdx, n: 10);
    final data = top.map((e) => _CD(e.key.substring(0, min(8, e.key.length)), e.value.toDouble())).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Ranking Dinámico Top 10'),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(6, (i) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(_labels[i], style: const TextStyle(fontSize: 11)),
              selected: _statIdx == i,
              onSelected: (_) => setState(() => _statIdx = i),
            ),
          )),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
          height: 220,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 9)),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 180),
            series: <CartesianSeries>[
              BarSeries<_CD, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.x,
                  yValueMapper: (d, _) => d.y,
                  color: PokemonChartData.statColors[_statIdx],
                  borderRadius: BorderRadius.circular(4),
                  animationDuration: 600)
            ],
          )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// A07 – A11 : ADVANCED LINE CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfA07 extends StatelessWidget {
  const SfA07({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List.generate(20, (i) => _CD('P${i + 1}', PokemonChartData.first20HP[i].toDouble()));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Línea con Zoom/Pan'),
      SizedBox(
          height: 250,
          child: SfCartesianChart(
            zoomPanBehavior: ZoomPanBehavior(enablePanning: true, enablePinching: true, enableDoubleTapZooming: true),
            primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 160),
            series: <CartesianSeries>[
              LineSeries<_CD, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.x,
                  yValueMapper: (d, _) => d.y,
                  color: const Color(0xFF4CAF50),
                  width: 2,
                  markerSettings: const MarkerSettings(isVisible: true, height: 6, width: 6))
            ],
          ))
    ]);
  }
}

class SfA08 extends StatelessWidget {
  const SfA08({super.key});
  @override
  Widget build(BuildContext context) {
    const name = 'Mewtwo';
    List<_CD> _line(int idx) => [_CD(name, PokemonChartData.statsOf(name)[idx].toDouble())];

    final names20 = ['Bulbasaur','Ivysaur','Venusaur','Charmander','Charmeleon','Charizard','Squirtle','Wartortle','Blastoise','Pikachu','Raichu','Jigglypuff','Gengar','Gyarados','Lapras','Eevee','Vaporeon','Jolteon','Flareon','Snorlax'];
    List<_CD> _lineAll(int idx) => List.generate(20, (i) => _CD('P${i + 1}', PokemonChartData.statsOf(names20[i])[idx].toDouble()));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Multi-serie 6 Stats'),
      SizedBox(
          height: 260,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 9)),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 200),
            legend: const Legend(isVisible: true, position: LegendPosition.bottom, textStyle: TextStyle(fontSize: 9)),
            series: <CartesianSeries>[
              for (int i = 0; i < 6; i++)
                LineSeries<_CD, String>(
                    dataSource: _lineAll(i),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    color: PokemonChartData.statColors[i],
                    name: PokemonChartData.statNames[i],
                    width: 1.5)
            ],
          ))
    ]);
  }
}

class SfA09 extends StatelessWidget {
  const SfA09({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List.generate(20, (i) => _CD('P${i + 1}', PokemonChartData.first20HP[i].toDouble()));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Línea con Gradiente'),
      SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 160),
            series: <CartesianSeries>[
              SplineAreaSeries<_CD, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.x,
                  yValueMapper: (d, _) => d.y,
                  gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF4CAF50), Color(0x114CAF50)]),
                  borderColor: const Color(0xFF4CAF50),
                  borderWidth: 3)
            ],
          ))
    ]);
  }
}

class SfA10 extends StatefulWidget {
  const SfA10({super.key});
  @override
  State<SfA10> createState() => _SfA10State();
}

class _SfA10State extends State<SfA10> {
  final _rng = Random();
  late List<_CD> _data;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _data = List.generate(10, (i) => _CD('T$i', 50 + _rng.nextDouble() * 80));
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() {
        _data = List.generate(10, (i) => _CD('T$i', 40 + _rng.nextDouble() * 90));
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Actualización Animada'),
        const Text('Datos se actualizan cada 2 segundos', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 8),
        SizedBox(
            height: 230,
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 150),
              series: <CartesianSeries>[
                LineSeries<_CD, String>(
                    dataSource: _data,
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    color: const Color(0xFF00BCD4),
                    width: 2,
                    markerSettings: const MarkerSettings(isVisible: true, height: 6, width: 6),
                    animationDuration: 400)
              ],
            ))
      ]);
}

class SfA11 extends StatefulWidget {
  const SfA11({super.key});
  @override
  State<SfA11> createState() => _SfA11State();
}

class _SfA11State extends State<SfA11> {
  int _line = 0;
  static const _evos = [
    ['Bulbasaur', 'Ivysaur', 'Venusaur'],
    ['Charmander', 'Charmeleon', 'Charizard'],
    ['Squirtle', 'Wartortle', 'Blastoise'],
  ];
  static const _colors = [Color(0xFF78C850), Color(0xFFF08030), Color(0xFF6890F0)];
  static const _names = ['Planta', 'Fuego', 'Agua'];

  @override
  Widget build(BuildContext context) {
    final names = _evos[_line];
    final data = names.map((n) => _CD(n, PokemonChartData.statsOf(n).fold(0, (a, b) => a + b).toDouble())).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Comparativa Evolutiva'),
      Row(
        children: List.generate(3, (i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(label: Text(_names[i]), selected: _line == i, onSelected: (_) => setState(() => _line = i),
              selectedColor: _colors[i].withOpacity(0.3)),
        )),
      ),
      const SizedBox(height: 8),
      SizedBox(
          height: 220,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 11)),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 600),
            series: <CartesianSeries>[
              LineSeries<_CD, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.x,
                  yValueMapper: (d, _) => d.y,
                  color: _colors[_line],
                  width: 3,
                  markerSettings: const MarkerSettings(isVisible: true, height: 8, width: 8),
                  animationDuration: 600)
            ],
          )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// A12 – A16 : ADVANCED PIE CHARTS
// ─────────────────────────────────────────────────────────────────────────────

List<_CD> _pieTypes() => PokemonChartData.topTypes.entries
    .map((e) => _CD(e.key, e.value.toDouble(), color: PokemonChartData.typeColors[e.key] ?? Colors.grey))
    .toList();

class SfA12 extends StatelessWidget {
  const SfA12({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Pastel Animado'),
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
                    animationDuration: 1800,
                    radius: '75%')
              ],
            ))
      ]);
}

class SfA13 extends StatefulWidget {
  const SfA13({super.key});
  @override
  State<SfA13> createState() => _SfA13State();
}

class _SfA13State extends State<SfA13> {
  int _exploded = 0;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Leyenda Interactiva'),
        const Text('Toca una sección para explotar', style: TextStyle(fontSize: 11, color: Colors.grey)),
        SizedBox(
            height: 250,
            child: SfCircularChart(
              onChartTouchInteractionUp: (args) {
                setState(() => _exploded = (_exploded + 1) % _pieTypes().length);
              },
              series: <CircularSeries>[
                PieSeries<_CD, String>(
                    dataSource: _pieTypes(),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    pointColorMapper: (d, _) => d.color,
                    explode: true,
                    explodeIndex: _exploded,
                    explodeOffset: '12%',
                    radius: '80%')
              ],
            ))
      ]);
}

class SfA14 extends StatelessWidget {
  const SfA14({super.key});
  @override
  Widget build(BuildContext context) {
    const name = 'Mewtwo';
    final total = PokemonChartData.totalOf(name);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Donut con Estadística'),
      SizedBox(
          height: 260,
          child: Stack(alignment: Alignment.center, children: [
            SfCircularChart(
              series: <CircularSeries>[
                DoughnutSeries<_CD, String>(
                    dataSource: _stats(name),
                    xValueMapper: (d, _) => d.x,
                    yValueMapper: (d, _) => d.y,
                    pointColorMapper: (d, _) => d.color,
                    innerRadius: '50%',
                    radius: '80%')
              ],
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('$total', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0))),
            ]),
          ]))
    ]);
  }
}

class SfA15 extends StatelessWidget {
  const SfA15({super.key});
  @override
  Widget build(BuildContext context) {
    final outerData = _pieTypes().take(5).toList();
    final innerData = [
      _CD('Agua+Normal', 50, color: const Color(0xFF6890F0)),
      _CD('Veneno+Psi', 28, color: const Color(0xFFA040A0)),
      _CD('Otros', 73, color: const Color(0xFF78C850)),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Donut Multi-nivel'),
      SizedBox(
          height: 260,
          child: SfCircularChart(
            legend: const Legend(isVisible: true, position: LegendPosition.bottom, textStyle: TextStyle(fontSize: 9)),
            series: <CircularSeries>[
              DoughnutSeries<_CD, String>(
                  dataSource: outerData, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y, pointColorMapper: (d, _) => d.color, radius: '80%', innerRadius: '65%'),
              DoughnutSeries<_CD, String>(
                  dataSource: innerData, xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y, pointColorMapper: (d, _) => d.color, radius: '55%', innerRadius: '35%'),
            ],
          ))
    ]);
  }
}

class SfA16 extends StatelessWidget {
  const SfA16({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = _stats('Mewtwo');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Semi-Donut Gauge'),
      SizedBox(
          height: 220,
          child: SfCircularChart(
            series: <CircularSeries>[
              DoughnutSeries<_CD, String>(
                  dataSource: stats,
                  xValueMapper: (d, _) => d.x,
                  yValueMapper: (d, _) => d.y,
                  pointColorMapper: (d, _) => d.color,
                  startAngle: 270,
                  endAngle: 90,
                  innerRadius: '45%',
                  radius: '85%',
                  dataLabelSettings: const DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.inside, textStyle: TextStyle(fontSize: 9, color: Colors.white)))
            ],
          ))
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// A17 – A21 : ADVANCED SCATTER CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfA17 extends StatelessWidget {
  const SfA17({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = [const Color(0xFFF08030), const Color(0xFF6890F0), const Color(0xFF78C850), const Color(0xFFF8D030), const Color(0xFFA040A0)];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Scatter por Tipo'),
      SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: const NumericAxis(minimum: 0, maximum: 160, title: AxisTitle(text: 'Ataque')),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 160, title: AxisTitle(text: 'Defensa')),
            series: <CartesianSeries>[
              for (int t = 0; t < 5; t++)
                ScatterSeries<List<int>, double>(
                    dataSource: PokemonChartData.attackVsDefense.skip(t * 8).take(8).toList(),
                    xValueMapper: (d, _) => d[0].toDouble(),
                    yValueMapper: (d, _) => d[1].toDouble(),
                    color: colors[t],
                    name: ['Fuego','Agua','Planta','Eléc','Veneno'][t],
                    markerSettings: const MarkerSettings(isVisible: true, height: 10, width: 10))
            ],
          ))
    ]);
  }
}

class SfA18 extends StatefulWidget {
  const SfA18({super.key});
  @override
  State<SfA18> createState() => _SfA18State();
}

class _SfA18State extends State<SfA18> {
  String? _tapped;
  static const _names = ['Bulbasaur','Ivysaur','Venusaur','Charmander','Charmeleon','Charizard','Squirtle','Wartortle','Blastoise','Pikachu','Raichu','Jigglypuff','Gengar','Gyarados','Lapras','Eevee','Vaporeon','Jolteon','Flareon','Snorlax'];

  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.attackVsDefense.take(20).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Scatter con Detalle'),
      if (_tapped != null)
        Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
            child: Text('Seleccionado: $_tapped', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
      SizedBox(
          height: 230,
          child: SfCartesianChart(
            primaryXAxis: const NumericAxis(minimum: 0, maximum: 160, title: AxisTitle(text: 'Ataque')),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 160, title: AxisTitle(text: 'Defensa')),
            series: <CartesianSeries>[
              ScatterSeries<List<int>, double>(
                  dataSource: data,
                  xValueMapper: (d, _) => d[0].toDouble(),
                  yValueMapper: (d, _) => d[1].toDouble(),
                  onPointTap: (details) {
                    if (details.pointIndex != null && details.pointIndex! < _names.length) {
                      setState(() => _tapped = _names[details.pointIndex!]);
                    }
                  },
                  color: const Color(0xFF00BCD4).withOpacity(0.8),
                  markerSettings: const MarkerSettings(isVisible: true, height: 10, width: 10))
            ],
          )),
    ]);
  }
}

class SfA19 extends StatefulWidget {
  const SfA19({super.key});
  @override
  State<SfA19> createState() => _SfA19State();
}

class _SfA19State extends State<SfA19> {
  bool _showFirst = true;

  @override
  Widget build(BuildContext context) {
    final data = _showFirst ? PokemonChartData.attackVsDefense : PokemonChartData.hpVsSpeed;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Scatter Animado'),
      Row(children: [
        const Text('Dataset: ', style: TextStyle(fontSize: 12)),
        Switch(value: _showFirst, onChanged: (v) => setState(() => _showFirst = v)),
        Text(_showFirst ? 'Atk vs Def' : 'HP vs Vel', style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
      SizedBox(
          height: 220,
          child: SfCartesianChart(
            primaryXAxis: const NumericAxis(minimum: 0, maximum: 180),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 160),
            series: <CartesianSeries>[
              ScatterSeries<List<int>, double>(
                  dataSource: data,
                  xValueMapper: (d, _) => d[0].toDouble(),
                  yValueMapper: (d, _) => d[1].toDouble(),
                  color: _showFirst ? const Color(0xFF2196F3).withOpacity(0.7) : const Color(0xFFFF9800).withOpacity(0.7),
                  markerSettings: const MarkerSettings(isVisible: true, height: 9, width: 9),
                  animationDuration: 800)
            ],
          )),
    ]);
  }
}

class SfA20 extends StatelessWidget {
  const SfA20({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Scatter con Zoom'),
        const Text('Pellizca para hacer zoom', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 6),
        SizedBox(
            height: 240,
            child: SfCartesianChart(
              zoomPanBehavior: ZoomPanBehavior(enablePanning: true, enablePinching: true, enableDoubleTapZooming: true, enableSelectionZooming: true),
              primaryXAxis: const NumericAxis(minimum: 0, maximum: 180),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 160),
              series: <CartesianSeries>[
                ScatterSeries<List<int>, double>(
                    dataSource: PokemonChartData.attackVsDefense,
                    xValueMapper: (d, _) => d[0].toDouble(),
                    yValueMapper: (d, _) => d[1].toDouble(),
                    color: const Color(0xFF9C27B0).withOpacity(0.7),
                    markerSettings: const MarkerSettings(isVisible: true, height: 10, width: 10))
              ],
            ))
      ]);
}

class SfA21 extends StatelessWidget {
  const SfA21({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Línea de Regresión'),
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
                    markerSettings: const MarkerSettings(isVisible: true, height: 8, width: 8),
                    trendlines: <Trendline>[
                      Trendline(type: TrendlineType.linear, color: Colors.red, width: 2, opacity: 0.8)
                    ])
              ],
            ))
      ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// A22 – A25 : ADVANCED RADAR CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfA22 extends StatefulWidget {
  const SfA22({super.key});
  @override
  State<SfA22> createState() => _SfA22State();
}

class _SfA22State extends State<SfA22> with SingleTickerProviderStateMixin {
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
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf('Charizard').map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Radar Animado'),
      AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => SizedBox(
              height: 260,
              width: double.infinity,
              child: CustomPaint(
                  painter: _RP(
                      datasets: [s], colors: [const Color(0xFFF08030)], labels: PokemonChartData.statNames, progress: _anim.value)))),
      Center(child: TextButton(onPressed: () => _ctrl.forward(from: 0), child: const Text('Reiniciar animación'))),
    ]);
  }
}

class SfA23 extends StatelessWidget {
  const SfA23({super.key});
  @override
  Widget build(BuildContext context) {
    final c = PokemonChartData.statsOf('Charizard').map((v) => v / 160.0).toList();
    final b = PokemonChartData.statsOf('Blastoise').map((v) => v / 160.0).toList();
    final m = PokemonChartData.statsOf('Mewtwo').map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Radar Triple'),
      SizedBox(
          height: 270,
          width: double.infinity,
          child: CustomPaint(
              painter: _RP(
                  datasets: [c, b, m],
                  colors: [const Color(0xFFF08030), const Color(0xFF6890F0), const Color(0xFF9C27B0)],
                  labels: PokemonChartData.statNames))),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _dot(const Color(0xFFF08030), 'Charizard'),
        const SizedBox(width: 12),
        _dot(const Color(0xFF6890F0), 'Blastoise'),
        const SizedBox(width: 12),
        _dot(const Color(0xFF9C27B0), 'Mewtwo'),
      ]),
    ]);
  }

  Widget _dot(Color c, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11)),
  ]);
}

class SfA24 extends StatelessWidget {
  const SfA24({super.key});
  @override
  Widget build(BuildContext context) {
    final fire = PokemonChartData.avgStatsOf(PokemonChartData.fireTypes).map((v) => v / 160.0).toList();
    final water = PokemonChartData.avgStatsOf(PokemonChartData.waterTypes).map((v) => v / 160.0).toList();
    final grass = PokemonChartData.avgStatsOf(PokemonChartData.grassTypes).map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Radar por Tipo'),
      SizedBox(
          height: 270,
          width: double.infinity,
          child: CustomPaint(
              painter: _RP(
                  datasets: [fire, water, grass],
                  colors: [const Color(0xFFF08030), const Color(0xFF6890F0), const Color(0xFF78C850)],
                  labels: PokemonChartData.statNames))),
    ]);
  }
}

class SfA25 extends StatefulWidget {
  const SfA25({super.key});
  @override
  State<SfA25> createState() => _SfA25State();
}

class _SfA25State extends State<SfA25> {
  static const _options = ['Pikachu', 'Mewtwo', 'Charizard', 'Blastoise', 'Snorlax'];
  static const _cols = [Color(0xFFF8D030), Color(0xFF9C27B0), Color(0xFFF08030), Color(0xFF6890F0), Color(0xFFD4A82A)];
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf(_options[_idx]).map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Radar Interactivo'),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(5, (i) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
                label: Text(_options[i], style: const TextStyle(fontSize: 11)),
                selected: _idx == i,
                selectedColor: _cols[i].withOpacity(0.3),
                onSelected: (_) => setState(() => _idx = i)),
          )),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
          height: 260,
          width: double.infinity,
          child: CustomPaint(
              painter: _RP(datasets: [s], colors: [_cols[_idx]], labels: PokemonChartData.statNames))),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// A26 – A28 : ADVANCED BUBBLE CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfA26 extends StatefulWidget {
  const SfA26({super.key});
  @override
  State<SfA26> createState() => _SfA26State();
}

class _SfA26State extends State<SfA26> {
  int _visible = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (!mounted) return;
      if (_visible < PokemonChartData.bubbleHpAtk.length) {
        setState(() => _visible++);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.bubbleHpAtk.take(_visible).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Burbujas Escalonadas'),
      SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: const NumericAxis(minimum: 0, maximum: 180),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 160),
            series: <CartesianSeries>[
              BubbleSeries<List<int>, double>(
                  dataSource: data,
                  xValueMapper: (d, _) => d[0].toDouble(),
                  yValueMapper: (d, _) => d[1].toDouble(),
                  sizeValueMapper: (d, _) => d[2].toDouble(),
                  color: const Color(0xFF2196F3).withOpacity(0.6),
                  minimumRadius: 6, maximumRadius: 24)
            ],
          ))
    ]);
  }
}

class SfA27 extends StatefulWidget {
  const SfA27({super.key});
  @override
  State<SfA27> createState() => _SfA27State();
}

class _SfA27State extends State<SfA27> {
  static const _names = ['Bulbasaur','Ivysaur','Venusaur','Charmander','Charmeleon','Charizard','Squirtle','Wartortle','Blastoise','Pikachu','Raichu','Jigglypuff','Gengar','Gyarados','Lapras','Eevee','Vaporeon','Jolteon','Flareon','Snorlax'];
  String? _info;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Burbujas Interactivas'),
        if (_info != null)
          Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(_info!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
        SizedBox(
            height: 240,
            child: SfCartesianChart(
              primaryXAxis: const NumericAxis(minimum: 0, maximum: 180),
              primaryYAxis: const NumericAxis(minimum: 0, maximum: 160),
              series: <CartesianSeries>[
                BubbleSeries<List<int>, double>(
                    dataSource: PokemonChartData.bubbleHpAtk,
                    xValueMapper: (d, _) => d[0].toDouble(),
                    yValueMapper: (d, _) => d[1].toDouble(),
                    sizeValueMapper: (d, _) => d[2].toDouble(),
                    color: const Color(0xFFFF9800).withOpacity(0.6),
                    minimumRadius: 6, maximumRadius: 24,
                    onPointTap: (details) {
                      if (details.pointIndex != null && details.pointIndex! < _names.length) {
                        final p = PokemonChartData.bubbleHpAtk[details.pointIndex!];
                        setState(() => _info = '${_names[details.pointIndex!]} | HP: ${p[0]} | Atk: ${p[1]} | Def: ${p[2]}');
                      }
                    })
              ],
            )),
      ]);
}

class SfA28 extends StatelessWidget {
  const SfA28({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = [const Color(0xFFF08030), const Color(0xFF6890F0), const Color(0xFF78C850), const Color(0xFFF8D030), const Color(0xFFA040A0)];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Burbujas por Tipo'),
      SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: const NumericAxis(minimum: 0, maximum: 180),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 160),
            series: <CartesianSeries>[
              for (int t = 0; t < 5; t++)
                BubbleSeries<List<int>, double>(
                    dataSource: PokemonChartData.bubbleHpAtk.skip(t * 4).take(4).toList(),
                    xValueMapper: (d, _) => d[0].toDouble(),
                    yValueMapper: (d, _) => d[1].toDouble(),
                    sizeValueMapper: (d, _) => d[2].toDouble(),
                    name: ['Fuego','Agua','Planta','Eléc','Psíq'][t],
                    color: colors[t].withOpacity(0.7),
                    minimumRadius: 8, maximumRadius: 22)
            ],
          ))
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// A29 – A30 : ADVANCED HEATMAP CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfA29 extends StatefulWidget {
  const SfA29({super.key});
  @override
  State<SfA29> createState() => _SfA29State();
}

class _SfA29State extends State<SfA29> {
  String? _info;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _t('Heatmap Interactivo'),
        const Text('Toca una celda para ver el valor', style: TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 6),
        if (_info != null)
          Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(_info!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
        _heatGrid(PokemonChartData.heatmapAvg, 130.0, Colors.teal,
            onTap: (r, c, v) {
          setState(() => _info = '${PokemonChartData.heatmapTypes[r]} / ${PokemonChartData.statNames[c]}: ${v.toStringAsFixed(1)}');
        }),
      ]);
}

class SfA30 extends StatelessWidget {
  const SfA30({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.heatmapAvg;
    final maxVal = 130.0;
    final cols = data[0].length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Heatmap Gradiente'),
      const Text('Gradiente rojo-amarillo-verde', style: TextStyle(fontSize: 11, color: Colors.grey)),
      const SizedBox(height: 8),
      SizedBox(
          height: 180,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols, childAspectRatio: cols / data.length.toDouble()),
            itemCount: data.length * cols,
            itemBuilder: (_, idx) {
              final r = idx ~/ cols;
              final c = idx % cols;
              final v = (data[r][c] / maxVal).clamp(0.0, 1.0);
              final color = v < 0.5
                  ? Color.lerp(Colors.red.shade400, Colors.yellow.shade400, v * 2)!
                  : Color.lerp(Colors.yellow.shade400, Colors.green.shade600, (v - 0.5) * 2)!;
              return Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                  child: Center(child: Text(data[r][c].toStringAsFixed(0),
                      style: const TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.bold))));
            },
          )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// A31 – A32 : ADVANCED AREA CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfA31 extends StatelessWidget {
  const SfA31({super.key});
  @override
  Widget build(BuildContext context) {
    List<_CD> _evo(List<String> names, Color c, String label) =>
        names.map((n) => _CD(n.substring(0, min(7, n.length)), PokemonChartData.statsOf(n)[0].toDouble(), color: c)).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Área Apilada Animada'),
      SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 9)),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 250),
            legend: const Legend(isVisible: true, position: LegendPosition.bottom),
            series: <CartesianSeries>[
              StackedAreaSeries<_CD, String>(
                  dataSource: _evo(['Bulbasaur', 'Ivysaur', 'Venusaur'], const Color(0xFF78C850), 'Planta'),
                  xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y, name: 'Planta', animationDuration: 1200),
              StackedAreaSeries<_CD, String>(
                  dataSource: _evo(['Charmander', 'Charmeleon', 'Charizard'], const Color(0xFFF08030), 'Fuego'),
                  xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y, name: 'Fuego', animationDuration: 1200),
              StackedAreaSeries<_CD, String>(
                  dataSource: _evo(['Squirtle', 'Wartortle', 'Blastoise'], const Color(0xFF6890F0), 'Agua'),
                  xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y, name: 'Agua', animationDuration: 1200),
            ],
          ))
    ]);
  }
}

class SfA32 extends StatelessWidget {
  const SfA32({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List.generate(20, (i) => _CD('P${i + 1}', PokemonChartData.first20HP[i].toDouble()));
    final avgHP = PokemonChartData.first20HP.fold(0, (a, b) => a + b) / 20.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Área con Threshold'),
      Text('Promedio HP: ${avgHP.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
      const SizedBox(height: 6),
      SizedBox(
          height: 240,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 160,
              plotBands: [
                PlotBand(start: avgHP, end: avgHP, borderWidth: 2, borderColor: Colors.red, dashArray: <double>[5, 5], text: 'Promedio', textStyle: const TextStyle(color: Colors.red, fontSize: 10))
              ],
            ),
            series: <CartesianSeries>[
              SplineAreaSeries<_CD, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y,
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  borderColor: const Color(0xFF4CAF50), borderWidth: 2)
            ],
          ))
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// A33 – A36 : ADVANCED COMBINED CHARTS
// ─────────────────────────────────────────────────────────────────────────────

class SfA33 extends StatefulWidget {
  const SfA33({super.key});
  @override
  State<SfA33> createState() => _SfA33State();
}

class _SfA33State extends State<SfA33> {
  String _name = 'Pikachu';
  static const _options = ['Pikachu', 'Mewtwo', 'Charizard', 'Blastoise', 'Snorlax'];

  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf(_name);
    final total = stats.fold(0, (a, b) => a + b);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Dashboard Completo'),
      DropdownButton<String>(
          value: _name,
          items: _options.map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
          onChanged: (v) => setState(() => _name = v!)),
      SizedBox(
          height: 180,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
            primaryYAxis: const NumericAxis(minimum: 0, maximum: 170),
            series: <CartesianSeries>[
              ColumnSeries<_CD, String>(
                  dataSource: List.generate(6, (i) => _CD(PokemonChartData.statNames[i], stats[i].toDouble(), color: PokemonChartData.statColors[i])),
                  xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y, pointColorMapper: (d, _) => d.color,
                  borderRadius: BorderRadius.circular(4), animationDuration: 600)
            ],
          )),
      const SizedBox(height: 8),
      Row(children: [
        _StatChip('Total', '$total', Colors.purple),
        const SizedBox(width: 6),
        _StatChip('Mejor', PokemonChartData.statNames[stats.indexOf(stats.reduce(max))], Colors.orange),
        const SizedBox(width: 6),
        _StatChip('HP', '${stats[0]}', const Color(0xFF4CAF50)),
      ]),
    ]);
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatChip(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
    ),
  );
}

class SfA34 extends StatelessWidget {
  const SfA34({super.key});
  @override
  Widget build(BuildContext context) {
    Widget _col(String name, Color color) {
      final stats = PokemonChartData.statsOf(name);
      return Expanded(
        child: Column(children: [
          Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 8)),
                primaryYAxis: NumericAxis(minimum: 0, maximum: 170, isVisible: false),
                plotAreaBorderWidth: 0,
                series: <CartesianSeries>[
                  ColumnSeries<_CD, String>(
                      dataSource: List.generate(6, (i) => _CD(PokemonChartData.statNames[i], stats[i].toDouble())),
                      xValueMapper: (d, _) => d.x, yValueMapper: (d, _) => d.y,
                      color: color, borderRadius: BorderRadius.circular(4))
                ],
              )),
        ]),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Comparador Lado a Lado'),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _col('Charizard', const Color(0xFFF08030)),
        const SizedBox(width: 8),
        _col('Blastoise', const Color(0xFF6890F0)),
      ]),
    ]);
  }
}

class SfA35 extends StatelessWidget {
  const SfA35({super.key});
  @override
  Widget build(BuildContext context) {
    const evos = [
      ('Bulbasaur', 0, 16),
      ('Ivysaur', 16, 32),
      ('Venusaur', 32, 100),
      ('Charmander', 0, 16),
      ('Charmeleon', 16, 36),
      ('Charizard', 36, 100),
    ];
    final colors = [const Color(0xFF78C850), const Color(0xFF78C850), const Color(0xFF78C850), const Color(0xFFF08030), const Color(0xFFF08030), const Color(0xFFF08030)];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Timeline Evolutivo'),
      SizedBox(
          height: 260,
          child: CustomPaint(
              size: const Size(double.infinity, 260),
              painter: _TimelinePainter(evos: evos, colors: colors))),
    ]);
  }
}

class _TimelinePainter extends CustomPainter {
  final List<(String, int, int)> evos;
  final List<Color> colors;
  const _TimelinePainter({required this.evos, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 80.0;
    const rightPad = 10.0;
    final rowH = size.height / evos.length;
    final w = size.width - leftPad - rightPad;
    for (int i = 0; i < evos.length; i++) {
      final (name, start, end) = evos[i];
      final y = i * rowH + rowH / 2;
      final x0 = leftPad + w * start / 100;
      final x1 = leftPad + w * end / 100;
      final paint = Paint()..color = colors[i]..style = PaintingStyle.fill;
      canvas.drawRRect(
          RRect.fromLTRBR(x0, y - rowH * 0.3, x1, y + rowH * 0.3, const Radius.circular(4)), paint);
      final tp = TextPainter(
          text: TextSpan(text: name, style: const TextStyle(fontSize: 11, color: Colors.black87)),
          textDirection: TextDirection.ltr);
      tp.layout();
      canvas.save();
      canvas.translate(4, y - tp.height / 2);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
    }
    final axisPaint = Paint()..color = Colors.grey.shade400..strokeWidth = 1;
    for (int lvl in [0, 20, 40, 60, 80, 100]) {
      final x = leftPad + w * lvl / 100;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), axisPaint..style = PaintingStyle.stroke);
      final tp = TextPainter(
          text: TextSpan(text: 'Lv$lvl', style: const TextStyle(fontSize: 8, color: Colors.grey)),
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 14));
    }
  }

  @override
  bool shouldRepaint(_TimelinePainter o) => false;
}

class SfA36 extends StatelessWidget {
  const SfA36({super.key});
  @override
  Widget build(BuildContext context) {
    const n1 = 'Bulbasaur';
    const n2 = 'Mewtwo';
    final s1 = PokemonChartData.statsOf(n1);
    final s2 = PokemonChartData.statsOf(n2);
    final diffs = List.generate(6, (i) => s2[i] - s1[i]);
    final data = List.generate(6, (i) => _CD(
        PokemonChartData.statNames[i],
        diffs[i].toDouble(),
        color: diffs[i] >= 0 ? Colors.green : Colors.red));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _t('Waterfall Stats'),
      Text('$n1 → $n2 (diferencia por stat)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 8),
      SizedBox(
          height: 250,
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(labelStyle: TextStyle(fontSize: 10)),
            series: <CartesianSeries>[
              ColumnSeries<_CD, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.x,
                  yValueMapper: (d, _) => d.y,
                  pointColorMapper: (d, _) => d.color,
                  borderRadius: BorderRadius.circular(4),
                  dataLabelSettings: const DataLabelSettings(isVisible: true, textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))
            ],
          ))
    ]);
  }
}
