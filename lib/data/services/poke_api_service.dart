import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_list_item.dart';
import '../models/pokemon.dart';
import '../models/pokemon_species.dart';
import '../models/evolution_chain.dart';
import '../../core/constants/api_constants.dart';

class PokeApiService {
  static final _client = http.Client();

  static Future<Map<String, dynamic>> _fetch(String url) async {
    final response = await _client
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Error HTTP ${response.statusCode}');
  }

  static Future<List<PokemonListItem>> fetchList({
    int limit = ApiConstants.firstGenLimit,
    int offset = 0,
  }) async {
    final data = await _fetch(
        '${ApiConstants.pokemonEndpoint}?limit=$limit&offset=$offset');
    return (data['results'] as List)
        .map((e) => PokemonListItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Pokemon> fetchPokemon(String nameOrId) async {
    final data = await _fetch('${ApiConstants.pokemonEndpoint}/$nameOrId');
    return Pokemon.fromJson(data);
  }

  static Future<PokemonSpecies> fetchSpecies(int id) async {
    final data = await _fetch('${ApiConstants.speciesEndpoint}/$id');
    return PokemonSpecies.fromJson(data);
  }

  static Future<EvolutionChain> fetchEvolutionChain(String url) async {
    final data = await _fetch(url);
    return EvolutionChain(
      steps: _flattenChain(data['chain'] as Map<String, dynamic>),
    );
  }

  static Future<Map<String, String>> fetchAbilityDescriptions(
      List<PokemonAbility> abilities) async {
    final results = <String, String>{};
    await Future.wait(abilities.map((a) async {
      try {
        final data =
            await _fetch('${ApiConstants.baseUrl}/ability/${a.name}');
        final entries =
            (data['effect_entries'] as List).cast<Map<String, dynamic>>();
        final en = entries.firstWhere(
          (e) => e['language']['name'] == 'en',
          orElse: () => entries.isNotEmpty ? entries.first : {},
        );
        results[a.name] = en['short_effect'] as String? ?? '';
      } catch (_) {
        results[a.name] = '';
      }
    }));
    return results;
  }

  static List<EvolutionStep> _flattenChain(
    Map<String, dynamic> node, {
    String? trigger,
    int? minLevel,
  }) {
    final species = node['species'] as Map<String, dynamic>;
    final parts = (species['url'] as String).split('/');
    final id = int.parse(parts[parts.length - 2]);
    final name = species['name'] as String;

    final step =
        EvolutionStep(id: id, name: name, trigger: trigger, minLevel: minLevel);

    final evolvesTo = node['evolves_to'] as List;
    if (evolvesTo.isEmpty) return [step];

    final next = evolvesTo.first as Map<String, dynamic>;
    final details =
        (next['evolution_details'] as List).cast<Map<String, dynamic>>();
    String? nextTrigger;
    int? nextMinLevel;
    if (details.isNotEmpty) {
      final trigger = details.first['trigger'];
      if (trigger != null) {
        nextTrigger = (trigger as Map<String, dynamic>)['name'] as String?;
      }
      nextMinLevel = details.first['min_level'] as int?;
    }

    return [
      step,
      ..._flattenChain(next, trigger: nextTrigger, minLevel: nextMinLevel)
    ];
  }
}
