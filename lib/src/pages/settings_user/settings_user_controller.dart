import 'dart:io';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vernelly_app/src/environment/environment.dart';
import 'package:vernelly_app/src/models/settings_users/user_model_data.dart';

class SettingsController extends GetxController {
  var indexTab = 0.obs;
  var searchQuery = ''.obs;
  var users = <User>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  void changeTab(int index) {
    indexTab.value = index;
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<User> get filteredUsers {
    if (searchQuery.value.isEmpty) {
      return users;
    } else {
      return users.where((user) {
        return (user.nombre ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (user.apellido ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (user.correo ?? '').toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final token = GetStorage().read('authToken');
      final page = 1; // Cambia este valor según sea necesario
      final response = await http.get(
        Uri.parse('${Environment.API_URL}usuarios/listar?page=$page&limit=1000&valorBusqueda='),
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
          users.value = (jsonResponse['result'] as List)
              .map((user) => User.fromJson(user))
              .toList();
          print('Usuarios cargados: ${users.length}');
        } else {
          print('Error: result is null');
          throw Exception('Error: result is null');
        }
      } else {
        Get.snackbar('Error', 'Error al traer el listado de usuarios');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor');
    } finally {
      isLoading.value = false;
    }
  }

  void updateUser(User updatedUser) async {
    try {
      final token = GetStorage().read('authToken');
      final response = await http.put(
        Uri.parse('${Environment.API_URL}usuarios/actualizar/${updatedUser.id}'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
        body: jsonEncode(updatedUser.toJson()),
      );

      print('Update Status Code: ${response.statusCode}');
      print('Update Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['result'] != null) {
          int index = users.indexWhere((user) => user.id == updatedUser.id);
          if (index != -1) {
            users[index] = updatedUser;
            users.refresh();
          }
          Get.snackbar('Éxito', 'Usuario actualizado correctamente');
        } else {
          Get.snackbar('Error', 'No se pudo actualizar el usuario');
        }
      } else {
        Get.snackbar('Error', 'Error al actualizar el usuario');
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Error al conectar con el servidor');
    }
  }

  void deactivateUser(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Desactivar usuario'),
          content: Text('¿Desea desactivar este usuario?'),
          actions: [
            TextButton(
              child: Text('CANCELAR'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ACEPTAR'),
              onPressed: () {
                Navigator.of(context).pop();
                updateUserStatus(user, 'INACTIVO');
              },
            ),
          ],
        );
      },
    );
  }

  void activateUser(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Activar usuario'),
          content: Text('¿Desea activar este usuario?'),
          actions: [
            TextButton(
              child: Text('CANCELAR'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ACEPTAR'),
              onPressed: () {
                Navigator.of(context).pop();
                updateUserStatus(user, 'ACTIVO');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateUserStatus(User user, String status) async {
    final token = GetStorage().read('authToken');
    final url = status == 'ACTIVO'
        ? '${Environment.API_URL}usuarios/activar/${user.id}'
        : '${Environment.API_URL}usuarios/eliminar/${user.id}';

    try {
      final response = status == 'ACTIVO'
          ? await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      )
          : await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      print('Update Status Code: ${response.statusCode}');
      print('Update Response Body: ${response.body}');

      if (response.statusCode == 200) {
        fetchUsers(); // Actualiza la lista de usuarios después de cambiar el estado
        Get.snackbar('Éxito', 'El estado del usuario ha sido actualizado');
      } else {
        Get.snackbar('Error', 'No se pudo actualizar el estado del usuario');
      }
    } catch (e) {
      print('Error al actualizar el estado del usuario: $e');
      Get.snackbar('Error', 'Error al conectar con el servidor');
    }
  }

  Future<void> addUser(User newUser) async {
    isLoading.value = true;
    final token = GetStorage().read('authToken');
    try {
      final response = await http.post(
        Uri.parse('${Environment.API_URL}usuarios/crear'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
        body: jsonEncode(newUser.toJson()),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['mensaje'] == 'Datos insertados correctamente') {
          await fetchUsers();  // Recargar la lista de usuarios después de agregar un nuevo usuario
          Get.snackbar('Éxito', 'Usuario añadido correctamente');
        } else {
          print('Error: result is null');
          Get.snackbar('Error', 'Error al añadir usuario: result is null');
        }
      } else {
        print('Error: ${response.body}');
        Get.snackbar('Error', 'Error al añadir usuario: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Error al conectar con el servidor: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadReport() async {
    try {
      // Solicitar permiso de almacenamiento
      var status = await Permission.storage.request();

      if (status.isGranted) {
        var excel = Excel.createExcel();
        Sheet sheetObject = excel['Reporte de Usuarios'];

        // Encabezados de las columnas
        sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue('ID');
        sheetObject.cell(CellIndex.indexByString("B1")).value = TextCellValue('Nombre');
        sheetObject.cell(CellIndex.indexByString("C1")).value = TextCellValue('Apellido');
        sheetObject.cell(CellIndex.indexByString("D1")).value = TextCellValue('Celular');
        sheetObject.cell(CellIndex.indexByString("E1")).value = TextCellValue('Correo');
        sheetObject.cell(CellIndex.indexByString("F1")).value = TextCellValue('Dirección');
        sheetObject.cell(CellIndex.indexByString("G1")).value = TextCellValue('Observación');
        sheetObject.cell(CellIndex.indexByString("H1")).value = TextCellValue('Estado');

// Rellenar datos de usuarios
        for (var i = 0; i < users.length; i++) {
          User user = users[i];
          sheetObject.cell(CellIndex.indexByString("A${i + 2}")).value = TextCellValue(user.id?.toString() ?? '');
          sheetObject.cell(CellIndex.indexByString("B${i + 2}")).value = TextCellValue(user.nombre ?? '');
          sheetObject.cell(CellIndex.indexByString("C${i + 2}")).value = TextCellValue(user.apellido ?? '');
          sheetObject.cell(CellIndex.indexByString("D${i + 2}")).value = TextCellValue(user.celular ?? '');
          sheetObject.cell(CellIndex.indexByString("E${i + 2}")).value = TextCellValue(user.correo ?? '');
          sheetObject.cell(CellIndex.indexByString("F${i + 2}")).value = TextCellValue(user.direccion ?? '');
          sheetObject.cell(CellIndex.indexByString("G${i + 2}")).value = TextCellValue(user.observacion ?? '');
          sheetObject.cell(CellIndex.indexByString("H${i + 2}")).value = TextCellValue(user.estado ?? '');
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

        final path = '${directory.path}/reporte_usuarios.xlsx';
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
    }
  }
}
