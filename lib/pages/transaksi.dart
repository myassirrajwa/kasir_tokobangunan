import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kasir_toko_bangunan/pages/sukses_page.dart';

class TransaksiPage extends StatefulWidget {
  final String title;
  const TransaksiPage({super.key, required this.title});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final NumberFormat rupiah = NumberFormat("#,###", "id_ID");

  final Map<String, int> jumlahMap = {};
  final Map<String, String> satuanMap = {};

  List<QueryDocumentSnapshot> produkList = [];

  @override
  void initState() {
    super.initState();
    _ambilDataProduk();
  }

  Future<void> _ambilDataProduk() async {
    final snapshot = await db.collection('produk').orderBy('nama').get();
    setState(() {
      produkList = snapshot.docs;
    });
  }

  void _tambahJumlah(String id) async {
    final doc = produkList.firstWhere((e) => e.id == id);
    final data = doc.data()! as Map<String, dynamic>;
    final stok = int.tryParse(data['jumlah'].toString()) ?? 0;
    final jumlahSekarang = jumlahMap[id] ?? 0;

    if (jumlahSekarang < stok) {
      setState(() {
        jumlahMap[id] = jumlahSekarang + 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Stok ${data['nama']} hanya tersisa $stok!')),
      );
    }
  }

  void _kurangiJumlah(String id) {
    setState(() {
      if ((jumlahMap[id] ?? 0) > 0) jumlahMap[id] = jumlahMap[id]! - 1;
    });
  }

  int getHargaPaku(String satuan) {
    switch (satuan) {
      case 'pcs':
        return 2000;
      case 'kg':
        return 50000;
      case 'pack':
        return 100000;
      default:
        return 0;
    }
  }

  int _hitungTotalSemua() {
    int total = 0;
    for (var produk in produkList) {
      final id = produk.id;
      final data = produk.data() as Map<String, dynamic>;
      final nama = (data['nama'] ?? '').toString();
      final hargaDasar = (data['harga'] ?? 0) as int;
      final jumlah = jumlahMap[id] ?? 0;

      if (jumlah > 0) {
        final isPaku = nama.toLowerCase() == 'paku';
        final satuan = satuanMap[id] ?? 'pcs';
        final harga = isPaku ? getHargaPaku(satuan) : hargaDasar;
        total += harga * jumlah;
      }
    }
    return total;
  }

  Future<void> _tampilkanDialogPembayaran(int total) async {
    String? metodePembayaran;
    String namaPembeli = '';
    bool diantar = false;
    String alamat = '';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFF8F0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                '💳 Pilih Metode Pembayaran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioListTile<String>(
                      activeColor: Colors.brown,
                      title: const Text('QRIS'),
                      value: 'QRIS',
                      groupValue: metodePembayaran,
                      onChanged: (value) =>
                          setStateDialog(() => metodePembayaran = value),
                    ),
                    RadioListTile<String>(
                      activeColor: Colors.brown,
                      title: const Text('Tunai'),
                      value: 'Tunai',
                      groupValue: metodePembayaran,
                      onChanged: (value) =>
                          setStateDialog(() => metodePembayaran = value),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Nama Pembeli',
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown),
                        ),
                      ),
                      onChanged: (value) => namaPembeli = value,
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      activeColor: Colors.brown,
                      title: const Text('Diantar ke alamat?'),
                      value: diantar,
                      onChanged: (value) =>
                          setStateDialog(() => diantar = value ?? false),
                    ),
                    if (diantar)
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Alamat Pengantaran',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.brown),
                          ),
                        ),
                        onChanged: (value) => alamat = value,
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.brown)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (metodePembayaran == null || namaPembeli.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Isi semua data terlebih dahulu'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuccessPage(
                          namaPembeli: namaPembeli,
                          metode: metodePembayaran!,
                          diantar: diantar,
                          alamat: alamat,
                          total: total,
                          daftarBarang: jumlahMap.entries
                              .map((entry) {
                                final produkId = entry.key;
                                final jumlah = entry.value;
                                if (jumlah > 0) {
                                  final satuan = satuanMap[produkId] ?? 'pcs';
                                  return {
                                    'id': produkId,
                                    'nama': 'Produk $produkId',
                                    'jumlah': jumlah,
                                    'harga': 0,
                                    'satuan': satuan,
                                  };
                                }
                                return null;
                              })
                              .whereType<Map<String, dynamic>>()
                              .toList(),
                        ),
                      ),
                    );
                  },
                  child: const Text('Konfirmasi', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSemua = _hitungTotalSemua();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Transaksi Barang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown,
        centerTitle: true,
        elevation: 4,
      ),
      body: produkList.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: produkList.length,
                    itemBuilder: (context, index) {
                      final produk = produkList[index];
                      final id = produk.id;
                      final data = produk.data() as Map<String, dynamic>;
                      final nama = (data['nama'] ?? '').toString();
                      final hargaDasar = (data['harga'] ?? 0) as int;
                      final jumlahBeli = jumlahMap[id] ?? 0;
                      final isPaku = nama.toLowerCase() == 'paku';
                      final satuanDipilih = satuanMap[id] ?? 'pcs';
                      final harga =
                          isPaku ? getHargaPaku(satuanDipilih) : hargaDasar;
                      final total = harga * jumlahBeli;

                      return Card(
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    nama,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                  const Icon(Icons.inventory, color: Colors.brown),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Harga: Rp ${rupiah.format(harga)}',
                                style: const TextStyle(color: Colors.black87),
                              ),
                              const Divider(height: 20, color: Colors.brown),
                              if (isPaku)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Satuan:'),
                                    DropdownButton<String>(
                                      dropdownColor: Colors.white,
                                      value: satuanDipilih,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'pcs', child: Text('pcs')),
                                        DropdownMenuItem(
                                            value: 'pack', child: Text('pack')),
                                        DropdownMenuItem(
                                            value: 'kg', child: Text('kg')),
                                      ],
                                      onChanged: (value) =>
                                          setState(() => satuanMap[id] = value!),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Jumlah:'),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline,
                                            color: Colors.brown),
                                        onPressed: () => _kurangiJumlah(id),
                                      ),
                                      Text('$jumlahBeli'),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline,
                                            color: Colors.brown),
                                        onPressed: () => _tambahJumlah(id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                'Subtotal: Rp ${rupiah.format(total)}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Keseluruhan:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Rp ${rupiah.format(totalSemua)}',
                            style: const TextStyle(
                              color: Colors.brown,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        icon: const Icon(Icons.receipt, color: Colors.white),
                        label: const Text(
                          'Check Out',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: totalSemua > 0
                            ? () => _tampilkanDialogPembayaran(totalSemua)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
