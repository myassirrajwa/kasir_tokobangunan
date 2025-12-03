import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StrukPage extends StatelessWidget {
  final String namaPembeli;
  final String metode;
  final bool diantar;
  final String alamat;
  final int total;
  final List<Map<String, dynamic>> daftarBarang;

  const StrukPage({
    super.key,
    required this.namaPembeli,
    required this.metode,
    required this.diantar,
    required this.alamat,
    required this.total,
    required this.daftarBarang,
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
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'TOKO BANGUNAN MAKMUR JAYA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Jl. Raya Makmur No. 123, Jakarta',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const Divider(thickness: 1.2, height: 30, color: Colors.brown),

                _buildRow('Nama Pembeli', namaPembeli),
                _buildRow('Metode Pembayaran', metode),
                _buildRow('Pengantaran', diantar ? 'Ya' : 'Tidak'),
                if (diantar) _buildRow('Alamat', alamat),

                const Divider(height: 30, color: Colors.brown),
                const Text(
                  'Daftar Barang',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 10),
                ...daftarBarang.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['nama'],
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                        Text(
                          '${item['jumlah']}x',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        Text(
                          'Rp ${rupiah.format(item['harga'])}',
                          style: const TextStyle(
                            color: Colors.brown,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 30, color: Colors.brown),
                _buildRow(
                  'Total',
                  'Rp ${rupiah.format(total)}',
                  isBold: true,
                  fontSize: 18,
                  color: Colors.brown,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Terima kasih telah berbelanja!',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 14,
    Color color = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: fontSize, color: Colors.grey[700]),
          ),
          Text(
            value.isNotEmpty ? value : '-',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
