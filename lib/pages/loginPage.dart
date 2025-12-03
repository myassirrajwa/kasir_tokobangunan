import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kasir_toko_bangunan/pages/controller/loginController.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final controller = Get.put(LoginController());

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/logo1.png', width: 120, height: 120),
              const SizedBox(height: 20),
              Text(
                "Selamat Datang Kembali!",
                style: TextStyle(
                  fontSize: 16,
                  color: accentColor,
                  fontWeight: FontWeight.w500,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Login Kasir Toko",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                        ),
                      ),

                      const SizedBox(height: 35),

                      // EMAIL
                      TextField(
                        onChanged: (v) => controller.emailC.value = v,
                        decoration: _inputDecoration(
                          label: "Email",
                          icon: Icons.person_outline,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // PASSWORD
                      Obx(() => TextField(
                        obscureText: !controller.isPasswordVisible.value,
                        onChanged: (v) => controller.passwordC.value = v,
                        decoration: _inputDecoration(
                          label: "Password",
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.brown.shade400,
                            ),
                            onPressed: controller.togglePassword,
                          ),
                        ),
                      )),

                      const SizedBox(height: 30),

                      // TOMBOL LOGIN
                      Obx(() => SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      )),

                      const SizedBox(height: 16),

                      // REGISTRASI
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () {
                            Get.toNamed('/register');
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryColor, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Registrasi",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
    );
  }
}
