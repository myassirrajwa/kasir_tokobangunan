import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PengeluaranPage extends StatefulWidget {
  final String title;

  const PengeluaranPage({super.key, required this.title});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final FocusNode _deskripsiFocus = FocusNode();
  final FocusNode _jumlahFocus = FocusNode();

  final Color primaryColor = Color(0xFF4A2C2A);
  final Color secondaryColor = Color(0xFF6D4C41);
  final Color accentColor = Color(0xFFD2691E);
  final Color backgroundColor = Color(0xFFF9F5F0);
  final Color cardColor = Colors.white;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  double totalPengeluaran = 0;

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

      // Reset focus
      _deskripsiFocus.unfocus();
      _jumlahFocus.unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Pengeluaran berhasil ditambahkan"),
          backgroundColor: Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Gagal menambahkan pengeluaran: $e"),
          backgroundColor: Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _hitungTotalPengeluaran(List<QueryDocumentSnapshot> data) {
    double total = 0;
    for (var doc in data) {
      total += (doc['jumlah'] ?? 0).toDouble();
    }
    if (total != totalPengeluaran) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          totalPengeluaran = total;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatRupiah = NumberFormat("#,###", "id_ID");

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: primaryColor,
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                "Pengeluaran Toko",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, secondaryColor],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Card Form Tambah Pengeluaran
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [cardColor, Color(0xFFF5F5F5)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Form
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.add_chart,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Tambah Pengeluaran Baru",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 24),

                                // Input Deskripsi
                                Text(
                                  "Deskripsi Pengeluaran",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _deskripsiController,
                                  focusNode: _deskripsiFocus,
                                  decoration: InputDecoration(
                                    hintText: "Contoh: Beli bahan bangunan, gaji karyawan, dll",
                                    prefixIcon: Icon(Icons.description, color: primaryColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: primaryColor, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  ),
                                  validator: (value) => value!.isEmpty
                                      ? "Deskripsi tidak boleh kosong"
                                      : null,
                                  maxLines: 2,
                                ),

                                SizedBox(height: 20),

                                // Input Jumlah
                                Text(
                                  "Jumlah (Rp)",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: _jumlahController,
                                  focusNode: _jumlahFocus,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Masukkan jumlah pengeluaran",
                                    prefixIcon: Icon(Icons.attach_money, color: primaryColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: primaryColor, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  ),
                                  validator: (value) => value!.isEmpty
                                      ? "Jumlah tidak boleh kosong"
                                      : null,
                                ),

                                SizedBox(height: 28),

                                // Tombol Simpan
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _tambahPengeluaran,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 4,
                                      shadowColor: primaryColor.withOpacity(0.3),
                                    ),
                                    child: _isLoading
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text("Menyimpan..."),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check_circle_outline, size: 22),
                                              SizedBox(width: 10),
                                              Text(
                                                "SIMPAN PENGELUARAN",
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
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Header Daftar Pengeluaran
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Riwayat Pengeluaran",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('pengeluaran')
                                .snapshots(),
                            builder: (context, snapshot) {
                              int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                              _hitungTotalPengeluaran(snapshot.data?.docs ?? []);
                              return Text(
                                "$count items",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Card Total Pengeluaran
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xFF4A2C2A),
                          Color(0xFF6D4C41),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total Pengeluaran",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Rp ${formatRupiah.format(totalPengeluaran.toInt())}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Icon(
                            Icons.bar_chart,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // List Pengeluaran
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('pengeluaran')
                .orderBy('tanggal', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(40),
                    padding: EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.money_off,
                          size: 70,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Belum Ada Pengeluaran",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Tambahkan pengeluaran pertama Anda",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final data = snapshot.data!.docs;
              _hitungTotalPengeluaran(data);

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = data[index];
                    final tanggal = (item['tanggal'] as Timestamp).toDate();
                    final jumlah = item['jumlah'] ?? 0;
                    final deskripsi = item['deskripsi'] ?? "";

                    return Container(
                      margin: EdgeInsets.fromLTRB(16, 0, 16, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon Container
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getIconByDeskripsi(deskripsi),
                                    color: primaryColor,
                                    size: 24,
                                  ),
                                ),

                                SizedBox(width: 16),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        deskripsi,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey.shade500,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            DateFormat('dd MMM yyyy, HH:mm').format(tanggal),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Amount
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "- Rp ${formatRupiah.format(jumlah)}",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD32F2F),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: data.length,
                ),
              );
            },
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  IconData _getIconByDeskripsi(String deskripsi) {
    final desc = deskripsi.toLowerCase();
    if (desc.contains('gaji') || desc.contains('upah')) return Icons.work;
    if (desc.contains('listrik') || desc.contains('air') || desc.contains('pdam')) 
      return Icons.bolt;
    if (desc.contains('bahan') || desc.contains('material')) return Icons.build;
    if (desc.contains('sewa') || desc.contains('kontrakan')) return Icons.home_work;
    if (desc.contains('transport') || desc.contains('bensin')) return Icons.directions_car;
    return Icons.payments;
  }
}