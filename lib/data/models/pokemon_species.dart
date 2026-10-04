class PokemonSpecies {
  final String flavorText;
  final String habitat;
  final String generation;
  final String evolutionChainUrl;

  const PokemonSpecies({
    required this.flavorText,
    required this.habitat,
    required this.generation,
    required this.evolutionChainUrl,
  });

  factory PokemonSpecies.fromJson(Map<String, dynamic> json) {
    final entries = json['flavor_text_entries'] as List;
    final en = entries.cast<Map<String, dynamic>>().firstWhere(
          (e) => e['language']['name'] == 'en',
          orElse: () => entries.first as Map<String, dynamic>,
        );
    final flavorText = (en['flavor_text'] as String)
        .replaceAll('\n', ' ')
        .replaceAll('\f', ' ');

    return PokemonSpecies(
      flavorText: flavorText,
      habitat:
          (json['habitat'] as Map<String, dynamic>?)?['name'] as String? ??
              'unknown',
      generation:
          (json['generation'] as Map<String, dynamic>)['name'] as String,
      evolutionChainUrl:
          (json['evolution_chain'] as Map<String, dynamic>)['url'] as String,
    );
  }
}
