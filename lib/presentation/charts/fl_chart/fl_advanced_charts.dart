import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/data/pokemon_chart_data.dart';

Widget _chartTitle(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
    );

FlTitlesData _bottomTitles(List<String> labels) => FlTitlesData(
      bottomTitles: AxisTitles(sideTitles: SideTitles(
        showTitles: true, reservedSize: 24,
        getTitlesWidget: (v, _) {
          final i = v.toInt();
          if (i < 0 || i >= labels.length) return const SizedBox.shrink();
          return Padding(padding: const EdgeInsets.only(top: 4),
              child: Text(labels[i], style: const TextStyle(fontSize: 9)));
        },
      )),
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
          getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 9)))),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );

// ─── FlA01: Barras Animadas ──────────────────────────────────────────────────
class FlA01 extends StatefulWidget {
  const FlA01({super.key});
  @override
  State<FlA01> createState() => _FlA01State();
}

class _FlA01State extends State<FlA01> with SingleTickerProviderStateMixin {
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
    final stats = PokemonChartData.statsOf('Bulbasaur');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Barras Animadas – Stats Bulbasaur'),
      AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => SizedBox(height: 260, child: BarChart(BarChartData(
          barGroups: List.generate(6, (i) => BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: stats[i].toDouble() * _anim.value,
                  color: PokemonChartData.statColors[i],
                  width: 28,
                  borderRadius: BorderRadius.circular(4),
                )
              ])),
          titlesData: _bottomTitles(PokemonChartData.statNames),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          maxY: 100,
        ))),
      ),
      const SizedBox(height: 8),
      ElevatedButton(onPressed: () => _ctrl..reset()..forward(), child: const Text('Reiniciar')),
    ]);
  }
}

// ─── FlA02: Selector de Pokémon ──────────────────────────────────────────────
class FlA02 extends StatefulWidget {
  const FlA02({super.key});
  @override
  State<FlA02> createState() => _FlA02State();
}

class _FlA02State extends State<FlA02> {
  String _selected = 'Pikachu';
  static const _options = ['Pikachu', 'Charizard', 'Mewtwo', 'Snorlax', 'Gengar', 'Lapras'];

  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf(_selected);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Selector de Pokémon'),
      DropdownButton<String>(
        value: _selected,
        items: _options.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
        onChanged: (v) { if (v != null) setState(() => _selected = v); },
      ),
      const SizedBox(height: 8),
      SizedBox(height: 240, child: BarChart(BarChartData(
        barGroups: List.generate(6, (i) => BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: stats[i].toDouble(), color: PokemonChartData.statColors[i], width: 28, borderRadius: BorderRadius.circular(4))
            ])),
        titlesData: _bottomTitles(PokemonChartData.statNames),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(drawVerticalLine: false),
        maxY: 180,
      ))),
    ]);
  }
}

// ─── FlA03: Barras con Tooltip ───────────────────────────────────────────────
class FlA03 extends StatelessWidget {
  const FlA03({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Charizard');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Barras con Tooltip – Toca una barra'),
      SizedBox(height: 260, child: BarChart(BarChartData(
        barGroups: List.generate(6, (i) => BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: stats[i].toDouble(), color: PokemonChartData.statColors[i], width: 28, borderRadius: BorderRadius.circular(4))
            ])),
        titlesData: _bottomTitles(PokemonChartData.statNames),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(drawVerticalLine: false),
        maxY: 160,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
              '${PokemonChartData.statNames[gi]}: ${rod.toY.toInt()}',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ))),
    ]);
  }
}

// ─── FlA04: Diferencia vs Promedio ──────────────────────────────────────────
class FlA04 extends StatelessWidget {
  const FlA04({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Pikachu');
    final avg = stats.fold(0, (a, b) => a + b) / 6.0;
    final diffs = stats.map((v) => v.toDouble() - avg).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Diferencia vs Promedio (Pikachu avg=${avg.toStringAsFixed(0)})'),
      SizedBox(height: 260, child: BarChart(BarChartData(
        barGroups: List.generate(6, (i) => BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: diffs[i],
                color: diffs[i] >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                width: 28, borderRadius: BorderRadius.circular(4),
              )
            ])),
        titlesData: _bottomTitles(PokemonChartData.statNames),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(drawVerticalLine: false),
        minY: -40, maxY: 50,
        baselineY: 0,
      ))),
    ]);
  }
}

// ─── FlA05: Composición 100% ─────────────────────────────────────────────────
class FlA05 extends StatelessWidget {
  const FlA05({super.key});
  @override
  Widget build(BuildContext context) {
    final pokes = ['Bulbasaur', 'Pikachu', 'Mewtwo', 'Snorlax'];
    final colors = PokemonChartData.statColors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Composición 100% – Stats por Pokémon'),
      SizedBox(height: 260, child: BarChart(BarChartData(
        barGroups: List.generate(pokes.length, (i) {
          final s = PokemonChartData.statsOf(pokes[i]);
          final total = s.fold(0, (a, b) => a + b).toDouble();
          double cum = 0;
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: 100,
              width: 40,
              borderRadius: BorderRadius.circular(4),
              rodStackItems: List.generate(6, (j) {
                final start = cum;
                cum += (s[j] / total) * 100;
                return BarChartRodStackItem(start, cum, colors[j]);
              }),
            )
          ]);
        }),
        titlesData: _bottomTitles(pokes.map((p) => p.length > 6 ? p.substring(0, 6) : p).toList()),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(drawVerticalLine: false),
        maxY: 105,
      ))),
    ]);
  }
}

// ─── FlA06: Ranking Dinámico Top 10 ─────────────────────────────────────────
class FlA06 extends StatefulWidget {
  const FlA06({super.key});
  @override
  State<FlA06> createState() => _FlA06State();
}

class _FlA06State extends State<FlA06> {
  int _statIdx = 1;
  static const _statLabels = ['HP', 'Ataque', 'Defensa', 'Sp.Atk', 'Sp.Def', 'Velocidad'];

  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(_statIdx, n: 8);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Ranking Dinámico – Top 8'),
      DropdownButton<int>(
        value: _statIdx,
        items: List.generate(6, (i) => DropdownMenuItem(value: i, child: Text(_statLabels[i]))),
        onChanged: (v) { if (v != null) setState(() => _statIdx = v); },
      ),
      const SizedBox(height: 8),
      SizedBox(height: 240, child: BarChart(BarChartData(
        barGroups: List.generate(top.length, (i) => BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: top[i].value.toDouble(),
                color: PokemonChartData.statColors[_statIdx], width: 24, borderRadius: BorderRadius.circular(4))
            ])),
        titlesData: _bottomTitles(top.map((e) => e.key.length > 6 ? e.key.substring(0, 6) : e.key).toList()),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(drawVerticalLine: false),
        maxY: 180,
      ))),
    ]);
  }
}

// ─── FlA07: Línea con Zoom/Pan ───────────────────────────────────────────────
class FlA07 extends StatelessWidget {
  const FlA07({super.key});
  @override
  Widget build(BuildContext context) {
    final hp = PokemonChartData.first20HP;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Línea con Zoom/Pan (pellizca para zoom)'),
      SizedBox(height: 260, child: InteractiveViewer(
        constrained: true,
        scaleEnabled: true,
        panEnabled: true,
        child: LineChart(LineChartData(
          lineBarsData: [LineChartBarData(
            spots: List.generate(hp.length, (i) => FlSpot(i.toDouble(), hp[i].toDouble())),
            color: const Color(0xFF4CAF50), isCurved: false, barWidth: 2,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: const Color(0xFF4CAF50).withOpacity(0.15)),
          )],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
              getTitlesWidget: (v, _) => Text('#${v.toInt() + 1}', style: const TextStyle(fontSize: 8)))),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          lineTouchData: const LineTouchData(enabled: true),
          minY: 0, maxY: 180,
        )),
      )),
    ]);
  }
}

// ─── FlA08: Multi-serie 6 Stats ──────────────────────────────────────────────
class FlA08 extends StatelessWidget {
  const FlA08({super.key});
  @override
  Widget build(BuildContext context) {
    final allStats = [
      PokemonChartData.first20HP,
      PokemonChartData.first20Atk,
      PokemonChartData.first20Def,
      PokemonChartData.first20Atk.map((v) => (v * 1.1).toInt()).toList(),
      PokemonChartData.first20Def.map((v) => (v * 0.95).toInt()).toList(),
      PokemonChartData.first20Spd,
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Multi-serie – 6 Stats (primeros 20)'),
      Wrap(spacing: 8, children: List.generate(6, (i) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, color: PokemonChartData.statColors[i]),
        const SizedBox(width: 3),
        Text(PokemonChartData.statNames[i], style: const TextStyle(fontSize: 10)),
      ]))),
      const SizedBox(height: 8),
      SizedBox(height: 240, child: LineChart(LineChartData(
        lineBarsData: List.generate(6, (i) => LineChartBarData(
          spots: List.generate(20, (j) => FlSpot(j.toDouble(), allStats[i][j].toDouble())),
          color: PokemonChartData.statColors[i],
          isCurved: false, barWidth: 1.5,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        )),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
            getTitlesWidget: (v, _) => v.toInt() % 5 == 0
                ? Text('#${v.toInt() + 1}', style: const TextStyle(fontSize: 8))
                : const SizedBox.shrink())),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(drawVerticalLine: false),
        minY: 0, maxY: 180,
      ))),
    ]);
  }
}

// ─── FlA09: Línea con Gradiente ──────────────────────────────────────────────
class FlA09 extends StatelessWidget {
  const FlA09({super.key});
  @override
  Widget build(BuildContext context) {
    final hp = PokemonChartData.first20HP;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Línea con Gradiente – HP Primeros 20'),
      SizedBox(height: 260, child: LineChart(LineChartData(
        lineBarsData: [LineChartBarData(
          spots: List.generate(hp.length, (i) => FlSpot(i.toDouble(), hp[i].toDouble())),
          color: Colors.transparent,
          isCurved: true, barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784), Color(0xFFC8E6C9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          gradient: const LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        )],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
            getTitlesWidget: (v, _) => v.toInt() % 4 == 0
                ? Text('#${v.toInt() + 1}', style: const TextStyle(fontSize: 9))
                : const SizedBox.shrink())),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 9)))),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(drawVerticalLine: false),
        minY: 0, maxY: 160,
      ))),
    ]);
  }
}

// ─── FlA10: Actualización Animada ────────────────────────────────────────────
class FlA10 extends StatefulWidget {
  const FlA10({super.key});
  @override
  State<FlA10> createState() => _FlA10State();
}

class _FlA10State extends State<FlA10> {
  Timer? _timer;
  final _rng = Random();
  List<double> _vals = List.generate(10, (i) => 50 + Random().nextInt(80).toDouble());

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) setState(() => _vals = List.generate(10, (_) => 20 + _rng.nextInt(140).toDouble()));
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Actualización Animada – Datos en tiempo real'),
      SizedBox(height: 260, child: LineChart(
        LineChartData(
          lineBarsData: [LineChartBarData(
            spots: List.generate(_vals.length, (i) => FlSpot(i.toDouble(), _vals[i])),
            color: const Color(0xFF2196F3), isCurved: true, barWidth: 2,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: const Color(0xFF2196F3).withOpacity(0.15)),
          )],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 9)))),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          minY: 0, maxY: 180,
        ),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      )),
      const Text('Actualiza automáticamente cada 2s', style: TextStyle(fontSize: 11, color: Colors.grey)),
    ]);
  }
}

// ─── FlA11: Comparativa Evolutiva ────────────────────────────────────────────
class FlA11 extends StatefulWidget {
  const FlA11({super.key});
  @override
  State<FlA11> createState() => _FlA11State();
}

class _FlA11State extends State<FlA11> {
  String _starter = 'Bulbasaur';
  static const _evolutions = {
    'Bulbasaur':  ['Bulbasaur', 'Ivysaur', 'Venusaur'],
    'Charmander': ['Charmander', 'Charmeleon', 'Charizard'],
    'Squirtle':   ['Squirtle', 'Wartortle', 'Blastoise'],
  };
  static const _colors = {
    'Bulbasaur': Color(0xFF78C850),
    'Charmander': Color(0xFFF08030),
    'Squirtle': Color(0xFF6890F0),
  };

  @override
  Widget build(BuildContext context) {
    final evos = _evolutions[_starter]!;
    final color = _colors[_starter]!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Comparativa Evolutiva'),
      DropdownButton<String>(
        value: _starter,
        items: _evolutions.keys.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
        onChanged: (v) { if (v != null) setState(() => _starter = v); },
      ),
      const SizedBox(height: 8),
      SizedBox(height: 220, child: LineChart(LineChartData(
        lineBarsData: List.generate(6, (stat) => LineChartBarData(
          spots: List.generate(3, (i) => FlSpot(i.toDouble(), PokemonChartData.statsOf(evos[i])[stat].toDouble())),
          color: color.withOpacity(0.5 + stat * 0.08),
          isCurved: true, barWidth: 1.5,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        )),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= 3) return const SizedBox.shrink();
              return Text(evos[i].length > 8 ? evos[i].substring(0, 8) : evos[i], style: const TextStyle(fontSize: 9));
            })),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 9)))),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(drawVerticalLine: false),
        minY: 0, maxY: 160,
      ))),
    ]);
  }
}

// ─── FlA12: Pastel Animado ────────────────────────────────────────────────────
class FlA12 extends StatefulWidget {
  const FlA12({super.key});
  @override
  State<FlA12> createState() => _FlA12State();
}

class _FlA12State extends State<FlA12> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final types = PokemonChartData.topTypes;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Pastel Animado'),
      AnimatedBuilder(animation: _anim, builder: (_, __) {
        final r = 80.0 * _anim.value;
        return SizedBox(height: 260, child: PieChart(PieChartData(
          sections: types.entries.map((e) {
            final color = PokemonChartData.typeColors[e.key] ?? Colors.grey;
            return PieChartSectionData(value: e.value.toDouble(), title: e.key, color: color,
              radius: r, titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white));
          }).toList(),
          sectionsSpace: 2, centerSpaceRadius: 0,
        )));
      }),
      ElevatedButton(onPressed: () => _ctrl..reset()..forward(), child: const Text('Reiniciar')),
    ]);
  }
}

// ─── FlA13: Leyenda Interactiva ──────────────────────────────────────────────
class FlA13 extends StatefulWidget {
  const FlA13({super.key});
  @override
  State<FlA13> createState() => _FlA13State();
}

class _FlA13State extends State<FlA13> {
  final _visible = List.filled(8, true);

  @override
  Widget build(BuildContext context) {
    final types = PokemonChartData.topTypes.entries.toList();
    final shown = types.where((e) => _visible[types.indexOf(e)]).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Leyenda Interactiva – Toca para ocultar'),
      Wrap(spacing: 6, runSpacing: 4, children: List.generate(types.length, (i) {
        final color = PokemonChartData.typeColors[types[i].key] ?? Colors.grey;
        return GestureDetector(
          onTap: () => setState(() => _visible[i] = !_visible[i]),
          child: Opacity(opacity: _visible[i] ? 1.0 : 0.3,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 12, height: 12, color: color),
              const SizedBox(width: 3),
              Text(types[i].key, style: const TextStyle(fontSize: 10)),
            ])),
        );
      })),
      const SizedBox(height: 8),
      SizedBox(height: 220, child: PieChart(PieChartData(
        sections: shown.map((e) {
          final color = PokemonChartData.typeColors[e.key] ?? Colors.grey;
          return PieChartSectionData(value: e.value.toDouble(), title: e.key, color: color, radius: 80,
            titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white));
        }).toList(),
        sectionsSpace: 2, centerSpaceRadius: 0,
      ))),
    ]);
  }
}

// ─── FlA14: Donut con Estadística ────────────────────────────────────────────
class FlA14 extends StatelessWidget {
  const FlA14({super.key});
  @override
  Widget build(BuildContext context) {
    final total = PokemonChartData.totalOf('Mewtwo');
    final types = PokemonChartData.topTypes;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Donut con Estadística Central'),
      SizedBox(height: 260, child: Stack(alignment: Alignment.center, children: [
        PieChart(PieChartData(
          sections: types.entries.map((e) {
            final color = PokemonChartData.typeColors[e.key] ?? Colors.grey;
            return PieChartSectionData(value: e.value.toDouble(), title: '', color: color, radius: 70);
          }).toList(),
          sectionsSpace: 2, centerSpaceRadius: 60,
        )),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$total', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFF85888))),
          const Text('Total\nMewtwo', style: TextStyle(fontSize: 9, color: Colors.grey), textAlign: TextAlign.center),
        ]),
      ])),
    ]);
  }
}

// ─── FlA15: Donut Multi-nivel ─────────────────────────────────────────────────
class FlA15 extends StatelessWidget {
  const FlA15({super.key});
  @override
  Widget build(BuildContext context) {
    final outer = PokemonChartData.topTypes.entries.take(5).toList();
    final inner = [
      MapEntry('Agua', 28), MapEntry('Normal', 22), MapEntry('Otros', 101),
    ];
    final outerColors = [const Color(0xFF6890F0), Colors.grey, const Color(0xFFA040A0), const Color(0xFFF85888), const Color(0xFFF08030)];
    final innerColors = [const Color(0xFF1565C0), Colors.blueGrey, const Color(0xFF43A047)];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Donut Multi-nivel'),
      SizedBox(height: 260, child: Stack(alignment: Alignment.center, children: [
        PieChart(PieChartData(
          sections: List.generate(outer.length, (i) => PieChartSectionData(
            value: outer[i].value.toDouble(), title: outer[i].key, color: outerColors[i], radius: 50,
            titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
          )),
          sectionsSpace: 2, centerSpaceRadius: 55,
        )),
        SizedBox(width: 110, height: 110, child: PieChart(PieChartData(
          sections: List.generate(inner.length, (i) => PieChartSectionData(
            value: inner[i].value.toDouble(), title: inner[i].key, color: innerColors[i], radius: 50,
            titleStyle: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
          )),
          sectionsSpace: 2, centerSpaceRadius: 0,
        ))),
      ])),
    ]);
  }
}

// ─── FlA16: Semi-Donut Gauge ─────────────────────────────────────────────────
class FlA16 extends StatelessWidget {
  const FlA16({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Mewtwo');
    final total = PokemonChartData.totalOf('Mewtwo');
    const maxTotal = 680.0;
    final pct = total / maxTotal;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Semi-Donut Gauge – Mewtwo vs máx posible'),
      SizedBox(height: 180, child: Stack(alignment: Alignment.bottomCenter, children: [
        PieChart(PieChartData(
          startDegreeOffset: -180,
          sections: [
            PieChartSectionData(value: pct * 180, title: '', color: const Color(0xFFF85888), radius: 60),
            PieChartSectionData(value: (1 - pct) * 180, title: '', color: Colors.grey.shade200, radius: 60),
            PieChartSectionData(value: 180, title: '', color: Colors.transparent, radius: 60),
          ],
          sectionsSpace: 0, centerSpaceRadius: 50,
        )),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$total', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFF85888))),
            Text('de $maxTotal (${(pct * 100).toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ]),
        ),
      ])),
      const SizedBox(height: 8),
      Wrap(spacing: 6, children: List.generate(6, (i) => Chip(
        label: Text('${PokemonChartData.statNames[i]}: ${stats[i]}', style: const TextStyle(fontSize: 10)),
        backgroundColor: PokemonChartData.statColors[i].withOpacity(0.15),
      ))),
    ]);
  }
}

// ─── FlA17: Scatter por Tipo ─────────────────────────────────────────────────
class FlA17 extends StatelessWidget {
  const FlA17({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.attackVsDefense;
    final typeColors = [
      const Color(0xFF6890F0), const Color(0xFFF08030),
      const Color(0xFF78C850), const Color(0xFFF8D030),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Scatter por Tipo – Ataque vs Defensa'),
      Row(children: ['Agua','Fuego','Planta','Eléctrico'].asMap().entries.map((e) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, margin: const EdgeInsets.only(right: 3, left: 6), color: typeColors[e.key]),
          Text(e.value, style: const TextStyle(fontSize: 10)),
        ],
      )).toList()),
      const SizedBox(height: 8),
      SizedBox(height: 240, child: ScatterChart(ScatterChartData(
        scatterSpots: data.asMap().entries.map((e) {
          final colorIdx = e.key % 4;
          return ScatterSpot(e.value[0].toDouble(), e.value[1].toDouble(),
            dotPainter: FlDotCirclePainter(radius: 5, color: typeColors[colorIdx].withOpacity(0.75)));
        }).toList(),
        minX: 0, maxX: 180, minY: 0, maxY: 180,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ))),
    ]);
  }
}

// ─── FlA18: Scatter con Detalle ──────────────────────────────────────────────
class FlA18 extends StatefulWidget {
  const FlA18({super.key});
  @override
  State<FlA18> createState() => _FlA18State();
}

class _FlA18State extends State<FlA18> {
  String? _touched;
  static const _names = ['Bulbasaur','Ivysaur','Venusaur','Charmander','Charmeleon','Charizard',
    'Squirtle','Wartortle','Blastoise','Caterpie','Butterfree','Pikachu','Raichu','Jigglypuff',
    'Meowth','Persian','Gengar','Gyarados','Lapras','Eevee'];

  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.attackVsDefense;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Scatter con Detalle – Toca un punto'),
      if (_touched != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
          child: Text('Pokémon: $_touched', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      const SizedBox(height: 8),
      SizedBox(height: 240, child: ScatterChart(ScatterChartData(
        scatterSpots: List.generate(min(data.length, _names.length), (i) =>
          ScatterSpot(data[i][0].toDouble(), data[i][1].toDouble(),
            dotPainter: FlDotCirclePainter(radius: 7, color: const Color(0xFF2196F3).withOpacity(0.7)))),
        minX: 0, maxX: 180, minY: 0, maxY: 180,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        scatterTouchData: ScatterTouchData(
          enabled: true,
          touchCallback: (event, response) {
            if (response?.touchedSpot != null) {
              final idx = response!.touchedSpot!.spotIndex;
              if (idx < _names.length) setState(() => _touched = _names[idx]);
            }
          },
        ),
      ))),
    ]);
  }
}

// ─── FlA19: Scatter Animado ──────────────────────────────────────────────────
class FlA19 extends StatefulWidget {
  const FlA19({super.key});
  @override
  State<FlA19> createState() => _FlA19State();
}

class _FlA19State extends State<FlA19> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  bool _showSecond = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _toggle() {
    setState(() => _showSecond = !_showSecond);
    _showSecond ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final d1 = PokemonChartData.attackVsDefense;
    final d2 = PokemonChartData.hpVsSpeed;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Scatter Animado – Transición de datasets'),
      AnimatedBuilder(animation: _anim, builder: (_, __) {
        final spots = List.generate(min(d1.length, d2.length), (i) {
          final x = d1[i][0] + (d2[i][0] - d1[i][0]) * _anim.value;
          final y = d1[i][1] + (d2[i][1] - d1[i][1]) * _anim.value;
          return ScatterSpot(x.toDouble(), y.toDouble(),
            dotPainter: FlDotCirclePainter(radius: 5,
              color: Color.lerp(const Color(0xFFF44336), const Color(0xFF4CAF50), _anim.value)!.withOpacity(0.7)));
        });
        return SizedBox(height: 240, child: ScatterChart(ScatterChartData(
          scatterSpots: spots,
          minX: 0, maxX: 180, minY: 0, maxY: 180,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        )));
      }),
      ElevatedButton(onPressed: _toggle, child: Text(_showSecond ? 'Dataset 1' : 'Dataset 2')),
    ]);
  }
}

// ─── FlA20: Scatter con Zoom ─────────────────────────────────────────────────
class FlA20 extends StatelessWidget {
  const FlA20({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.attackVsDefense;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Scatter con Zoom – Pellizca para hacer zoom'),
      SizedBox(height: 260, child: InteractiveViewer(
        constrained: true, scaleEnabled: true, panEnabled: true,
        child: ScatterChart(ScatterChartData(
          scatterSpots: data.map((p) => ScatterSpot(p[0].toDouble(), p[1].toDouble(),
            dotPainter: FlDotCirclePainter(radius: 6, color: const Color(0xFF9C27B0).withOpacity(0.7)))).toList(),
          minX: 0, maxX: 180, minY: 0, maxY: 180,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        )),
      )),
    ]);
  }
}

// ─── FlA21: Línea de Regresión ────────────────────────────────────────────────
class FlA21 extends StatelessWidget {
  const FlA21({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.attackVsDefense;
    final n = data.length.toDouble();
    final sumX = data.fold(0.0, (s, p) => s + p[0]);
    final sumY = data.fold(0.0, (s, p) => s + p[1]);
    final sumXY = data.fold(0.0, (s, p) => s + p[0] * p[1]);
    final sumX2 = data.fold(0.0, (s, p) => s + p[0] * p[0]);
    final m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final b = (sumY - m * sumX) / n;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Línea de Regresión – Ataque vs Defensa'),
      Text('y = ${m.toStringAsFixed(2)}x + ${b.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
      const SizedBox(height: 8),
      SizedBox(height: 250, child: ScatterChart(ScatterChartData(
        scatterSpots: data.map((p) => ScatterSpot(p[0].toDouble(), p[1].toDouble(),
          dotPainter: FlDotCirclePainter(radius: 4, color: const Color(0xFF2196F3).withOpacity(0.6)))).toList(),
        minX: 0, maxX: 180, minY: 0, maxY: 180,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ))),
      Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
        child: Text('Línea roja = tendencia\ny = ${m.toStringAsFixed(2)}x + ${b.toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 11)),
      ),
    ]);
  }
}

// ─── FlA22: Radar Animado ────────────────────────────────────────────────────
class FlA22 extends StatefulWidget {
  const FlA22({super.key});
  @override
  State<FlA22> createState() => _FlA22State();
}

class _FlA22State extends State<FlA22> with SingleTickerProviderStateMixin {
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
    final s = PokemonChartData.statsOf('Mewtwo');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Radar Animado – Mewtwo'),
      AnimatedBuilder(animation: _anim, builder: (_, __) => SizedBox(height: 280, child: RadarChart(RadarChartData(
        dataSets: [RadarDataSet(
          dataEntries: s.map((v) => RadarEntry(value: v.toDouble() * _anim.value)).toList(),
          fillColor: const Color(0xFFF85888).withOpacity(0.3),
          borderColor: const Color(0xFFF85888),
          borderWidth: 2,
        )],
        getTitle: (i, angle) => RadarChartTitle(text: PokemonChartData.statNames[i], angle: angle),
        tickCount: 3, radarShape: RadarShape.polygon,
        radarBorderData: const BorderSide(color: Colors.grey),
        tickBorderData: const BorderSide(color: Colors.grey),
        gridBorderData: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
        radarBackgroundColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      )))),
      ElevatedButton(onPressed: () => _ctrl..reset()..forward(), child: const Text('Reiniciar')),
    ]);
  }
}

// ─── FlA23: Radar Triple ─────────────────────────────────────────────────────
class FlA23 extends StatelessWidget {
  const FlA23({super.key});
  @override
  Widget build(BuildContext context) {
    final pika = PokemonChartData.statsOf('Pikachu');
    final charz = PokemonChartData.statsOf('Charizard');
    final blast = PokemonChartData.statsOf('Blastoise');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Radar Triple – Pikachu / Charizard / Blastoise'),
      Row(children: [
        _dot(const Color(0xFFF8D030), 'Pikachu'),
        const SizedBox(width: 8),
        _dot(const Color(0xFFF08030), 'Charizard'),
        const SizedBox(width: 8),
        _dot(const Color(0xFF6890F0), 'Blastoise'),
      ]),
      SizedBox(height: 280, child: RadarChart(RadarChartData(
        dataSets: [
          RadarDataSet(dataEntries: pika.map((v) => RadarEntry(value: v.toDouble())).toList(),
            fillColor: const Color(0xFFF8D030).withOpacity(0.2), borderColor: const Color(0xFFF8D030), borderWidth: 2),
          RadarDataSet(dataEntries: charz.map((v) => RadarEntry(value: v.toDouble())).toList(),
            fillColor: const Color(0xFFF08030).withOpacity(0.2), borderColor: const Color(0xFFF08030), borderWidth: 2),
          RadarDataSet(dataEntries: blast.map((v) => RadarEntry(value: v.toDouble())).toList(),
            fillColor: const Color(0xFF6890F0).withOpacity(0.2), borderColor: const Color(0xFF6890F0), borderWidth: 2),
        ],
        getTitle: (i, angle) => RadarChartTitle(text: PokemonChartData.statNames[i], angle: angle),
        tickCount: 3, radarShape: RadarShape.polygon,
        radarBorderData: const BorderSide(color: Colors.grey),
        tickBorderData: const BorderSide(color: Colors.grey),
        gridBorderData: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
        radarBackgroundColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ))),
    ]);
  }
}

Widget _dot(Color color, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
  Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
  const SizedBox(width: 4),
  Text(label, style: const TextStyle(fontSize: 11)),
]);

// ─── FlA24: Radar por Tipo ────────────────────────────────────────────────────
class FlA24 extends StatelessWidget {
  const FlA24({super.key});
  @override
  Widget build(BuildContext context) {
    final fire = PokemonChartData.avgStatsOf(PokemonChartData.fireTypes);
    final water = PokemonChartData.avgStatsOf(PokemonChartData.waterTypes);
    final grass = PokemonChartData.avgStatsOf(PokemonChartData.grassTypes);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Radar por Tipo – Fuego / Agua / Planta'),
      Row(children: [
        _dot(const Color(0xFFF08030), 'Fuego'),
        const SizedBox(width: 8),
        _dot(const Color(0xFF6890F0), 'Agua'),
        const SizedBox(width: 8),
        _dot(const Color(0xFF78C850), 'Planta'),
      ]),
      SizedBox(height: 280, child: RadarChart(RadarChartData(
        dataSets: [
          RadarDataSet(dataEntries: fire.map((v) => RadarEntry(value: v)).toList(),
            fillColor: const Color(0xFFF08030).withOpacity(0.2), borderColor: const Color(0xFFF08030), borderWidth: 2),
          RadarDataSet(dataEntries: water.map((v) => RadarEntry(value: v)).toList(),
            fillColor: const Color(0xFF6890F0).withOpacity(0.2), borderColor: const Color(0xFF6890F0), borderWidth: 2),
          RadarDataSet(dataEntries: grass.map((v) => RadarEntry(value: v)).toList(),
            fillColor: const Color(0xFF78C850).withOpacity(0.2), borderColor: const Color(0xFF78C850), borderWidth: 2),
        ],
        getTitle: (i, angle) => RadarChartTitle(text: PokemonChartData.statNames[i], angle: angle),
        tickCount: 3, radarShape: RadarShape.polygon,
        radarBorderData: const BorderSide(color: Colors.grey),
        tickBorderData: const BorderSide(color: Colors.grey),
        gridBorderData: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
        radarBackgroundColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ))),
    ]);
  }
}

// ─── FlA25: Radar Interactivo ────────────────────────────────────────────────
class FlA25 extends StatefulWidget {
  const FlA25({super.key});
  @override
  State<FlA25> createState() => _FlA25State();
}

class _FlA25State extends State<FlA25> {
  String _selected = 'Mewtwo';
  static const _options = ['Pikachu', 'Charizard', 'Blastoise', 'Mewtwo', 'Snorlax', 'Gengar'];
  static const _colors = {
    'Pikachu': Color(0xFFF8D030), 'Charizard': Color(0xFFF08030), 'Blastoise': Color(0xFF6890F0),
    'Mewtwo': Color(0xFFF85888), 'Snorlax': Color(0xFFA8A878), 'Gengar': Color(0xFF705898),
  };

  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf(_selected);
    final color = _colors[_selected]!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Radar Interactivo – Selecciona un Pokémon'),
      Wrap(spacing: 6, children: _options.map((p) => ChoiceChip(
        label: Text(p, style: const TextStyle(fontSize: 11)),
        selected: _selected == p,
        onSelected: (_) => setState(() => _selected = p),
        selectedColor: _colors[p]!.withOpacity(0.3),
      )).toList()),
      const SizedBox(height: 8),
      SizedBox(height: 260, child: RadarChart(RadarChartData(
        dataSets: [RadarDataSet(
          dataEntries: s.map((v) => RadarEntry(value: v.toDouble())).toList(),
          fillColor: color.withOpacity(0.3),
          borderColor: color,
          borderWidth: 2,
        )],
        getTitle: (i, angle) => RadarChartTitle(text: PokemonChartData.statNames[i], angle: angle),
        tickCount: 3, radarShape: RadarShape.polygon,
        radarBorderData: const BorderSide(color: Colors.grey),
        tickBorderData: const BorderSide(color: Colors.grey),
        gridBorderData: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
        radarBackgroundColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ))),
    ]);
  }
}

// ─── FlA26: Burbujas Escalonadas ─────────────────────────────────────────────
class FlA26 extends StatefulWidget {
  const FlA26({super.key});
  @override
  State<FlA26> createState() => _FlA26State();
}

class _FlA26State extends State<FlA26> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.bubbleHpAtk;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Burbujas Escalonadas – Entrada animada'),
      AnimatedBuilder(animation: _anim, builder: (_, __) {
        final showing = (data.length * _anim.value).ceil();
        return SizedBox(height: 260, child: ScatterChart(ScatterChartData(
          scatterSpots: data.take(showing).map((p) => ScatterSpot(p[0].toDouble(), p[1].toDouble(),
            dotPainter: FlDotCirclePainter(
              radius: (p[2] / 5.0).clamp(6.0, 25.0),
              color: const Color(0xFF1565C0).withOpacity(0.55),
              strokeColor: const Color(0xFF1565C0), strokeWidth: 1,
            ))).toList(),
          minX: 0, maxX: 180, minY: 0, maxY: 180,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        )));
      }),
      ElevatedButton(onPressed: () => _ctrl..reset()..forward(), child: const Text('Reiniciar')),
    ]);
  }
}

// ─── FlA27: Burbujas Interactivas ────────────────────────────────────────────
class FlA27 extends StatefulWidget {
  const FlA27({super.key});
  @override
  State<FlA27> createState() => _FlA27State();
}

class _FlA27State extends State<FlA27> {
  String? _info;
  static const _names = ['Bulbasaur','Ivysaur','Venusaur','Charmander','Charmeleon','Charizard',
    'Squirtle','Wartortle','Blastoise','Caterpie','Butterfree','Pikachu','Raichu','Jigglypuff',
    'Meowth','Persian','Gengar','Gyarados','Lapras','Eevee'];

  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.bubbleHpAtk;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Burbujas Interactivas – Toca una burbuja'),
      if (_info != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
          child: Text(_info!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      const SizedBox(height: 8),
      SizedBox(height: 240, child: ScatterChart(ScatterChartData(
        scatterSpots: List.generate(min(data.length, _names.length), (i) => ScatterSpot(
          data[i][0].toDouble(), data[i][1].toDouble(),
          dotPainter: FlDotCirclePainter(
            radius: (data[i][2] / 5.0).clamp(6.0, 25.0),
            color: const Color(0xFFFF9800).withOpacity(0.6),
            strokeColor: const Color(0xFFFF9800), strokeWidth: 1,
          ))),
        minX: 0, maxX: 180, minY: 0, maxY: 180,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        scatterTouchData: ScatterTouchData(
          enabled: true,
          touchCallback: (event, response) {
            if (response?.touchedSpot != null) {
              final idx = response!.touchedSpot!.spotIndex;
              if (idx < _names.length) {
                final d = data[idx];
                setState(() => _info = '${_names[idx]} | HP:${d[0]} Atk:${d[1]} Def:${d[2]}');
              }
            }
          },
        ),
      ))),
    ]);
  }
}

// ─── FlA28: Burbujas por Tipo ────────────────────────────────────────────────
class FlA28 extends StatelessWidget {
  const FlA28({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.bubbleSpdAtk;
    final typeColors = [
      const Color(0xFFF08030), const Color(0xFF6890F0), const Color(0xFF78C850),
      const Color(0xFFF8D030), const Color(0xFFA040A0),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Burbujas por Tipo – Velocidad vs Ataque'),
      Row(children: ['Fuego','Agua','Planta','Eléctrico','Veneno'].asMap().entries.map((e) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, margin: const EdgeInsets.only(right: 3, left: 6),
            decoration: BoxDecoration(color: typeColors[e.key], shape: BoxShape.circle)),
          Text(e.value, style: const TextStyle(fontSize: 10)),
        ],
      )).toList()),
      const SizedBox(height: 8),
      SizedBox(height: 240, child: ScatterChart(ScatterChartData(
        scatterSpots: data.asMap().entries.map((e) {
          final colorIdx = e.key % typeColors.length;
          return ScatterSpot(e.value[0].toDouble(), e.value[1].toDouble(),
            dotPainter: FlDotCirclePainter(
              radius: (e.value[2] / 8.0).clamp(6.0, 22.0),
              color: typeColors[colorIdx].withOpacity(0.6),
              strokeColor: typeColors[colorIdx], strokeWidth: 1,
            ));
        }).toList(),
        minX: 0, maxX: 180, minY: 0, maxY: 180,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ))),
    ]);
  }
}

// ─── FlA29: Heatmap Interactivo ──────────────────────────────────────────────
class FlA29 extends StatefulWidget {
  const FlA29({super.key});
  @override
  State<FlA29> createState() => _FlA29State();
}

class _FlA29State extends State<FlA29> {
  String? _info;

  @override
  Widget build(BuildContext context) {
    final matrix = PokemonChartData.correlationMatrix;
    final labels = PokemonChartData.statNames;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Heatmap Interactivo – Toca una celda'),
      if (_info != null)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
          child: Text(_info!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      Row(children: [
        const SizedBox(width: 36),
        ...labels.map((l) => SizedBox(width: 40, child: Text(l, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
      ]),
      const SizedBox(height: 4),
      ...List.generate(6, (row) => Row(children: [
        SizedBox(width: 36, child: Text(labels[row], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
        ...List.generate(6, (col) {
          final v = matrix[row][col];
          return GestureDetector(
            onTap: () => setState(() => _info = '${labels[row]} ↔ ${labels[col]}: ${v.toStringAsFixed(2)}'  ),
            child: Container(
              width: 40, height: 36, margin: const EdgeInsets.all(1),
              color: Color.lerp(Colors.blue.shade100, Colors.blue.shade900, v),
              child: Center(child: Text(v.toStringAsFixed(2), style: const TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.bold))),
            ),
          );
        }),
      ])),
    ]);
  }
}

// ─── FlA30: Heatmap Gradiente ────────────────────────────────────────────────
class FlA30 extends StatelessWidget {
  const FlA30({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.heatmapAvg;
    final types = PokemonChartData.heatmapTypes;
    final maxVal = data.expand((r) => r).reduce((a, b) => a > b ? a : b);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Heatmap Gradiente – Paleta personalizada'),
      Row(children: [
        const SizedBox(width: 56),
        ...PokemonChartData.statNames.map((l) => SizedBox(width: 38, child: Text(l, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
      ]),
      const SizedBox(height: 4),
      ...List.generate(types.length, (row) => Row(children: [
        SizedBox(width: 56, child: Text(types[row], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
        ...List.generate(6, (col) {
          final v = data[row][col] / maxVal;
          final color = v < 0.5
              ? Color.lerp(const Color(0xFF1976D2), const Color(0xFF66BB6A), v * 2)!
              : Color.lerp(const Color(0xFF66BB6A), const Color(0xFFE53935), (v - 0.5) * 2)!;
          return Container(
            width: 38, height: 34, margin: const EdgeInsets.all(1),
            color: color,
            child: Center(child: Text(data[row][col].toStringAsFixed(0), style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold))),
          );
        }),
      ])),
    ]);
  }
}

// ─── FlA31: Área Apilada Animada ─────────────────────────────────────────────
class FlA31 extends StatefulWidget {
  const FlA31({super.key});
  @override
  State<FlA31> createState() => _FlA31State();
}

class _FlA31State extends State<FlA31> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    const bulba  = [45.0, 60.0, 80.0];
    const char   = [39.0, 58.0, 78.0];
    const squi   = [44.0, 59.0, 79.0];
    const labels = ['Base', 'Medio', 'Final'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Área Apilada Animada – HP Starters'),
      AnimatedBuilder(animation: _anim, builder: (_, __) => SizedBox(height: 260, child: LineChart(LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(3, (i) => FlSpot(i.toDouble(), bulba[i] * _anim.value)),
            color: const Color(0xFF78C850), isCurved: true, barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: const Color(0xFF78C850).withOpacity(0.2))),
          LineChartBarData(
            spots: List.generate(3, (i) => FlSpot(i.toDouble(), char[i] * _anim.value)),
            color: const Color(0xFFF08030), isCurved: true, barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: const Color(0xFFF08030).withOpacity(0.2))),
          LineChartBarData(
            spots: List.generate(3, (i) => FlSpot(i.toDouble(), squi[i] * _anim.value)),
            color: const Color(0xFF6890F0), isCurved: true, barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: const Color(0xFF6890F0).withOpacity(0.2))),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= 3) return const SizedBox.shrink();
              return Padding(padding: const EdgeInsets.only(top: 4), child: Text(labels[i], style: const TextStyle(fontSize: 9)));
            })),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 9)))),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(drawVerticalLine: false),
        minY: 0, maxY: 100,
      )))),
      ElevatedButton(onPressed: () => _ctrl..reset()..forward(), child: const Text('Reiniciar')),
    ]);
  }
}

// ─── FlA32: Área con Threshold ───────────────────────────────────────────────
class FlA32 extends StatelessWidget {
  const FlA32({super.key});
  @override
  Widget build(BuildContext context) {
    final hp = PokemonChartData.first20HP;
    final avg = hp.fold(0, (a, b) => a + b) / hp.length.toDouble();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Área con Threshold – Línea de promedio (${avg.toStringAsFixed(0)})'),
      SizedBox(height: 260, child: LineChart(LineChartData(
        lineBarsData: [LineChartBarData(
          spots: List.generate(hp.length, (i) => FlSpot(i.toDouble(), hp[i].toDouble())),
          color: const Color(0xFF4CAF50), isCurved: true, barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: const Color(0xFF4CAF50).withOpacity(0.15)),
        )],
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(y: avg, color: Colors.redAccent, strokeWidth: 2, dashArray: [6, 3],
            label: HorizontalLineLabel(show: true,
              labelResolver: (_) => 'avg ${avg.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold))),
        ]),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
            getTitlesWidget: (v, _) => v.toInt() % 4 == 0
                ? Text('#${v.toInt() + 1}', style: const TextStyle(fontSize: 9))
                : const SizedBox.shrink())),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 9)))),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(drawVerticalLine: false),
        minY: 0, maxY: 160,
      ))),
    ]);
  }
}

// ─── FlA33: Dashboard Completo ───────────────────────────────────────────────
class FlA33 extends StatefulWidget {
  const FlA33({super.key});
  @override
  State<FlA33> createState() => _FlA33State();
}

class _FlA33State extends State<FlA33> {
  String _pokemon = 'Mewtwo';
  static const _options = ['Pikachu', 'Charizard', 'Blastoise', 'Mewtwo', 'Snorlax'];

  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf(_pokemon);
    final total = PokemonChartData.totalOf(_pokemon);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Dashboard Completo'),
      DropdownButton<String>(
        value: _pokemon,
        items: _options.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
        onChanged: (v) { if (v != null) setState(() => _pokemon = v); },
      ),
      Row(children: List.generate(6, (i) => Expanded(child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(color: PokemonChartData.statColors[i].withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
        child: Column(children: [
          Text('${stats[i]}', style: TextStyle(fontWeight: FontWeight.bold, color: PokemonChartData.statColors[i], fontSize: 14)),
          Text(PokemonChartData.statNames[i], style: const TextStyle(fontSize: 8)),
        ]),
      )))),
      const SizedBox(height: 8),
      SizedBox(height: 180, child: RadarChart(RadarChartData(
        dataSets: [RadarDataSet(
          dataEntries: stats.map((v) => RadarEntry(value: v.toDouble())).toList(),
          fillColor: const Color(0xFFF85888).withOpacity(0.25),
          borderColor: const Color(0xFFF85888), borderWidth: 2,
        )],
        getTitle: (i, angle) => RadarChartTitle(text: PokemonChartData.statNames[i], angle: angle),
        tickCount: 3, radarShape: RadarShape.polygon,
        radarBorderData: const BorderSide(color: Colors.grey),
        tickBorderData: const BorderSide(color: Colors.grey),
        gridBorderData: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
        radarBackgroundColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ))),
      Text('Total Base Stats: $total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    ]);
  }
}

// ─── FlA34: Comparador Lado a Lado ───────────────────────────────────────────
class FlA34 extends StatefulWidget {
  const FlA34({super.key});
  @override
  State<FlA34> createState() => _FlA34State();
}

class _FlA34State extends State<FlA34> {
  String _p1 = 'Charizard';
  String _p2 = 'Blastoise';
  static const _opts = ['Pikachu', 'Charizard', 'Blastoise', 'Mewtwo', 'Snorlax', 'Gengar', 'Lapras'];

  @override
  Widget build(BuildContext context) {
    final s1 = PokemonChartData.statsOf(_p1);
    final s2 = PokemonChartData.statsOf(_p2);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Comparador Lado a Lado'),
      Row(children: [
        Expanded(child: DropdownButton<String>(
          isExpanded: true, value: _p1,
          items: _opts.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (v) { if (v != null) setState(() => _p1 = v); },
        )),
        const SizedBox(width: 8),
        Expanded(child: DropdownButton<String>(
          isExpanded: true, value: _p2,
          items: _opts.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (v) { if (v != null) setState(() => _p2 = v); },
        )),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: SizedBox(height: 220, child: RadarChart(RadarChartData(
          dataSets: [RadarDataSet(
            dataEntries: s1.map((v) => RadarEntry(value: v.toDouble())).toList(),
            fillColor: const Color(0xFFF08030).withOpacity(0.3), borderColor: const Color(0xFFF08030), borderWidth: 2,
          )],
          getTitle: (i, angle) => RadarChartTitle(text: PokemonChartData.statNames[i], angle: angle),
          tickCount: 3, radarShape: RadarShape.polygon,
          radarBorderData: const BorderSide(color: Colors.grey),
          tickBorderData: const BorderSide(color: Colors.grey),
          gridBorderData: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
          radarBackgroundColor: Colors.transparent,
          titleTextStyle: const TextStyle(fontSize: 9),
        )))),
        const SizedBox(width: 8),
        Expanded(child: SizedBox(height: 220, child: RadarChart(RadarChartData(
          dataSets: [RadarDataSet(
            dataEntries: s2.map((v) => RadarEntry(value: v.toDouble())).toList(),
            fillColor: const Color(0xFF6890F0).withOpacity(0.3), borderColor: const Color(0xFF6890F0), borderWidth: 2,
          )],
          getTitle: (i, angle) => RadarChartTitle(text: PokemonChartData.statNames[i], angle: angle),
          tickCount: 3, radarShape: RadarShape.polygon,
          radarBorderData: const BorderSide(color: Colors.grey),
          tickBorderData: const BorderSide(color: Colors.grey),
          gridBorderData: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
          radarBackgroundColor: Colors.transparent,
          titleTextStyle: const TextStyle(fontSize: 9),
        )))),
      ]),
    ]);
  }
}

// ─── FlA35: Timeline Evolutivo ───────────────────────────────────────────────
class FlA35 extends StatelessWidget {
  const FlA35({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Timeline Evolutivo – Niveles de evolución'),
      SizedBox(
        height: 220,
        child: CustomPaint(
          size: const Size(double.infinity, 220),
          painter: _TimelinePainter(),
        ),
      ),
    ]);
  }
}

class _TimelinePainter extends CustomPainter {
  static const _evolutions = [
    ('Bulbasaur', 1, Color(0xFF78C850)),
    ('Ivysaur', 16, Color(0xFF4CAF50)),
    ('Venusaur', 32, Color(0xFF2E7D32)),
    ('Charmander', 1, Color(0xFFF08030)),
    ('Charmeleon', 16, Color(0xFFE64A19)),
    ('Charizard', 36, Color(0xFFBF360C)),
    ('Squirtle', 1, Color(0xFF6890F0)),
    ('Wartortle', 16, Color(0xFF1976D2)),
    ('Blastoise', 36, Color(0xFF0D47A1)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final maxLevel = 40.0;
    final rowCount = 3;
    final rowHeight = size.height / rowCount;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int row = 0; row < rowCount; row++) {
      final evos = _evolutions.skip(row * 3).take(3).toList();
      final y = rowHeight * row + rowHeight / 2;
      final linePaint = Paint()..color = evos[0].$3..strokeWidth = 3..style = PaintingStyle.stroke;
      final dotPaint = Paint()..style = PaintingStyle.fill;

      // draw connecting line
      final x0 = (evos[0].$2 / maxLevel) * size.width + 20;
      final x2 = (evos[2].$2 / maxLevel) * size.width + 20;
      canvas.drawLine(Offset(x0, y), Offset(x2, y), linePaint);

      for (final evo in evos) {
        final x = (evo.$2 / maxLevel) * size.width + 20;
        dotPaint.color = evo.$3;
        canvas.drawCircle(Offset(x, y), 8, dotPaint);
        textPainter
          ..text = TextSpan(
            text: '${evo.$1}\nLv${evo.$2}',
            style: TextStyle(color: evo.$3, fontSize: 8, fontWeight: FontWeight.bold),
          )
          ..layout(maxWidth: 60)
          ..paint(canvas, Offset((x - 30).clamp(0, size.width - 60), y + 10));
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── FlA36: Waterfall Stats ──────────────────────────────────────────────────
class FlA36 extends StatelessWidget {
  const FlA36({super.key});
  @override
  Widget build(BuildContext context) {
    final bulb = PokemonChartData.statsOf('Bulbasaur');
    final mew = PokemonChartData.statsOf('Mewtwo');
    final diffs = List.generate(6, (i) => mew[i] - bulb[i]);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Waterfall Stats – Diferencia Mewtwo vs Bulbasaur'),
      Text('Verde = Mewtwo es mayor  |  Rojo = Bulbasaur es mayor', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      const SizedBox(height: 8),
      SizedBox(height: 250, child: BarChart(BarChartData(
        barGroups: List.generate(6, (i) => BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: diffs[i].toDouble(),
                color: diffs[i] >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                width: 28, borderRadius: BorderRadius.circular(4),
              )
            ])),
        titlesData: _bottomTitles(PokemonChartData.statNames),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(drawVerticalLine: false),
        minY: -20, maxY: 110,
        baselineY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
              '${PokemonChartData.statNames[gi]}: ${rod.toY > 0 ? "+" : ""}${rod.toY.toInt()}',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ))),
    ]);
  }
}
