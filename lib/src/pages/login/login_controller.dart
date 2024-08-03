import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vernelly_app/src/models/response_api.dart';
import 'package:vernelly_app/src/providers/users_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  UsersProvider usersProvider = UsersProvider();

  void login(BuildContext context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (isValidForm(email, password)) {
      ProgressDialog progressDialog = ProgressDialog(context: context);
      progressDialog.show(max: 100, msg: 'Verificando Datos');

      try {
        ResponseAPi responseAPi = await usersProvider.login(email, password);

        // Imprimimos la respuesta del API para depuración
        print('ResponseApi : ${responseAPi.toJson()}');

        if (responseAPi.success == true) {
          // Guarda el token en GetStorage si el inicio de sesión es exitoso
          GetStorage().write('authToken', responseAPi.token);
          progressDialog.close();
          goToCtrldasboardHomePage();
        } else {
          // Cierra el diálogo de progreso y muestra un diálogo de error
          progressDialog.close();
          _showErrorDialog(context, 'Login Fallido', responseAPi.message ?? 'Error desconocido');
        }
      } catch (e) {
        // Cierra el diálogo de progreso y registra el error
        progressDialog.close();
        print('Login Error: $e');
        // Muestra un diálogo de error con detalles de la excepción
        _showErrorDialog(context, 'Excepción de Login', e.toString());
      }
    }
  }


  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            title,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.grey[800]),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        );
      },
    );
  }


  void goToHomePage() {
    Get.offNamedUntil('/home', (route) => false);
  }

  void goToCtrldasboardHomePage() {
    Get.offNamedUntil('/models/ctrldashboard', (route) => false);
  }

  void goToClientHomePage() {
    Get.offNamedUntil('/client/home', (route) => false);
  }

  bool isValidForm(String email, String password) {
    if (email.isEmpty) {
      _showErrorDialog(Get.context!, 'Formulario no válido', 'Debes ingresar tu Correo');
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      _showErrorDialog(Get.context!, 'Formulario no válido', 'El Correo no es válido');
      return false;
    }

    if (password.isEmpty) {
      _showErrorDialog(Get.context!, 'Formulario no válido', 'Debes ingresar tu Contraseña');
      return false;
    }

    return true;
  }
}
