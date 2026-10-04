class EvolutionStep {
  final int id;
  final String name;
  final String? trigger;
  final int? minLevel;

  const EvolutionStep({
    required this.id,
    required this.name,
    this.trigger,
    this.minLevel,
  });

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}

class EvolutionChain {
  final List<EvolutionStep> steps;
  const EvolutionChain({required this.steps});
}
