import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kasir_toko_bangunan/pages/controller/loginController.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE1),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _LogoSection(),
              const SizedBox(height: 20),
              const _WelcomeText(),
              const SizedBox(height: 10),
              _LoginCard(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget untuk logo
class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'images/logo1.png',
      width: 120,
      height: 120,
      filterQuality: FilterQuality.low, // Optimasi gambar
    );
  }
}

// Widget untuk text welcome
class _WelcomeText extends StatelessWidget {
  const _WelcomeText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Selamat Datang Kembali!",
      style: TextStyle(
        fontSize: 16,
        color: Color(0xFF5D4037),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// Widget untuk kartu login
class _LoginCard extends StatelessWidget {
  final LoginController controller;

  const _LoginCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      color: const Color(0xFFFFF8F0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TitleText(),
            SizedBox(height: 35),
            _EmailField(),
            SizedBox(height: 20),
            _PasswordField(),
            SizedBox(height: 30),
            _LoginButton(),
            SizedBox(height: 16),
            _RegisterButton(),
          ],
        ),
      ),
    );
  }
}

// Widget untuk title
class _TitleText extends StatelessWidget {
  const _TitleText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Login Kasir Toko",
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: Color(0xFF5D4037),
      ),
    );
  }
}

// Widget untuk email field
class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    
    return TextField(
      onChanged: (value) => controller.emailC.value = value,
      decoration: _AppInputDecoration(
        label: "Email",
        icon: Icons.person_outline,
      ).build(),
    );
  }
}

// Widget untuk password field
class _PasswordField extends StatelessWidget {
  const _PasswordField();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    
    return Obx(() {
      return TextField(
        obscureText: !controller.isPasswordVisible.value,
        onChanged: (value) => controller.passwordC.value = value,
        decoration: _AppInputDecoration(
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
        ).build(),
      );
    });
  }
}

// Widget untuk login button
class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.loginUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B4513),
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
      );
    });
  }
}


class _RegisterButton extends StatelessWidget {
  const _RegisterButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: () => Get.toNamed('/register'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF8B4513), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Registrasi",
          style: TextStyle(
            color: Color(0xFF8B4513),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Helper class untuk input decoration
class _AppInputDecoration {
  final String label;
  final IconData icon;
  final Widget? suffixIcon;

  _AppInputDecoration({
    required this.label,
    required this.icon,
    this.suffixIcon,
  });

  InputDecoration build() {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF5D4037),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF8B4513)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFFF8F0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8B4513), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
    );
  }
}
