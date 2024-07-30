import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vernelly_app/src/models/ctrldashboard/ctrldasboard_controller.dart';
import 'package:vernelly_app/src/pages/contacts/contacts_page.dart';
import 'package:vernelly_app/src/pages/dashboard/dashboard_page.dart';
import 'package:vernelly_app/src/pages/inventory/inventory_page.dart';
import 'package:vernelly_app/src/pages/sales/sales_page.dart';
import 'package:vernelly_app/src/pages/settings/settings_page.dart';

class CtrldasboardHome extends StatelessWidget {
  final CtrldasboardController con = Get.put(CtrldasboardController());

  final List<MenuItem> menuItems = [
    MenuItem('DASHBOARD', 'assets/img/dashboard.png', () => DashboardPage()),
    MenuItem('INVENTARIO', 'assets/img/inventory.png', () => InventoryPage()),
    MenuItem('VENTAS', 'assets/img/sales.png', () => SalesPage()),
    MenuItem('CONTACTOS', 'assets/img/contacts.png', () => ContactsPage()),
    MenuItem('CONFIGURACION DE USUARIOS', 'assets/img/settings.png', () => SettingsPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seleccionar',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.yellow, // Color de fondo del AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black), // Icono de cerrar sesión
            onPressed: () {
              // Lógica para cerrar sesión
              con.signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Definir el número de columnas según el ancho de la pantalla
                    int crossAxisCount = (constraints.maxWidth > 600) ? 3 : 2; // Ejemplo: 3 columnas en pantallas grandes, 2 en pantallas pequeñas

                    return GridView.builder(
                      physics: NeverScrollableScrollPhysics(), // Desactivar desplazamiento en GridView
                      shrinkWrap: true, // Encoger GridView para ajustar su contenido
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount, // Número de columnas
                        crossAxisSpacing: 10, // Espacio horizontal entre tarjetas
                        mainAxisSpacing: 10, // Espacio vertical entre tarjetas
                        childAspectRatio: 0.8, // Ajustar la relación de aspecto para evitar el desbordamiento
                      ),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        return _carddas(item.title, item.imagePath, item.pageBuilder);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _carddas(String title, String imagePath, Widget Function() pageBuilder) {
    return GestureDetector(
      onTap: () {
        Get.to(pageBuilder); // Navega a la página correspondiente
      },
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: FadeInImage(
                    fit: BoxFit.contain,
                    fadeInDuration: Duration(milliseconds: 50),
                    placeholder: AssetImage('assets/img/no-image.png'),
                    image: AssetImage(imagePath),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  final String title;
  final String imagePath;
  final Widget Function() pageBuilder;

  MenuItem(this.title, this.imagePath, this.pageBuilder);
}
