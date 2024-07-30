import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vernelly_app/src/models/sales/orders/orders_model_data.dart';
import 'sales_orders_controller.dart';

class SalesOrdersPage extends StatelessWidget {
  final SalesOrdersController con = Get.put(SalesOrdersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Órdenes'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Obx(() {
        if (con.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: con.updateSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: con.fetchOrders,
                  child: ListView.builder(
                    itemCount: con.filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = con.filteredOrders[index];
                      return ListTile(
                        title: Text(order.userName ?? 'Nombre no disponible'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha de ingreso: ${order.date}'),
                            Text('Total: \$${order.total}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionButton(
                              icon: Icons.visibility,
                              color: Colors.blue,
                              onPressed: () => _showOrderDetails(context, order),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }
      }),
      bottomNavigationBar: BottomAppBar(
        color: Colors.purpleAccent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: con.downloadReport,
            icon: Icon(Icons.download),
            label: Text('Descargar Reporte'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purpleAccent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    final parentContext = context;
    final SalesOrdersController con = Get.find();

    if (con.cachedOrderDetails.containsKey(order.id)) {
      _showDialogWithDetails(parentContext, con);
    } else {
      con.fetchOrderDetails(order.id!).then((_) {
        if (parentContext.mounted) {
          _showDialogWithDetails(parentContext, con);
        }
      });
    }
  }

  void _showDialogWithDetails(BuildContext context, SalesOrdersController con) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalles de la Orden', style: TextStyle(color: Colors.purpleAccent)),
          content: Obx(() {
            if (con.isLoadingDetails.value) {
              return Center(child: CircularProgressIndicator());
            }
            if (con.orderDetails.isEmpty) {
              return Text('No hay productos en la orden.', style: TextStyle(color: Colors.grey));
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: con.orderDetails.map((detail) {
                  return ListTile(
                    title: Text(detail.productName ?? 'Producto'),
                    subtitle: Text('Cantidad: ${detail.quantity}, Precio: \$${detail.price}'),
                  );
                }).toList(),
              );
            }
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('CANCELAR'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
