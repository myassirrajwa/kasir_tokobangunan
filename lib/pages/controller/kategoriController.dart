import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProdukController extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Stream produk realtime
  Stream<QuerySnapshot> getProduk() {
    return db
        .collection('produk')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  // Tambah
  Future<void> tambahProduk(String nama, String jumlah, int harga) async {
    await db.collection('produk').add({
      'nama': nama,
      'jumlah': jumlah,
      'harga': harga,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Edit
  Future<void> updateProduk(String id, String nama, String jumlah, int harga) async {
    await db.collection('produk').doc(id).update({
      'nama': nama,
      'jumlah': jumlah,
      'harga': harga,
    });
  }

  // Hapus
  Future<void> hapusProduk(String id) async {
    await db.collection('produk').doc(id).delete();
  }
}
