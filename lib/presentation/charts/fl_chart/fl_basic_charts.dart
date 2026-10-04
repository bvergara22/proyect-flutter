import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/data/pokemon_chart_data.dart';

Widget _chartTitle(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(t,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.black87)),
    );

FlTitlesData _bottomTitles(List<String> labels) => FlTitlesData(
      bottomTitles: AxisTitles(
          sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 24,
        getTitlesWidget: (v, _) {
          final i = v.toInt();
          if (i < 0 || i >= labels.length) return const SizedBox.shrink();
          return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(labels[i],
                  style: const TextStyle(fontSize: 9)));
        },
      )),
      leftTitles: AxisTitles(
          sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 28,
        getTitlesWidget: (v, _) =>
            Text(v.toInt().toString(), style: const TextStyle(fontSize: 9)),
      )),
      rightTitles:
          AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles:
          AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );

// ─── FlB01: Stats de Bulbasaur ───────────────────────────────────────────────
class FlB01 extends StatelessWidget {
  const FlB01({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Bulbasaur');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats de Bulbasaur'),
      SizedBox(
        height: 250,
        child: BarChart(BarChartData(
          barGroups: List.generate(
              6,
              (i) => BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                        toY: stats[i].toDouble(),
                        color: PokemonChartData.statColors[i],
                        width: 28,
                        borderRadius: BorderRadius.circular(4))
                  ])),
          titlesData: _bottomTitles(PokemonChartData.statNames),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          maxY: 180,
        )),
      ),
    ]);
  }
}

// ─── FlB02: Stats de Mewtwo ──────────────────────────────────────────────────
class FlB02 extends StatelessWidget {
  const FlB02({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Mewtwo');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats de Mewtwo'),
      SizedBox(
        height: 250,
        child: BarChart(BarChartData(
          barGroups: List.generate(
              6,
              (i) => BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                        toY: stats[i].toDouble(),
                        color: PokemonChartData.statColors[i],
                        width: 28,
                        borderRadius: BorderRadius.circular(4))
                  ])),
          titlesData: _bottomTitles(PokemonChartData.statNames),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          maxY: 200,
        )),
      ),
    ]);
  }
}

// ─── FlB03: Bulbasaur vs Charmander ─────────────────────────────────────────
class FlB03 extends StatelessWidget {
  const FlB03({super.key});
  @override
  Widget build(BuildContext context) {
    final b = PokemonChartData.statsOf('Bulbasaur');
    final c = PokemonChartData.statsOf('Charmander');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Bulbasaur vs Charmander'),
      Row(children: [
        _legendDot(const Color(0xFF78C850), 'Bulbasaur'),
        const SizedBox(width: 12),
        _legendDot(const Color(0xFFF08030), 'Charmander'),
      ]),
      const SizedBox(height: 8),
      SizedBox(
        height: 230,
        child: BarChart(BarChartData(
          barGroups: List.generate(
              6,
              (i) => BarChartGroupData(x: i, groupVertically: false, barRods: [
                    BarChartRodData(
                        toY: b[i].toDouble(),
                        color: const Color(0xFF78C850),
                        width: 14,
                        borderRadius: BorderRadius.circular(3)),
                    BarChartRodData(
                        toY: c[i].toDouble(),
                        color: const Color(0xFFF08030),
                        width: 14,
                        borderRadius: BorderRadius.circular(3)),
                  ])),
          titlesData: _bottomTitles(PokemonChartData.statNames),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          maxY: 180,
        )),
      ),
    ]);
  }
}

Widget _legendDot(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );

// ─── FlB04: Top 5 por Ataque ─────────────────────────────────────────────────
class FlB04 extends StatelessWidget {
  const FlB04({super.key});
  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(1, n: 5);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 5 por Ataque'),
      SizedBox(
        height: 250,
        child: BarChart(BarChartData(
          barGroups: List.generate(
              top.length,
              (i) => BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                        toY: top[i].value.toDouble(),
                        color: const Color(0xFFF44336),
                        width: 28,
                        borderRadius: BorderRadius.circular(4))
                  ])),
          titlesData: _bottomTitles(top.map((e) => e.key.length > 7 ? e.key.substring(0, 7) : e.key).toList()),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          maxY: 180,
        )),
      ),
    ]);
  }
}

// ─── FlB05: Top 5 por Defensa ────────────────────────────────────────────────
class FlB05 extends StatelessWidget {
  const FlB05({super.key});
  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(2, n: 5);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 5 por Defensa'),
      SizedBox(
        height: 250,
        child: BarChart(BarChartData(
          barGroups: List.generate(
              top.length,
              (i) => BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                        toY: top[i].value.toDouble(),
                        color: const Color(0xFF2196F3),
                        width: 28,
                        borderRadius: BorderRadius.circular(4))
                  ])),
          titlesData: _bottomTitles(top.map((e) => e.key.length > 7 ? e.key.substring(0, 7) : e.key).toList()),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          maxY: 160,
        )),
      ),
    ]);
  }
}

// ─── FlB06: Top 5 por HP ─────────────────────────────────────────────────────
class FlB06 extends StatelessWidget {
  const FlB06({super.key});
  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(0, n: 5);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 5 por HP'),
      SizedBox(
        height: 250,
        child: BarChart(BarChartData(
          barGroups: List.generate(
              top.length,
              (i) => BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                        toY: top[i].value.toDouble(),
                        color: const Color(0xFF4CAF50),
                        width: 28,
                        borderRadius: BorderRadius.circular(4))
                  ])),
          titlesData: _bottomTitles(top.map((e) => e.key.length > 7 ? e.key.substring(0, 7) : e.key).toList()),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          maxY: 200,
        )),
      ),
    ]);
  }
}

// ─── FlB07: Top 5 por Velocidad ──────────────────────────────────────────────
class FlB07 extends StatelessWidget {
  const FlB07({super.key});
  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(5, n: 5);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 5 por Velocidad'),
      SizedBox(
        height: 250,
        child: BarChart(BarChartData(
          barGroups: List.generate(
              top.length,
              (i) => BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                        toY: top[i].value.toDouble(),
                        color: const Color(0xFFFF9800),
                        width: 28,
                        borderRadius: BorderRadius.circular(4))
                  ])),
          titlesData: _bottomTitles(top.map((e) => e.key.length > 7 ? e.key.substring(0, 7) : e.key).toList()),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          maxY: 160,
        )),
      ),
    ]);
  }
}

// ─── FlB08: Fuego vs Agua vs Planta ─────────────────────────────────────────
class FlB08 extends StatelessWidget {
  const FlB08({super.key});
  @override
  Widget build(BuildContext context) {
    final fire = PokemonChartData.avgStatsOf(PokemonChartData.fireTypes);
    final water = PokemonChartData.avgStatsOf(PokemonChartData.waterTypes);
    final grass = PokemonChartData.avgStatsOf(PokemonChartData.grassTypes);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Fuego vs Agua vs Planta'),
      Row(children: [
        _legendDot(const Color(0xFFF08030), 'Fuego'),
        const SizedBox(width: 8),
        _legendDot(const Color(0xFF6890F0), 'Agua'),
        const SizedBox(width: 8),
        _legendDot(const Color(0xFF78C850), 'Planta'),
      ]),
      const SizedBox(height: 8),
      SizedBox(
        height: 230,
        child: BarChart(BarChartData(
          barGroups: List.generate(
              6,
              (i) => BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: fire[i], color: const Color(0xFFF08030), width: 10, borderRadius: BorderRadius.circular(3)),
                    BarChartRodData(toY: water[i], color: const Color(0xFF6890F0), width: 10, borderRadius: BorderRadius.circular(3)),
                    BarChartRodData(toY: grass[i], color: const Color(0xFF78C850), width: 10, borderRadius: BorderRadius.circular(3)),
                  ])),
          titlesData: _bottomTitles(PokemonChartData.statNames),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          maxY: 160,
        )),
      ),
    ]);
  }
}

// ─── FlB09: Evolución HP Bulbasaur ───────────────────────────────────────────
class FlB09 extends StatelessWidget {
  const FlB09({super.key});
  @override
  Widget build(BuildContext context) {
    const evos = ['Bulbasaur', 'Ivysaur', 'Venusaur'];
    final hp = evos.map((n) => PokemonChartData.statsOf(n)[0].toDouble()).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Evolución HP Bulbasaur'),
      SizedBox(
        height: 250,
        child: LineChart(LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(3, (i) => FlSpot(i.toDouble(), hp[i])),
              color: const Color(0xFF78C850),
              isCurved: true,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF78C850).withOpacity(0.15)),
            )
          ],
          titlesData: _bottomTitles(evos),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          minY: 0,
          maxY: 120,
        )),
      ),
    ]);
  }
}

// ─── FlB10: Evolución Ataque Charmander ──────────────────────────────────────
class FlB10 extends StatelessWidget {
  const FlB10({super.key});
  @override
  Widget build(BuildContext context) {
    const evos = ['Charmander', 'Charmeleon', 'Charizard'];
    final atk = evos.map((n) => PokemonChartData.statsOf(n)[1].toDouble()).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Evolución Ataque Charmander'),
      SizedBox(
        height: 250,
        child: LineChart(LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(3, (i) => FlSpot(i.toDouble(), atk[i])),
              color: const Color(0xFFF08030),
              isCurved: true,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: const Color(0xFFF08030).withOpacity(0.15)),
            )
          ],
          titlesData: _bottomTitles(evos),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          minY: 0,
          maxY: 130,
        )),
      ),
    ]);
  }
}

// ─── FlB11: Evolución Defensa Squirtle ──────────────────────────────────────
class FlB11 extends StatelessWidget {
  const FlB11({super.key});
  @override
  Widget build(BuildContext context) {
    const evos = ['Squirtle', 'Wartortle', 'Blastoise'];
    final def = evos.map((n) => PokemonChartData.statsOf(n)[2].toDouble()).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Evolución Defensa Squirtle'),
      SizedBox(
        height: 250,
        child: LineChart(LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(3, (i) => FlSpot(i.toDouble(), def[i])),
              color: const Color(0xFF6890F0),
              isCurved: true,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF6890F0).withOpacity(0.15)),
            )
          ],
          titlesData: _bottomTitles(evos),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          minY: 0,
          maxY: 130,
        )),
      ),
    ]);
  }
}

// ─── FlB12: HP Primeros 20 Pokémon ──────────────────────────────────────────
class FlB12 extends StatelessWidget {
  const FlB12({super.key});
  @override
  Widget build(BuildContext context) {
    final hp = PokemonChartData.first20HP;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP Primeros 20 Pokémon'),
      SizedBox(
        height: 250,
        child: LineChart(LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(hp.length, (i) => FlSpot(i.toDouble(), hp[i].toDouble())),
              color: const Color(0xFF4CAF50),
              isCurved: false,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF4CAF50).withOpacity(0.1)),
            )
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, reservedSize: 22,
              getTitlesWidget: (v, _) => v.toInt() % 4 == 0
                  ? Text('#${v.toInt() + 1}', style: const TextStyle(fontSize: 9))
                  : const SizedBox.shrink(),
            )),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 9)))),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          minY: 0,
          maxY: 160,
        )),
      ),
    ]);
  }
}

// ─── FlB13: Velocidad Primeros 20 ────────────────────────────────────────────
class FlB13 extends StatelessWidget {
  const FlB13({super.key});
  @override
  Widget build(BuildContext context) {
    final spd = PokemonChartData.first20Spd;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Velocidad Primeros 20'),
      SizedBox(
        height: 250,
        child: LineChart(LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(spd.length, (i) => FlSpot(i.toDouble(), spd[i].toDouble())),
              color: const Color(0xFFFF9800),
              isCurved: false,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: const Color(0xFFFF9800).withOpacity(0.1)),
            )
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, reservedSize: 22,
              getTitlesWidget: (v, _) => v.toInt() % 4 == 0
                  ? Text('#${v.toInt() + 1}', style: const TextStyle(fontSize: 9))
                  : const SizedBox.shrink(),
            )),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 9)))),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          minY: 0,
          maxY: 140,
        )),
      ),
    ]);
  }
}

// ─── FlB14: Distribución Tipos Gen I ────────────────────────────────────────
class FlB14 extends StatelessWidget {
  const FlB14({super.key});
  @override
  Widget build(BuildContext context) {
    final types = PokemonChartData.topTypes;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Distribución Tipos Gen I'),
      SizedBox(
        height: 250,
        child: PieChart(PieChartData(
          sections: types.entries.map((e) {
            final color = PokemonChartData.typeColors[e.key] ?? Colors.grey;
            return PieChartSectionData(
              value: e.value.toDouble(),
              title: e.key,
              color: color,
              radius: 80,
              titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 0,
        )),
      ),
    ]);
  }
}

// ─── FlB15: Top 5 Tipos más Comunes ─────────────────────────────────────────
class FlB15 extends StatelessWidget {
  const FlB15({super.key});
  @override
  Widget build(BuildContext context) {
    final top5 = [
      MapEntry('Agua', 28),
      MapEntry('Normal', 22),
      MapEntry('Veneno', 14),
      MapEntry('Psíquico', 14),
      MapEntry('Fuego', 12),
    ];
    final colors = [const Color(0xFF6890F0), Colors.grey, const Color(0xFFA040A0), const Color(0xFFF85888), const Color(0xFFF08030)];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 5 Tipos más Comunes'),
      SizedBox(
        height: 250,
        child: PieChart(PieChartData(
          sections: List.generate(5, (i) => PieChartSectionData(
            value: top5[i].value.toDouble(),
            title: '${top5[i].key}\n${top5[i].value}',
            color: colors[i],
            radius: 90,
            titleStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
          )),
          sectionsSpace: 3,
          centerSpaceRadius: 0,
        )),
      ),
    ]);
  }
}

// ─── FlB16: Tipos Gen I (Donut) ──────────────────────────────────────────────
class FlB16 extends StatelessWidget {
  const FlB16({super.key});
  @override
  Widget build(BuildContext context) {
    final types = PokemonChartData.topTypes;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Tipos Gen I (Donut)'),
      SizedBox(
        height: 250,
        child: PieChart(PieChartData(
          sections: types.entries.map((e) {
            final color = PokemonChartData.typeColors[e.key] ?? Colors.grey;
            return PieChartSectionData(
              value: e.value.toDouble(),
              title: e.key,
              color: color,
              radius: 70,
              titleStyle: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 50,
        )),
      ),
    ]);
  }
}

// ─── FlB17: 1 Tipo vs 2 Tipos ────────────────────────────────────────────────
class FlB17 extends StatelessWidget {
  const FlB17({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Pokémon 1 Tipo vs 2 Tipos'),
      SizedBox(
        height: 250,
        child: PieChart(PieChartData(
          sections: [
            PieChartSectionData(value: 72, title: '1 Tipo\n72', color: const Color(0xFF1565C0), radius: 70,
                titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            PieChartSectionData(value: 79, title: '2 Tipos\n79', color: const Color(0xFF43A047), radius: 70,
                titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
          sectionsSpace: 3,
          centerSpaceRadius: 50,
        )),
      ),
    ]);
  }
}

// ─── FlB18: Legendarios vs Normales ─────────────────────────────────────────
class FlB18 extends StatelessWidget {
  const FlB18({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Legendarios vs Normales'),
      SizedBox(
        height: 250,
        child: PieChart(PieChartData(
          sections: [
            PieChartSectionData(value: 5, title: 'Legendarios\n5', color: const Color(0xFF7038F8), radius: 90,
                titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            PieChartSectionData(value: 146, title: 'Normales\n146', color: Colors.grey.shade400, radius: 90,
                titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 0,
        )),
      ),
    ]);
  }
}

// ─── FlB19: HP de los Starters ──────────────────────────────────────────────
class FlB19 extends StatelessWidget {
  const FlB19({super.key});
  @override
  Widget build(BuildContext context) {
    const starterHp = [45.0, 60.0, 80.0, 39.0, 58.0, 78.0, 44.0, 59.0, 79.0];
    const names = ['Bul', 'Ivy', 'Ven', 'Char', 'Mel', 'Zard', 'Squi', 'Wart', 'Blas'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP de los Starters'),
      SizedBox(
        height: 250,
        child: LineChart(LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(9, (i) => FlSpot(i.toDouble(), starterHp[i])),
              color: const Color(0xFF78C850),
              isCurved: true,
              barWidth: 2,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF78C850).withOpacity(0.2)),
            )
          ],
          titlesData: _bottomTitles(names),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          minY: 0,
          maxY: 120,
        )),
      ),
    ]);
  }
}

// ─── FlB20: Ataque Primeros 15 ───────────────────────────────────────────────
class FlB20 extends StatelessWidget {
  const FlB20({super.key});
  @override
  Widget build(BuildContext context) {
    final atk = PokemonChartData.first20Atk.take(15).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Ataque Primeros 15 Pokémon'),
      SizedBox(
        height: 250,
        child: LineChart(LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(atk.length, (i) => FlSpot(i.toDouble(), atk[i].toDouble())),
              color: const Color(0xFFF44336),
              isCurved: true,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: const Color(0xFFF44336).withOpacity(0.15)),
            )
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, reservedSize: 22,
              getTitlesWidget: (v, _) => v.toInt() % 3 == 0
                  ? Text('#${v.toInt() + 1}', style: const TextStyle(fontSize: 9))
                  : const SizedBox.shrink(),
            )),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 9)))),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          minY: 0, maxY: 140,
        )),
      ),
    ]);
  }
}

// ─── FlB21: HP Comparativa Starters ─────────────────────────────────────────
class FlB21 extends StatelessWidget {
  const FlB21({super.key});
  @override
  Widget build(BuildContext context) {
    const bulba = [45.0, 60.0, 80.0];
    const char  = [39.0, 58.0, 78.0];
    const squi  = [44.0, 59.0, 79.0];
    const labels = ['Base', 'Medio', 'Final'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP Comparativa Starters'),
      Row(children: [
        _legendDot(const Color(0xFF78C850), 'Planta'),
        const SizedBox(width: 8),
        _legendDot(const Color(0xFFF08030), 'Fuego'),
        const SizedBox(width: 8),
        _legendDot(const Color(0xFF6890F0), 'Agua'),
      ]),
      const SizedBox(height: 8),
      SizedBox(
        height: 220,
        child: LineChart(LineChartData(
          lineBarsData: [
            LineChartBarData(spots: List.generate(3, (i) => FlSpot(i.toDouble(), bulba[i])),
              color: const Color(0xFF78C850), isCurved: true, barWidth: 2,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF78C850).withOpacity(0.1))),
            LineChartBarData(spots: List.generate(3, (i) => FlSpot(i.toDouble(), char[i])),
              color: const Color(0xFFF08030), isCurved: true, barWidth: 2,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: const Color(0xFFF08030).withOpacity(0.1))),
            LineChartBarData(spots: List.generate(3, (i) => FlSpot(i.toDouble(), squi[i])),
              color: const Color(0xFF6890F0), isCurved: true, barWidth: 2,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF6890F0).withOpacity(0.1))),
          ],
          titlesData: _bottomTitles(labels),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          minY: 0, maxY: 100,
        )),
      ),
    ]);
  }
}

// ─── FlB22: Defensa Primeros 20 ──────────────────────────────────────────────
class FlB22 extends StatelessWidget {
  const FlB22({super.key});
  @override
  Widget build(BuildContext context) {
    final def = PokemonChartData.first20Def;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Defensa Primeros 20 Pokémon'),
      SizedBox(
        height: 250,
        child: LineChart(LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(def.length, (i) => FlSpot(i.toDouble(), def[i].toDouble())),
              color: const Color(0xFF2196F3),
              isCurved: false,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF2196F3).withOpacity(0.15)),
            )
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, reservedSize: 22,
              getTitlesWidget: (v, _) => v.toInt() % 4 == 0
                  ? Text('#${v.toInt() + 1}', style: const TextStyle(fontSize: 9))
                  : const SizedBox.shrink(),
            )),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 9)))),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          minY: 0, maxY: 140,
        )),
      ),
    ]);
  }
}

// ─── FlB23: Sp. Ataque Primeros 20 ──────────────────────────────────────────
class FlB23 extends StatelessWidget {
  const FlB23({super.key});
  @override
  Widget build(BuildContext context) {
    final spAtk = PokemonChartData.first20Atk.map((v) => (v * 1.1).toInt()).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Sp. Ataque Primeros 20'),
      SizedBox(
        height: 250,
        child: LineChart(LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(spAtk.length, (i) => FlSpot(i.toDouble(), spAtk[i].toDouble())),
              color: const Color(0xFF9C27B0),
              isCurved: true,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF9C27B0).withOpacity(0.15)),
            )
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, reservedSize: 22,
              getTitlesWidget: (v, _) => v.toInt() % 4 == 0
                  ? Text('#${v.toInt() + 1}', style: const TextStyle(fontSize: 9))
                  : const SizedBox.shrink(),
            )),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 9)))),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          minY: 0, maxY: 150,
        )),
      ),
    ]);
  }
}

// ─── FlB24–27: Histogramas ────────────────────────────────────────────────────

Widget _histogramChart(List<int> bins, Color color) => BarChart(BarChartData(
      barGroups: List.generate(
          bins.length,
          (i) => BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: bins[i].toDouble(), color: color, width: 24, borderRadius: BorderRadius.circular(3))
              ])),
      titlesData: _bottomTitles(PokemonChartData.binLabels),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(drawVerticalLine: false),
      maxY: 55,
    ));

class FlB24 extends StatelessWidget {
  const FlB24({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _chartTitle('Distribución HP Gen I'),
        SizedBox(height: 250, child: _histogramChart(PokemonChartData.hpBins, const Color(0xFF4CAF50))),
      ]);
}

class FlB25 extends StatelessWidget {
  const FlB25({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _chartTitle('Distribución Ataque Gen I'),
        SizedBox(height: 250, child: _histogramChart(PokemonChartData.atkBins, const Color(0xFFF44336))),
      ]);
}

class FlB26 extends StatelessWidget {
  const FlB26({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _chartTitle('Distribución Defensa Gen I'),
        SizedBox(height: 250, child: _histogramChart(PokemonChartData.defBins, const Color(0xFF2196F3))),
      ]);
}

class FlB27 extends StatelessWidget {
  const FlB27({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _chartTitle('Distribución Velocidad Gen I'),
        SizedBox(height: 250, child: _histogramChart(PokemonChartData.speedBins, const Color(0xFFFF9800))),
      ]);
}

// ─── FlB28–31: Scatter ────────────────────────────────────────────────────────

FlTitlesData _scatterTitles(String xLabel, String yLabel) => FlTitlesData(
      bottomTitles: AxisTitles(
          axisNameWidget: Text(xLabel, style: const TextStyle(fontSize: 10)),
          axisNameSize: 18,
          sideTitles: SideTitles(showTitles: true, reservedSize: 22,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
      leftTitles: AxisTitles(
          axisNameWidget: Text(yLabel, style: const TextStyle(fontSize: 10)),
          axisNameSize: 18,
          sideTitles: SideTitles(showTitles: true, reservedSize: 28,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );

class FlB28 extends StatelessWidget {
  const FlB28({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.attackVsDefense;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Ataque vs Defensa'),
      SizedBox(height: 250, child: ScatterChart(ScatterChartData(
        scatterSpots: data.map((p) => ScatterSpot(p[0].toDouble(), p[1].toDouble(),
            dotPainter: FlDotCirclePainter(radius: 5, color: const Color(0xFFF44336).withOpacity(0.7)))).toList(),
        minX: 0, maxX: 180, minY: 0, maxY: 180,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: _scatterTitles('Ataque', 'Defensa'),
      ))),
    ]);
  }
}

class FlB29 extends StatelessWidget {
  const FlB29({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.hpVsSpeed;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP vs Velocidad'),
      SizedBox(height: 250, child: ScatterChart(ScatterChartData(
        scatterSpots: data.map((p) => ScatterSpot(p[0].toDouble(), p[1].toDouble(),
            dotPainter: FlDotCirclePainter(radius: 5, color: const Color(0xFF4CAF50).withOpacity(0.7)))).toList(),
        minX: 0, maxX: 180, minY: 0, maxY: 150,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: _scatterTitles('HP', 'Velocidad'),
      ))),
    ]);
  }
}

class FlB30 extends StatelessWidget {
  const FlB30({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.attackVsDefense;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Ataque vs Velocidad'),
      SizedBox(height: 250, child: ScatterChart(ScatterChartData(
        scatterSpots: data.asMap().entries.map((e) {
          final spd = e.key < PokemonChartData.first20Spd.length ? PokemonChartData.first20Spd[e.key].toDouble() : 60.0;
          return ScatterSpot(e.value[0].toDouble(), spd,
              dotPainter: FlDotCirclePainter(radius: 5, color: const Color(0xFFFF9800).withOpacity(0.7)));
        }).toList(),
        minX: 0, maxX: 180, minY: 0, maxY: 150,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: _scatterTitles('Ataque', 'Velocidad'),
      ))),
    ]);
  }
}

class FlB31 extends StatelessWidget {
  const FlB31({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.spAtkVsSpDef;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Sp.Atk vs Sp.Def'),
      SizedBox(height: 250, child: ScatterChart(ScatterChartData(
        scatterSpots: data.map((p) => ScatterSpot(p[0].toDouble(), p[1].toDouble(),
            dotPainter: FlDotCirclePainter(radius: 5, color: const Color(0xFF9C27B0).withOpacity(0.7)))).toList(),
        minX: 0, maxX: 180, minY: 0, maxY: 180,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: _scatterTitles('Sp.Atk', 'Sp.Def'),
      ))),
    ]);
  }
}

// ─── FlB32–34: Bubble ────────────────────────────────────────────────────────

class FlB32 extends StatelessWidget {
  const FlB32({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.bubbleHpAtk;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP vs Ataque (tamaño = Defensa)'),
      SizedBox(height: 250, child: ScatterChart(ScatterChartData(
        scatterSpots: data.map((p) => ScatterSpot(p[0].toDouble(), p[1].toDouble(),
            dotPainter: FlDotCirclePainter(
              radius: (p[2] / 5.0).clamp(6.0, 25.0),
              color: const Color(0xFF1565C0).withOpacity(0.55),
              strokeColor: const Color(0xFF1565C0),
              strokeWidth: 1,
            ))).toList(),
        minX: 0, maxX: 180, minY: 0, maxY: 180,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: _scatterTitles('HP', 'Ataque'),
      ))),
    ]);
  }
}

class FlB33 extends StatelessWidget {
  const FlB33({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.bubbleSpdAtk;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Velocidad vs Ataque (tamaño = HP)'),
      SizedBox(height: 250, child: ScatterChart(ScatterChartData(
        scatterSpots: data.map((p) => ScatterSpot(p[0].toDouble(), p[1].toDouble(),
            dotPainter: FlDotCirclePainter(
              radius: (p[2] / 8.0).clamp(6.0, 22.0),
              color: const Color(0xFFFF9800).withOpacity(0.55),
              strokeColor: const Color(0xFFFF9800),
              strokeWidth: 1,
            ))).toList(),
        minX: 0, maxX: 180, minY: 0, maxY: 180,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: _scatterTitles('Velocidad', 'Ataque'),
      ))),
    ]);
  }
}

class FlB34 extends StatelessWidget {
  const FlB34({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.bubbleHpAtk;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP vs Sp.Atk (tamaño = Velocidad)'),
      SizedBox(height: 250, child: ScatterChart(ScatterChartData(
        scatterSpots: data.map((p) => ScatterSpot(p[0].toDouble(), (p[1] * 1.15).clamp(0, 160).toDouble(),
            dotPainter: FlDotCirclePainter(
              radius: (p[2] / 5.5).clamp(6.0, 24.0),
              color: const Color(0xFF9C27B0).withOpacity(0.55),
              strokeColor: const Color(0xFF9C27B0),
              strokeWidth: 1,
            ))).toList(),
        minX: 0, maxX: 180, minY: 0, maxY: 180,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: _scatterTitles('HP', 'Sp.Atk'),
      ))),
    ]);
  }
}

// ─── FlB35–38: Radar ─────────────────────────────────────────────────────────

RadarChartData _radarData(List<RadarDataSet> sets) => RadarChartData(
      dataSets: sets,
      getTitle: (index, angle) =>
          RadarChartTitle(text: PokemonChartData.statNames[index], angle: angle),
      tickCount: 3,
      radarShape: RadarShape.polygon,
      radarBorderData: const BorderSide(color: Colors.grey, width: 1),
      tickBorderData: const BorderSide(color: Colors.grey, width: 1),
      gridBorderData: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
      ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
      radarBackgroundColor: Colors.transparent,
      titleTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
    );

class FlB35 extends StatelessWidget {
  const FlB35({super.key});
  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf('Pikachu');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats de Pikachu'),
      SizedBox(height: 280, child: RadarChart(_radarData([
        RadarDataSet(
          dataEntries: s.map((v) => RadarEntry(value: v.toDouble())).toList(),
          fillColor: const Color(0xFFF8D030).withOpacity(0.3),
          borderColor: const Color(0xFFF8D030),
          borderWidth: 2,
        )
      ]))),
    ]);
  }
}

class FlB36 extends StatelessWidget {
  const FlB36({super.key});
  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf('Mewtwo');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats de Mewtwo'),
      SizedBox(height: 280, child: RadarChart(_radarData([
        RadarDataSet(
          dataEntries: s.map((v) => RadarEntry(value: v.toDouble())).toList(),
          fillColor: const Color(0xFFF85888).withOpacity(0.3),
          borderColor: const Color(0xFFF85888),
          borderWidth: 2,
        )
      ]))),
    ]);
  }
}

class FlB37 extends StatelessWidget {
  const FlB37({super.key});
  @override
  Widget build(BuildContext context) {
    final ch = PokemonChartData.statsOf('Charizard');
    final bl = PokemonChartData.statsOf('Blastoise');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Charizard vs Blastoise'),
      Row(children: [
        _legendDot(const Color(0xFFF08030), 'Charizard'),
        const SizedBox(width: 8),
        _legendDot(const Color(0xFF6890F0), 'Blastoise'),
      ]),
      SizedBox(height: 260, child: RadarChart(_radarData([
        RadarDataSet(
          dataEntries: ch.map((v) => RadarEntry(value: v.toDouble())).toList(),
          fillColor: const Color(0xFFF08030).withOpacity(0.25),
          borderColor: const Color(0xFFF08030),
          borderWidth: 2,
        ),
        RadarDataSet(
          dataEntries: bl.map((v) => RadarEntry(value: v.toDouble())).toList(),
          fillColor: const Color(0xFF6890F0).withOpacity(0.25),
          borderColor: const Color(0xFF6890F0),
          borderWidth: 2,
        ),
      ]))),
    ]);
  }
}

class FlB38 extends StatelessWidget {
  const FlB38({super.key});
  @override
  Widget build(BuildContext context) {
    final fire = PokemonChartData.avgStatsOf(PokemonChartData.fireTypes);
    final water = PokemonChartData.avgStatsOf(PokemonChartData.waterTypes);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Fuego avg vs Agua avg'),
      Row(children: [
        _legendDot(const Color(0xFFF08030), 'Fuego'),
        const SizedBox(width: 8),
        _legendDot(const Color(0xFF6890F0), 'Agua'),
      ]),
      SizedBox(height: 260, child: RadarChart(_radarData([
        RadarDataSet(
          dataEntries: fire.map((v) => RadarEntry(value: v)).toList(),
          fillColor: const Color(0xFFF08030).withOpacity(0.25),
          borderColor: const Color(0xFFF08030),
          borderWidth: 2,
        ),
        RadarDataSet(
          dataEntries: water.map((v) => RadarEntry(value: v)).toList(),
          fillColor: const Color(0xFF6890F0).withOpacity(0.25),
          borderColor: const Color(0xFF6890F0),
          borderWidth: 2,
        ),
      ]))),
    ]);
  }
}

// ─── FlB39: Heatmap Correlación ──────────────────────────────────────────────
class FlB39 extends StatelessWidget {
  const FlB39({super.key});
  @override
  Widget build(BuildContext context) {
    final matrix = PokemonChartData.correlationMatrix;
    final labels = PokemonChartData.statNames;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Correlación Stats Gen I'),
      Row(children: [
        const SizedBox(width: 36),
        ...labels.map((l) => SizedBox(width: 40, child: Text(l, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
      ]),
      const SizedBox(height: 4),
      ...List.generate(6, (row) => Row(children: [
        SizedBox(width: 36, child: Text(labels[row], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
        ...List.generate(6, (col) {
          final v = matrix[row][col];
          return Container(
            width: 40, height: 36, margin: const EdgeInsets.all(1),
            color: Color.lerp(Colors.blue.shade100, Colors.blue.shade900, v),
            child: Center(child: Text(v.toStringAsFixed(2), style: const TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.bold))),
          );
        }),
      ])),
    ]);
  }
}

// ─── FlB40: Heatmap Stats por Tipo ───────────────────────────────────────────
class FlB40 extends StatelessWidget {
  const FlB40({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.heatmapAvg;
    final types = PokemonChartData.heatmapTypes;
    final maxVal = data.expand((r) => r).reduce((a, b) => a > b ? a : b);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats Promedio por Tipo'),
      Row(children: [
        const SizedBox(width: 56),
        ...PokemonChartData.statNames.map((l) => SizedBox(width: 38, child: Text(l, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center))),
      ]),
      const SizedBox(height: 4),
      ...List.generate(types.length, (row) => Row(children: [
        SizedBox(width: 56, child: Text(types[row], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
        ...List.generate(6, (col) {
          final v = data[row][col] / maxVal;
          return Container(
            width: 38, height: 34, margin: const EdgeInsets.all(1),
            color: Color.lerp(Colors.green.shade100, Colors.green.shade900, v),
            child: Center(child: Text(data[row][col].toStringAsFixed(0), style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold))),
          );
        }),
      ])),
    ]);
  }
}

// ─── FlB41: Combined – Stats + Línea Promedio ────────────────────────────────
class FlB41 extends StatelessWidget {
  const FlB41({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Pikachu');
    final avg = stats.fold(0, (a, b) => a + b) / 6.0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats + Línea Promedio (Pikachu)'),
      SizedBox(
        height: 250,
        child: BarChart(BarChartData(
          barGroups: List.generate(6, (i) => BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: stats[i].toDouble(), color: PokemonChartData.statColors[i], width: 28, borderRadius: BorderRadius.circular(4))
              ])),
          titlesData: _bottomTitles(PokemonChartData.statNames),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(drawVerticalLine: false),
          maxY: 130,
          extraLinesData: ExtraLinesData(horizontalLines: [
            HorizontalLine(y: avg, color: Colors.redAccent, strokeWidth: 2, dashArray: [6, 3],
              label: HorizontalLineLabel(show: true, labelResolver: (_) => 'avg ${avg.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold))),
          ]),
        )),
      ),
    ]);
  }
}

// ─── FlB42: Combined – HP Área + Scatter ────────────────────────────────────
class FlB42 extends StatelessWidget {
  const FlB42({super.key});
  @override
  Widget build(BuildContext context) {
    const starterHp = [45.0, 60.0, 80.0, 39.0, 58.0, 78.0, 44.0, 59.0, 79.0];
    final scatter = PokemonChartData.hpVsSpeed.take(15).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP Área + HP vs Velocidad Scatter'),
      SizedBox(height: 130, child: LineChart(LineChartData(
        lineBarsData: [LineChartBarData(
          spots: List.generate(9, (i) => FlSpot(i.toDouble(), starterHp[i])),
          color: const Color(0xFF78C850), isCurved: true, barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: const Color(0xFF78C850).withOpacity(0.2)),
        )],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 8)))),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(drawVerticalLine: false),
        minY: 0, maxY: 110,
      ))),
      const SizedBox(height: 8),
      SizedBox(height: 120, child: ScatterChart(ScatterChartData(
        scatterSpots: scatter.map((p) => ScatterSpot(p[0].toDouble(), p[1].toDouble(),
            dotPainter: FlDotCirclePainter(radius: 4, color: const Color(0xFF6890F0).withOpacity(0.7)))).toList(),
        minX: 0, maxX: 170, minY: 0, maxY: 140,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 18,
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

// ─── FlB43: Dashboard Pokémon ────────────────────────────────────────────────
class FlB43 extends StatelessWidget {
  const FlB43({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Snorlax');
    final total = PokemonChartData.totalOf('Snorlax');
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Dashboard Pokémon – Snorlax'),
      Row(children: [
        Expanded(child: _InfoCard('Total', total.toString(), Colors.deepPurple)),
        const SizedBox(width: 8),
        Expanded(child: _InfoCard('HP', stats[0].toString(), const Color(0xFF4CAF50))),
        const SizedBox(width: 8),
        Expanded(child: _InfoCard('Velocidad', stats[5].toString(), const Color(0xFFFF9800))),
      ]),
      const SizedBox(height: 12),
      SizedBox(height: 200, child: BarChart(BarChartData(
        barGroups: List.generate(6, (i) => BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: stats[i].toDouble(), color: PokemonChartData.statColors[i], width: 28, borderRadius: BorderRadius.circular(4))
            ])),
        titlesData: _bottomTitles(PokemonChartData.statNames),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(drawVerticalLine: false),
        maxY: 200,
      ))),
    ]);
  }
}

class _InfoCard extends StatelessWidget {
  final String title, value;
  final Color color;
  const _InfoCard(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(fontSize: 10, color: color)),
        ]),
      );
}
