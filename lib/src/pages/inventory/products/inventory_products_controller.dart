import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vernelly_app/src/environment/environment.dart';
import 'package:vernelly_app/src/models/inventory/category/categories_model_data.dart';
import 'package:vernelly_app/src/models/inventory/products/products_model_data.dart';

class InventoryProductsController extends GetxController {
  var indexTab = 0.obs;
  var searchQuery = ''.obs;
  var products = <Product>[].obs;
  var categories = <Category>[].obs; // Lista de categorías
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories(); // Obtén las categorías al inicializar el controlador
    fetchProducts();
  }

  void changeTab(int index) {
    indexTab.value = index;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<Product> get filteredProducts {
    if (searchQuery.value.isEmpty) {
      return products;
    } else {
      return products.where((product) {
        return (product.nombre ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (product.codigox ?? '').toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final token = GetStorage().read('authToken');
      final page = 1; // Puedes ajustar este valor según sea necesario
      final limit = 1000; // Puedes ajustar este valor según sea necesario
      final valorBusqueda = ''; // Puedes ajustar este valor según sea necesario

      final response = await http.get(
        Uri.parse('${Environment.API_URL}productos/listar?page=$page&limit=$limit&valorBusqueda=$valorBusqueda'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      print('Código de estado: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        print('JSON Response: $jsonResponse');

        if (jsonResponse['result'] != null) {
          products.value = (jsonResponse['result'] as List)
              .map((product) => Product.fromJson(product))
              .toList();
          print('Productos cargados: ${products.length}');
        } else {
          print('Error: result is null');
          throw Exception('Error: result is null');
        }
      } else {
        Get.snackbar('Error', 'Error al traer el listado de productos');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final token = GetStorage().read('authToken');
      final response = await http.get(
        Uri.parse('${Environment.API_URL}categorias/listar'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['result'] != null) {
          final categoriesList = jsonResponse['result'] as List;
          categories.value = categoriesList.map((category) => Category.fromJson(category)).toList();
        } else {
          Get.snackbar('Error', 'Error: result is null');
          print('Error: result is null');
        }
      } else {
        Get.snackbar('Error', 'Error al traer el listado de categorías: ${response.statusCode}');
        print('Error al traer el listado de categorías: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor: $e');
      print('Error al conectar con el servidor: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProduct(Product newProduct, File? image) async {
    isLoading.value = true;
    final token = GetStorage().read('authToken');
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Environment.API_URL}productos/crear'),
      );
      request.headers['token'] = token ?? '';

      request.fields['nombre'] = newProduct.nombre ?? '';
      request.fields['id_categoria'] = newProduct.idCategoria.toString();
      request.fields['observacion'] = newProduct.observacion ?? '';
      request.fields['codigoP'] = newProduct.codigox ?? '';
      request.fields['precio'] = newProduct.precio?.toString() ?? '';

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          image.path,
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        fetchProducts();
        Get.snackbar('Éxito', 'Producto añadido correctamente');
      } else {
        Get.snackbar('Error', 'Error al añadir producto: $responseBody');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(Product updatedProduct, File? image) async {
    isLoading.value = true;
    final token = GetStorage().read('authToken');
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${Environment.API_URL}productos/actualizar'),
      );
      request.headers['token'] = token ?? '';

      request.fields['id'] = updatedProduct.id.toString();
      request.fields['nombre'] = updatedProduct.nombre ?? '';
      request.fields['id_categoria'] = updatedProduct.idCategoria.toString();
      request.fields['observacion'] = updatedProduct.observacion ?? '';
      request.fields['codigoP'] = updatedProduct.codigox ?? '';
      request.fields['precio'] = updatedProduct.precio?.toString() ?? '';

      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          image.path,
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Update Status Code: ${response.statusCode}');
      print('Update Response Body: $responseBody');

      if (response.statusCode == 200) {
        fetchProducts();
        Get.snackbar('Éxito', 'Producto actualizado correctamente');
      } else {
        Get.snackbar('Error', 'Error al actualizar producto: $responseBody');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> activateProduct(BuildContext context, Product product) async {
    try {
      final token = GetStorage().read('authToken');
      final response = await http.put(
        Uri.parse('${Environment.API_URL}productos/activar/${product.id}'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        fetchProducts();
        Get.snackbar('Éxito', 'Producto activado');
      } else {
        Get.snackbar('Error', 'Error al activar producto');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor');
    }
  }

  Future<void> deactivateProduct(BuildContext context, Product product) async {
    try {
      final token = GetStorage().read('authToken');
      final response = await http.delete(
        Uri.parse('${Environment.API_URL}productos/eliminar/${product.id}'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        fetchProducts();
        Get.snackbar('Éxito', 'Producto desactivado');
      } else {
        Get.snackbar('Error', 'Error al desactivar producto');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor');
    }
  }

  Future<void> downloadReport() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Reporte de Productos'];

      // Encabezados de las columnas
      sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue('ID');
      sheetObject.cell(CellIndex.indexByString("B1")).value = TextCellValue('Nombre');
      sheetObject.cell(CellIndex.indexByString("C1")).value = TextCellValue('Precio');
      sheetObject.cell(CellIndex.indexByString("D1")).value = TextCellValue('Categoría');
      sheetObject.cell(CellIndex.indexByString("E1")).value = TextCellValue('Observación');
      sheetObject.cell(CellIndex.indexByString("F1")).value = TextCellValue('Código');
      sheetObject.cell(CellIndex.indexByString("G1")).value = TextCellValue('Estado');

// Rellenar datos de productos
      for (var i = 0; i < products.length; i++) {
        Product product = products[i];
        sheetObject.cell(CellIndex.indexByString("A${i + 2}")).value = TextCellValue(product.id?.toString() ?? '');
        sheetObject.cell(CellIndex.indexByString("B${i + 2}")).value = TextCellValue(product.nombre ?? '');
        sheetObject.cell(CellIndex.indexByString("C${i + 2}")).value = TextCellValue(product.precio?.toString() ?? '');
        sheetObject.cell(CellIndex.indexByString("D${i + 2}")).value = TextCellValue(product.idCategoria?.toString() ?? '');
        sheetObject.cell(CellIndex.indexByString("E${i + 2}")).value = TextCellValue(product.observacion ?? '');
        sheetObject.cell(CellIndex.indexByString("F${i + 2}")).value = TextCellValue(product.codigox ?? '');
        sheetObject.cell(CellIndex.indexByString("G${i + 2}")).value = TextCellValue(product.estado ?? '');
      }


      var fileBytes = excel.save();
      final directory = await getExternalStorageDirectory();
      final path = '${directory?.path}/reporte_productos.xlsx';
      final file = File(path);

      if (fileBytes != null) {
        await file.writeAsBytes(fileBytes, flush: true);
        Get.snackbar('Éxito', 'Reporte descargado en $path');
      } else {
        Get.snackbar('Error', 'No se pudo generar el archivo Excel.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Ocurrió un error al descargar el reporte: $e');
    }
  }
}
