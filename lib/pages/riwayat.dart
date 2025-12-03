import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RiwayatTransaksi extends StatefulWidget {
  final String title;
  const RiwayatTransaksi({super.key, required this.title});

  @override
  State<RiwayatTransaksi> createState() => _RiwayatTransaksiState();
}

class _RiwayatTransaksiState extends State<RiwayatTransaksi> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final NumberFormat rupiah = NumberFormat("#,###", "id_ID");

  Future<String> getNamaProduk(String produkId) async {
    if (produkId == "-" || produkId.isEmpty) return "-";

    try {
      final doc = await FirebaseFirestore.instance
          .collection('produk')
          .doc(produkId)
          .get();

      if (doc.exists) {
        return doc.data()?['nama'] ?? "-";
      }
      return "-";
    } catch (e) {
      return "-";
    }
  }

  void _hapusTransaksi(String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Transaksi',
            style: TextStyle(color: Color(0xFF4E342E))),
        content: const Text('Yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal',
                  style: TextStyle(color: Color(0xFF4E342E)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD84315)),
            onPressed: () async {
              try {
                await db.collection('transaksi').doc(id).delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaksi berhasil dihapus!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus transaksi: $e')),
                );
              }
            },
            child:
                const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getStringField(QueryDocumentSnapshot doc, List<String> keys,
      String fallback) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    for (final k in keys) {
      if (data[k] != null) return data[k].toString();
    }
    return fallback;
  }

  int _getIntField(QueryDocumentSnapshot doc, String key, int fallback) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final v = data[key];
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) {
      return int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? fallback;
    }
    return fallback;
  }

  DateTime? _getDateField(QueryDocumentSnapshot doc, String key) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final v = data[key];
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _getDaftarBarang(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final raw = data['daftarBarang'] ?? data['items'] ?? data['cartItems'];

    if (raw == null) return [];
    try {
      return List<Map<String, dynamic>>.from(
        List.from(raw).map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EDE5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF795548),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Riwayat Transaksi',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: db
            .collection('transaksi')
            .orderBy('tanggal', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: Color(0xFF6D4C41)));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada transaksi.'));
          }

          final data = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final transaksi = data[index];

              final nama = _getStringField(
                  transaksi, ['nama', 'nama_pembeli'], '-');
              final total = _getIntField(transaksi, 'total', 0);
              final diantar =
                  (transaksi.data() as Map<String, dynamic>?)?['diantar'] ??
                      false;
              final alamat = _getStringField(transaksi, ['alamat'], '-');
              final waktu = _getDateField(transaksi, 'tanggal');
              final daftarBarang = _getDaftarBarang(transaksi);

              return Card(
                color: const Color(0xFFFFF8E1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  childrenPadding: const EdgeInsets.only(bottom: 12),

                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFD7CCC8),
                    child:
                        Icon(Icons.receipt_long, color: Color(0xFF5D4037)),
                  ),

                  title: Text(nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                        fontSize: 16,
                      )),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total: Rp ${rupiah.format(total)}",
                          style:
                              const TextStyle(color: Color(0xFF2E7D32))),
                      if (waktu != null)
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(waktu),
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF795548)),
                        ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              diantar ? Colors.green[100] : Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          diantar
                              ? "Diantar ke $alamat"
                              : "Ambil di toko",
                          style: TextStyle(
                            fontSize: 12,
                            color: diantar
                                ? Colors.green[700]
                                : Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete,
                        color: Color(0xFFD84315)),
                    onPressed: () => _hapusTransaksi(transaksi.id),
                  ),

                  children: [
                    const Divider(color: Color(0xFFBCAAA4)),

                    if (daftarBarang.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Tidak ada rincian barang."),
                      )
                    else
                      ...daftarBarang.map((item) {
                        final produkId = item['id'] ??
                            item['produkId'] ??
                            item['kode'] ??
                            "-";

                        final int jumlah = item['jumlah'] is int
                            ? item['jumlah']
                            : int.tryParse(item['jumlah'].toString()) ?? 0;

                        final int harga = item['harga'] is int
                            ? item['harga']
                            : int.tryParse(item['harga'].toString()) ?? 0;

                        final int totalItem = jumlah * harga;

                        return FutureBuilder(
                          future: getNamaProduk(produkId),
                          builder: (context, snapshot) {
                            String namaProduk =
                                snapshot.data ?? "Memuat...";

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      namaProduk,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF4E342E)),
                                    ),
                                  ),
                                  Text("${jumlah}x",
                                      style: const TextStyle(
                                          color: Color(0xFF6D4C41))),

                                  /// TOTAL ITEM
                                  Text(
                                    "Rp ${rupiah.format(totalItem)}",
                                    style: const TextStyle(
                                        color: Color(0xFF2E7D32)),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      })
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
