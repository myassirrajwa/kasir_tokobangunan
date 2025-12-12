import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kasir_toko_bangunan/pages/controller/registerController.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final controller = Get.put(RegisterController());

  final Color primaryColor = const Color(0xFF8B4513);
  final Color accentColor = const Color(0xFF5D4037);
  final Color backgroundColor = const Color(0xFFF5EDE1);
  final Color cardColor = const Color(0xFFFFF8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Image.asset('images/logo1.png', width: 120, height: 120),
              const SizedBox(height: 20),

              Text(
                "Buat Akun Baru",
                style: TextStyle(
                  fontSize: 18,
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              Card(
                elevation: 10,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Registrasi Kasir Toko",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // NAMA
                        TextFormField(
                          controller: controller.namaC,
                          decoration: _inputDecoration(
                            label: "Nama Lengkap",
                            icon: Icons.person_outline,
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Nama tidak boleh kosong" : null,
                        ),

                        const SizedBox(height: 20),

                        // EMAIL
                        TextFormField(
                          controller: controller.emailC,
                          decoration: _inputDecoration(
                            label: "Email",
                            icon: Icons.email_outlined,
                          ),
                          validator: (v) =>
                              v!.isEmpty ? "Email tidak boleh kosong" : null,
                        ),

                        const SizedBox(height: 20),

                        // PASSWORD
                        Obx(() => TextFormField(
                              controller: controller.passC,
                              obscureText: !controller.showPass.value,
                              decoration: _inputDecoration(
                                label: "Password",
                                icon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.showPass.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.brown.shade400,
                                  ),
                                  onPressed: () =>
                                      controller.showPass.toggle(),
                                ),
                              ),
                              validator: (v) => v!.length < 6
                                  ? "Password minimal 6 karakter"
                                  : null,
                            )),

                        const SizedBox(height: 20),

                        // KONFIRMASI PASSWORD
                        Obx(() => TextFormField(
                              controller: controller.confirmPassC,
                              obscureText: !controller.showConfirmPass.value,
                              decoration: _inputDecoration(
                                label: "Konfirmasi Password",
                                icon: Icons.lock_person_outlined,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    controller.showConfirmPass.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.brown.shade400,
                                  ),
                                  onPressed: () =>
                                      controller.showConfirmPass.toggle(),
                                ),
                              ),
                              validator: (v) => v != controller.passC.text
                                  ? "Password tidak cocok"
                                  : null,
                            )),

                        const SizedBox(height: 30),

                        // BUTTON REGISTER
                        Obx(() => SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.registerUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: controller.isLoading.value
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'DAFTAR',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Input Decoration
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: accentColor,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: primaryColor),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: cardColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
    );
  }
}
