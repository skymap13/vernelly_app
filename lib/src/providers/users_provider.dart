import 'package:get/get.dart';
import 'package:vernelly_app/src/environment/environment.dart';
import 'package:vernelly_app/src/models/response_api.dart';
import 'dart:convert';

class UsersProvider extends GetConnect {
  String url = Environment.API_URL + 'login';

  Future<ResponseAPi> login(String email, String password) async {
    Response response = await post(
        url,
        jsonEncode({
          'correo': email,  // Asegúrate de que coincida con lo que espera el backend
          'password': password
        }),
        headers: {
          'Content-Type': 'application/json'
        }
    );

    if (response.body == null) {
      Get.snackbar('ERROR', 'No se pudo ejecutar la petición');
      return ResponseAPi();
    }

    if (response.statusCode != 200) {
      Get.snackbar('ERROR', 'Error en la solicitud');
      return ResponseAPi();
    }

    if (response.headers?['content-type']?.contains('application/json') == true) {
      var responseBody = response.body;
      if (responseBody is String) {
        responseBody = jsonDecode(responseBody);
      }
      ResponseAPi responseAPi = ResponseAPi.fromJson(responseBody);
      return responseAPi;
    } else {
      Get.snackbar('ERROR', 'La respuesta no es un JSON válido');
      return ResponseAPi();
    }
  }
}
