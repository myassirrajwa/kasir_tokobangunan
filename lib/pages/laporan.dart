import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  int totalPembelian = 0;
  int totalPengeluaran = 0;

  @override
  void initState() {
    super.initState();
    loadLaporan();
  }

  Future<void> loadLaporan() async {
    final NumberFormat rupiah = NumberFormat("#,###", "id_ID");

    try {
      // 🔥 Ambil total pembelian dari koleksi "transaksi"
      final pembelianSnapshot =
          await FirebaseFirestore.instance.collection('transaksi').get();

      int pembelian = 0;
      for (var doc in pembelianSnapshot.docs) {
        pembelian += (doc['total'] ?? 0) as int;
      }

      // 🔥 Ambil total pengeluaran dari koleksi "pengeluaran"
      final pengeluaranSnapshot =
          await FirebaseFirestore.instance.collection('pengeluaran').get();

      int pengeluaran = 0;
      for (var doc in pengeluaranSnapshot.docs) {
        pengeluaran += (doc['jumlah'] ?? 0) as int;
      }

      setState(() {
        totalPembelian = pembelian;
        totalPengeluaran = pengeluaran;
      });

    } catch (e) {
      print("Error laporan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat rupiah = NumberFormat("#,###", "id_ID");

    int uangTersisa = totalPembelian - totalPengeluaran; 

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F2),
      appBar: AppBar(
        title: const Text(
          "Laporan Penjualan",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            laporanCard("Total Pembelian", rupiah.format(totalPembelian), Colors.green),
            const SizedBox(height: 15),
            laporanCard("Total Pengeluaran", rupiah.format(totalPengeluaran), Colors.red),
            const SizedBox(height: 15),
            laporanCard("Uang Tersisa", rupiah.format(uangTersisa), Colors.brown),
          ],
        ),
      ),
    );
  }

  // 🔶 Widget Card Laporan
  Widget laporanCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Rp $value",
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
