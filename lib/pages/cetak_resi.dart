import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasir_toko_bangunan/pages/blue_thermal_print.dart';

class StrukPage extends StatelessWidget {
  final String namaPembeli;
  final String metode;
  final bool diantar;
  final String alamat;
  final int total;
  final List<Map<String, dynamic>> daftarBarang;
  final int uangCustomer;
  final int kembalian;

  const StrukPage({
    super.key,
    required this.namaPembeli,
    required this.metode,
    required this.diantar,
    required this.alamat,
    required this.total,
    required this.daftarBarang,
    required this.uangCustomer,
    required this.kembalian,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat rupiah = NumberFormat("#,###", "id_ID");

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Struk Pembayaran',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.brown,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF6F5F2),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'TOKO BANGUNAN MAKMUR JAYA',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text(
                'Jl. Raya Makmur No. 123, Jakarta',
                style: TextStyle(fontSize: 12),
              ),

              const SizedBox(height: 10),
              const Divider(), 
              _row("Pembeli", namaPembeli),
              _row("Pembayaran", metode),
              _row("Pengantaran", diantar ? "Ya" : "Tidak"),
              if (diantar) _row("Alamat", alamat),

              const Divider(),

              const Text(
                "Daftar Barang",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ...daftarBarang.map(
                (item) => _row(
                  "${item['nama']} (${item['jumlah']}x)",
                  "Rp ${rupiah.format(item['harga'])}",
                ),
              ),

              const Divider(),

              _row("Uang Customer", "Rp ${rupiah.format(uangCustomer)}"),
              _row("Kembalian", "Rp ${rupiah.format(kembalian)}"),
              _row("TOTAL", "Rp ${rupiah.format(total)}", isBold: true),


              const Divider(),
              const SizedBox(height: 10),

              const Text(
                "Terima kasih telah berbelanja!",
                style: TextStyle(fontStyle: FontStyle.italic),
              )
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.brown,
        icon: const Icon(Icons.print, color: Colors.white),
        label: const Text("Print Struk", style: TextStyle(color: Colors.white)),
        onPressed: () {
          StrukPrinter().printStruk(
            namaPembeli: namaPembeli,
            metode: metode,
            diantar: diantar,
            alamat: alamat,
            total: total,
            uangCustomer: uangCustomer,
            kembalian: kembalian,
            daftarBarang: daftarBarang,
          );
        },
      ),
    );
  }

  Widget _row(String left, String right, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            right,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
