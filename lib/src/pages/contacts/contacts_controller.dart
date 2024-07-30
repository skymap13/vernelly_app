import 'dart:io';
import 'package:excel/excel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vernelly_app/src/environment/environment.dart';
import 'package:vernelly_app/src/models/contacts/contacts_model_data.dart';

class ContactsController extends GetxController {
  var searchQuery = ''.obs;
  var contacts = <Contact>[].obs;
  var isLoading = false.obs;
  var contactDetails = Rxn<Contact>();
  var isLoadingDetails = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchContacts();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  List<Contact> get filteredContacts {
    if (searchQuery.value.isEmpty) {
      return contacts;
    } else {
      return contacts.where((contact) {
        return (contact.firstName ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (contact.lastName ?? '').toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            (contact.email ?? '').toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }

  Future<void> fetchContacts() async {
    try {
      isLoading.value = true;
      final token = GetStorage().read('authToken');
      final response = await http.get(
        Uri.parse('${Environment.API_URL}contacto/listar?valorBusqueda=&page=1&limit=10'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Response JSON: $jsonResponse');
        contacts.value = (jsonResponse['result'] as List).map((contact) => Contact.fromJson(contact)).toList();
        print('Contacts: $contacts');
      } else {
        Get.snackbar('Error', 'Error al traer el listado de contactos');
        print('Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al conectar con el servidor');
      print('Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchContactDetails(int contactId) async {
    try {
      isLoadingDetails.value = true;
      final token = GetStorage().read('authToken');
      final response = await http.get(
        Uri.parse('${Environment.API_URL}contacto/obtener/$contactId'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('Response JSON: $jsonResponse');
        contactDetails.value = Contact.fromJson((jsonResponse['result'] as List).first);
        print('Contact Details: ${contactDetails.value}');
      } else {
        Get.snackbar('Error', 'Error al traer los detalles del contacto');
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
        Sheet sheetObject = excel['Reporte de Contactos'];

        // Encabezados de las columnas
        sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue('Nombres');
        sheetObject.cell(CellIndex.indexByString("B1")).value = TextCellValue('Apellidos');
        sheetObject.cell(CellIndex.indexByString("C1")).value = TextCellValue('Correo');
        sheetObject.cell(CellIndex.indexByString("D1")).value = TextCellValue('Mensaje');
        sheetObject.cell(CellIndex.indexByString("E1")).value = TextCellValue('Fecha de ingreso');
        sheetObject.cell(CellIndex.indexByString("F1")).value = TextCellValue('Usuario quien envía');

        // Rellenar datos de contactos
        for (var i = 0; i < contacts.length; i++) {
          Contact contact = contacts[i];
          sheetObject.cell(CellIndex.indexByString("A${i + 2}")).value = TextCellValue(contact.firstName ?? '');
          sheetObject.cell(CellIndex.indexByString("B${i + 2}")).value = TextCellValue(contact.lastName ?? '');
          sheetObject.cell(CellIndex.indexByString("C${i + 2}")).value = TextCellValue(contact.email ?? '');
          sheetObject.cell(CellIndex.indexByString("D${i + 2}")).value = TextCellValue(contact.message ?? '');
          sheetObject.cell(CellIndex.indexByString("E${i + 2}")).value = TextCellValue(contact.date ?? '');
          sheetObject.cell(CellIndex.indexByString("F${i + 2}")).value = TextCellValue(contact.senderName ?? '');
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

        final path = '${directory.path}/reporte_contactos.xlsx';
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
