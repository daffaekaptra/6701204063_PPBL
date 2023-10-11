import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fl_chart/fl_chart.dart'; // Import pustaka fl_chart

Future<List<List<dynamic>>?> readCSV() async {
  final String csvData = await rootBundle.loadString('assets/data_sensor.csv');
  List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvData);
  return rowsAsListOfValues;
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('CSV Reader'),
        ),
        body: FutureBuilder<List<List<dynamic>>?>(
          future: readCSV(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No data available');
            }

            // Data has been successfully loaded from CSV
            final csvData = snapshot.data!;
            List<double> soilHumData = [];
            List<double> humData = [];

            for (var row in csvData) {
              if (row.length >= 8) {
                soilHumData.add(double.parse(row[0].toString()));
                humData.add(double.parse(row[7].toString()));
              }
            }

            return Column(
              children: [
                // Bar Chart
                AspectRatio(
                  aspectRatio: 1.7,
                  child: BarChart(
                    BarChartData(
                      titlesData: FlTitlesData(
                        leftTitles: SideTitles(showTitles: true),
                        bottomTitles: SideTitles(showTitles: true),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                      barGroups: soilHumData
                          .asMap()
                          .entries
                          .map(
                            (entry) => BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              y: entry.value,
                              width: 22,
                              colors: [const Color(0xff23b6e6)],
                            ),
                          ],
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
