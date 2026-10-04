import 'package:flutter/material.dart';
import '../../data/models/pokemon_list_item.dart';

class PokemonGridCard extends StatelessWidget {
  final PokemonListItem item;
  final VoidCallback onTap;

  const PokemonGridCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey.shade50, Colors.white],
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                right: -18,
                bottom: -18,
                child: Opacity(
                  opacity: 0.07,
                  child: Icon(Icons.catching_pokemon, size: 100, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${item.id.toString().padLeft(3, '0')}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Expanded(
                      child: Hero(
                        tag: 'pokemon-${item.id}',
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) => progress == null
                              ? child
                              : Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    color: const Color(0xFFCC0000),
                                  ),
                                ),
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(Icons.catching_pokemon,
                                size: 56, color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name[0].toUpperCase() + item.name.substring(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
