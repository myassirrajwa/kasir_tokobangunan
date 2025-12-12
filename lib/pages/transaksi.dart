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
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _ambilDataProduk();
  }

  Future<void> _ambilDataProduk() async {
    try {
      final snapshot = await db.collection('produk').orderBy('nama').get();
      setState(() {
        produkList = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
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
        SnackBar(
          content: Text('⚠️ Stok ${data['nama']} hanya tersisa $stok!'),
          backgroundColor: Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
        ),
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

  List<QueryDocumentSnapshot> get filteredProducts {
    if (searchQuery.isEmpty) return produkList;
    return produkList.where((produk) {
      final nama = produk['nama'].toString().toLowerCase();
      return nama.contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _tampilkanDialogPembayaran(int total) async {
    int uangCustomer = 0;
    int kembalian = 0;
    String? metodePembayaran;
    String namaPembeli = '';
    bool diantar = false;
    String alamat = '';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFF8F0),
                      Color(0xFFF5EBE0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF4A2C2A),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.credit_card,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pembayaran',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A2C2A),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: Colors.grey),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Total Pembayaran
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Pembayaran:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              'Rp ${rupiah.format(total)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A2C2A),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Input Nama Pembeli
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Nama Pembeli",
                          prefixIcon: Icon(Icons.person, color: Color(0xFF4A2C2A)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF4A2C2A), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (v) => namaPembeli = v,
                      ),

                      SizedBox(height: 16),

                      // Metode Pembayaran
                      Text(
                        'Metode Pembayaran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A2C2A),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: Text('QRIS'),
                              selected: metodePembayaran == 'QRIS',
                              onSelected: (selected) {
                                setStateDialog(() {
                                  metodePembayaran = selected ? 'QRIS' : null;
                                  uangCustomer = total;
                                  kembalian = 0;
                                });
                              },
                              selectedColor: Color(0xFF4A2C2A),
                              backgroundColor: Colors.grey.shade200,
                              labelStyle: TextStyle(
                                color: metodePembayaran == 'QRIS' ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: Text('Tunai'),
                              selected: metodePembayaran == 'Tunai',
                              onSelected: (selected) {
                                setStateDialog(() {
                                  metodePembayaran = selected ? 'Tunai' : null;
                                  uangCustomer = 0;
                                  kembalian = 0;
                                });
                              },
                              selectedColor: Color(0xFF4A2C2A),
                              backgroundColor: Colors.grey.shade200,
                              labelStyle: TextStyle(
                                color: metodePembayaran == 'Tunai' ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Input Uang Customer
                      if (metodePembayaran == 'Tunai') ...[
                        SizedBox(height: 16),
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Uang Customer",
                            prefixIcon: Icon(Icons.money, color: Color(0xFF4A2C2A)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF4A2C2A), width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (v) {
                            uangCustomer = int.tryParse(v) ?? 0;
                            setStateDialog(() {
                              kembalian = uangCustomer - total;
                            });
                          },
                        ),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kembalian >= 0 ? Color(0xFFE8F5E9) : Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: kembalian >= 0 ? Color(0xFFC8E6C9) : Color(0xFFFFCDD2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Kembalian:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                'Rp ${rupiah.format(kembalian < 0 ? 0 : kembalian)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kembalian >= 0 ? Color(0xFF2E7D32) : Color(0xFFD32F2F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Pengiriman
                      SizedBox(height: 16),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.delivery_dining, color: Color(0xFF4A2C2A)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Pengiriman',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4A2C2A),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              SwitchListTile(
                                title: Text('Diantar ke alamat?'),
                                value: diantar,
                                activeColor: Color(0xFF4A2C2A),
                                onChanged: (v) => setStateDialog(() => diantar = v),
                              ),
                              if (diantar)
                                TextField(
                                  decoration: InputDecoration(
                                    labelText: "Alamat Pengantaran",
                                    prefixIcon: Icon(Icons.location_on, color: Color(0xFF4A2C2A)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: (v) => alamat = v,
                                ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      // Tombol Aksi
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Color(0xFF4A2C2A)),
                              ),
                              child: Text(
                                'Batal',
                                style: TextStyle(
                                  color: Color(0xFF4A2C2A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (metodePembayaran == null || namaPembeli.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Isi semua data terlebih dahulu!"),
                                      backgroundColor: Color(0xFFD32F2F),
                                    ),
                                  );
                                  return;
                                }

                                if (metodePembayaran == "Tunai" && uangCustomer < total) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Uang customer kurang!"),
                                      backgroundColor: Color(0xFFD32F2F),
                                    ),
                                  );
                                  return;
                                }

                                final daftarBarang = jumlahMap.entries
                                    .map((e) {
                                      final id = e.key;
                                      final jumlah = e.value;
                                      if (jumlah > 0) {
                                        final data = produkList
                                            .firstWhere((p) => p.id == id)
                                            .data() as Map<String, dynamic>;

                                        final nama = data["nama"];
                                        final hargaDasar = data["harga"];
                                        final isPaku = nama.toString().toLowerCase() == "paku";
                                        final satuan = satuanMap[id] ?? "pcs";
                                        final harga = isPaku ? getHargaPaku(satuan) : hargaDasar;

                                        return {
                                          "id": id,
                                          "nama": nama,
                                          "jumlah": jumlah,
                                          "harga": harga,
                                          "satuan": satuan,
                                          "subtotal": harga * jumlah,
                                        };
                                      }
                                      return null;
                                    })
                                    .whereType<Map<String, dynamic>>()
                                    .toList();

                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SuccessPage(
                                      namaPembeli: namaPembeli,
                                      metode: metodePembayaran!,
                                      diantar: diantar,
                                      alamat: alamat,
                                      total: total,
                                      daftarBarang: daftarBarang,
                                      uangCustomer: uangCustomer,
                                      kembalian: kembalian < 0 ? 0 : kembalian,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF4A2C2A),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: Color(0xFF4A2C2A).withOpacity(0.3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Konfirmasi',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
      backgroundColor: Color(0xFFF9F5F0),
      body: Column(
        children: [
          // App Bar Custom
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A2C2A), Color(0xFF6D4C41)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.brown.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Transaksi Barang',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: Icon(Icons.shopping_cart, color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Cari produk...',
                        hintStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.search, color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Content
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF4A2C2A)),
                        SizedBox(height: 16),
                        Text(
                          'Memuat produk...',
                          style: TextStyle(
                            color: Color(0xFF4A2C2A),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
                            SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty
                                  ? 'Belum ada produk'
                                  : 'Produk tidak ditemukan',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final produk = filteredProducts[index];
                          final id = produk.id;
                          final data = produk.data() as Map<String, dynamic>;
                          final nama = (data['nama'] ?? '').toString();
                          final hargaDasar = (data['harga'] ?? 0) as int;
                          final stok = (data['jumlah'] ?? 0).toString();

                          final jumlahBeli = jumlahMap[id] ?? 0;
                          final isPaku = nama.toLowerCase() == 'paku';
                          final satuanDipilih = satuanMap[id] ?? 'pcs';
                          final harga = isPaku ? getHargaPaku(satuanDipilih) : hargaDasar;
                          final total = harga * jumlahBeli;

                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {},
                                  splashColor: Color(0xFF4A2C2A).withOpacity(0.1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    nama,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF4A2C2A),
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.price_change, size: 16, color: Colors.green),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Rp ${rupiah.format(harga)}',
                                                        style: TextStyle(
                                                          color: Colors.green.shade700,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Icon(Icons.inventory, size: 16, color: Colors.blue),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Stok: $stok',
                                                        style: TextStyle(
                                                          color: Colors.blue.shade700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFF4A2C2A).withOpacity(0.1),
                                              ),
                                              child: Icon(
                                                Icons.build_circle,
                                                color: Color(0xFF4A2C2A),
                                                size: 24,
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 16),

                                        // Satuan untuk Paku
                                        if (isPaku)
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFF5F5F5),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Satuan:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF4A2C2A),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF4A2C2A),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: DropdownButton<String>(
                                                    value: satuanDipilih,
                                                    dropdownColor: Color(0xFF4A2C2A),
                                                    underline: Container(),
                                                    icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                                                    items: const [
                                                      DropdownMenuItem(
                                                        value: 'pcs',
                                                        child: Text('pcs', style: TextStyle(color: Colors.white)),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'pack',
                                                        child: Text('pack', style: TextStyle(color: Colors.white)),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'kg',
                                                        child: Text('kg', style: TextStyle(color: Colors.white)),
                                                      ),
                                                    ],
                                                    onChanged: (value) => setState(() => satuanMap[id] = value!),
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        SizedBox(height: isPaku ? 16 : 0),

                                        // Jumlah Pembelian
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF5F5F5),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Jumlah:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF4A2C2A),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.grey.shade300),
                                                ),
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(Icons.remove, color: Colors.red),
                                                      onPressed: () => _kurangiJumlah(id),
                                                      splashRadius: 20,
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                                      decoration: BoxDecoration(
                                                        border: Border.symmetric(
                                                          horizontal: BorderSide(color: Colors.grey.shade300),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        '$jumlahBeli',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xFF4A2C2A),
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.add, color: Colors.green),
                                                      onPressed: () => _tambahJumlah(id),
                                                      splashRadius: 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Subtotal
                                        if (jumlahBeli > 0) ...[
                                          SizedBox(height: 12),
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFE8F5E9),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Color(0xFFC8E6C9)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'Subtotal:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF2E7D32),
                                                  ),
                                                ),
                                                Text(
                                                  'Rp ${rupiah.format(total)}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF2E7D32),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Footer Total
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pembelian:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Rp ${rupiah.format(totalSemua)}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A2C2A),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: totalSemua > 0 ? () => _tampilkanDialogPembayaran(totalSemua) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A2C2A),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: Color(0xFF4A2C2A).withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_bag, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Checkout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (totalSemua > 0) ...[
                  SizedBox(height: 8),
                  Text(
                    '${jumlahMap.values.where((j) => j > 0).length} produk dipilih',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}