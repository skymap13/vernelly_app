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

      ResponseAPi responseAPi = await usersProvider.login(email, password);

      print('ResponseApi : ${responseAPi.toJson()}');

      if (responseAPi.success == true) {
        // Guarda el token en GetStorage
        GetStorage().write('authToken', responseAPi.token);
        progressDialog.close();
        goToCtrldasboardHomePage();
      } else {
        Get.snackbar('Login Fallido', responseAPi.message ?? 'Error desconocido');
        progressDialog.close();
      }
    }
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
      Get.snackbar('Formulario no valido', 'Debes ingresar tu Correo');
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Formulario no valido', 'El Correo no es valido');
      return false;
    }

    if (password.isEmpty) {
      Get.snackbar('Formulario no valido', 'Debes ingresar tu Contraseña');
      return false;
    }

    return true;
  }
}
