class PokemonListItem {
  final int id;
  final String name;

  const PokemonListItem({required this.id, required this.name});

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  static int _idFromUrl(String url) {
    final parts = url.split('/');
    return int.parse(parts[parts.length - 2]);
  }

  factory PokemonListItem.fromJson(Map<String, dynamic> json) => PokemonListItem(
        id: _idFromUrl(json['url'] as String),
        name: json['name'] as String,
      );
}
