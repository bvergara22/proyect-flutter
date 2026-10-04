import 'package:flutter/material.dart';

class PokemonChartData {
  static const Map<String, List<int>> _stats = {
    'Bulbasaur':  [45, 49, 49,  65,  65,  45],
    'Ivysaur':    [60, 62, 63,  80,  80,  60],
    'Venusaur':   [80, 82, 83, 100, 100,  80],
    'Charmander': [39, 52, 43,  60,  50,  65],
    'Charmeleon': [58, 64, 58,  80,  65,  80],
    'Charizard':  [78, 84, 78, 109,  85, 100],
    'Squirtle':   [44, 48, 65,  50,  64,  43],
    'Wartortle':  [59, 63, 80,  65,  80,  58],
    'Blastoise':  [79, 83,100,  85, 105,  78],
    'Caterpie':   [45, 30, 35,  20,  20,  45],
    'Butterfree': [60, 45, 50,  90,  80,  70],
    'Pikachu':    [35, 55, 40,  50,  50,  90],
    'Raichu':     [60, 90, 55,  90,  80, 110],
    'Jigglypuff': [115,45, 20,  45,  25,  20],
    'Wigglytuff': [140,70, 45,  85,  50,  45],
    'Meowth':     [40, 45, 35,  40,  40,  90],
    'Persian':    [65, 70, 60,  65,  65, 115],
    'Gengar':     [60, 65, 60, 130,  75, 110],
    'Gyarados':   [95,125, 79,  60, 100,  81],
    'Lapras':     [130,85, 80,  85,  95,  60],
    'Eevee':      [55, 55, 50,  45,  65,  55],
    'Vaporeon':   [130,65, 60, 110,  95,  65],
    'Jolteon':    [65, 65, 60, 110,  95, 130],
    'Flareon':    [65,130, 60,  95, 110,  65],
    'Snorlax':    [160,110,65,  65, 110,  30],
    'Articuno':   [90, 85,100,  95, 125,  85],
    'Zapdos':     [90, 90, 85, 125,  90, 100],
    'Moltres':    [90,100, 90, 125,  85,  90],
    'Dratini':    [41, 64, 45,  50,  50,  50],
    'Dragonair':  [61, 84, 65,  70,  70,  70],
    'Dragonite':  [91,134, 95, 100, 100,  80],
    'Mewtwo':     [106,110,90, 154,  90, 130],
    'Mew':        [100,100,100,100, 100, 100],
  };

  static const List<String> statNames = ['HP', 'Atk', 'Def', 'SpA', 'SpD', 'Spe'];

  static const List<Color> statColors = [
    Color(0xFF4CAF50),
    Color(0xFFF44336),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFF9800),
  ];

  static List<int> statsOf(String name) => _stats[name] ?? [0, 0, 0, 0, 0, 0];
  static int totalOf(String name) => statsOf(name).fold(0, (a, b) => a + b);

  static List<MapEntry<String, int>> topByStatIndex(int idx, {int n = 5}) {
    final entries = _stats.entries.map((e) => MapEntry(e.key, e.value[idx])).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(n).toList();
  }

  static List<double> avgStatsOf(List<String> names) {
    final result = List.filled(6, 0.0);
    for (final n in names) {
      final s = statsOf(n);
      for (int i = 0; i < 6; i++) result[i] += s[i];
    }
    return result.map((v) => v / names.length).toList();
  }

  static const List<String> fireTypes    = ['Charmander','Charmeleon','Charizard','Flareon','Moltres'];
  static const List<String> waterTypes   = ['Squirtle','Wartortle','Blastoise','Vaporeon','Gyarados','Lapras'];
  static const List<String> grassTypes   = ['Bulbasaur','Ivysaur','Venusaur'];
  static const List<String> legendaries  = ['Articuno','Zapdos','Moltres','Mewtwo','Mew'];

  static const Map<String, int> topTypes = {
    'Agua': 28, 'Normal': 22, 'Veneno': 14, 'Psíquico': 14,
    'Fuego': 12, 'Planta': 12, 'Bicho': 12, 'Otros': 37,
  };

  static const Map<String, Color> typeColors = {
    'Normal':    Color(0xFFA8A878),
    'Agua':      Color(0xFF6890F0),
    'Fuego':     Color(0xFFF08030),
    'Planta':    Color(0xFF78C850),
    'Veneno':    Color(0xFFA040A0),
    'Psíquico':  Color(0xFFF85888),
    'Bicho':     Color(0xFFA8B820),
    'Tierra':    Color(0xFFE0C068),
    'Eléctrico': Color(0xFFF8D030),
    'Fantasma':  Color(0xFF705898),
    'Hielo':     Color(0xFF98D8D8),
    'Dragón':    Color(0xFF7038F8),
    'Lucha':     Color(0xFFC03028),
    'Roca':      Color(0xFFB8A038),
    'Volador':   Color(0xFF98A0E0),
    'Otros':     Color(0xFF68A090),
  };

  static const List<int> first20HP    = [45,60,80,39,58,78,44,59,79,45,40,60,35,60,115,40,65,55,50,80];
  static const List<int> first20Spd   = [45,60,80,65,80,100,43,58,78,45,70,70,90,110,20,45,65,55,45,80];
  static const List<int> first20Atk   = [49,62,82,52,64,84,48,63,83,30,35,45,55,90,45,35,45,55,65,82];
  static const List<int> first20Def   = [49,63,83,43,58,78,65,80,100,35,30,50,40,55,20,45,65,50,45,83];
  static const List<String> first20Names = [
    'Bulbasaur','Ivysaur','Venusaur','Charmander','Charmeleon','Charizard',
    'Squirtle','Wartortle','Blastoise','Caterpie','Metapod','Butterfree',
    'Pikachu','Raichu','Jigglypuff','Meowth','Persian','Eevee','Vaporeon','Venusaur2',
  ];

  static const List<int> hpBins    = [2,  8, 22, 38, 34, 24, 15,  7, 1];
  static const List<int> atkBins   = [0,  5, 20, 42, 38, 25, 14,  6, 1];
  static const List<int> defBins   = [0,  8, 28, 44, 36, 22, 10,  3, 0];
  static const List<int> speedBins = [3,  6, 18, 36, 42, 30, 12,  4, 0];
  static const List<String> binLabels = ['0-19','20-39','40-59','60-79','80-99','100-119','120-139','140-159','160+'];

  // [attack, defense]
  static const List<List<int>> attackVsDefense = [
    [49,49],[52,43],[48,65],[30,35],[35,30],[45,50],[55,40],[90,55],[45,20],[70,45],
    [85,100],[80,80],[83,100],[84,78],[82,83],[110,65],[90,55],[125,79],[85,80],[65,60],
    [95,100],[100,90],[90,85],[110,90],[90,85],[100,90],[134,95],[110,90],[154,90],[100,100],
    [65,35],[60,50],[45,20],[70,45],[90,45],[84,78],[50,64],[63,80],[62,63],[64,58],
  ];

  // [hp, speed]
  static const List<List<int>> hpVsSpeed = [
    [45,45],[60,60],[80,80],[39,65],[58,80],[78,100],[44,43],[59,58],[79,78],
    [35,90],[60,110],[115,20],[140,45],[40,90],[65,115],[60,65],[65,130],[65,65],
    [95,81],[130,60],[160,30],[90,85],[90,100],[90,90],[91,80],[106,130],[100,100],
    [55,55],[60,65],[65,65],[130,65],[60,110],[65,45],[41,50],[61,70],[100,80],
    [45,70],[60,70],[80,80],[40,45],
  ];

  // [spAtk, spDef]
  static const List<List<int>> spAtkVsSpDef = [
    [65,65],[80,80],[100,100],[60,50],[80,65],[109,85],[50,64],[65,80],[85,105],
    [50,50],[90,80],[45,25],[130,75],[60,100],[85,95],[65,110],[90,80],[95,125],
    [125,90],[125,85],[100,100],[154,90],[100,100],[45,65],[110,95],[95,110],[90,80],
    [90,95],[65,65],[85,65],[120,100],[95,85],[70,70],[100,100],[75,80],[95,80],
  ];

  // [x=hp, y=attack, size=defense]
  static const List<List<int>> bubbleHpAtk = [
    [45,49,49],[39,52,43],[44,48,65],[35,55,40],[60,90,55],[115,45,20],
    [95,125,79],[130,85,80],[160,110,65],[90,85,100],[91,134,95],[106,110,90],[100,100,100],
    [60,65,60],[65,65,60],[65,130,60],[80,82,83],[78,84,78],[79,83,100],[61,84,65],
  ];

  // [x=speed, y=attack, size=hp]
  static const List<List<int>> bubbleSpdAtk = [
    [45,49,45],[65,52,39],[43,48,44],[90,55,35],[110,90,60],[20,45,115],
    [81,125,95],[60,85,130],[30,110,160],[85,85,90],[80,134,91],[130,110,106],[100,100,100],
    [110,65,60],[130,65,65],[65,130,65],[80,82,80],[100,84,78],[78,83,79],[70,84,61],
  ];

  static const List<String> heatmapTypes = ['Fuego','Agua','Planta','Eléctrico','Psíquico','Normal'];
  // [HP, Atk, Def, SpA, SpD, Spe]
  static const List<List<double>> heatmapAvg = [
    [72.5, 87.0, 68.0, 92.0, 73.0, 89.0],
    [82.0, 74.0, 79.5, 73.0, 84.0, 64.5],
    [65.0, 72.0, 72.5, 82.5, 80.0, 61.0],
    [72.5, 76.5, 64.0, 94.5, 74.5, 91.5],
    [79.5, 75.0, 72.5, 97.0, 81.0, 78.5],
    [80.5, 68.5, 64.5, 60.0, 65.5, 73.0],
  ];

  static const List<List<double>> correlationMatrix = [
    [1.00, 0.12, 0.24, 0.23, 0.35, 0.10],
    [0.12, 1.00, 0.48, 0.55, 0.25, 0.32],
    [0.24, 0.48, 1.00, 0.32, 0.60, 0.22],
    [0.23, 0.55, 0.32, 1.00, 0.48, 0.38],
    [0.35, 0.25, 0.60, 0.48, 1.00, 0.20],
    [0.10, 0.32, 0.22, 0.38, 0.20, 1.00],
  ];

  static List<Map<String, dynamic>> scatterMaps(List<List<int>> pairs, String xKey, String yKey) =>
      pairs.map((p) => {xKey: p[0].toDouble(), yKey: p[1].toDouble()}).toList();

  static List<Map<String, dynamic>> bubbleMaps(List<List<int>> data) =>
      data.map((p) => {'x': p[0].toDouble(), 'y': p[1].toDouble(), 'size': p[2].toDouble()}).toList();
}
