// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'dart:math';
import '../../../core/data/pokemon_chart_data.dart';

Widget _chartTitle(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 12),
  child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
);

class _RadarPainter extends CustomPainter {
  final List<String> labels;
  final List<Color> colors;
  final List<List<double>> datasets;
  final double animProgress;
  const _RadarPainter({required this.labels, required this.colors, required this.datasets, this.animProgress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.shortestSide * 0.35;
    final n = labels.length;
    const pi = 3.14159265358979;
    for (int g = 1; g <= 4; g++) {
      final r = maxR * g / 4;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final a = (i * 2 * pi / n) - pi / 2;
        final pt = Offset(center.dx + r * cos(a), center.dy + r * sin(a));
        if (i == 0) path.moveTo(pt.dx, pt.dy); else path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = Colors.grey.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 1);
    }
    for (int i = 0; i < n; i++) {
      final a = (i * 2 * pi / n) - pi / 2;
      canvas.drawLine(center, Offset(center.dx + maxR * cos(a), center.dy + maxR * sin(a)),
          Paint()..color = Colors.grey.withOpacity(0.3)..strokeWidth = 1);
    }
    for (int d = 0; d < datasets.length; d++) {
      final ds = datasets[d];
      final color = d < colors.length ? colors[d] : Colors.blue;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final a = (i * 2 * pi / n) - pi / 2;
        final r = maxR * ds[i] * animProgress;
        final pt = Offset(center.dx + r * cos(a), center.dy + r * sin(a));
        if (i == 0) path.moveTo(pt.dx, pt.dy); else path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = color.withOpacity(0.25)..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);
    }
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < n; i++) {
      final a = (i * 2 * pi / n) - pi / 2;
      final pt = Offset(center.dx + (maxR + 16) * cos(a), center.dy + (maxR + 16) * sin(a));
      tp.text = TextSpan(text: labels[i], style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w600));
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

// B01
class GrB01 extends StatelessWidget {
  const GrB01({super.key});
  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf('Bulbasaur');
    final data = List<Map<String, dynamic>>.generate(6, (i) => {'stat': PokemonChartData.statNames[i], 'val': s[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats de Bulbasaur'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'stat': Variable(accessor: (Map m) => m['stat'] as String),
          'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 160)),
        },
        marks: [IntervalMark(color: ColorEncode(variable: 'stat', values: PokemonChartData.statColors))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B02
class GrB02 extends StatelessWidget {
  const GrB02({super.key});
  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf('Mewtwo');
    final data = List<Map<String, dynamic>>.generate(6, (i) => {'stat': PokemonChartData.statNames[i], 'val': s[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats de Mewtwo'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'stat': Variable(accessor: (Map m) => m['stat'] as String),
          'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 180)),
        },
        marks: [IntervalMark(color: ColorEncode(variable: 'stat', values: PokemonChartData.statColors))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B03
class GrB03 extends StatelessWidget {
  const GrB03({super.key});
  @override
  Widget build(BuildContext context) {
    final b = PokemonChartData.statsOf('Bulbasaur');
    final c = PokemonChartData.statsOf('Charmander');
    final data = <Map<String, dynamic>>[];
    for (int i = 0; i < 6; i++) {
      data.add({'stat': PokemonChartData.statNames[i], 'val': b[i], 'poke': 'Bulbasaur'});
      data.add({'stat': PokemonChartData.statNames[i], 'val': c[i], 'poke': 'Charmander'});
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Bulbasaur vs Charmander'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'stat': Variable(accessor: (Map m) => m['stat'] as String),
          'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 160)),
          'poke': Variable(accessor: (Map m) => m['poke'] as String),
        },
        marks: [IntervalMark(
          position: Varset('stat') * Varset('val') / Varset('poke'),
          color: ColorEncode(variable: 'poke', values: [const Color(0xFF78C850), const Color(0xFFF08030)]),
        )],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B04
class GrB04 extends StatelessWidget {
  const GrB04({super.key});
  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(1, n: 5);
    final data = top.map((e) => <String, dynamic>{'name': e.key, 'val': e.value}).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 5 por Ataque'),
      SizedBox(height: 250, child: Chart(data: data,
        coord: RectCoord(transposed: true),
        variables: {
          'name': Variable(accessor: (Map m) => m['name'] as String),
          'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 160)),
        },
        marks: [IntervalMark(color: ColorEncode(value: const Color(0xFFF44336)))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B05
class GrB05 extends StatelessWidget {
  const GrB05({super.key});
  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(2, n: 5);
    final data = top.map((e) => <String, dynamic>{'name': e.key, 'val': e.value}).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 5 por Defensa'),
      SizedBox(height: 250, child: Chart(data: data,
        coord: RectCoord(transposed: true),
        variables: {
          'name': Variable(accessor: (Map m) => m['name'] as String),
          'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 120)),
        },
        marks: [IntervalMark(color: ColorEncode(value: const Color(0xFF2196F3)))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B06
class GrB06 extends StatelessWidget {
  const GrB06({super.key});
  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(0, n: 5);
    final data = top.map((e) => <String, dynamic>{'name': e.key, 'val': e.value}).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 5 por HP'),
      SizedBox(height: 250, child: Chart(data: data,
        coord: RectCoord(transposed: true),
        variables: {
          'name': Variable(accessor: (Map m) => m['name'] as String),
          'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 180)),
        },
        marks: [IntervalMark(color: ColorEncode(value: const Color(0xFF4CAF50)))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B07
class GrB07 extends StatelessWidget {
  const GrB07({super.key});
  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(5, n: 5);
    final data = top.map((e) => <String, dynamic>{'name': e.key, 'val': e.value}).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 5 por Velocidad'),
      SizedBox(height: 250, child: Chart(data: data,
        coord: RectCoord(transposed: true),
        variables: {
          'name': Variable(accessor: (Map m) => m['name'] as String),
          'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 140)),
        },
        marks: [IntervalMark(color: ColorEncode(value: const Color(0xFFFF9800)))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B08
class GrB08 extends StatelessWidget {
  const GrB08({super.key});
  @override
  Widget build(BuildContext context) {
    final fa = PokemonChartData.avgStatsOf(PokemonChartData.fireTypes);
    final wa = PokemonChartData.avgStatsOf(PokemonChartData.waterTypes);
    final ga = PokemonChartData.avgStatsOf(PokemonChartData.grassTypes);
    final data = <Map<String, dynamic>>[];
    for (int i = 0; i < 6; i++) {
      data.add({'stat': PokemonChartData.statNames[i], 'val': fa[i].roundToDouble(), 'tipo': 'Fuego'});
      data.add({'stat': PokemonChartData.statNames[i], 'val': wa[i].roundToDouble(), 'tipo': 'Agua'});
      data.add({'stat': PokemonChartData.statNames[i], 'val': ga[i].roundToDouble(), 'tipo': 'Planta'});
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Fuego vs Agua vs Planta'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'stat': Variable(accessor: (Map m) => m['stat'] as String),
          'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 140)),
          'tipo': Variable(accessor: (Map m) => m['tipo'] as String),
        },
        marks: [IntervalMark(
          position: Varset('stat') * Varset('val') / Varset('tipo'),
          color: ColorEncode(variable: 'tipo', values: [const Color(0xFFF08030), const Color(0xFF6890F0), const Color(0xFF78C850)]),
        )],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B09
class GrB09 extends StatelessWidget {
  const GrB09({super.key});
  @override
  Widget build(BuildContext context) {
    final data = [{'x': 'Bulbasaur', 'y': 45}, {'x': 'Ivysaur', 'y': 60}, {'x': 'Venusaur', 'y': 80}];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Evolución HP Bulbasaur'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as String),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 100)),
        },
        marks: [LineMark(color: ColorEncode(value: const Color(0xFF78C850))), PointMark(color: ColorEncode(value: const Color(0xFF78C850)), size: SizeEncode(value: 6))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B10
class GrB10 extends StatelessWidget {
  const GrB10({super.key});
  @override
  Widget build(BuildContext context) {
    final data = [{'x': 'Charmander', 'y': 52}, {'x': 'Charmeleon', 'y': 64}, {'x': 'Charizard', 'y': 84}];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Evolución Ataque Charmander'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as String),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 100)),
        },
        marks: [LineMark(color: ColorEncode(value: const Color(0xFFF08030))), PointMark(color: ColorEncode(value: const Color(0xFFF08030)), size: SizeEncode(value: 6))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B11
class GrB11 extends StatelessWidget {
  const GrB11({super.key});
  @override
  Widget build(BuildContext context) {
    final data = [{'x': 'Squirtle', 'y': 65}, {'x': 'Wartortle', 'y': 80}, {'x': 'Blastoise', 'y': 100}];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Evolución Defensa Squirtle'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as String),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 120)),
        },
        marks: [LineMark(color: ColorEncode(value: const Color(0xFF6890F0))), PointMark(color: ColorEncode(value: const Color(0xFF6890F0)), size: SizeEncode(value: 6))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B12
class GrB12 extends StatelessWidget {
  const GrB12({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List<Map<String, dynamic>>.generate(PokemonChartData.first20HP.length, (i) => {'x': '${i + 1}', 'y': PokemonChartData.first20HP[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP Primeros 20 Pokémon'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as String),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 160)),
        },
        marks: [LineMark(color: ColorEncode(value: const Color(0xFF4CAF50))), PointMark(color: ColorEncode(value: const Color(0xFF4CAF50)), size: SizeEncode(value: 4))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B13
class GrB13 extends StatelessWidget {
  const GrB13({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List<Map<String, dynamic>>.generate(PokemonChartData.first20Spd.length, (i) => {'x': '${i + 1}', 'y': PokemonChartData.first20Spd[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Velocidad Primeros 20'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as String),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 140)),
        },
        marks: [LineMark(color: ColorEncode(value: const Color(0xFFFF9800))), PointMark(color: ColorEncode(value: const Color(0xFFFF9800)), size: SizeEncode(value: 4))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B14
class GrB14 extends StatelessWidget {
  const GrB14({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.topTypes.entries.map((e) => <String, dynamic>{'tipo': e.key, 'count': e.value}).toList();
    final colors = data.map((d) => PokemonChartData.typeColors[d['tipo']] ?? Colors.grey).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Distribución Tipos Gen I'),
      SizedBox(height: 250, child: Chart(data: data,
        coord: PolarCoord(transposed: true, dimCount: 1),
        variables: {
          'tipo': Variable(accessor: (Map m) => m['tipo'] as String),
          'count': Variable(accessor: (Map m) => m['count'] as num, scale: LinearScale(min: 0)),
        },
        marks: [IntervalMark(
          position: Varset('count'),
          color: ColorEncode(variable: 'tipo', values: colors),
          label: LabelEncode(encoder: (tuple) => Label(tuple['tipo'].toString(), LabelStyle(textStyle: const TextStyle(fontSize: 8, color: Colors.white)))),
        )])),
    ]);
  }
}

// B15
class GrB15 extends StatelessWidget {
  const GrB15({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.topTypes.entries.take(5).map((e) => <String, dynamic>{'tipo': e.key, 'count': e.value}).toList();
    final colors = data.map((d) => PokemonChartData.typeColors[d['tipo']] ?? Colors.grey).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 5 Tipos más Comunes'),
      SizedBox(height: 250, child: Chart(data: data,
        coord: PolarCoord(transposed: true, dimCount: 1),
        variables: {
          'tipo': Variable(accessor: (Map m) => m['tipo'] as String),
          'count': Variable(accessor: (Map m) => m['count'] as num, scale: LinearScale(min: 0)),
        },
        marks: [IntervalMark(
          position: Varset('count'),
          color: ColorEncode(variable: 'tipo', values: colors),
          label: LabelEncode(encoder: (tuple) => Label('${tuple['tipo']}', LabelStyle(textStyle: const TextStyle(fontSize: 9, color: Colors.white)))),
        )])),
    ]);
  }
}

// B16 – Donut
class GrB16 extends StatelessWidget {
  const GrB16({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.topTypes.entries.map((e) => <String, dynamic>{'tipo': e.key, 'count': e.value}).toList();
    final colors = data.map((d) => PokemonChartData.typeColors[d['tipo']] ?? Colors.grey).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Tipos Gen I (Donut)'),
      Stack(alignment: Alignment.center, children: [
        SizedBox(height: 250, child: Chart(data: data,
          coord: PolarCoord(transposed: true, dimCount: 1),
          variables: {
            'tipo': Variable(accessor: (Map m) => m['tipo'] as String),
            'count': Variable(accessor: (Map m) => m['count'] as num, scale: LinearScale(min: 0)),
          },
          marks: [IntervalMark(position: Varset('count'), color: ColorEncode(variable: 'tipo', values: colors))])),
        Container(width: 90, height: 90, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        const Text('Tipos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    ]);
  }
}

// B17
class GrB17 extends StatelessWidget {
  const GrB17({super.key});
  @override
  Widget build(BuildContext context) {
    final data = [{'tipo': '1 tipo', 'count': 98}, {'tipo': '2 tipos', 'count': 53}];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('1 Tipo vs 2 Tipos'),
      Stack(alignment: Alignment.center, children: [
        SizedBox(height: 250, child: Chart(data: data,
          coord: PolarCoord(transposed: true, dimCount: 1),
          variables: {
            'tipo': Variable(accessor: (Map m) => m['tipo'] as String),
            'count': Variable(accessor: (Map m) => m['count'] as num, scale: LinearScale(min: 0)),
          },
          marks: [IntervalMark(
            position: Varset('count'),
            color: ColorEncode(variable: 'tipo', values: [const Color(0xFF2196F3), const Color(0xFFE91E63)]),
            label: LabelEncode(encoder: (tuple) => Label('${tuple['tipo']}\n${tuple['count']}', LabelStyle(textStyle: const TextStyle(fontSize: 10, color: Colors.white)))),
          )])),
        Container(width: 80, height: 80, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        const Text('151', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ]),
    ]);
  }
}

// B18
class GrB18 extends StatelessWidget {
  const GrB18({super.key});
  @override
  Widget build(BuildContext context) {
    final data = [{'tipo': 'Legendarios', 'count': 5}, {'tipo': 'Regulares', 'count': 146}];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Legendarios vs Normales'),
      SizedBox(height: 250, child: Chart(data: data,
        coord: PolarCoord(transposed: true, dimCount: 1),
        variables: {
          'tipo': Variable(accessor: (Map m) => m['tipo'] as String),
          'count': Variable(accessor: (Map m) => m['count'] as num, scale: LinearScale(min: 0)),
        },
        marks: [IntervalMark(
          position: Varset('count'),
          color: ColorEncode(variable: 'tipo', values: [const Color(0xFFFFD700), const Color(0xFF9E9E9E)]),
          label: LabelEncode(encoder: (tuple) => Label('${tuple['tipo']}\n${tuple['count']}', LabelStyle(textStyle: const TextStyle(fontSize: 10, color: Colors.white)))),
        )])),
    ]);
  }
}

// B19
class GrB19 extends StatelessWidget {
  const GrB19({super.key});
  @override
  Widget build(BuildContext context) {
    final names = ['Bulbasaur','Ivysaur','Venusaur','Charmander','Charmeleon','Charizard','Squirtle','Wartortle','Blastoise'];
    final hp = [45,60,80,39,58,78,44,59,79];
    final data = List<Map<String,dynamic>>.generate(9, (i) => {'x': names[i], 'y': hp[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP de los Starters'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as String),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 100)),
        },
        marks: [AreaMark(color: ColorEncode(value: const Color(0xFF78C850).withOpacity(0.3))), LineMark(color: ColorEncode(value: const Color(0xFF78C850)))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B20
class GrB20 extends StatelessWidget {
  const GrB20({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List<Map<String,dynamic>>.generate(15, (i) => {'x': '${i+1}', 'y': PokemonChartData.first20Atk[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Ataque Primeros 15'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as String),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 100)),
        },
        marks: [AreaMark(color: ColorEncode(value: const Color(0xFFF44336).withOpacity(0.3))), LineMark(color: ColorEncode(value: const Color(0xFFF44336)))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B21
class GrB21 extends StatelessWidget {
  const GrB21({super.key});
  @override
  Widget build(BuildContext context) {
    final stages = ['Base','Etapa 1','Etapa 2'];
    final data = <Map<String,dynamic>>[];
    for (int i = 0; i < 3; i++) {
      data.add({'stage': stages[i], 'hp': [45,60,80][i].toDouble(), 'linea': 'Bulbasaur'});
      data.add({'stage': stages[i], 'hp': [39,58,78][i].toDouble(), 'linea': 'Charmander'});
      data.add({'stage': stages[i], 'hp': [44,59,79][i].toDouble(), 'linea': 'Squirtle'});
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP Comparativa Starters'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'stage': Variable(accessor: (Map m) => m['stage'] as String),
          'hp': Variable(accessor: (Map m) => m['hp'] as num, scale: LinearScale(min: 0, max: 100)),
          'linea': Variable(accessor: (Map m) => m['linea'] as String),
        },
        marks: [
          AreaMark(position: Varset('stage') * Varset('hp'), color: ColorEncode(variable: 'linea', values: [const Color(0xFF78C850).withOpacity(0.3), const Color(0xFFF08030).withOpacity(0.3), const Color(0xFF6890F0).withOpacity(0.3)])),
          LineMark(position: Varset('stage') * Varset('hp'), color: ColorEncode(variable: 'linea', values: [const Color(0xFF78C850), const Color(0xFFF08030), const Color(0xFF6890F0)])),
        ],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B22
class GrB22 extends StatelessWidget {
  const GrB22({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List<Map<String,dynamic>>.generate(PokemonChartData.first20Def.length, (i) => {'x': '${i+1}', 'y': PokemonChartData.first20Def[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Defensa Primeros 20'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as String),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 120)),
        },
        marks: [AreaMark(color: ColorEncode(value: const Color(0xFF2196F3).withOpacity(0.3))), LineMark(color: ColorEncode(value: const Color(0xFF2196F3)))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B23
class GrB23 extends StatelessWidget {
  const GrB23({super.key});
  @override
  Widget build(BuildContext context) {
    final spa = [65,80,100,60,80,109,50,65,85,20,25,90,50,90,45,40,65,45,110,100];
    final data = List<Map<String,dynamic>>.generate(spa.length, (i) => {'x': '${i+1}', 'y': spa[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Sp. Ataque Primeros 20'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as String),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 120)),
        },
        marks: [AreaMark(color: ColorEncode(value: const Color(0xFF9C27B0).withOpacity(0.3))), LineMark(color: ColorEncode(value: const Color(0xFF9C27B0)))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B24
class GrB24 extends StatelessWidget {
  const GrB24({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List<Map<String,dynamic>>.generate(PokemonChartData.binLabels.length, (i) => {'bin': PokemonChartData.binLabels[i], 'count': PokemonChartData.hpBins[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Distribución HP Gen I'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'bin': Variable(accessor: (Map m) => m['bin'] as String),
          'count': Variable(accessor: (Map m) => m['count'] as num, scale: LinearScale(min: 0)),
        },
        marks: [IntervalMark(color: ColorEncode(value: const Color(0xFF4CAF50).withOpacity(0.8)))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B25
class GrB25 extends StatelessWidget {
  const GrB25({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List<Map<String,dynamic>>.generate(PokemonChartData.binLabels.length, (i) => {'bin': PokemonChartData.binLabels[i], 'count': PokemonChartData.atkBins[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Distribución Ataque'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'bin': Variable(accessor: (Map m) => m['bin'] as String),
          'count': Variable(accessor: (Map m) => m['count'] as num, scale: LinearScale(min: 0)),
        },
        marks: [IntervalMark(color: ColorEncode(value: const Color(0xFFF44336).withOpacity(0.8)))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B26
class GrB26 extends StatelessWidget {
  const GrB26({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List<Map<String,dynamic>>.generate(PokemonChartData.binLabels.length, (i) => {'bin': PokemonChartData.binLabels[i], 'count': PokemonChartData.defBins[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Distribución Defensa'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'bin': Variable(accessor: (Map m) => m['bin'] as String),
          'count': Variable(accessor: (Map m) => m['count'] as num, scale: LinearScale(min: 0)),
        },
        marks: [IntervalMark(color: ColorEncode(value: const Color(0xFF2196F3).withOpacity(0.8)))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B27
class GrB27 extends StatelessWidget {
  const GrB27({super.key});
  @override
  Widget build(BuildContext context) {
    final data = List<Map<String,dynamic>>.generate(PokemonChartData.binLabels.length, (i) => {'bin': PokemonChartData.binLabels[i], 'count': PokemonChartData.speedBins[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Distribución Velocidad'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'bin': Variable(accessor: (Map m) => m['bin'] as String),
          'count': Variable(accessor: (Map m) => m['count'] as num, scale: LinearScale(min: 0)),
        },
        marks: [IntervalMark(color: ColorEncode(value: const Color(0xFFFF9800).withOpacity(0.8)))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B28
class GrB28 extends StatelessWidget {
  const GrB28({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.attackVsDefense.map((p) => <String,dynamic>{'x': p[0].toDouble(), 'y': p[1].toDouble()}).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Ataque vs Defensa'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 160)),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 160)),
        },
        marks: [PointMark(color: ColorEncode(value: const Color(0xFF2196F3).withOpacity(0.6)), size: SizeEncode(value: 5))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B29
class GrB29 extends StatelessWidget {
  const GrB29({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.hpVsSpeed.map((p) => <String,dynamic>{'x': p[0].toDouble(), 'y': p[1].toDouble()}).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP vs Velocidad'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 170)),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 140)),
        },
        marks: [PointMark(color: ColorEncode(value: const Color(0xFF4CAF50).withOpacity(0.6)), size: SizeEncode(value: 5))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B30
class GrB30 extends StatelessWidget {
  const GrB30({super.key});
  @override
  Widget build(BuildContext context) {
    final n = min(PokemonChartData.attackVsDefense.length, PokemonChartData.hpVsSpeed.length);
    final data = List<Map<String,dynamic>>.generate(n, (i) => {'x': PokemonChartData.attackVsDefense[i][0].toDouble(), 'y': PokemonChartData.hpVsSpeed[i][1].toDouble()});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Ataque vs Velocidad'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 160)),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 140)),
        },
        marks: [PointMark(color: ColorEncode(value: const Color(0xFFFF9800).withOpacity(0.6)), size: SizeEncode(value: 5))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B31
class GrB31 extends StatelessWidget {
  const GrB31({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.spAtkVsSpDef.map((p) => <String,dynamic>{'x': p[0].toDouble(), 'y': p[1].toDouble()}).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Sp.Atk vs Sp.Def'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 160)),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 130)),
        },
        marks: [PointMark(color: ColorEncode(value: const Color(0xFF9C27B0).withOpacity(0.6)), size: SizeEncode(value: 5))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B32
class GrB32 extends StatelessWidget {
  const GrB32({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.bubbleHpAtk.map((p) => <String,dynamic>{'x': p[0].toDouble(), 'y': p[1].toDouble(), 'sz': p[2].toDouble()}).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP vs Ataque'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 170)),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 160)),
          'sz': Variable(accessor: (Map m) => m['sz'] as num, scale: LinearScale(min: 20, max: 110)),
        },
        marks: [PointMark(color: ColorEncode(value: const Color(0xFFE91E63).withOpacity(0.5)), size: SizeEncode(variable: 'sz', values: [5, 22]))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B33
class GrB33 extends StatelessWidget {
  const GrB33({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.bubbleSpdAtk.map((p) => <String,dynamic>{'x': p[0].toDouble(), 'y': p[1].toDouble(), 'sz': p[2].toDouble()}).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Velocidad vs Ataque'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 140)),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 160)),
          'sz': Variable(accessor: (Map m) => m['sz'] as num, scale: LinearScale(min: 20, max: 165)),
        },
        marks: [PointMark(color: ColorEncode(value: const Color(0xFF00BCD4).withOpacity(0.5)), size: SizeEncode(variable: 'sz', values: [4, 20]))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B34
class GrB34 extends StatelessWidget {
  const GrB34({super.key});
  @override
  Widget build(BuildContext context) {
    const pokes = ['Bulbasaur','Ivysaur','Venusaur','Charmander','Charmeleon','Charizard','Squirtle','Blastoise','Pikachu','Gengar','Gyarados','Lapras','Mewtwo','Mew','Snorlax','Dragonite','Jolteon','Vaporeon'];
    final data = pokes.map((n) { final s = PokemonChartData.statsOf(n); return <String,dynamic>{'x': s[0].toDouble(), 'y': s[3].toDouble(), 'sz': s[5].toDouble()}; }).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP vs Sp.Atk'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 170)),
          'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 165)),
          'sz': Variable(accessor: (Map m) => m['sz'] as num, scale: LinearScale(min: 20, max: 130)),
        },
        marks: [PointMark(color: ColorEncode(value: const Color(0xFF8BC34A).withOpacity(0.5)), size: SizeEncode(variable: 'sz', values: [4, 20]))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B35
class GrB35 extends StatelessWidget {
  const GrB35({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Pikachu').map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats de Pikachu'),
      SizedBox(height: 260, child: CustomPaint(size: const Size(double.infinity, 260),
        painter: _RadarPainter(labels: PokemonChartData.statNames, colors: [const Color(0xFFF8D030)], datasets: [stats]))),
    ]);
  }
}

// B36
class GrB36 extends StatelessWidget {
  const GrB36({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Mewtwo').map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats de Mewtwo'),
      SizedBox(height: 260, child: CustomPaint(size: const Size(double.infinity, 260),
        painter: _RadarPainter(labels: PokemonChartData.statNames, colors: [const Color(0xFF9C27B0)], datasets: [stats]))),
    ]);
  }
}

// B37
class GrB37 extends StatelessWidget {
  const GrB37({super.key});
  @override
  Widget build(BuildContext context) {
    final d1 = PokemonChartData.statsOf('Charizard').map((v) => v / 160.0).toList();
    final d2 = PokemonChartData.statsOf('Blastoise').map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Charizard vs Blastoise'),
      SizedBox(height: 260, child: CustomPaint(size: const Size(double.infinity, 260),
        painter: _RadarPainter(labels: PokemonChartData.statNames, colors: [const Color(0xFFF08030), const Color(0xFF6890F0)], datasets: [d1, d2]))),
    ]);
  }
}

// B38
class GrB38 extends StatelessWidget {
  const GrB38({super.key});
  @override
  Widget build(BuildContext context) {
    final fa = PokemonChartData.avgStatsOf(PokemonChartData.fireTypes).map((v) => v / 130.0).toList();
    final wa = PokemonChartData.avgStatsOf(PokemonChartData.waterTypes).map((v) => v / 130.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Fuego avg vs Agua avg'),
      SizedBox(height: 260, child: CustomPaint(size: const Size(double.infinity, 260),
        painter: _RadarPainter(labels: PokemonChartData.statNames, colors: [const Color(0xFFF08030), const Color(0xFF6890F0)], datasets: [fa, wa]))),
    ]);
  }
}

// B39
class GrB39 extends StatelessWidget {
  const GrB39({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Correlación Stats Gen I'),
      Row(children: [const SizedBox(width: 4), ...PokemonChartData.statNames.map((s) => Expanded(child: Center(child: Text(s, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))))]),
      const SizedBox(height: 4),
      SizedBox(height: 210, child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 36,
        itemBuilder: (ctx, index) {
          final row = index ~/ 6; final col = index % 6;
          final val = PokemonChartData.correlationMatrix[row][col];
          return Container(margin: const EdgeInsets.all(1), color: Color.lerp(Colors.blue.shade50, Colors.indigo.shade800, val),
            child: Center(child: Text(val.toStringAsFixed(2), style: const TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.w600))));
        },
      )),
    ]);
  }
}

// B40
class GrB40 extends StatelessWidget {
  const GrB40({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats Promedio por Tipo'),
      Row(children: [const SizedBox(width: 62), ...PokemonChartData.statNames.map((s) => Expanded(child: Center(child: Text(s, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)))))]),
      const SizedBox(height: 4),
      ...List.generate(PokemonChartData.heatmapTypes.length, (row) => Row(children: [
        SizedBox(width: 62, child: Text(PokemonChartData.heatmapTypes[row], style: const TextStyle(fontSize: 9))),
        ...List.generate(6, (col) {
          final val = PokemonChartData.heatmapAvg[row][col];
          final norm = ((val - 60) / 50).clamp(0.0, 1.0);
          return Expanded(child: Container(height: 32, margin: const EdgeInsets.all(1), color: Color.lerp(Colors.yellow.shade100, Colors.red.shade800, norm),
            child: Center(child: Text(val.toStringAsFixed(0), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)))));
        }),
      ])),
    ]);
  }
}

// B41
class GrB41 extends StatelessWidget {
  const GrB41({super.key});
  @override
  Widget build(BuildContext context) {
    final stats = PokemonChartData.statsOf('Bulbasaur');
    final avg = stats.fold(0, (a, b) => a + b) / stats.length;
    final data = List<Map<String,dynamic>>.generate(6, (i) => {'stat': PokemonChartData.statNames[i], 'val': stats[i]});
    final lineTop = 250.0 * (1 - avg / 160.0) * 0.72;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats + Línea Promedio'),
      Stack(children: [
        SizedBox(height: 250, child: Chart(data: data,
          variables: {
            'stat': Variable(accessor: (Map m) => m['stat'] as String),
            'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 160)),
          },
          marks: [IntervalMark(color: ColorEncode(variable: 'stat', values: PokemonChartData.statColors))],
          axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
        Positioned(left: 38, right: 8, top: lineTop, child: Row(children: [
          Expanded(child: Container(height: 1.5, color: Colors.red.withOpacity(0.8))),
          const SizedBox(width: 4),
          Text('avg=${avg.toStringAsFixed(0)}', style: const TextStyle(fontSize: 9, color: Colors.red)),
        ])),
      ]),
    ]);
  }
}

// B42
class GrB42 extends StatelessWidget {
  const GrB42({super.key});
  @override
  Widget build(BuildContext context) {
    final areaData = List<Map<String,dynamic>>.generate(10, (i) => {'x': '${i+1}', 'y': PokemonChartData.first20HP[i]});
    final scatData = PokemonChartData.hpVsSpeed.take(15).map((p) => <String,dynamic>{'x': p[0].toDouble(), 'y': p[1].toDouble()}).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP Área + Velocidad Scatter'),
      SizedBox(height: 125, child: Chart(data: areaData,
        variables: {'x': Variable(accessor: (Map m) => m['x'] as String), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 130))},
        marks: [AreaMark(color: ColorEncode(value: Colors.green.withOpacity(0.3))), LineMark(color: ColorEncode(value: Colors.green))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
      const SizedBox(height: 8),
      SizedBox(height: 125, child: Chart(data: scatData,
        variables: {'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 170)), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 140))},
        marks: [PointMark(color: ColorEncode(value: Colors.orange.withOpacity(0.7)), size: SizeEncode(value: 5))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// B43
class GrB43 extends StatelessWidget {
  const GrB43({super.key});
  @override
  Widget build(BuildContext context) {
    const poke = 'Pikachu';
    final stats = PokemonChartData.statsOf(poke);
    final total = PokemonChartData.totalOf(poke);
    final data = List<Map<String,dynamic>>.generate(6, (i) => {'stat': PokemonChartData.statNames[i], 'val': stats[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Dashboard Pokémon: $poke'),
      Row(children: [
        const Icon(Icons.catching_pokemon, color: Color(0xFFF8D030), size: 40),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(poke, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text('Total: $total', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Text('Tipo: Eléctrico', style: TextStyle(color: Color(0xFFF8D030), fontSize: 12)),
        ]),
      ]),
      const SizedBox(height: 12),
      SizedBox(height: 200, child: Chart(data: data,
        variables: {'stat': Variable(accessor: (Map m) => m['stat'] as String), 'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 120))},
        marks: [IntervalMark(color: ColorEncode(variable: 'stat', values: PokemonChartData.statColors))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}
