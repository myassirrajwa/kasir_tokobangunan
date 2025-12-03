import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController extends GetxController {
  final emailC = ''.obs;
  final passwordC = ''.obs;

  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  void togglePassword() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> loginUser() async {
    if (emailC.value.isEmpty || passwordC.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Email atau Password tidak boleh kosong",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isLoading.value = true;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailC.value.trim(),
        password: passwordC.value.trim(),
      );

      // MATIKAN LOADING DULU
      isLoading.value = false;

      // LANGSUNG PINDAH HALAMAN TANPA SNACKBAR
      Get.offAllNamed('/home');

    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      String message = "Terjadi kesalahan";

      if (e.code == 'user-not-found') {
        message = "Email tidak terdaftar";
      } else if (e.code == 'wrong-password') {
        message = "Password salah";
      } else if (e.code == 'invalid-email') {
        message = "Format email tidak valid";
      }

      Get.snackbar(
        "Login Gagal",
        message,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
