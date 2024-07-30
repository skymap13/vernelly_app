import 'dart:io';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vernelly_app/src/models/sales/carts/carts_model_data.dart';
import 'package:vernelly_app/src/environment/environment.dart'; // Asegúrate de importar el archivo de entorno

class SalesCartsController extends GetxController {
  var searchQuery = ''.obs;
  var carts = <Cart>[].obs;
  var isLoading = false.obs;
  var cartDetails = <CartDetail>[].obs;
  var cachedCartDetails = <int, List<CartDetail>>{}.obs; // Cache para detalles del carrito
  var isLoadingDetails = false.obs; // Estado de carga para detalles del carrito

  @override
  void onInit() {
    super.onInit();
    fetchCarts();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<Cart> get filteredCarts {
    if (searchQuery.value.isEmpty) {
      return carts;
    } else {
      return carts.where((cart) {
        return (cart.userName ?? '').toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }

  Future<void> fetchCarts() async {
    try {
      isLoading.value = true;
      final token = GetStorage().read('authToken');
      final response = await http.get(
        Uri.parse('${Environment.API_URL}carrito/listar?valorBusqueda=&page=1&limit=1000'), // Usa la URL del entorno
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Response JSON: $jsonResponse');
        carts.value = (jsonResponse['result'] as List).map((cart) => Cart.fromJson(cart)).toList();
        print('Carts: $carts');
      } else {
        Get.snackbar('Error', 'Error al traer el listado de carritos');
        print('Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor');
      print('Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCartDetails(int cartId) async {
    if (cachedCartDetails.containsKey(cartId)) {
      cartDetails.value = cachedCartDetails[cartId]!;
      return;
    }
    try {
      isLoadingDetails.value = true; // Iniciar carga de detalles
      final token = GetStorage().read('authToken');
      final response = await http.get(
        Uri.parse('${Environment.API_URL}carrito/obtener/$cartId'), // Usa la URL del entorno
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Response JSON: $jsonResponse');
        cartDetails.value = (jsonResponse['result'] as List).map((detail) => CartDetail.fromJson(detail)).toList();
        cachedCartDetails[cartId] = cartDetails.value;
        print('Cart Details: $cartDetails');
      } else {
        Get.snackbar('Error', 'Error al traer los detalles del carrito');
        print('Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor');
      print('Exception: $e');
    } finally {
      isLoadingDetails.value = false; // Finalizar carga de detalles
    }
  }

  void toggleCartStatus(String cartId) async {
    try {
      final cart = carts.firstWhere((c) => c.id.toString() == cartId);
      final newStatus = cart.status == 'ACTIVO' ? 'INACTIVO' : 'ACTIVO';

      final response = await http.put(
        Uri.parse('${Environment.API_URL}carrito/activar/$cartId'), // Asegúrate de usar la URL correcta
        headers: {
          'Content-Type': 'application/json',
          'token': GetStorage().read('authToken') ?? '',
        },
        body: jsonEncode({'estado': newStatus}),
      );

      if (response.statusCode == 200) {
        cart.status = newStatus;
        carts.refresh();
        Get.snackbar('Éxito', 'El estado del carrito ha sido actualizado');
      } else {
        Get.snackbar('Error', 'No se pudo actualizar el estado del carrito');
        print('Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor');
      print('Exception: $e');
    }
  }

  Future<void> downloadReport() async {
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        var excel = Excel.createExcel();
        Sheet sheetObject = excel['Reporte de Carritos'];

        // Encabezados de las columnas
        sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue('ID');
        sheetObject.cell(CellIndex.indexByString("B1")).value = TextCellValue('Nombre de Usuario');
        sheetObject.cell(CellIndex.indexByString("C1")).value = TextCellValue('Fecha de Ingreso');
        sheetObject.cell(CellIndex.indexByString("D1")).value = TextCellValue('Estado');

        // Rellenar datos de carritos
        for (var i = 0; i < carts.length; i++) {
          Cart cart = carts[i];
          sheetObject.cell(CellIndex.indexByString("A${i + 2}")).value = TextCellValue(cart.id?.toString() ?? '');
          sheetObject.cell(CellIndex.indexByString("B${i + 2}")).value = TextCellValue(cart.userName ?? '');
          sheetObject.cell(CellIndex.indexByString("C${i + 2}")).value = TextCellValue(cart.date ?? '');
          sheetObject.cell(CellIndex.indexByString("D${i + 2}")).value = TextCellValue(cart.status ?? '');
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

        final path = '${directory.path}/reporte_carritos.xlsx';
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
