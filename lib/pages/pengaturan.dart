import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';

class PengaturanPage extends StatelessWidget {
  const PengaturanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pengaturan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.brown,
        centerTitle: true,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown.shade50,
              Colors.brown.shade100.withOpacity(0.3),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header Profil
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.brown.shade100,
                      border: Border.all(color: Colors.brown.shade300, width: 2),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: Colors.brown.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? "Pengguna",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.brown,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? "Email tidak tersedia",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade100),
                          ),
                          child: Text(
                            user?.emailVerified == true ? "✓ Terverifikasi" : "Belum Verifikasi",
                            style: TextStyle(
                              fontSize: 12,
                              color: user?.emailVerified == true 
                                ? Colors.green.shade700 
                                : Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // List Menu Pengaturan
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildSectionTitle("Akun & Keamanan"),
                    _buildSettingItem(
                      icon: Icons.person_outline,
                      title: "Profil Akun",
                      subtitle: "Kelola informasi akun Anda",
                      color: Colors.blue,
                      onTap: () {
                        Get.snackbar(
                          "Profil",
                          "Fitur pengaturan profil sedang dikembangkan",
                          backgroundColor: Colors.blue,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                          borderRadius: 12,
                          margin: const EdgeInsets.all(16),
                        );
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.lock_outline,
                      title: "Ganti Password",
                      subtitle: "Ubah kata sandi akun",
                      color: Colors.orange,
                      onTap: () {
                        _showChangePasswordDialog(context);
                      },
                    ),

                    _buildSectionTitle("Tampilan"),
                    _buildSettingItem(
                      icon: Icons.color_lens_outlined,
                      title: "Tema Aplikasi",
                      subtitle: "Pilih tema gelap atau terang",
                      color: Colors.purple,
                      trailing: Switch(
                        value: isDarkMode,
                        onChanged: (value) {
                          Get.snackbar(
                            "Tema",
                            "Fitur tema sedang dikembangkan",
                            backgroundColor: Colors.purple,
                            colorText: Colors.white,
                          );
                        },
                        activeColor: Colors.brown,
                      ),
                    ),

                    _buildSectionTitle("Tentang"),
                    _buildSettingItem(
                      icon: Icons.info_outline,
                      title: "Tentang Aplikasi",
                      subtitle: "Versi dan informasi aplikasi",
                      color: Colors.teal,
                      onTap: () {
                        _showAboutDialog(context);
                      },
                    ),
                    _buildSettingItem(
                      icon: Icons.security_outlined,
                      title: "Kebijakan Privasi",
                      subtitle: "Baca kebijakan privasi kami",
                      color: Colors.indigo,
                      onTap: () {
                        Get.snackbar(
                          "Kebijakan Privasi",
                          "Halaman kebijakan privasi akan ditambahkan",
                          backgroundColor: Colors.indigo,
                          colorText: Colors.white,
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Logout Button
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        borderRadius: BorderRadius.circular(15),
                        child: InkWell(
                          onTap: () async {
                            await _showLogoutConfirmation(context);
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade400,
                                  Colors.red.shade600,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Keluar dari Akun",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 24, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing,
                ] else
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Ganti Password",
      titleStyle: const TextStyle(
        color: Colors.brown,
        fontWeight: FontWeight.bold,
      ),
      content: Column(
        children: [
          const Text(
            "Fitur ganti password akan segera hadir dalam pembaruan aplikasi.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.grey),
              children: [
                const TextSpan(text: "Untuk saat ini, gunakan fitur "),
                TextSpan(
                  text: "Lupa Password",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Get.back();
                      Get.snackbar(
                        "Info",
                        "Silakan gunakan fitur lupa password di halaman login",
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                      );
                    },
                ),
                const TextSpan(text: " di halaman login."),
              ],
            ),
          ),
        ],
      ),
      textConfirm: "Mengerti",
      confirmTextColor: Colors.white,
      buttonColor: Colors.brown,
      onConfirm: Get.back,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.brown.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Kasir Toko Bangunan",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Versi 1.0.0",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Aplikasi kasir khusus untuk toko bangunan dengan fitur lengkap untuk mengelola penjualan, stok, dan laporan keuangan.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        "Dukungan",
                        "Halaman dukungan akan ditambahkan",
                        backgroundColor: Colors.brown,
                        colorText: Colors.white,
                      );
                    },
                    child: const Text("Dukungan"),
                  ),
                  ElevatedButton(
                    onPressed: Get.back,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text("Tutup"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    await Get.defaultDialog(
      title: "Konfirmasi Logout",
      titleStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
      content: const Column(
        children: [
          Icon(
            Icons.logout,
            color: Colors.red,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            "Apakah Anda yakin ingin keluar dari akun ini?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      textConfirm: "Ya, Keluar",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.brown,
      buttonColor: Colors.red,
      onConfirm: () async {
        try {
          await FirebaseAuth.instance.signOut();
          Get.offAllNamed('/login');
          Get.snackbar(
            "Berhasil",
            "Anda telah keluar dari akun",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            "Error",
            "Gagal logout: ${e.toString()}",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }
}