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
      return ResponseAPi(message: 'No se pudo ejecutar la petición');
    }

    if (response.statusCode != 200) {
      Get.snackbar('ERROR', 'Error en la solicitud: ${response.statusCode}');
      return ResponseAPi(message: 'Error en la solicitud');
    }

    try {
      var responseBody = response.body;
      if (responseBody is String) {
        responseBody = jsonDecode(responseBody);
      }
      ResponseAPi responseAPi = ResponseAPi.fromJson(responseBody);
      // Asumir éxito si el token no es null, incluso si success es null
      if (responseAPi.token != null && responseAPi.success == null) {
        responseAPi.success = true;
      }
      return responseAPi;
    } catch (e) {
      Get.snackbar('ERROR', 'Error al parsear la respuesta: ${e.toString()}');
      return ResponseAPi(message: 'Error al parsear la respuesta');
    }
  }

}
