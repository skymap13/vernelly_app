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
        SizedBox(height: 20), // Añadir espacio entre los gráficos
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0), // Añadir padding alrededor del gráfico
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, color: Colors.black)),
          SizedBox(
            height: 300, // Aumentar la altura para dar más espacio al gráfico
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: 7,
                minY: 0,
                maxY: (title == 'Cantidad de productos vendidos') ? 200 : 5500,
                lineBarsData: [
                  LineChartBarData(
                    spots: dataPoints,
                    isCurved: true,
                    barWidth: 4,
                    color: Colors.blue,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 70, // Aumentar el tamaño reservado
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8.0, // Añadir espacio
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(color: Colors.black, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40, // Aumentar el tamaño reservado
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt() - 1;
                        if (index >= 0 && index < bottomTitles.length) {
                          String mes = bottomTitles[index];
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8.0, // Añadir espacio
                            child: Text(
                              _getMonthAbbreviation(mes),
                              style: TextStyle(color: Colors.black, fontSize: 10),
                            ),
                          );
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8.0, // Añadir espacio
                          child: Text('', style: TextStyle(color: Colors.black)),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.black.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.black.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
                ),
                backgroundColor: Colors.white,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.x}, ${spot.y}',
                          TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthAbbreviation(String mes) {
    switch (mes) {
      case '01': return 'Jan';
      case '02': return 'Feb';
      case '03': return 'Mar';
      case '04': return 'Apr';
      case '05': return 'May';
      case '06': return 'Jun';
      case '07': return 'Jul';
      case '08': return 'Aug';
      case '09': return 'Sep';
      case '10': return 'Oct';
      case '11': return 'Nov';
      case '12': return 'Dec';
      default: return '';
    }
  }
}
