import 'package:flutter/material.dart';
import '../../charts/chart_item.dart';

class LibraryChartsScreen extends StatefulWidget {
  final ChartLibrary library;
  const LibraryChartsScreen({super.key, required this.library});

  @override
  State<LibraryChartsScreen> createState() => _LibraryChartsScreenState();
}

class _LibraryChartsScreenState extends State<LibraryChartsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.library.name),
        backgroundColor: widget.library.color,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Básicas (${widget.library.basic.length})'),
            Tab(text: 'Avanzadas (${widget.library.advanced.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _ChartList(items: widget.library.basic, color: widget.library.color),
          _ChartList(items: widget.library.advanced, color: widget.library.color),
        ],
      ),
    );
  }
}

class _ChartList extends StatelessWidget {
  final List<ChartItem> items;
  final Color color;
  const _ChartList({required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ChartDetailScreen(item: item, color: color))),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text('${i + 1}',
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(item.subtitle,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                  _CategoryBadge(category: item.category),
                  const SizedBox(width: 6),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  const _CategoryBadge({required this.category});

  static const Map<String, Color> _colors = {
    'bar':       Color(0xFF2196F3),
    'line':      Color(0xFF4CAF50),
    'pie':       Color(0xFFF44336),
    'area':      Color(0xFF9C27B0),
    'histogram': Color(0xFFFF9800),
    'scatter':   Color(0xFF00BCD4),
    'bubble':    Color(0xFFE91E63),
    'radar':     Color(0xFF8BC34A),
    'heatmap':   Color(0xFFFF5722),
    'combined':  Color(0xFF607D8B),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[category] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(category, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class ChartDetailScreen extends StatelessWidget {
  final ChartItem item;
  final Color color;
  const ChartDetailScreen({super.key, required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title, style: const TextStyle(fontSize: 16)),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoCard(item: item, color: color),
            const SizedBox(height: 16),
            item.builder(),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final ChartItem item;
  final Color color;
  const _InfoCard({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.category.toUpperCase(),
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.subtitle,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            ],
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Text(
              item.description,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.5),
            ),
          ],
        ],
      ),
    );
  }
}
