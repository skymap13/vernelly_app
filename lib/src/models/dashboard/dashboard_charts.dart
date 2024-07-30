import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vernelly_app/src/models/dashboard/dashboard_data.dart';

class DashboardCharts extends StatelessWidget {
  final List<Venta>? ventas;
  final List<Ingreso>? ingresos;

  DashboardCharts({this.ventas, this.ingresos});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LineChartWidget(
          title: 'Cantidad de productos vendidos',
          dataPoints: ventas!.map((venta) => FlSpot(
              double.parse(venta.mes!.split('-')[1]).toDouble(),
              double.parse(venta.result!).toDouble()
          )).toList(),
          bottomTitles: ventas!.map((venta) => venta.mes!.split('-')[1]).toList(),
          leftTitles: ventas!.map((venta) => venta.result!).toList(),
        ),
        LineChartWidget(
          title: 'Ingresos por ventas',
          dataPoints: ingresos!.map((ingreso) => FlSpot(
              double.parse(ingreso.mes!.split('-')[1]).toDouble(),
              double.parse(ingreso.result!).toDouble()
          )).toList(),
          bottomTitles: ingresos!.map((ingreso) => ingreso.mes!.split('-')[1]).toList(),
          leftTitles: ingresos!.map((ingreso) => ingreso.result!).toList(),
        ),
      ],
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final String title;
  final List<FlSpot> dataPoints;
  final List<String> bottomTitles;
  final List<String> leftTitles;

  LineChartWidget({required this.title, required this.dataPoints, required this.bottomTitles, required this.leftTitles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 18)),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: dataPoints,
                  isCurved: true,
                  barWidth: 4,
                  color: Colors.blue,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = dataPoints.indexWhere((spot) => spot.y == value);
                      if (index != -1) {
                        return Text(leftTitles[index]);
                      }
                      return Text('');
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt() - 1; // Restar 1 para convertir 1-based a 0-based
                      if (index >= 0 && index < bottomTitles.length) {
                        String mes = bottomTitles[index];
                        switch (mes) {
                          case '01': return Text('Jan');
                          case '02': return Text('Feb');
                          case '03': return Text('Mar');
                          case '04': return Text('Apr');
                          case '05': return Text('May');
                          case '06': return Text('Jun');
                          case '07': return Text('Jul');
                          case '08': return Text('Aug');
                          case '09': return Text('Sep');
                          case '10': return Text('Oct');
                          case '11': return Text('Nov');
                          case '12': return Text('Dec');
                          default: return Text('');
                        }
                      }
                      return Text('');
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
