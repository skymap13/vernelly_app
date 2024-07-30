import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vernelly_app/src/pages/sales/carts/sales_carts_page.dart';
import 'package:vernelly_app/src/pages/sales/orders/sales_orders_page.dart';
import 'package:vernelly_app/src/pages/sales/sales_controller.dart';

class SalesPage extends StatelessWidget {
  final SalesController con = Get.put(SalesController());

  final List<MenuItem> menuItems = [
    MenuItem('CARRITO', 'assets/img/cart.png', () => SalesCartPage()),
    MenuItem('ORDENES', 'assets/img/orders.png', () => SalesOrdersPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ventas',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.yellow,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () {
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
                    int crossAxisCount = (constraints.maxWidth > 600) ? 2 : 2;

                    return GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
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
        Get.to(pageBuilder());
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
