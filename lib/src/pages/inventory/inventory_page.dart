import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vernelly_app/src/pages/inventory/category/inventory_category_page.dart';
import 'package:vernelly_app/src/pages/inventory/inventory_controller.dart';
import 'package:vernelly_app/src/pages/inventory/products/inventory_products_page.dart';

class InventoryPage extends StatelessWidget {
  final InventoryController con = Get.put(InventoryController());

  final List<MenuItem> menuItems = [
    MenuItem('PRODUCTOS', 'assets/img/products.png', () => InventoryProductsPage()),
    MenuItem('CATEGORIAS', 'assets/img/categories.png', () => InventoryCategoryPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inventario',
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
                    int crossAxisCount = (constraints.maxWidth > 600) ? 2 : 2; // Ejemplo: 2 columnas en pantallas grandes, 1 en pantallas pequeñas

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
                        return _card(item.title, item.imagePath, item.page);
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

  Widget _card(String title, String imagePath, Widget Function() pageBuilder) {
    return GestureDetector(
      onTap: () {
        Get.to(pageBuilder()); // Navega a la página correspondiente usando la función
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
  final Widget Function() page;

  MenuItem(this.title, this.imagePath, this.page);
}
