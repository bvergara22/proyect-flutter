import 'package:flutter/material.dart';
import '../../data/models/pokemon_list_item.dart';
import '../../data/services/poke_api_service.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/pokemon_grid_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/error_view.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PokemonListItem> _all = [];
  List<PokemonListItem> _filtered = [];
  bool _loading = true;
  String? _error;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await PokeApiService.fetchList(limit: 151);
      if (!mounted) { return; }
      setState(() { _all = list; _filtered = list; _loading = false; });
    } catch (e) {
      if (!mounted) { return; }
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _filter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all.where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.id.toString() == q).toList();
    });
  }

  void _goToDetail(PokemonListItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(id: item.id, name: item.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          if (_loading)
            const SliverFillRemaining(child: LoadingView())
          else if (_error != null)
            SliverFillRemaining(
              child: ErrorView(message: _error!, onRetry: _load),
            )
          else if (_filtered.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('Sin resultados')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => PokemonGridCard(
                    item: _filtered[i],
                    onTap: () => _goToDetail(_filtered[i]),
                  ),
                  childCount: _filtered.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8B0000), Color(0xFFCC0000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                right: -30,
                top: -30,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.catching_pokemon,
                      size: 200, color: Colors.white),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PokéDex',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const Text(
                        'Generación I · 151 Pokémon',
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      _SearchBar(
                        controller: _searchController,
                        onChanged: _filter,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          height: 0,
          decoration: const BoxDecoration(
            color: Color(0xFFF2F2F2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o número...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFCC0000), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                  onPressed: () { controller.clear(); onChanged(''); },
                )
              : null,
        ),
      ),
    );
  }
}
