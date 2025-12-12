import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final namaC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmPassC = TextEditingController();

  var isLoading = false.obs;

  var showPass = false.obs;
  var showConfirmPass = false.obs;

  final auth = FirebaseAuth.instance;

  Future<void> registerUser() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // buat akun
      await auth.createUserWithEmailAndPassword(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );

      // ⬅️ SIMPAN NAMA KE PROFIL FIREBASE
      await auth.currentUser!.updateDisplayName(namaC.text.trim());
      await auth.currentUser!.reload();

      // ⬅️ LOGOUT SUPAYA LOGIN ULANG DENGAN NAMA
      await auth.signOut();

      isLoading.value = false;

      Get.snackbar(
        "Berhasil",
        "Akun berhasil dibuat! Silakan login.",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 2),
      );

      // pindah ke login
      Future.delayed(const Duration(milliseconds: 800), () {
        Get.offAllNamed('/login');
      });

    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      Get.snackbar(
        "Gagal",
        e.message ?? "Terjadi kesalahan.",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );
    }
  }
}
