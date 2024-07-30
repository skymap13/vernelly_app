import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vernelly_app/src/models/sales/carts/carts_model_data.dart';
import 'sales_carts_controller.dart';

class SalesCartPage extends StatelessWidget {
  final SalesCartsController con = Get.put(SalesCartsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Carritos'),
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
                  onRefresh: con.fetchCarts,
                  child: ListView.builder(
                    itemCount: con.filteredCarts.length,
                    itemBuilder: (context, index) {
                      final cart = con.filteredCarts[index];
                      return ListTile(
                        title: Text(cart.userName ?? 'Nombre no disponible'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fecha de ingreso: ${cart.date}'),
                            Text(cart.status ?? 'INACTIVO'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionButton(
                              icon: Icons.visibility,
                              color: Colors.blue,
                              onPressed: () => _showCartDetails(context, cart),
                            ),
                            SizedBox(width: 8),
                            _buildActionButton(
                              icon: cart.status == 'ACTIVO' ? Icons.cancel : Icons.check_circle,
                              color: cart.status == 'ACTIVO' ? Colors.red : Colors.green,
                              onPressed: () => _showConfirmationDialog(context, cart),
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

  void _showCartDetails(BuildContext context, Cart cart) {
    final parentContext = context;
    final SalesCartsController con = Get.find();

    if (con.cachedCartDetails.containsKey(cart.id)) {
      // Si los detalles están en caché, muéstralos inmediatamente
      _showDialogWithDetails(parentContext, con);
    } else {
      // Si no están en caché, obtenlos del backend
      con.fetchCartDetails(cart.id!).then((_) {
        if (parentContext.mounted) {
          _showDialogWithDetails(parentContext, con);
        }
      });
    }
  }

  void _showDialogWithDetails(BuildContext context, SalesCartsController con) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Datos del carrito', style: TextStyle(color: Colors.purpleAccent)),
          content: Obx(() {
            if (con.isLoadingDetails.value) {
              return Center(child: CircularProgressIndicator());
            }
            if (con.cartDetails.isEmpty) {
              return Text('No hay productos en el carrito.', style: TextStyle(color: Colors.grey));
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: con.cartDetails.map((detail) {
                  return ListTile(
                    title: Text(detail.productName ?? 'Producto'),
                    subtitle: Text('Cantidad: ${detail.quantity}'),
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

  void _showConfirmationDialog(BuildContext context, Cart cart) {
    final SalesCartsController con = Get.find();
    final newStatus = cart.status == 'ACTIVO' ? 'INACTIVO' : 'ACTIVO';
    final dialogTitle = newStatus == 'ACTIVO' ? 'Activar carrito' : 'Desactivar carrito';
    final dialogContent = newStatus == 'ACTIVO' ? '¿Desea activar este carrito?' : '¿Desea desactivar este carrito?';
    final acceptButtonColor = newStatus == 'ACTIVO' ? Colors.green : Colors.red;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(dialogTitle),
          content: Text(dialogContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('CANCELAR'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                con.toggleCartStatus(cart.id.toString());
              },
              child: Text('ACEPTAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: acceptButtonColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
