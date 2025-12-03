import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kasir_toko_bangunan/pages/controller/homeController.dart';
import 'package:kasir_toko_bangunan/pages/kategori.dart';
import 'package:kasir_toko_bangunan/pages/pengeluaran.dart';
import 'package:kasir_toko_bangunan/pages/riwayat.dart';
import 'package:kasir_toko_bangunan/pages/transaksi.dart';
import 'package:kasir_toko_bangunan/pages/laporan.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Toko Bangunan',
          style: TextStyle(
            color: Colors.brown,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset('images/logo1.png'),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.brown),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Obx(() => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8D6E63), Color(0xFFA1887F)],
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle_rounded,
                          size: 60, color: Colors.white),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.namaPegawai.value.isEmpty
                                ? "Memuat..."
                                : c.namaPegawai.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "ID: ${c.nomorPegawai.value}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Menu Utama",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Konfirmasi Logout",
                      middleText: "Apakah Anda yakin ingin keluar?",
                      textCancel: "Batal",
                      textConfirm: "Logout",
                      confirmTextColor: Colors.white,
                      onConfirm: () => c.logout(),
                    );
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            /// ✨ MENU GRID (pakai Get.to)
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              children: [
                _menuItem("Kategori", "images/kategori.png", () {
                  Get.to(() => Kategori(title: "Kategori"));
                }),
                _menuItem("Riwayat", "images/riwayat.png", () {
                  Get.to(() => RiwayatTransaksi(title: "Riwayat"));
                }),
                _menuItem("Laporan", "images/report.png", () {
                  Get.to(() => LaporanPage());
                }),
                _menuItem("Pengeluaran", "images/pengeluaran.png", () {
                  Get.to(() => PengeluaranPage());
                }),
              ],
            ),
          ],
        ),
      ),

      /// BAGIAN TRANSAKSI BAWAH
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Get.to(() => const TransaksiPage(title: "Transaksi"));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
          child: const Text(
            "Transaksi",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// Widget Builder Menu
  Widget _menuItem(String name, String image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.brown.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, width: 45, height: 38),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
