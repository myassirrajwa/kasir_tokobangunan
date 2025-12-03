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
  final List<Map<String, dynamic>> daftarBarang;

  const SuccessPage({
    super.key,
    required this.namaPembeli,
    required this.metode,
    required this.diantar,
    required this.alamat,
    required this.total,
    required this.daftarBarang,
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
      print('❌ Gagal menyimpan transaksi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 20),
              const Text('Pembayaran Berhasil!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Terima kasih, $namaPembeli',
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Metode: $metode'),
                    Text('Total: Rp ${NumberFormat("#,###", "id_ID").format(total)}'),
                    Text('Pengantaran: ${diantar ? 'Ya' : 'Tidak'}'),
                    if (diantar) Text('Alamat: $alamat'),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Tombol Cetak Resi
              ElevatedButton(
                onPressed: () async {
                  await simpanTransaksi();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StrukPage(
                        namaPembeli: namaPembeli,
                        metode: metode,
                        diantar: diantar,
                        alamat: alamat,
                        total: total,
                        daftarBarang: daftarBarang,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Cetak Resi',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),

              const SizedBox(height: 10),

              // Tombol Kembali
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Kembali ke Transaksi',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
