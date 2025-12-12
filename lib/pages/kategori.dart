import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kasir_toko_bangunan/pages/controller/kategoriController.dart';

class Kategori extends StatelessWidget {
  final String title;
  Kategori({super.key, required this.title});

  final ProdukController c = Get.put(ProdukController());
  final NumberFormat rupiah = NumberFormat("#,###", "id_ID");

  final nama = TextEditingController();
  final jumlah = TextEditingController();
  final harga = TextEditingController();

  // Dialog Tambah/Edit
  void showProdukDialog({String? id, DocumentSnapshot? produk}) {
    if (produk != null) {
      nama.text = produk['nama'];
      jumlah.text = produk['jumlah'];
      harga.text = produk['harga'].toString();
    } else {
      nama.clear();
      jumlah.clear();
      harga.clear();
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5F5F5), Color(0xFFEAEAEA)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 25,
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
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF4A2C2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        id == null ? Icons.add_circle : Icons.edit,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        id == null ? "Tambah Produk Baru" : "Edit Produk",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A2C2A),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: Colors.grey.shade600),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Input Fields
                TextFormField(
                  controller: nama,
                  decoration: InputDecoration(
                    labelText: 'Nama Produk',
                    prefixIcon: Icon(Icons.category, color: Color(0xFF4A2C2A)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFF4A2C2A),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: jumlah,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Jumlah',
                          prefixIcon: Icon(
                            Icons.inventory,
                            color: Color(0xFF4A2C2A),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF4A2C2A),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: harga,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Harga',
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: Color(0xFF4A2C2A),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF4A2C2A),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 28),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Color(0xFF4A2C2A)),
                        ),
                        child: Text(
                          "Batal",
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
                          final h = int.tryParse(harga.text) ?? 0;
                          final jml = jumlah.text;

                          if (nama.text.isEmpty || jml.isEmpty || h <= 0) {
                            Get.snackbar(
                              "Perhatian",
                              "Harap isi semua data dengan benar",
                              backgroundColor: Color(0xFFD32F2F),
                              colorText: Colors.white,
                            );
                            return;
                          }

                          if (id == null) {
                            await c.tambahProduk(nama.text, jml, h);
                          } else {
                            await c.updateProduk(id, nama.text, jml, h);
                          }

                          Get.back();
                          Get.snackbar(
                            "Sukses",
                            id == null
                                ? "Produk berhasil ditambahkan"
                                : "Produk berhasil diperbarui",
                            backgroundColor: Color(0xFF4A2C2A),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4A2C2A),
                          foregroundColor: Colors.white,
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
                            Icon(Icons.check_circle, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Simpan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F5F0),
      body: Column(
        children: [
          // App Bar
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: 16,
            ),
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
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Kategori Produk",
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
                        child: Icon(
                          Icons.category,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info, color: Colors.white70, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "Kelola produk toko bangunan Anda",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Content
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: c.getProduk(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF4A2C2A)),
                        SizedBox(height: 16),
                        Text(
                          "Memuat data produk...",
                          style: TextStyle(
                            color: Color(0xFF4A2C2A),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Container(
                      padding: EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Belum Ada Produk",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A2C2A),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Tambahkan produk pertama Anda\nuntuk mulai mengelola inventaris",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 25),
                          ElevatedButton.icon(
                            onPressed: () => showProdukDialog(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4A2C2A),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(Icons.add),
                            label: Text("Tambah Produk Pertama"),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final data = snapshot.data!.docs;
                int totalProduk = data.length;
                int totalStok = data.fold(
                  0,
                  (sum, doc) => sum + int.parse(doc['jumlah'] ?? '0'),
                );
                int totalNilai = data.fold(0, (sum, doc) {
                  return sum + (int.tryParse(doc['harga'].toString()) ?? 0);
                });

                return Column(
                  children: [
                    // Stats Cards
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Color(
                                            0xFF4A2C2A,
                                          ).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.layers,
                                          size: 20,
                                          color: Color(0xFF4A2C2A),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Total Produk",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    totalProduk.toString(),
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A2C2A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.inventory,
                                          size: 20,
                                          color: Colors.green,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Total Stok",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    totalStok.toString(),
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A2C2A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.attach_money,
                                          size: 20,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Total Nilai",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Rp ${rupiah.format(totalNilai)}",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A2C2A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Products List
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final p = data[index];

                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
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
                                  splashColor: Color(
                                    0xFF4A2C2A,
                                  ).withOpacity(0.1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Product Icon
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Color(
                                              0xFF4A2C2A,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.inventory_2,
                                            color: Color(0xFF4A2C2A),
                                            size: 28,
                                          ),
                                        ),

                                        SizedBox(width: 16),

                                        // Product Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p['nama'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF4A2C2A),
                                                ),
                                              ),
                                              SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.inventory,
                                                          size: 14,
                                                          color: Colors
                                                              .grey
                                                              .shade600,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          p['jumlah'],
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey
                                                                .shade700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFE8F5E9),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.attach_money,
                                                          size: 14,
                                                          color: Colors.green,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          "Rp ${rupiah.format(p['harga'])}",
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors
                                                                .green
                                                                .shade700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Action Buttons
                                        Column(
                                          children: [
                                            IconButton(
                                              onPressed: () => showProdukDialog(
                                                id: p.id,
                                                produk: p,
                                              ),
                                              style: IconButton.styleFrom(
                                                backgroundColor: Color(
                                                  0xFF4A2C2A,
                                                ).withOpacity(0.1),
                                              ),
                                              icon: Icon(
                                                Icons.edit,
                                                color: Color(0xFF4A2C2A),
                                                size: 20,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            IconButton(
                                              onPressed: () {
                                                Get.dialog(
                                                  AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    title: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.warning_amber,
                                                          color: Colors.orange,
                                                        ),
                                                        SizedBox(width: 12),
                                                        Text(
                                                          "Konfirmasi Hapus",
                                                          style: TextStyle(
                                                            color: Color(
                                                              0xFF4A2C2A,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    content: Text(
                                                      "Apakah Anda yakin ingin menghapus produk '${p['nama']}'?",
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey
                                                            .shade700,
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Get.back(),
                                                        child: Text(
                                                          "Batal",
                                                          style: TextStyle(
                                                            color: Color(
                                                              0xFF4A2C2A,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          await c.hapusProduk(
                                                            p.id,
                                                          );
                                                          Get.back();
                                                          Get.snackbar(
                                                            "Berhasil",
                                                            "Produk berhasil dihapus",
                                                            backgroundColor:
                                                                Color(
                                                                  0xFF4A2C2A,
                                                                ),
                                                            colorText:
                                                                Colors.white,
                                                          );
                                                        },
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Color(
                                                                    0xFFD32F2F,
                                                                  ),
                                                            ),
                                                        child: Text("Hapus"),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              style: IconButton.styleFrom(
                                                backgroundColor: Color(
                                                  0xFFD32F2F,
                                                ).withOpacity(0.1),
                                              ),
                                              icon: Icon(
                                                Icons.delete,
                                                color: Color(0xFFD32F2F),
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
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
                  ],
                );
              },
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProdukDialog(),
        icon: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(Icons.add, color: Color(0xFF4A2C2A), size: 24),
        ),
        label: Text(
          "Tambah Produk",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        backgroundColor: Color(0xFF4A2C2A),
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
