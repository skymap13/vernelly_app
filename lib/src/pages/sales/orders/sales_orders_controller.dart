import 'dart:io';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vernelly_app/src/environment/environment.dart';
import 'package:vernelly_app/src/models/sales/orders/orders_model_data.dart';

class SalesOrdersController extends GetxController {
  var searchQuery = ''.obs;
  var orders = <Order>[].obs;
  var isLoading = false.obs;
  var orderDetails = <OrderDetail>[].obs;
  var cachedOrderDetails = <int, List<OrderDetail>>{}.obs;
  var isLoadingDetails = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<Order> get filteredOrders {
    if (searchQuery.value.isEmpty) {
      return orders;
    } else {
      return orders.where((order) {
        return (order.userName ?? '').toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final token = GetStorage().read('authToken');
      final response = await http.get(
        Uri.parse('${Environment.API_URL}pedidos/listar?valorBusqueda=&page=1&limit=1000'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Response JSON: $jsonResponse');
        orders.value = (jsonResponse['result'] as List).map((order) => Order.fromJson(order)).toList();
        print('Orders: $orders');
      } else {
        Get.snackbar('Error', 'Error al traer el listado de órdenes');
        print('Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor');
      print('Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchOrderDetails(int orderId) async {
    if (cachedOrderDetails.containsKey(orderId)) {
      orderDetails.value = cachedOrderDetails[orderId]!;
      return;
    }
    try {
      isLoadingDetails.value = true;
      final token = GetStorage().read('authToken');
      final response = await http.get(
        Uri.parse('${Environment.API_URL}pedidos/obtener/$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Response JSON: $jsonResponse');
        orderDetails.value = (jsonResponse['result'] as List).map((detail) => OrderDetail.fromJson(detail)).toList();
        cachedOrderDetails[orderId] = orderDetails.value;
        print('Order Details: $orderDetails');
      } else {
        Get.snackbar('Error', 'Error al traer los detalles de la orden');
        print('Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor');
      print('Exception: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<void> downloadReport() async {
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        var excel = Excel.createExcel();
        Sheet sheetObject = excel['Reporte de Órdenes'];

        // Encabezados de las columnas
        sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue('ID');
        sheetObject.cell(CellIndex.indexByString("B1")).value = TextCellValue('Nombre de Usuario');
        sheetObject.cell(CellIndex.indexByString("C1")).value = TextCellValue('Fecha de Ingreso');
        sheetObject.cell(CellIndex.indexByString("D1")).value = TextCellValue('Total');

        // Rellenar datos de órdenes
        for (var i = 0; i < orders.length; i++) {
          Order order = orders[i];
          sheetObject.cell(CellIndex.indexByString("A${i + 2}")).value = TextCellValue(order.id?.toString() ?? '');
          sheetObject.cell(CellIndex.indexByString("B${i + 2}")).value = TextCellValue(order.userName ?? '');
          sheetObject.cell(CellIndex.indexByString("C${i + 2}")).value = TextCellValue(order.date ?? '');
          sheetObject.cell(CellIndex.indexByString("D${i + 2}")).value = TextCellValue(order.total?.toString() ?? '');
        }

        var fileBytes = excel.save();
        if (fileBytes == null) {
          Get.snackbar('Error', 'No se pudo generar el archivo Excel.');
          return;
        }

        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          Get.snackbar('Error', 'No se pudo encontrar el directorio de almacenamiento.');
          return;
        }

        final path = '${directory.path}/reporte_ordenes.xlsx';
        final file = File(path);

        await file.writeAsBytes(fileBytes, flush: true);
        Get.snackbar('Éxito', 'Reporte descargado en $path');
      } else if (status.isDenied) {
        Get.snackbar('Error', 'Permiso de almacenamiento denegado.');
      } else if (status.isPermanentlyDenied) {
        Get.snackbar('Error', 'Permiso de almacenamiento denegado permanentemente. Por favor, habilite el permiso en la configuración.');
        openAppSettings();
      }
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un error al descargar el reporte: $e');
      print('Exception: $e');
    }
  }
}
