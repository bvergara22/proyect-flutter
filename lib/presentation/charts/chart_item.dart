import 'package:flutter/material.dart';

class ChartItem {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String category;
  final Widget Function() builder;

  const ChartItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.description = '',
    required this.category,
    required this.builder,
  });
}

class ChartLibrary {
  final String id;
  final String name;
  final String description;
  final Color color;
  final IconData icon;
  final List<ChartItem> basic;
  final List<ChartItem> advanced;

  const ChartLibrary({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.basic,
    required this.advanced,
  });

  int get totalCharts => basic.length + advanced.length;
}
