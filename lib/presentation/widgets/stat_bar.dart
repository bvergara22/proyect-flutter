import 'package:flutter/material.dart';
import '../../data/models/pokemon.dart';

class StatBar extends StatelessWidget {
  final PokemonStat stat;

  const StatBar({super.key, required this.stat});

  static const _labels = <String, String>{
    'hp': 'HP',
    'attack': 'Ataque',
    'defense': 'Defensa',
    'special-attack': 'Sp. Atq.',
    'special-defense': 'Sp. Def.',
    'speed': 'Velocidad',
  };

  Color _barColor() {
    if (stat.value >= 100) return Colors.green;
    if (stat.value >= 60) return Colors.lightGreen;
    if (stat.value >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              _labels[stat.name] ?? stat.name,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${stat.value}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: stat.value / 255,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(_barColor()),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
