import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kasir_toko_bangunan/pages/cetak_resi.dart';

class SuccessPage extends StatelessWidget {
  final String namaPembeli;
  final String metode;
  final bool diantar;
  final String alamat;
  final int total;
  final int uangCustomer;
  final int kembalian;

  final List<Map<String, dynamic>> daftarBarang;

  const SuccessPage({
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

  Future<void> simpanTransaksi() async {
    try {
      final transaksi = {
        'nama': namaPembeli,
        'metode': metode,
        'diantar': diantar,
        'alamat': diantar ? alamat : '-',
        'total': total,
        'tanggal': Timestamp.now(),
        'daftarBarang': daftarBarang,
      };

      await FirebaseFirestore.instance.collection('transaksi').add(transaksi);
    } catch (e) {
      print('Gagal menyimpan transaksi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat("#,###", "id_ID");

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 110,
                color: Color.fromARGB(255, 60, 139, 72),
              ),
              const SizedBox(height: 20),
              const Text(
                "Pembayaran Berhasil!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff5C3B20),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Terima kasih, $namaPembeli",
                style: const TextStyle(fontSize: 16, color: Color(0xFFA47551)),
              ),
              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _rowInfo("Metode Pembayaran", metode),
                    const SizedBox(height: 6),
                    _rowInfo(
                      "Uang Customer",
                      "Rp ${formatRupiah.format(uangCustomer)}",
                    ),
                    _rowInfo(
                      "Total Belanja",
                      "Rp ${formatRupiah.format(total)}",
                    ),
                    const SizedBox(height: 6),
                    const SizedBox(height: 6),
                    _rowInfo(
                      "Kembalian",
                      "Rp ${formatRupiah.format(kembalian)}",
                    ),
                    const SizedBox(height: 6),
                    _rowInfo("Pengantaran", diantar ? "Ya" : "Tidak"),
                    if (diantar)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: _rowInfo("Alamat", alamat),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await simpanTransaksi();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StrukPage(
                          namaPembeli: namaPembeli,
                          metode: metode,
                          diantar: diantar,
                          alamat: alamat,
                          total: total,
                          daftarBarang: daftarBarang,
                          uangCustomer: uangCustomer,
                          kembalian: kembalian,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9000),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Cetak Resi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E3C),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Kembali ke Transaksi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _rowInfo(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title : ",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF5C3B20),
            fontSize: 15,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFFA47551), fontSize: 15),
          ),
        ),
      ],
    );
  }
}
