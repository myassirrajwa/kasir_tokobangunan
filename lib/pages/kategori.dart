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

    Get.defaultDialog(
      title: id == null ? "Tambah Produk" : "Edit Produk",
      backgroundColor: Colors.white,
      titleStyle: const TextStyle(
          fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 18),
      radius: 15,
      content: Column(
        children: [
          TextField(controller: nama, decoration: const InputDecoration(labelText: 'Nama Produk')),
          TextField(controller: jumlah, decoration: const InputDecoration(labelText: 'Jumlah'), keyboardType: TextInputType.number),
          TextField(controller: harga, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
        ],
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
          onPressed: () async {
            final h = int.tryParse(harga.text) ?? 0;

            if (id == null) {
              await c.tambahProduk(nama.text, jumlah.text, h);
            } else {
              await c.updateProduk(id, nama.text, jumlah.text, h);
            }

            Get.back();
            Get.snackbar("Sukses", id == null ? "Produk ditambahkan" : "Produk diperbarui",
                backgroundColor: Colors.brown, colorText: Colors.white);
          },
          child: const Text("Simpan", style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5F2),
      appBar: AppBar(
        backgroundColor: Colors.brown,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text("Kategori Produk",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showProdukDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Produk", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: c.getProduk(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Colors.brown));
          }

          final data = snapshot.data!.docs;

          if (data.isEmpty) {
            return const Center(
                child: Text("Belum ada produk.",
                    style: TextStyle(color: Colors.brown, fontSize: 16)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final p = data[index];

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.brown.withOpacity(0.15),
                    child: const Icon(Icons.inventory_2, color: Colors.brown),
                  ),
                  title: Text(p['nama'],
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Jumlah: ${p['jumlah']}"),
                      Text("Harga: Rp ${rupiah.format(p['harga'])}",
                          style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => showProdukDialog(id: p.id, produk: p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          Get.defaultDialog(
                            title: "Hapus Produk?",
                            middleText: "Yakin ingin menghapus produk ini?",
                            backgroundColor: Colors.white,
                            titleStyle: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
                            contentPadding: const EdgeInsets.all(20),
                            radius: 15,
                            actions: [
                              TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text("Batal", style: TextStyle(color: Colors.brown))),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () async {
                                  await c.hapusProduk(p.id);
                                  Get.back();
                                  Get.snackbar("Berhasil", "Produk dihapus",
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white);
                                },
                                child: const Text("Hapus", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
