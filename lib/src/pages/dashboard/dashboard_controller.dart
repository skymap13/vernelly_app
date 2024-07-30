import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vernelly_app/src/environment/environment.dart';
import 'package:vernelly_app/src/models/dashboard/dashboard_data.dart';

class DashboardController extends GetxController {
  var indexTab = 0.obs;
  var dashboardData = DashboardData().obs;
  var isLoading = true.obs;

  void changeTab(int index) {
    indexTab.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
    fetchDashboardData('2024'); // Cambia el año según sea necesario
  }

  void _checkAuthStatus() {
    final token = GetStorage().read('authToken');
    if (token == null) {
      Get.offNamed('/');
    }
  }

  void signOut() {
    GetStorage().remove('authToken');
    Get.offNamedUntil('/', (route) => false);
  }

  Future<void> fetchDashboardData(String year) async {
    try {
      isLoading.value = true;
      final token = GetStorage().read('authToken');
      final response = await http.get(
        Uri.parse('${Environment.API_URL}dashboard/$year'),
        headers: {
          'Content-Type': 'application/json',
          'token': token ?? '',
        },
      );

      print('Código de estado: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Verifica que 'result' exista y no sea null
        if (jsonResponse['result'] != null) {
          dashboardData.value = DashboardData.fromJson(jsonResponse['result']);
        } else {
          throw Exception('Error: result is null');
        }
      } else {
        throw Exception('No se pudieron cargar los datos del dashboard');
      }
    } catch (e) {
      print('Error al obtener datos del dashboard: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
