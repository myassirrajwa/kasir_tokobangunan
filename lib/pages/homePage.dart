import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kasir_toko_bangunan/pages/laporan.dart';
import 'package:kasir_toko_bangunan/pages/riwayat.dart';
import 'package:kasir_toko_bangunan/pages/transaksi.dart';
import 'package:kasir_toko_bangunan/pages/kategori.dart';
import 'package:kasir_toko_bangunan/pages/pengeluaran.dart';
import 'package:kasir_toko_bangunan/pages/loginPage.dart';
import 'package:kasir_toko_bangunan/pages/pengaturan.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser;

  String uidToNumber(String uid) {
    int hash = uid.hashCode.abs();
    int fourDigits = hash % 10000;
    return fourDigits.toString().padLeft(4, '0');
  }

  @override
  Widget build(BuildContext context) {
    final idPegawai = uidToNumber(user?.uid ?? "");
    final userName = user?.displayName ?? "Pegawai";
    final userEmail = user?.email ?? "No Email";

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      body: CustomScrollView(
        slivers: [
          // ========== APP BAR ==========
          SliverAppBar(
            backgroundColor: Color(0xFF4A2C2A),
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                "Kasir Bangunan",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4A2C2A),
                      Color(0xFF6D4C41),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  Get.defaultDialog(
                    title: "Konfirmasi Logout",
                    middleText: "Apakah Anda yakin ingin keluar?",
                    titleStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2C2A),
                    ),
                    textCancel: "Tidak",
                    textConfirm: "Ya",
                    cancelTextColor: Colors.grey[700],
                    confirmTextColor: Colors.white,
                    buttonColor: Color(0xFF4A2C2A),
                    onConfirm: () async {
                      await FirebaseAuth.instance.signOut();
                      Get.offAll(() => LoginPage());
                    },
                  );
                },
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: Icon(Icons.logout, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),

          // ========== BODY ==========
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ========== CARD PROFIL PEGAWAI ==========
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6D4C41),
                          Color(0xFF4A2C2A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.white, Color(0xFFD7CCC8)],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 36,
                              color: Color(0xFF4A2C2A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userEmail,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "ID: $idPegawai",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.verified_user,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ========== HEADER MENU ==========
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Menu Utama",
                          style: TextStyle(
                            color: Color(0xFF4A2C2A),
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF4A2C2A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "5 Menu",
                            style: TextStyle(
                              color: Color(0xFF4A2C2A),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ========== GRID MENU ==========
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      // Menu Transaksi
                      _buildMenuCard(
                        icon: Icons.shopping_cart_rounded,
                        title: "Transaksi",
                        color: Color(0xFF4CAF50),
                        gradient: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        onTap: () {
                          Get.to(() => const TransaksiPage(title: "Transaksi"));
                        },
                      ),

                      // Menu Kategori
                      _buildMenuCard(
                        icon: Icons.category_rounded,
                        title: "Kategori",
                        color: Color(0xFF2196F3),
                        gradient: [Color(0xFF2196F3), Color(0xFF42A5F5)],
                        onTap: () {
                          Get.to(() => Kategori(title: "Kategori"));
                        },
                      ),

                      // Menu Pengeluaran
                      _buildMenuCard(
                        icon: Icons.attach_money_rounded,
                        title: "Pengeluaran",
                        color: Color(0xFFFF9800),
                        gradient: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                        onTap: () {
                          Get.to(() => const PengeluaranPage(title: "Pengeluaran"));
                        },
                      ),

                      // Menu Laporan
                      // _buildMenuCard(
                      //   icon: Icons.assessment_rounded,
                      //   title: "Laporan",
                      //   color: Color(0xFF9C27B0),
                      //   gradient: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                      //   onTap: () {
                      //     Get.to(() => const LaporanPage(title: "Laporan"));
                      //   },
                      // ),

                      // Menu History
                      _buildMenuCard(
                        icon: Icons.history_rounded,
                        title: "History",
                        color: Color(0xFF607D8B),
                        gradient: [Color(0xFF607D8B), Color(0xFF90A4AE)],
                        onTap: () {
                          Get.to(() => const RiwayatPage(title: "History"));
                        },
                      ),

                      // Menu Pengaturan
                      _buildMenuCard(
                        icon: Icons.settings_rounded,
                        title: "Pengaturan",
                        color: Color(0xFF795548),
                        gradient: [Color(0xFF795548), Color(0xFFA1887F)],
                        onTap: () {
                          Get.to(() => const PengaturanPage());
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ========== FOOTER ==========
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store_rounded,
                          color: Color(0xFF4A2C2A),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Toko Bangunan",
                          style: TextStyle(
                            color: Color(0xFF4A2C2A),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget kartu menu yang lebih modern
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            
            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: Icon(
                    icon,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Hover Effect
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onTap,
                  splashColor: Colors.white.withOpacity(0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}