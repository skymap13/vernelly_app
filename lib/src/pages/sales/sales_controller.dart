
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SalesController extends GetxController {
  void signOut() {
    // Borra el token y redirige a la página de login
    GetStorage().remove('authToken');
    Get.offNamedUntil('/', (route) => false);
  }
}
