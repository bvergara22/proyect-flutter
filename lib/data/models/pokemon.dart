class PokemonStat {
  final String name;
  final int value;
  const PokemonStat({required this.name, required this.value});
}

class PokemonAbility {
  final String name;
  final bool isHidden;
  const PokemonAbility({required this.name, required this.isHidden});
}

class PokemonMove {
  final String name;
  const PokemonMove({required this.name});
}

class Pokemon {
  final int id;
  final String name;
  final int height;
  final int weight;
  final int baseExperience;
  final String imageUrl;
  final List<String> types;
  final List<PokemonStat> stats;
  final List<PokemonAbility> abilities;
  final List<PokemonMove> moves;
  final int speciesId;

  const Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.baseExperience,
    required this.imageUrl,
    required this.types,
    required this.stats,
    required this.abilities,
    required this.moves,
    required this.speciesId,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>;
    final other = sprites['other'] as Map<String, dynamic>?;
    final artwork = other?['official-artwork'] as Map<String, dynamic>?;
    final imageUrl = artwork?['front_default'] as String? ??
        sprites['front_default'] as String? ?? '';

    final speciesUrl =
        (json['species'] as Map<String, dynamic>)['url'] as String;
    final parts = speciesUrl.split('/');
    final speciesId = int.parse(parts[parts.length - 2]);

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      baseExperience: (json['base_experience'] ?? 0) as int,
      imageUrl: imageUrl,
      speciesId: speciesId,
      types: (json['types'] as List)
          .map((t) => (t as Map)['type']['name'] as String)
          .toList(),
      stats: (json['stats'] as List)
          .map((s) => PokemonStat(
                name: (s as Map)['stat']['name'] as String,
                value: s['base_stat'] as int,
              ))
          .toList(),
      abilities: (json['abilities'] as List)
          .map((a) => PokemonAbility(
                name: (a as Map)['ability']['name'] as String,
                isHidden: a['is_hidden'] as bool,
              ))
          .toList(),
      moves: (json['moves'] as List)
          .take(20)
          .map((m) => PokemonMove(name: (m as Map)['move']['name'] as String))
          .toList(),
    );
  }
}
