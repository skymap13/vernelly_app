import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vernelly_app/src/models/dashboard/dashboard_charts.dart';
import 'package:vernelly_app/src/models/dashboard/dashboard_data.dart';
import 'package:vernelly_app/src/pages/dashboard/dashboard_controller.dart';

class DashboardPage extends StatelessWidget {
  final DashboardController con = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.yellow,
      ),
      body: Obx(() {
        if (con.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            DropdownButton<String>(
              value: '2024',
              onChanged: (String? newYear) {
                if (newYear != null) {
                  con.fetchDashboardData(newYear);
                }
              },
              items: <String>['2023', '2024', '2025'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => con.fetchDashboardData('2024'), // Ajusta el año según tus necesidades
                child: ListView(
                  children: [
                    DashboardCard(
                      title: 'Cantidad de productos',
                      value: con.dashboardData.value.cantProductos?.toString() ?? 'N/A',
                    ),
                    DashboardCard(
                      title: 'Cantidad de carritos',
                      value: con.dashboardData.value.cantCarritos?.toString() ?? 'N/A',
                    ),
                    DashboardCard(
                      title: 'Cantidad de pedidos',
                      value: con.dashboardData.value.cantPedidos?.toString() ?? 'N/A',
                    ),
                    // Aquí añadimos los gráficos
                    FutureBuilder<DashboardData>(
                      future: Future.value(con.dashboardData.value),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else {
                          return DashboardCharts(
                            ventas: snapshot.data!.infoVentas,
                            ingresos: snapshot.data!.ingresos,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;

  DashboardCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: Text(value),
      ),
    );
  }
}
