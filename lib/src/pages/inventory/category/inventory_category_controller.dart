import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vernelly_app/src/environment/environment.dart';
import 'package:vernelly_app/src/models/inventory/category/categories_model_data.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'dart:io';

class InventoryCategoryController extends GetxController {
  var searchQuery = ''.obs;
  var categories = <Category>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<Category> get filteredCategories {
    if (searchQuery.value.isEmpty) {
      return categories;
    } else {
      return categories.where((category) {
        return (category.name ?? '').toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }

  String constructUrl(String endpoint) {
    return '${Environment.API_URL}$endpoint';
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final token = GetStorage().read('authToken');
      final page = 1; // Puedes ajustar este valor según sea necesario
      final limit = 10; // Puedes ajustar este valor según sea necesario
      final valorBusqueda = ''; // Puedes ajustar este valor según sea necesario

      final response = await http.get(
        Uri.parse('${Environment.API_URL}categorias/listar?page=$page&limit=$limit&valorBusqueda=$valorBusqueda'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      print('Código de estado: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['result'] != null) {
          final categoriesList = jsonResponse['result'] as List;
          categories.value = categoriesList.map((category) => Category.fromJson(category)).toList();
          print('Categorías cargadas: ${categories.length}');
        } else {
          print('Error: result is null');
          throw Exception('Error: result is null');
        }
      } else {
        Get.snackbar('Error', 'Error al traer el listado de categorías');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor: $e');
    } finally {
      isLoading.value = false;
    }
  }



  Future<void> addCategory(Category newCategory) async {
    isLoading.value = true;
    final token = GetStorage().read('authToken');
    try {
      final response = await http.post(
        Uri.parse('${Environment.API_URL}categorias/crear'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
        body: jsonEncode(newCategory.toJson()),
      );

      if (response.statusCode == 200) {
        fetchCategories();
        Get.snackbar('Éxito', 'Categoría añadida correctamente');
      } else {
        Get.snackbar('Error', 'Error al añadir categoría: ${response.statusCode}');
        print('Error al añadir categoría: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor: $e');
      print('Error al conectar con el servidor: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCategory(Category updatedCategory) async {
    isLoading.value = true;
    final token = GetStorage().read('authToken');
    try {
      final response = await http.put(
        Uri.parse('${Environment.API_URL}categorias/actualizar/${updatedCategory.id}'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
        body: jsonEncode(updatedCategory.toJson()),
      );

      if (response.statusCode == 200) {
        fetchCategories();
        Get.snackbar('Éxito', 'Categoría actualizada correctamente');
      } else {
        Get.snackbar('Error', 'Error al actualizar categoría: ${response.statusCode}');
        print('Error al actualizar categoría: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor: $e');
      print('Error al conectar con el servidor: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> activateCategory(BuildContext context, Category category) async {
    try {
      final token = GetStorage().read('authToken');
      final response = await http.put(
        Uri.parse('${Environment.API_URL}categorias/activar/${category.id}'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        fetchCategories();
        Get.snackbar('Éxito', 'Categoría activada');
      } else {
        Get.snackbar('Error', 'Error al activar categoría: ${response.statusCode}');
        print('Error al activar categoría: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor: $e');
      print('Error al conectar con el servidor: $e');
    }
  }

  Future<void> deactivateCategory(BuildContext context, Category category) async {
    try {
      final token = GetStorage().read('authToken');
      final response = await http.delete(
        Uri.parse('${Environment.API_URL}categorias/eliminar/${category.id}'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        fetchCategories();
        Get.snackbar('Éxito', 'Categoría desactivada');
      } else {
        Get.snackbar('Error', 'Error al desactivar categoría: ${response.statusCode}');
        print('Error al desactivar categoría: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor: $e');
      print('Error al conectar con el servidor: $e');
    }
  }

  Future<void> downloadReport() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Reporte de Categorías'];

      // Encabezados de las columnas
      sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue('ID');
      sheetObject.cell(CellIndex.indexByString("B1")).value = TextCellValue('Nombre');
      sheetObject.cell(CellIndex.indexByString("C1")).value = TextCellValue('Observación');
      sheetObject.cell(CellIndex.indexByString("D1")).value = TextCellValue('Estado');

// Rellenar datos de categorías
      for (var i = 0; i < categories.length; i++) {
        Category category = categories[i];
        sheetObject.cell(CellIndex.indexByString("A${i + 2}")).value = TextCellValue(category.id?.toString() ?? '');
        sheetObject.cell(CellIndex.indexByString("B${i + 2}")).value = TextCellValue(category.name ?? '');
        sheetObject.cell(CellIndex.indexByString("C${i + 2}")).value = TextCellValue(category.observation ?? '');
        sheetObject.cell(CellIndex.indexByString("D${i + 2}")).value = TextCellValue(category.status ?? '');
      }

      var fileBytes = excel.save();
      final directory = await getExternalStorageDirectory();
      final path = '${directory?.path}/reporte_categorias.xlsx';
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
