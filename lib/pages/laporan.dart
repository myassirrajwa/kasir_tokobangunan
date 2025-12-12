import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LaporanPage extends StatefulWidget {
  final String title;
  const LaporanPage({super.key, required this.title});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  @override
  Widget build(BuildContext context) {
    final NumberFormat rupiah = NumberFormat("#,###", "id_ID");

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

      body: StreamBuilder(
        // Hanya ambil transaksi kategori pembelian
        stream: FirebaseFirestore.instance
            .collection('transaksi')
            .where('kategori', isEqualTo: 'pembelian')
            .snapshots(),
        builder: (context, transaksiSnapshot) {
          return StreamBuilder(
            stream: FirebaseFirestore.instance.collection('pengeluaran').snapshots(),
            builder: (context, pengeluaranSnapshot) {
              
              if (!transaksiSnapshot.hasData || !pengeluaranSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // ============================
              // HITUNG TOTAL PEMBELIAN DARI HISTORY
              // ============================
              int totalPembelian = 0;

              for (var doc in transaksiSnapshot.data!.docs) {
                final List<dynamic> history = doc['history'] ?? [];

                for (var item in history) {
                  int harga = int.tryParse(item['harga'].toString()) ?? 0;
                  int qty = int.tryParse(item['qty'].toString()) ?? 0;
                  totalPembelian += harga * qty;
                }
              }

              // ============================
              // HITUNG TOTAL PENGELUARAN
              // ============================
              int totalPengeluaran = 0;
              for (var doc in pengeluaranSnapshot.data!.docs) {
                totalPengeluaran += int.tryParse(doc['jumlah'].toString()) ?? 0;
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    laporanCard("Total Pembelian", rupiah.format(totalPembelian), Colors.green),
                    const SizedBox(height: 15),
                    laporanCard("Total Pengeluaran", rupiah.format(totalPengeluaran), Colors.red),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // WIDGET CARD
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
