// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'dart:math';
import 'dart:async';
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

// A01 – Animated bar with expand
class GrA01 extends StatefulWidget {
  const GrA01({super.key});
  @override
  State<GrA01> createState() => _GrA01State();
}
class _GrA01State extends State<GrA01> with SingleTickerProviderStateMixin {
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
    final s = PokemonChartData.statsOf('Charizard');
    final data = List<Map<String,dynamic>>.generate(6, (i) => {'stat': PokemonChartData.statNames[i], 'val': s[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats Charizard (Animado)'),
      AnimatedBuilder(animation: _anim, builder: (_, __) {
        final scaled = List<Map<String,dynamic>>.generate(6, (i) => {'stat': PokemonChartData.statNames[i], 'val': (s[i] * _anim.value).round()});
        return SizedBox(height: 250, child: Chart(data: scaled,
          variables: {'stat': Variable(accessor: (Map m) => m['stat'] as String), 'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 140))},
          marks: [IntervalMark(color: ColorEncode(variable: 'stat', values: PokemonChartData.statColors))],
          axes: [Defaults.horizontalAxis, Defaults.verticalAxis]));
      }),
      const SizedBox(height: 8),
      Center(child: TextButton.icon(onPressed: () { _ctrl.reset(); _ctrl.forward(); }, icon: const Icon(Icons.replay), label: const Text('Replay'))),
    ]);
  }
}

// A02 – Animated line
class GrA02 extends StatefulWidget {
  const GrA02({super.key});
  @override
  State<GrA02> createState() => _GrA02State();
}
class _GrA02State extends State<GrA02> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final hps = PokemonChartData.first20HP;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP Animado (primeros 20)'),
      AnimatedBuilder(animation: _anim, builder: (_, __) {
        final count = max(1, (hps.length * _anim.value).round());
        final data = List<Map<String,dynamic>>.generate(count, (i) => {'x': '${i+1}', 'y': hps[i]});
        return SizedBox(height: 250, child: Chart(data: data,
          variables: {'x': Variable(accessor: (Map m) => m['x'] as String), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 130))},
          marks: [LineMark(color: ColorEncode(value: const Color(0xFF4CAF50))), PointMark(color: ColorEncode(value: const Color(0xFF4CAF50)), size: SizeEncode(value: 4))],
          axes: [Defaults.horizontalAxis, Defaults.verticalAxis]));
      }),
    ]);
  }
}

// A03 – Animated radar
class GrA03 extends StatefulWidget {
  const GrA03({super.key});
  @override
  State<GrA03> createState() => _GrA03State();
}
class _GrA03State extends State<GrA03> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward(); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final s1 = PokemonChartData.statsOf('Mewtwo').map((v) => v / 160.0).toList();
    final s2 = PokemonChartData.statsOf('Gengar').map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Mewtwo vs Gengar (Animado)'),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) => SizedBox(height: 260,
        child: CustomPaint(size: const Size(double.infinity, 260),
          painter: _RadarPainter(labels: PokemonChartData.statNames, colors: [const Color(0xFF9C27B0), const Color(0xFF212121)], datasets: [s1, s2], animProgress: _ctrl.value)))),
      Center(child: TextButton.icon(onPressed: () { _ctrl.reset(); _ctrl.forward(); }, icon: const Icon(Icons.replay), label: const Text('Replay'))),
    ]);
  }
}

// A04 – Animated pie
class GrA04 extends StatefulWidget {
  const GrA04({super.key});
  @override
  State<GrA04> createState() => _GrA04State();
}
class _GrA04State extends State<GrA04> with SingleTickerProviderStateMixin {
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
    final types = PokemonChartData.topTypes;
    final colors = types.values.toList();
    final data = types.entries.map((e) => <String,dynamic>{'tipo': e.key, 'count': e.value}).toList();
    final colorList = data.map((d) => PokemonChartData.typeColors[d['tipo']] ?? Colors.grey).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Tipos Gen I (Animado)'),
      AnimatedBuilder(animation: _anim, builder: (_, __) {
        final scaled = data.map((d) => <String,dynamic>{'tipo': d['tipo'], 'count': ((d['count'] as int) * _anim.value).round()}).toList();
        return SizedBox(height: 250, child: Chart(data: scaled,
          coord: PolarCoord(transposed: true, dimCount: 1),
          variables: {'tipo': Variable(accessor: (Map m) => m['tipo'] as String), 'count': Variable(accessor: (Map m) => m['count'] as num, scale: LinearScale(min: 0))},
          marks: [IntervalMark(position: Varset('count'), color: ColorEncode(variable: 'tipo', values: colorList))]));
      }),
    ]);
  }
}

// A05 – Selectable stat bar
class GrA05 extends StatefulWidget {
  const GrA05({super.key});
  @override
  State<GrA05> createState() => _GrA05State();
}
class _GrA05State extends State<GrA05> {
  String _sel = 'Bulbasaur';
  static const _pokes = ['Bulbasaur','Charmander','Squirtle','Pikachu','Gengar','Mewtwo','Dragonite','Snorlax'];
  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf(_sel);
    final data = List<Map<String,dynamic>>.generate(6, (i) => {'stat': PokemonChartData.statNames[i], 'val': s[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Stats por Pokémon'),
      DropdownButton<String>(value: _sel, onChanged: (v) => setState(() => _sel = v!), items: _pokes.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList()),
      const SizedBox(height: 8),
      SizedBox(height: 220, child: Chart(data: data,
        variables: {'stat': Variable(accessor: (Map m) => m['stat'] as String), 'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 180))},
        marks: [IntervalMark(color: ColorEncode(variable: 'stat', values: PokemonChartData.statColors))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A06 – Selectable type pie
class GrA06 extends StatefulWidget {
  const GrA06({super.key});
  @override
  State<GrA06> createState() => _GrA06State();
}
class _GrA06State extends State<GrA06> {
  int _topN = 5;
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.topTypes.entries.take(_topN).map((e) => <String,dynamic>{'tipo': e.key, 'count': e.value}).toList();
    final colorList = data.map((d) => PokemonChartData.typeColors[d['tipo']] ?? Colors.grey).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top N Tipos'),
      Row(children: [const Text('Mostrar top:'), const SizedBox(width: 8), ...List.generate(4, (i) {
        final n = i + 3;
        return Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text('$n'), selected: _topN == n, onSelected: (_) => setState(() => _topN = n)));
      })]),
      const SizedBox(height: 8),
      SizedBox(height: 220, child: Chart(data: data,
        coord: PolarCoord(transposed: true, dimCount: 1),
        variables: {'tipo': Variable(accessor: (Map m) => m['tipo'] as String), 'count': Variable(accessor: (Map m) => m['count'] as num, scale: LinearScale(min: 0))},
        marks: [IntervalMark(position: Varset('count'), color: ColorEncode(variable: 'tipo', values: colorList),
          label: LabelEncode(encoder: (tuple) => Label('${tuple['tipo']}', LabelStyle(textStyle: const TextStyle(fontSize: 9, color: Colors.white)))))])),
    ]);
  }
}

// A07 – Multi-select comparison bar
class GrA07 extends StatefulWidget {
  const GrA07({super.key});
  @override
  State<GrA07> createState() => _GrA07State();
}
class _GrA07State extends State<GrA07> {
  final _all = ['Bulbasaur','Charmander','Squirtle','Pikachu','Mewtwo','Gengar'];
  final Set<String> _sel = {'Bulbasaur','Mewtwo'};
  final _clrs = [const Color(0xFF4CAF50),const Color(0xFFF44336),const Color(0xFF2196F3),const Color(0xFFF8D030),const Color(0xFF9C27B0),const Color(0xFF212121)];
  @override
  Widget build(BuildContext context) {
    final selList = _all.where(_sel.contains).toList();
    final data = <Map<String,dynamic>>[];
    for (final p in selList) {
      final s = PokemonChartData.statsOf(p);
      for (int i = 0; i < 6; i++) data.add({'stat': PokemonChartData.statNames[i], 'val': s[i], 'poke': p});
    }
    final colors = selList.map((p) => _clrs[_all.indexOf(p) % _clrs.length]).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Comparativa Multi-Pokémon'),
      Wrap(spacing: 6, children: _all.map((p) => FilterChip(label: Text(p, style: const TextStyle(fontSize: 11)), selected: _sel.contains(p),
        onSelected: (v) => setState(() { if (v) { if (_sel.length < 3) _sel.add(p); } else if (_sel.length > 1) _sel.remove(p); }))).toList()),
      const SizedBox(height: 8),
      if (data.isEmpty) const Center(child: Text('Selecciona al menos 1'))
      else SizedBox(height: 220, child: Chart(data: data,
        variables: {'stat': Variable(accessor: (Map m) => m['stat'] as String), 'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 180)), 'poke': Variable(accessor: (Map m) => m['poke'] as String)},
        marks: [IntervalMark(position: Varset('stat') * Varset('val') / Varset('poke'), color: ColorEncode(variable: 'poke', values: colors))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A08 – Toggle chart type
class GrA08 extends StatefulWidget {
  const GrA08({super.key});
  @override
  State<GrA08> createState() => _GrA08State();
}
class _GrA08State extends State<GrA08> {
  bool _isBar = true;
  @override
  Widget build(BuildContext context) {
    final data = List<Map<String,dynamic>>.generate(PokemonChartData.first20HP.length, (i) => {'x': '${i+1}', 'y': PokemonChartData.first20HP[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP: Barras vs Línea'),
      Row(children: [
        ChoiceChip(label: const Text('Barras'), selected: _isBar, onSelected: (_) => setState(() => _isBar = true)),
        const SizedBox(width: 8),
        ChoiceChip(label: const Text('Línea'), selected: !_isBar, onSelected: (_) => setState(() => _isBar = false)),
      ]),
      const SizedBox(height: 8),
      SizedBox(height: 230, child: Chart(data: data,
        variables: {'x': Variable(accessor: (Map m) => m['x'] as String), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 130))},
        marks: _isBar ? [IntervalMark(color: ColorEncode(value: const Color(0xFF4CAF50)))] : [LineMark(color: ColorEncode(value: const Color(0xFF4CAF50))), PointMark(color: ColorEncode(value: const Color(0xFF4CAF50)), size: SizeEncode(value: 4))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A09 – Live timer bar (changes data every 2s)
class GrA09 extends StatefulWidget {
  const GrA09({super.key});
  @override
  State<GrA09> createState() => _GrA09State();
}
class _GrA09State extends State<GrA09> {
  final _pokes = ['Bulbasaur','Charmander','Squirtle','Pikachu','Mewtwo','Gengar','Dragonite','Snorlax'];
  int _idx = 0;
  Timer? _t;
  @override
  void initState() { super.initState(); _t = Timer.periodic(const Duration(seconds: 2), (_) { if (mounted) setState(() => _idx = (_idx + 1) % _pokes.length); }); }
  @override
  void dispose() { _t?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final p = _pokes[_idx];
    final s = PokemonChartData.statsOf(p);
    final data = List<Map<String,dynamic>>.generate(6, (i) => {'stat': PokemonChartData.statNames[i], 'val': s[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Live: $_p (auto-ciclo)'),
      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)), child: const Text('• Actualizando cada 2s', style: TextStyle(fontSize: 11, color: Colors.green))),
      const SizedBox(height: 8),
      SizedBox(height: 230, child: Chart(data: data,
        variables: {'stat': Variable(accessor: (Map m) => m['stat'] as String), 'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 180))},
        marks: [IntervalMark(color: ColorEncode(variable: 'stat', values: PokemonChartData.statColors))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
  String get _p => _pokes[_idx];
}

// A10 – Zoomable scatter
class GrA10 extends StatelessWidget {
  const GrA10({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.attackVsDefense.map((p) => <String,dynamic>{'x': p[0].toDouble(), 'y': p[1].toDouble()}).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Ataque vs Defensa (Zoomable)'),
      const Text('Pellizca para zoom', style: TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 8),
      SizedBox(height: 260, child: InteractiveViewer(
        child: Chart(data: data,
          variables: {'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 160)), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 160))},
          marks: [PointMark(color: ColorEncode(value: const Color(0xFF2196F3).withOpacity(0.6)), size: SizeEncode(value: 5))],
          axes: [Defaults.horizontalAxis, Defaults.verticalAxis]))),
    ]);
  }
}

// A11 – Stacked bar horizontal
class GrA11 extends StatelessWidget {
  const GrA11({super.key});
  @override
  Widget build(BuildContext context) {
    final pokes = ['Venusaur','Charizard','Blastoise'];
    final data = <Map<String,dynamic>>[];
    for (final p in pokes) {
      final s = PokemonChartData.statsOf(p);
      for (int i = 0; i < 6; i++) data.add({'poke': p, 'stat': PokemonChartData.statNames[i], 'val': s[i]});
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Starters Finales: Stats Apilados'),
      SizedBox(height: 250, child: Chart(data: data,
        coord: RectCoord(transposed: true),
        variables: {'poke': Variable(accessor: (Map m) => m['poke'] as String), 'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 500)), 'stat': Variable(accessor: (Map m) => m['stat'] as String)},
        marks: [IntervalMark(
          position: Varset('poke') * Varset('val') / Varset('stat'),
          modifiers: [StackModifier()],
          color: ColorEncode(variable: 'stat', values: PokemonChartData.statColors),
        )],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A12 – Stacked bar vertical
class GrA12 extends StatelessWidget {
  const GrA12({super.key});
  @override
  Widget build(BuildContext context) {
    final pokes = ['Bulbasaur','Charmander','Squirtle','Pikachu'];
    final data = <Map<String,dynamic>>[];
    for (final p in pokes) {
      final s = PokemonChartData.statsOf(p);
      for (int i = 0; i < 6; i++) data.add({'poke': p, 'stat': PokemonChartData.statNames[i], 'val': s[i]});
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Starters + Pikachu: Stats'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {'poke': Variable(accessor: (Map m) => m['poke'] as String), 'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 500)), 'stat': Variable(accessor: (Map m) => m['stat'] as String)},
        marks: [IntervalMark(
          position: Varset('poke') * Varset('val') / Varset('stat'),
          modifiers: [StackModifier()],
          color: ColorEncode(variable: 'stat', values: PokemonChartData.statColors),
        )],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A13 – Multi-line evolution comparison
class GrA13 extends StatelessWidget {
  const GrA13({super.key});
  @override
  Widget build(BuildContext context) {
    final stages = ['Base','Etapa 1','Etapa 2'];
    final lines = [
      {'names': ['Bulbasaur','Ivysaur','Venusaur'], 'stat': [65,80,100], 'color': const Color(0xFF78C850), 'label': 'Bulba'},
      {'names': ['Charmander','Charmeleon','Charizard'], 'stat': [43,58,78], 'color': const Color(0xFFF08030), 'label': 'Char'},
      {'names': ['Squirtle','Wartortle','Blastoise'], 'stat': [44,59,79], 'color': const Color(0xFF6890F0), 'label': 'Squirt'},
    ];
    final data = <Map<String,dynamic>>[];
    for (final l in lines) {
      final vals = l['stat'] as List;
      for (int i = 0; i < 3; i++) data.add({'stage': stages[i], 'val': vals[i], 'line': l['label']});
    }
    final colors = lines.map((l) => l['color'] as Color).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Evolución HP Multi-línea'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {'stage': Variable(accessor: (Map m) => m['stage'] as String), 'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 110)), 'line': Variable(accessor: (Map m) => m['line'] as String)},
        marks: [LineMark(position: Varset('stage') * Varset('val'), color: ColorEncode(variable: 'line', values: colors)), PointMark(position: Varset('stage') * Varset('val'), color: ColorEncode(variable: 'line', values: colors), size: SizeEncode(value: 5))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A14 – Multi-line with area shading
class GrA14 extends StatelessWidget {
  const GrA14({super.key});
  @override
  Widget build(BuildContext context) {
    final names = ['Bulbasaur','Charmander','Squirtle','Pikachu'];
    final vals = [45,39,44,35];
    final evolves = [80,78,79,75];
    final data = <Map<String,dynamic>>[];
    for (int i = 0; i < names.length; i++) {
      data.add({'x': names[i], 'y': vals[i].toDouble(), 'tipo': 'Base'});
      data.add({'x': names[i], 'y': evolves[i].toDouble(), 'tipo': 'Evolución'});
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Progresión HP Base → Evolución'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {'x': Variable(accessor: (Map m) => m['x'] as String), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 100)), 'tipo': Variable(accessor: (Map m) => m['tipo'] as String)},
        marks: [
          AreaMark(position: Varset('x') * Varset('y'), color: ColorEncode(variable: 'tipo', values: [const Color(0xFF4CAF50).withOpacity(0.2), const Color(0xFFFF9800).withOpacity(0.2)])),
          LineMark(position: Varset('x') * Varset('y'), color: ColorEncode(variable: 'tipo', values: [const Color(0xFF4CAF50), const Color(0xFFFF9800)])),
        ],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A15 – Scatter with color encode by type
class GrA15 extends StatelessWidget {
  const GrA15({super.key});
  @override
  Widget build(BuildContext context) {
    final fire = PokemonChartData.fireTypes;
    final water = PokemonChartData.waterTypes;
    final grass = PokemonChartData.grassTypes;
    final data = <Map<String,dynamic>>[];
    for (final p in fire) { final s = PokemonChartData.statsOf(p); data.add({'x': s[1].toDouble(), 'y': s[5].toDouble(), 'tipo': 'Fuego'}); }
    for (final p in water) { final s = PokemonChartData.statsOf(p); data.add({'x': s[1].toDouble(), 'y': s[5].toDouble(), 'tipo': 'Agua'}); }
    for (final p in grass) { final s = PokemonChartData.statsOf(p); data.add({'x': s[1].toDouble(), 'y': s[5].toDouble(), 'tipo': 'Planta'}); }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Ataque vs Velocidad por Tipo'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 110)), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 120)), 'tipo': Variable(accessor: (Map m) => m['tipo'] as String)},
        marks: [PointMark(color: ColorEncode(variable: 'tipo', values: [const Color(0xFFF08030), const Color(0xFF6890F0), const Color(0xFF78C850)]), size: SizeEncode(value: 7))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A16 – Scatter with regression line
class GrA16 extends StatelessWidget {
  const GrA16({super.key});
  @override
  Widget build(BuildContext context) {
    final pts = PokemonChartData.attackVsDefense;
    final n = pts.length;
    final sx = pts.fold(0.0, (s, p) => s + p[0]);
    final sy = pts.fold(0.0, (s, p) => s + p[1]);
    final sxx = pts.fold(0.0, (s, p) => s + p[0] * p[0]);
    final sxy = pts.fold(0.0, (s, p) => s + p[0] * p[1]);
    final m = (n * sxy - sx * sy) / (n * sxx - sx * sx);
    final b = (sy - m * sx) / n;
    final data = pts.map((p) => <String,dynamic>{'x': p[0].toDouble(), 'y': p[1].toDouble()}).toList();
    final minX = pts.map((p) => p[0]).reduce(min).toDouble();
    final maxX = pts.map((p) => p[0]).reduce(max).toDouble();
    final regData = [{'x': minX, 'y': m * minX + b}, {'x': maxX, 'y': m * maxX + b}];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Ataque vs Def + Regresión'),
      Stack(children: [
        SizedBox(height: 250, child: Chart(data: data,
          variables: {'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 160)), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 160))},
          marks: [PointMark(color: ColorEncode(value: const Color(0xFF2196F3).withOpacity(0.5)), size: SizeEncode(value: 5))],
          axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
        Positioned.fill(child: Chart(data: regData,
          variables: {'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 160)), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 160))},
          marks: [LineMark(color: ColorEncode(value: Colors.red))])),
      ]),
    ]);
  }
}

// A17 – Bubble animated
class GrA17 extends StatefulWidget {
  const GrA17({super.key});
  @override
  State<GrA17> createState() => _GrA17State();
}
class _GrA17State extends State<GrA17> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward(); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final raw = PokemonChartData.bubbleHpAtk;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Bubble HP vs Ataque (Animado)'),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) {
        final data = raw.map((p) => <String,dynamic>{'x': p[0].toDouble(), 'y': (p[1] * _ctrl.value).toDouble(), 'sz': p[2].toDouble()}).toList();
        return SizedBox(height: 250, child: Chart(data: data,
          variables: {'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 170)), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 160)), 'sz': Variable(accessor: (Map m) => m['sz'] as num, scale: LinearScale(min: 20, max: 110))},
          marks: [PointMark(color: ColorEncode(value: const Color(0xFFE91E63).withOpacity(0.5)), size: SizeEncode(variable: 'sz', values: [4, 20]))],
          axes: [Defaults.horizontalAxis, Defaults.verticalAxis]));
      }),
    ]);
  }
}

// A18 – Heatmap interactivo
class GrA18 extends StatefulWidget {
  const GrA18({super.key});
  @override
  State<GrA18> createState() => _GrA18State();
}
class _GrA18State extends State<GrA18> {
  int? _hovRow;
  int? _hovCol;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Heatmap Stats Interactivo'),
      if (_hovRow != null && _hovCol != null)
        Text('${PokemonChartData.heatmapTypes[_hovRow!]} — ${PokemonChartData.statNames[_hovCol!]}: ${PokemonChartData.heatmapAvg[_hovRow!][_hovCol!].toStringAsFixed(1)}',
          style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Row(children: [const SizedBox(width: 62), ...PokemonChartData.statNames.map((s) => Expanded(child: Center(child: Text(s, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)))))]),
      const SizedBox(height: 4),
      ...List.generate(PokemonChartData.heatmapTypes.length, (row) => Row(children: [
        SizedBox(width: 62, child: Text(PokemonChartData.heatmapTypes[row], style: const TextStyle(fontSize: 9))),
        ...List.generate(6, (col) {
          final val = PokemonChartData.heatmapAvg[row][col];
          final norm = ((val - 60) / 50).clamp(0.0, 1.0);
          final isHov = row == _hovRow && col == _hovCol;
          return Expanded(child: GestureDetector(
            onTap: () => setState(() { _hovRow = row; _hovCol = col; }),
            child: Container(height: 32, margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(color: Color.lerp(Colors.yellow.shade100, Colors.red.shade800, norm), border: isHov ? Border.all(color: Colors.black, width: 2) : null),
              child: Center(child: Text(val.toStringAsFixed(0), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))))));
        }),
      ])),
    ]);
  }
}

// A19 – Comparative radar 3 pokes
class GrA19 extends StatefulWidget {
  const GrA19({super.key});
  @override
  State<GrA19> createState() => _GrA19State();
}
class _GrA19State extends State<GrA19> {
  String _p1 = 'Gengar', _p2 = 'Alakazam', _p3 = 'Machamp';
  static const _opts = ['Bulbasaur','Charmander','Squirtle','Pikachu','Gengar','Mewtwo','Dragonite','Snorlax','Alakazam','Machamp','Lapras'];
  @override
  Widget build(BuildContext context) {
    final d1 = PokemonChartData.statsOf(_p1).map((v) => v / 160.0).toList();
    final d2 = PokemonChartData.statsOf(_p2).map((v) => v / 160.0).toList();
    final d3 = PokemonChartData.statsOf(_p3).map((v) => v / 160.0).toList();
    Widget dd(String v, void Function(String) on) => DropdownButton<String>(value: v, onChanged: (x) => on(x!), isDense: true, items: _opts.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 11)))).toList());
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Radar 3 Pokémon'),
      Row(children: [dd(_p1, (v) => setState(() => _p1 = v)), const SizedBox(width: 8), dd(_p2, (v) => setState(() => _p2 = v)), const SizedBox(width: 8), dd(_p3, (v) => setState(() => _p3 = v))]),
      const SizedBox(height: 8),
      SizedBox(height: 260, child: CustomPaint(size: const Size(double.infinity, 260),
        painter: _RadarPainter(labels: PokemonChartData.statNames, colors: [const Color(0xFF212121), const Color(0xFFF44336), const Color(0xFF2196F3)], datasets: [d1, d2, d3]))),
    ]);
  }
}

// A20 – Bar sorted by stat
class GrA20 extends StatefulWidget {
  const GrA20({super.key});
  @override
  State<GrA20> createState() => _GrA20State();
}
class _GrA20State extends State<GrA20> {
  int _statIdx = 0;
  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(_statIdx, n: 10);
    final data = top.map((e) => <String,dynamic>{'name': e.key, 'val': e.value}).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top 10 por Stat'),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: List.generate(6, (i) => Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text(PokemonChartData.statNames[i], style: const TextStyle(fontSize: 11)), selected: _statIdx == i, onSelected: (_) => setState(() => _statIdx = i)))))),
      const SizedBox(height: 8),
      SizedBox(height: 230, child: Chart(data: data,
        coord: RectCoord(transposed: true),
        variables: {'name': Variable(accessor: (Map m) => m['name'] as String), 'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 180))},
        marks: [IntervalMark(color: ColorEncode(value: PokemonChartData.statColors[_statIdx]))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A21 – Line smooth
class GrA21 extends StatelessWidget {
  const GrA21({super.key});
  @override
  Widget build(BuildContext context) {
    final data = <Map<String,dynamic>>[];
    final hp = PokemonChartData.first20HP;
    final spd = PokemonChartData.first20Spd;
    for (int i = 0; i < min(hp.length, spd.length); i++) {
      data.add({'x': '${i+1}', 'y': hp[i].toDouble(), 'serie': 'HP'});
      data.add({'x': '${i+1}', 'y': spd[i].toDouble(), 'serie': 'Velocidad'});
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP vs Velocidad (doble línea)'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {'x': Variable(accessor: (Map m) => m['x'] as String), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 135)), 'serie': Variable(accessor: (Map m) => m['serie'] as String)},
        marks: [LineMark(position: Varset('x') * Varset('y'), color: ColorEncode(variable: 'serie', values: [const Color(0xFF4CAF50), const Color(0xFFFF9800)])), PointMark(position: Varset('x') * Varset('y'), color: ColorEncode(variable: 'serie', values: [const Color(0xFF4CAF50), const Color(0xFFFF9800)]), size: SizeEncode(value: 4))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A22 – Polar bar (rose)
class GrA22 extends StatelessWidget {
  const GrA22({super.key});
  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf('Mew');
    final data = List<Map<String,dynamic>>.generate(6, (i) => {'stat': PokemonChartData.statNames[i], 'val': s[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Mew: Rosa de Vientos'),
      SizedBox(height: 280, child: Chart(data: data,
        coord: PolarCoord(dimCount: 2),
        variables: {'stat': Variable(accessor: (Map m) => m['stat'] as String), 'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 140))},
        marks: [IntervalMark(color: ColorEncode(variable: 'stat', values: PokemonChartData.statColors))])),
    ]);
  }
}

// A23 – Polar rose Charizard
class GrA23 extends StatelessWidget {
  const GrA23({super.key});
  @override
  Widget build(BuildContext context) {
    final s = PokemonChartData.statsOf('Charizard');
    final data = List<Map<String,dynamic>>.generate(6, (i) => {'stat': PokemonChartData.statNames[i], 'val': s[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Charizard: Rosa Polar'),
      SizedBox(height: 280, child: Chart(data: data,
        coord: PolarCoord(dimCount: 2),
        variables: {'stat': Variable(accessor: (Map m) => m['stat'] as String), 'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 140))},
        marks: [IntervalMark(color: ColorEncode(variable: 'stat', values: PokemonChartData.statColors))])),
    ]);
  }
}

// A24 – Scatter with color types animated
class GrA24 extends StatefulWidget {
  const GrA24({super.key});
  @override
  State<GrA24> createState() => _GrA24State();
}
class _GrA24State extends State<GrA24> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward(); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final fire = PokemonChartData.fireTypes;
    final water = PokemonChartData.waterTypes;
    final all = [...fire.map((p) => [p, 'Fuego']), ...water.map((p) => [p, 'Agua'])];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Scatter Fuego vs Agua (Animado)'),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) {
        final data = all.map((a) { final s = PokemonChartData.statsOf(a[0]); return <String,dynamic>{'x': s[1].toDouble(), 'y': (s[5] * _ctrl.value).toDouble(), 'tipo': a[1]}; }).toList();
        return SizedBox(height: 250, child: Chart(data: data,
          variables: {'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 110)), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 130)), 'tipo': Variable(accessor: (Map m) => m['tipo'] as String)},
          marks: [PointMark(color: ColorEncode(variable: 'tipo', values: [const Color(0xFFF08030), const Color(0xFF6890F0)]), size: SizeEncode(value: 7))],
          axes: [Defaults.horizontalAxis, Defaults.verticalAxis]));
      }),
    ]);
  }
}

// A25 – Legend with colored chips + chart
class GrA25 extends StatelessWidget {
  const GrA25({super.key});
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.topTypes.entries.map((e) => <String,dynamic>{'tipo': e.key, 'count': e.value}).toList();
    final colorList = data.map((d) => PokemonChartData.typeColors[d['tipo']] ?? Colors.grey).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Tipos + Leyenda'),
      Wrap(spacing: 6, runSpacing: 4, children: List.generate(data.length, (i) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: colorList[i], shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text('${data[i]['tipo']} (${data[i]['count']})', style: const TextStyle(fontSize: 10)),
      ]))),
      const SizedBox(height: 8),
      SizedBox(height: 200, child: Chart(data: data,
        coord: PolarCoord(transposed: true, dimCount: 1),
        variables: {'tipo': Variable(accessor: (Map m) => m['tipo'] as String), 'count': Variable(accessor: (Map m) => m['count'] as num, scale: LinearScale(min: 0))},
        marks: [IntervalMark(position: Varset('count'), color: ColorEncode(variable: 'tipo', values: colorList))])),
    ]);
  }
}

// A26 – Dual axis bar+line
class GrA26 extends StatelessWidget {
  const GrA26({super.key});
  @override
  Widget build(BuildContext context) {
    final hpData = List<Map<String,dynamic>>.generate(10, (i) => {'x': '${i+1}', 'y': PokemonChartData.first20HP[i]});
    final spdData = List<Map<String,dynamic>>.generate(10, (i) => {'x': '${i+1}', 'y': PokemonChartData.first20Spd[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP (barras) + Velocidad (línea)'),
      SizedBox(height: 125, child: Chart(data: hpData,
        variables: {'x': Variable(accessor: (Map m) => m['x'] as String), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 130))},
        marks: [IntervalMark(color: ColorEncode(value: const Color(0xFF4CAF50).withOpacity(0.8)))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
      const SizedBox(height: 8),
      SizedBox(height: 115, child: Chart(data: spdData,
        variables: {'x': Variable(accessor: (Map m) => m['x'] as String), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 110))},
        marks: [LineMark(color: ColorEncode(value: const Color(0xFFFF9800))), PointMark(color: ColorEncode(value: const Color(0xFFFF9800)), size: SizeEncode(value: 4))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A27 – Min/Max range bar
class GrA27 extends StatelessWidget {
  const GrA27({super.key});
  @override
  Widget build(BuildContext context) {
    final types = PokemonChartData.heatmapTypes.take(6).toList();
    final avgs = PokemonChartData.heatmapAvg.take(6).toList();
    final data = List<Map<String,dynamic>>.generate(6, (i) => {
      'tipo': types[i],
      'min': avgs[i].reduce(min),
      'max': avgs[i].reduce(max),
      'avg': avgs[i].fold(0.0, (s, v) => s + v) / avgs[i].length,
    });
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Rango Stats por Tipo'),
      SizedBox(height: 250, child: Chart(data: data,
        coord: RectCoord(transposed: true),
        variables: {'tipo': Variable(accessor: (Map m) => m['tipo'] as String), 'avg': Variable(accessor: (Map m) => m['avg'] as num, scale: LinearScale(min: 40, max: 140))},
        marks: [IntervalMark(color: ColorEncode(value: const Color(0xFF2196F3).withOpacity(0.7)))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A28 – Animated radar compare
class GrA28 extends StatefulWidget {
  const GrA28({super.key});
  @override
  State<GrA28> createState() => _GrA28State();
}
class _GrA28State extends State<GrA28> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  String _p1 = 'Snorlax', _p2 = 'Jolteon';
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward(); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final d1 = PokemonChartData.statsOf(_p1).map((v) => v / 160.0).toList();
    final d2 = PokemonChartData.statsOf(_p2).map((v) => v / 160.0).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Radar vs (Animado)'),
      Row(children: [
        Expanded(child: DropdownButton<String>(value: _p1, isExpanded: true, onChanged: (v) { setState(() { _p1 = v!; _ctrl.reset(); _ctrl.forward(); }); }, items: ['Snorlax','Dragonite','Lapras','Mewtwo','Mew','Gengar'].map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 11)))).toList())),
        const SizedBox(width: 8),
        Expanded(child: DropdownButton<String>(value: _p2, isExpanded: true, onChanged: (v) { setState(() { _p2 = v!; _ctrl.reset(); _ctrl.forward(); }); }, items: ['Jolteon','Vaporeon','Flareon','Pikachu','Charizard','Blastoise'].map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 11)))).toList())),
      ]),
      const SizedBox(height: 8),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) => SizedBox(height: 260,
        child: CustomPaint(size: const Size(double.infinity, 260),
          painter: _RadarPainter(labels: PokemonChartData.statNames, colors: [const Color(0xFFF44336), const Color(0xFF2196F3)], datasets: [d1, d2], animProgress: _ctrl.value)))),
    ]);
  }
}

// A29 – HP scatter + size = total
class GrA29 extends StatelessWidget {
  const GrA29({super.key});
  @override
  Widget build(BuildContext context) {
    const pokes = ['Bulbasaur','Charizard','Blastoise','Pikachu','Gengar','Mewtwo','Dragonite','Snorlax','Lapras','Mew','Jolteon','Vaporeon'];
    final data = pokes.map((p) { final s = PokemonChartData.statsOf(p); return <String,dynamic>{'x': s[0].toDouble(), 'y': s[2].toDouble(), 'sz': PokemonChartData.totalOf(p).toDouble()}; }).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP vs Def (tamaño = Total)'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 170)), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 110)), 'sz': Variable(accessor: (Map m) => m['sz'] as num, scale: LinearScale(min: 190, max: 680))},
        marks: [PointMark(color: ColorEncode(value: const Color(0xFF9C27B0).withOpacity(0.5)), size: SizeEncode(variable: 'sz', values: [4, 22]))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A30 – Heatmap correlation animated
class GrA30 extends StatefulWidget {
  const GrA30({super.key});
  @override
  State<GrA30> createState() => _GrA30State();
}
class _GrA30State extends State<GrA30> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward(); }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Correlación (Animada)'),
      Row(children: [const SizedBox(width: 4), ...PokemonChartData.statNames.map((s) => Expanded(child: Center(child: Text(s, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))))]),
      const SizedBox(height: 4),
      AnimatedBuilder(animation: _ctrl, builder: (_, __) => SizedBox(height: 210, child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 36,
        itemBuilder: (ctx, index) {
          final row = index ~/ 6; final col = index % 6;
          final val = PokemonChartData.correlationMatrix[row][col] * _ctrl.value;
          return Container(margin: const EdgeInsets.all(1), color: Color.lerp(Colors.blue.shade50, Colors.indigo.shade800, val),
            child: Center(child: Text(val.toStringAsFixed(2), style: const TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.w600))));
        },
      ))),
    ]);
  }
}

// A31 – Bar with value labels
class GrA31 extends StatelessWidget {
  const GrA31({super.key});
  @override
  Widget build(BuildContext context) {
    final top = PokemonChartData.topByStatIndex(3, n: 8);
    final data = top.map((e) => <String,dynamic>{'name': e.key, 'val': e.value}).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Top Sp.Atk con Etiquetas'),
      SizedBox(height: 250, child: Chart(data: data,
        coord: RectCoord(transposed: true),
        variables: {'name': Variable(accessor: (Map m) => m['name'] as String), 'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 180))},
        marks: [IntervalMark(
          color: ColorEncode(value: const Color(0xFF9C27B0).withOpacity(0.8)),
          label: LabelEncode(encoder: (tuple) => Label(tuple['val'].toString(), LabelStyle(textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)))),
        )],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A32 – Paged pokemon stat view
class GrA32 extends StatefulWidget {
  const GrA32({super.key});
  @override
  State<GrA32> createState() => _GrA32State();
}
class _GrA32State extends State<GrA32> {
  int _page = 0;
  static const _allPokes = ['Bulbasaur','Ivysaur','Venusaur','Charmander','Charmeleon','Charizard','Squirtle','Wartortle','Blastoise','Pikachu','Raichu','Gengar','Mewtwo','Mew','Snorlax','Dragonite','Lapras','Jolteon','Vaporeon','Flareon'];
  @override
  Widget build(BuildContext context) {
    final start = _page * 5;
    final pokes = _allPokes.skip(start).take(5).toList();
    final data = <Map<String,dynamic>>[];
    for (final p in pokes) {
      final s = PokemonChartData.statsOf(p);
      data.add({'name': p, 'total': s.fold(0, (a, b) => a + b).toDouble()});
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Totales (página ${_page+1})'),
      SizedBox(height: 230, child: Chart(data: data,
        coord: RectCoord(transposed: true),
        variables: {'name': Variable(accessor: (Map m) => m['name'] as String), 'total': Variable(accessor: (Map m) => m['total'] as num, scale: LinearScale(min: 0, max: 700))},
        marks: [IntervalMark(color: ColorEncode(value: const Color(0xFF1565C0).withOpacity(0.8)),
          label: LabelEncode(encoder: (t) => Label(t['total'].toString(), LabelStyle(textStyle: const TextStyle(fontSize: 10, color: Colors.white)))))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: _page > 0 ? () => setState(() => _page--) : null),
        Text('${_page+1} / ${(_allPokes.length / 5).ceil()}'),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: start + 5 < _allPokes.length ? () => setState(() => _page++) : null),
      ]),
    ]);
  }
}

// A33 – Live timer scatter
class GrA33 extends StatefulWidget {
  const GrA33({super.key});
  @override
  State<GrA33> createState() => _GrA33State();
}
class _GrA33State extends State<GrA33> {
  Timer? _t;
  int _n = 5;
  @override
  void initState() { super.initState(); _t = Timer.periodic(const Duration(seconds: 2), (_) { if (mounted) setState(() => _n = _n < 20 ? _n + 1 : 5); }); }
  @override
  void dispose() { _t?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final data = PokemonChartData.attackVsDefense.take(_n).map((p) => <String,dynamic>{'x': p[0].toDouble(), 'y': p[1].toDouble()}).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Scatter Creciente (n=$_n)'),
      const Text('• Auto-actualiza cada 2s', style: TextStyle(fontSize: 11, color: Colors.green)),
      const SizedBox(height: 8),
      SizedBox(height: 240, child: Chart(data: data,
        variables: {'x': Variable(accessor: (Map m) => m['x'] as num, scale: LinearScale(min: 0, max: 160)), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 160))},
        marks: [PointMark(color: ColorEncode(value: const Color(0xFF009688).withOpacity(0.6)), size: SizeEncode(value: 6))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A34 – Dashboard 4-panel
class GrA34 extends StatelessWidget {
  const GrA34({super.key});
  @override
  Widget build(BuildContext context) {
    final pikaStats = PokemonChartData.statsOf('Pikachu');
    final pieData = PokemonChartData.topTypes.entries.take(5).map((e) => <String,dynamic>{'tipo': e.key, 'count': e.value}).toList();
    final pieColors = pieData.map((d) => PokemonChartData.typeColors[d['tipo']] ?? Colors.grey).toList();
    final lineData = List<Map<String,dynamic>>.generate(10, (i) => {'x': '${i+1}', 'y': PokemonChartData.first20HP[i]});
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Dashboard Pokémon'),
      const Text('Pikachu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      const SizedBox(height: 8),
      Row(children: List.generate(6, (i) => Expanded(child: Column(children: [
        Text(PokemonChartData.statNames[i], style: const TextStyle(fontSize: 9, color: Colors.grey)),
        Text('${pikaStats[i]}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: PokemonChartData.statColors[i])),
      ])))),
      const SizedBox(height: 12),
      SizedBox(height: 120, child: Chart(data: pieData,
        coord: PolarCoord(transposed: true, dimCount: 1),
        variables: {'tipo': Variable(accessor: (Map m) => m['tipo'] as String), 'count': Variable(accessor: (Map m) => m['count'] as num, scale: LinearScale(min: 0))},
        marks: [IntervalMark(position: Varset('count'), color: ColorEncode(variable: 'tipo', values: pieColors))])),
      const SizedBox(height: 8),
      SizedBox(height: 110, child: Chart(data: lineData,
        variables: {'x': Variable(accessor: (Map m) => m['x'] as String), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 130))},
        marks: [LineMark(color: ColorEncode(value: Colors.green)), PointMark(color: ColorEncode(value: Colors.green), size: SizeEncode(value: 4))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A35 – Area overlay multiple
class GrA35 extends StatelessWidget {
  const GrA35({super.key});
  @override
  Widget build(BuildContext context) {
    final n = min(PokemonChartData.first20HP.length, PokemonChartData.first20Def.length);
    final data = <Map<String,dynamic>>[];
    for (int i = 0; i < n; i++) {
      data.add({'x': '${i+1}', 'y': PokemonChartData.first20HP[i].toDouble(), 'serie': 'HP'});
      data.add({'x': '${i+1}', 'y': PokemonChartData.first20Def[i].toDouble(), 'serie': 'Def'});
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('HP vs Defensa: Área Solapada'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {'x': Variable(accessor: (Map m) => m['x'] as String), 'y': Variable(accessor: (Map m) => m['y'] as num, scale: LinearScale(min: 0, max: 135)), 'serie': Variable(accessor: (Map m) => m['serie'] as String)},
        marks: [AreaMark(position: Varset('x') * Varset('y'), color: ColorEncode(variable: 'serie', values: [const Color(0xFF4CAF50).withOpacity(0.3), const Color(0xFF2196F3).withOpacity(0.3)]))],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}

// A36 – Full stats timeline
class GrA36 extends StatelessWidget {
  const GrA36({super.key});
  @override
  Widget build(BuildContext context) {
    const evos = ['Charmander','Charmeleon','Charizard'];
    final colors = [const Color(0xFFFFCC02), const Color(0xFFF08030), const Color(0xFFFF4444)];
    final data = <Map<String,dynamic>>[];
    for (int e = 0; e < 3; e++) {
      final s = PokemonChartData.statsOf(evos[e]);
      for (int i = 0; i < 6; i++) data.add({'stage': evos[e], 'stat': PokemonChartData.statNames[i], 'val': s[i], 'evo': evos[e]});
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chartTitle('Charmander: Evolución Completa'),
      SizedBox(height: 250, child: Chart(data: data,
        variables: {
          'stage': Variable(accessor: (Map m) => m['stage'] as String),
          'val': Variable(accessor: (Map m) => m['val'] as num, scale: LinearScale(min: 0, max: 500)),
          'stat': Variable(accessor: (Map m) => m['stat'] as String),
        },
        marks: [IntervalMark(
          position: Varset('stage') * Varset('val') / Varset('stat'),
          modifiers: [StackModifier()],
          color: ColorEncode(variable: 'stat', values: PokemonChartData.statColors),
        )],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis])),
    ]);
  }
}
