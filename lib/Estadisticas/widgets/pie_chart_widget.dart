import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final Map<DateTime, double> salesByDate;

  PieChartWidget({required this.salesByDate});

  @override
  Widget build(BuildContext context) {
    final sections = salesByDate.entries.map((entry) {
      int index = salesByDate.keys.toList().indexOf(entry.key);
      if (index == -1) {
        index = 0; // Manejo de error si no se encuentra el índice
      }
      Color color = Colors.primaries[index % Colors.primaries.length];
      return PieChartSectionData(
        value: entry.value,
        title: '', // No mostrar el título por defecto
        color: color,
        showTitle: false, // No mostrar el título por defecto
        badgeWidget: Tooltip(
          message: '${entry.value} - ${entry.key.day}/${entry.key.month}/${entry.key.year}',
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        ),
        badgePositionPercentageOffset: .98,
      );
    }).toList();

  }
}
