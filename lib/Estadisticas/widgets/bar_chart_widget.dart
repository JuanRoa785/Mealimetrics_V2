import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, int> dishSales;

  const BarChartWidget({super.key, required this.dishSales});

  @override
  Widget build(BuildContext context) {
    double maxY = (dishSales.values.isNotEmpty ? dishSales.values.first.toDouble() : 0) + 10;
    final barGroups = dishSales.entries.map((entry) {
      return BarChartGroupData(
        x: dishSales.keys.toList().indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            //colors: [Colors.blue],
          ),
        ],
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        height: 450,
        child: BarChart(
          BarChartData(
            maxY: maxY,
            alignment: BarChartAlignment.spaceAround,
            barGroups: barGroups,
            titlesData: FlTitlesData(
              topTitles:const AxisTitles(sideTitles: SideTitles(reservedSize: 6, showTitles: false)),
              rightTitles:const AxisTitles(sideTitles: SideTitles(reservedSize: 6, showTitles: false)),
              leftTitles:AxisTitles(
                sideTitles: SideTitles( 
                  showTitles: true,
                  getTitlesWidget:(value, meta) {
                    if(value%5==0){
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                      );
                    }
                    else{
                      return const Text('');
                    }
                  },
                  interval: 5
                  )
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                  reservedSize: 200,
                  showTitles: true, 
                  getTitlesWidget:(value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < dishSales.keys.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0), // Ajusta el padding vertical según tu preferencia
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Text(
                              dishSales.keys.elementAt(index),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  )
                ),
              ),
              
            ),
          ),
        ),
      );
  }
}
