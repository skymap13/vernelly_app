import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vernelly_app/src/models/ctrldashboard/ctrldasboard_home.dart';
import 'package:vernelly_app/src/pages/contacts/contacts_page.dart';
import 'package:vernelly_app/src/pages/dashboard/dashboard_page.dart';
import 'package:vernelly_app/src/pages/inventory/category/inventory_category_page.dart';
import 'package:vernelly_app/src/pages/inventory/inventory_page.dart';
import 'package:vernelly_app/src/pages/inventory/products/inventory_products_page.dart';
import 'package:vernelly_app/src/pages/login/login_page.dart';
import 'package:vernelly_app/src/pages/sales/carts/sales_carts_page.dart';
import 'package:vernelly_app/src/pages/sales/orders/sales_orders_page.dart';
import 'package:vernelly_app/src/pages/sales/sales_page.dart';
import 'package:vernelly_app/src/pages/settings_user/settings_user_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await checkAndRequestPermissions(); // Llama a la función de solicitud de permisos aquí
  runApp(const MyApp());
}

Future<void> checkAndRequestPermissions() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    status = await Permission.storage.request();
  }

  if (status.isGranted) {
    print('Permiso de almacenamiento concedido');
    // Procede con la operación que requiere permisos de almacenamiento
  } else {
    print('Permiso de almacenamiento denegado');
    // Notifica al usuario que el permiso es necesario
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vernelly',
      debugShowCheckedModeBanner: false,
      initialRoute: _getInitialRoute(),
      getPages: [
        GetPage(name: '/', page: () => LoginPage()),
        GetPage(name: '/models/ctrldashboard', page: () => CtrldasboardHome()),
        GetPage(name: '/pages/dashboard', page: () => DashboardPage()),
        GetPage(name: '/pages/inventory', page: () => InventoryPage()),
        GetPage(name: '/pages/inventory/products', page: () => InventoryProductsPage()),
        GetPage(name: '/pages/inventory/category', page: () => InventoryCategoryPage()),
        GetPage(name: '/pages/sales', page: () => SalesPage()),
        GetPage(name: '/pages/sales/carts', page: () => SalesCartPage()),
        GetPage(name: '/pages/sales/orders', page: () => SalesOrdersPage()),
        GetPage(name: '/pages/contacts', page: () => ContactsPage()),
        GetPage(name: '/pages/settings', page: () => SettingsPage()),
      ],
      theme: ThemeData(
        primaryColor: Colors.purpleAccent,
        colorScheme: ColorScheme(
          primary: Colors.purpleAccent,
          secondary: Colors.deepPurpleAccent,
          brightness: Brightness.light,
          onPrimary: Colors.red,
          surface: Colors.white,
          onSurface: Colors.black,
          onSecondary: Colors.amber,
          error: Colors.blue,
          onError: Colors.amberAccent,
        ),
      ),
      navigatorKey: Get.key,
    );
  }

  String _getInitialRoute() {
    final token = GetStorage().read('authToken');
    if (token != null) {
      return '/models/ctrldashboard'; // Ruta para la página principal si el usuario está autenticado
    } else {
      return '/'; // Ruta para la página de inicio de sesión si el usuario no está autenticado
    }
  }
}
