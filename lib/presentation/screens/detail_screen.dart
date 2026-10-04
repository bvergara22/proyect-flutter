import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/pokemon.dart';
import '../../data/models/pokemon_species.dart';
import '../../data/models/evolution_chain.dart';
import '../../data/services/poke_api_service.dart';
import '../widgets/type_badge.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  final String name;

  const DetailScreen({super.key, required this.id, required this.name});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Pokemon? _pokemon;
  PokemonSpecies? _species;
  EvolutionChain? _evolution;
  Map<String, String> _abilityDescs = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final pokemon = await PokeApiService.fetchPokemon(widget.id.toString());
      final results = await Future.wait([
        PokeApiService.fetchSpecies(pokemon.speciesId),
        PokeApiService.fetchAbilityDescriptions(pokemon.abilities),
      ]);
      final species = results[0] as PokemonSpecies;
      final abilityDescs = results[1] as Map<String, String>;
      final evolution =
          await PokeApiService.fetchEvolutionChain(species.evolutionChainUrl);
      if (!mounted) { return; }
      setState(() {
        _pokemon = pokemon;
        _species = species;
        _evolution = evolution;
        _abilityDescs = abilityDescs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) { return; }
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Color get _typeColor => _pokemon != null && _pokemon!.types.isNotEmpty
      ? AppColors.forType(_pokemon!.types.first)
      : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text(_cap(widget.name),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: const BackButton(color: Colors.white),
        ),
        body: const LoadingView(),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text(_cap(widget.name)),
          leading: const BackButton(color: Colors.white),
        ),
        body: ErrorView(message: _error!, onRetry: _load),
      );
    }
    return _buildBody();
  }

  Widget _buildBody() {
    final p = _pokemon!;
    final color = _typeColor;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildHeader(p, color),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'Info & Stats'),
                Tab(text: 'Habilidades'),
                Tab(text: 'Evolución'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _InfoStatsTab(pokemon: p, species: _species!, typeColor: color),
            _MovesTab(pokemon: p, abilityDescs: _abilityDescs, typeColor: color),
            _EvolutionTab(chain: _evolution!, currentId: p.id, typeColor: color),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Pokemon p, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.9),
            color,
            HSLColor.fromColor(color).withLightness(
              (HSLColor.fromColor(color).lightness - 0.15).clamp(0.0, 1.0),
            ).toColor(),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -40,
            bottom: 40,
            child: Opacity(
              opacity: 0.12,
              child: Icon(Icons.catching_pokemon, size: 220, color: Colors.white),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 60),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '#${p.id.toString().padLeft(3, '0')}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _cap(p.name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          children: p.types
                              .map((t) => TypeBadge(type: t, light: true))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  Hero(
                    tag: 'pokemon-${p.id}',
                    child: Image.network(
                      p.imageUrl,
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : const SizedBox(width: 140, height: 140),
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.catching_pokemon,
                        color: Colors.white38,
                        size: 100,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// =============================================================================
// TAB 1: INFO & STATS
// =============================================================================
class _InfoStatsTab extends StatelessWidget {
  final Pokemon pokemon;
  final PokemonSpecies species;
  final Color typeColor;

  const _InfoStatsTab({
    required this.pokemon,
    required this.species,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    final total = pokemon.stats.fold(0, (s, e) => s + e.value);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _flavorCard(),
        const SizedBox(height: 14),
        _sectionTitle('Información Básica'),
        const SizedBox(height: 10),
        _infoGrid(),
        const SizedBox(height: 20),
        _sectionTitle('Estadísticas de Combate'),
        const SizedBox(height: 12),
        ...pokemon.stats.asMap().entries.map((e) =>
            _AnimatedStatBar(stat: e.value, typeColor: typeColor, delay: e.key * 80)),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Total  $total',
              style: TextStyle(fontWeight: FontWeight.bold, color: typeColor),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _flavorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.menu_book_outlined, color: typeColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              species.flavorText,
              style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoGrid() {
    final items = [
      _Cell('Altura', '${pokemon.height / 10} m'),
      _Cell('Peso', '${pokemon.weight / 10} kg'),
      _Cell('Exp. base', '${pokemon.baseExperience}'),
      _Cell('Hábitat', _cap(species.habitat)),
      _Cell('Generación', species.generation
          .replaceFirst('generation-', '')
          .toUpperCase()),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((c) => _infoCell(c)).toList(),
    );
  }

  Widget _infoCell(_Cell c) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.label,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(c.value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) =>
      Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _Cell {
  final String label;
  final String value;
  const _Cell(this.label, this.value);
}

// Stat bar with animation
class _AnimatedStatBar extends StatefulWidget {
  final PokemonStat stat;
  final Color typeColor;
  final int delay;
  const _AnimatedStatBar({required this.stat, required this.typeColor, required this.delay});

  @override
  State<_AnimatedStatBar> createState() => _AnimatedStatBarState();
}

class _AnimatedStatBarState extends State<_AnimatedStatBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  static const _labels = <String, String>{
    'hp': 'HP',
    'attack': 'Ataque',
    'defense': 'Defensa',
    'special-attack': 'Sp. Atq.',
    'special-defense': 'Sp. Def.',
    'speed': 'Velocidad',
  };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _barColor(int v) {
    if (v >= 100) return Colors.green.shade500;
    if (v >= 70) return Colors.lightGreen;
    if (v >= 45) return Colors.orange;
    return Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.stat.value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              _labels[widget.stat.name] ?? widget.stat.name,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(
              '$v',
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _anim.value * v / 255,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(_barColor(v)),
                  minHeight: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB 2: HABILIDADES Y MOVIMIENTOS
// =============================================================================
class _MovesTab extends StatelessWidget {
  final Pokemon pokemon;
  final Map<String, String> abilityDescs;
  final Color typeColor;

  const _MovesTab({
    required this.pokemon,
    required this.abilityDescs,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Habilidades',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...pokemon.abilities.map((a) => _abilityCard(a)),
        const SizedBox(height: 20),
        const Text('Movimientos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Primeros 20 movimientos',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: pokemon.moves
              .map((m) => _moveBadge(m.name))
              .toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _abilityCard(PokemonAbility a) {
    final borderColor =
        a.isHidden ? Colors.purple.shade200 : typeColor.withValues(alpha: 0.4);
    final iconColor = a.isHidden ? Colors.purple : typeColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(a.isHidden ? Icons.visibility_off : Icons.bolt,
              color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                    _cap(a.name.replaceAll('-', ' ')),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  if (a.isHidden) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('Oculta',
                          style: TextStyle(
                              color: Colors.purple,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ]),
                if ((abilityDescs[a.name] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    abilityDescs[a.name]!,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _moveBadge(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: typeColor.withValues(alpha: 0.3)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: Text(
        _cap(name.replaceAll('-', ' ')),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: typeColor),
      ),
    );
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// =============================================================================
// TAB 3: EVOLUCIÓN
// =============================================================================
class _EvolutionTab extends StatelessWidget {
  final EvolutionChain chain;
  final int currentId;
  final Color typeColor;

  const _EvolutionTab({
    required this.chain,
    required this.currentId,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    final steps = chain.steps;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Cadena de Evolución',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (steps.length == 1)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Este Pokémon no evoluciona.',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
            ),
          )
        else
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            return Column(
              children: [
                if (i > 0) _arrow(step),
                _evoCard(step, step.id == currentId),
              ],
            );
          }),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _evoCard(EvolutionStep step, bool isCurrent) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent ? typeColor : Colors.grey.shade200,
          width: isCurrent ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? typeColor.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isCurrent ? 12 : 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.network(
            step.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.catching_pokemon,
              size: 60,
              color: typeColor.withValues(alpha: 0.5),
            ),
            loadingBuilder: (_, child, p) =>
                p == null ? child : const SizedBox(width: 80, height: 80),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                    _cap(step.name),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Actual',
                          style: TextStyle(
                              color: typeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ]),
                Text(
                  '#${step.id.toString().padLeft(3, '0')}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrow(EvolutionStep step) {
    final String label;
    if (step.minLevel != null) {
      label = 'Nivel ${step.minLevel}';
    } else if (step.trigger != null) {
      label = _cap(step.trigger!.replaceAll('-', ' '));
    } else {
      label = 'Evolución';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: typeColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_downward, size: 14, color: typeColor),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: typeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
