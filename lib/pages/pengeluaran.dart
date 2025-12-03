import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({super.key});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();

  final Color primaryColor = const Color(0xFF8B4513); // coklat tua
  final Color accentColor = const Color(0xFF5D4037);
  final Color backgroundColor = const Color(0xFFF5EDE1);
  final Color cardColor = const Color(0xFFFFF8F0);

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _tambahPengeluaran() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('pengeluaran').add({
        'deskripsi': _deskripsiController.text.trim(),
        'jumlah': int.parse(_jumlahController.text),
        'tanggal': DateTime.now(),
      });

      _deskripsiController.clear();
      _jumlahController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pengeluaran berhasil ditambahkan ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menambahkan pengeluaran: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Pengeluaran Toko",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form tambah pengeluaran
            Card(
              color: cardColor,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Tambah Pengeluaran",
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _deskripsiController,
                        decoration: _inputDecoration(
                          label: "Deskripsi Pengeluaran",
                          icon: Icons.description_outlined,
                        ),
                        validator: (value) => value!.isEmpty
                            ? "Deskripsi tidak boleh kosong"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _jumlahController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          label: "Jumlah (Rp)",
                          icon: Icons.attach_money_outlined,
                        ),
                        validator: (value) => value!.isEmpty
                            ? "Jumlah tidak boleh kosong"
                            : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _tambahPengeluaran,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "SIMPAN",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Daftar pengeluaran
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pengeluaran')
                    .orderBy('tanggal', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Belum ada data pengeluaran"));
                  }

                  final data = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      final tanggal = (item['tanggal'] as Timestamp).toDate();
                      final jumlah = item['jumlah'] ?? 0;
                      final deskripsi = item['deskripsi'] ?? "";

                      return Card(
                        color: cardColor,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.8),
                            child: const Icon(Icons.money_off, color: Colors.white),
                          ),
                          title: Text(
                            deskripsi,
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(tanggal),
                            style: TextStyle(color: Colors.brown.shade500),
                          ),
                          trailing: Text(
                            "Rp ${NumberFormat('#,###').format(jumlah)}",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.brown.shade600),
      prefixIcon: Icon(icon, color: primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: cardColor,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
    );
  }
}
