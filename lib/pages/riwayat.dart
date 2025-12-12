import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RiwayatPage extends StatefulWidget {
  final String title;
  const RiwayatPage({super.key, required this.title});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> with SingleTickerProviderStateMixin {
  final db = FirebaseFirestore.instance;
  final NumberFormat rupiah = NumberFormat("#,###", "id_ID");
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.brown,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color:Color(0xFFFFFFFF),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'PEMBELIAN'),
            Tab(text: 'PENGELUARAN'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRiwayatPembelian(),
          _buildRiwayatPengeluaran(),
        ],
      ),
    );
  }

  Widget _buildRiwayatPembelian() {
    return StreamBuilder<QuerySnapshot>(
      stream: db.collection('transaksi')
          .orderBy('tanggal', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.shopping_cart_outlined,
            message: "Belum ada transaksi pembelian",
            color: const Color(0xFF8B4513),
          );
        }

        final transaksi = snapshot.data!.docs;
        String? lastDate;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: transaksi.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = transaksi[index];
            final data = doc.data() as Map<String, dynamic>;
            final Timestamp ts = data['tanggal'];
            final DateTime tanggal = ts.toDate();
            final String formattedDate = DateFormat("EEEE, dd MMMM yyyy").format(tanggal);
            final String nama = data['nama'] ?? "Pelanggan";
            final int total = (data['total'] ?? 0).toInt();
            final bool diantar = data['diantar'] ?? false;
            final String alamat = data['alamat'] ?? "-";
            final List items = data['daftarBarang'] ?? [];
            final String time = DateFormat("HH:mm").format(tanggal);

            final bool showDateHeader = lastDate != formattedDate;
            lastDate = formattedDate;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDateHeader) _buildDateHeader(formattedDate),
                _buildTransactionCard(
                  nama: nama,
                  total: total,
                  time: time,
                  diantar: diantar,
                  alamat: alamat,
                  items: items,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRiwayatPengeluaran() {
    return StreamBuilder<QuerySnapshot>(
      stream: db.collection('pengeluaran')
          .orderBy('tanggal', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.money_off_outlined,
            message: "Belum ada riwayat pengeluaran",
            color: const Color(0xFFD32F2F),
          );
        }

        final pengeluaran = snapshot.data!.docs;
        String? lastDate;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: pengeluaran.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = pengeluaran[index];
            final data = doc.data() as Map<String, dynamic>;
            final Timestamp ts = data['tanggal'];
            final DateTime tanggal = ts.toDate();
            final String formattedDate = DateFormat("EEEE, dd MMMM yyyy").format(tanggal);
            final String nama = data['nama'] ?? "Pengeluaran";
            final int jumlah = data['jumlah'] ?? 0;
            final String keterangan = data['keterangan'] ?? "";
            final String time = DateFormat("HH:mm").format(tanggal);

            final bool showDateHeader = lastDate != formattedDate;
            lastDate = formattedDate;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDateHeader) _buildDateHeader(formattedDate, isPengeluaran: true),
                _buildExpenseCard(
                  nama: nama,
                  jumlah: jumlah,
                  time: time,
                  keterangan: keterangan,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateHeader(String date, {bool isPengeluaran = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, top: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: isPengeluaran ? const Color(0xFFFFEBEE) : const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPengeluaran ? const Color(0xFFFFCDD2) : const Color(0xFFE1BEE7),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPengeluaran ? Icons.calendar_today_outlined : Icons.calendar_month_outlined,
            color: isPengeluaran ? const Color(0xFFD32F2F) : const Color(0xFF7B1FA2),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              date,
              style: TextStyle(
                color: isPengeluaran ? const Color(0xFFD32F2F) : const Color(0xFF7B1FA2),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard({
    required String nama,
    required int total,
    required String time,
    required bool diantar,
    required String alamat,
    required List items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF8B4513).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: Color(0xFF8B4513),
            size: 24,
          ),
        ),
        title: Text(
          nama,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "Rp ${rupiah.format(total)}",
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: diantar ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    diantar ? "Diantar" : "Ambil Sendiri",
                    style: TextStyle(
                      color: diantar ? const Color(0xFF2E7D32) : const Color(0xFFF57C00),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (diantar && alamat.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alamat,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Detail Barang",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                ),
                ...items.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final e = entry.value;
                  int jumlah = e['jumlah'] ?? 0;
                  int harga = e['harga'] ?? 0;
                  int totalItem = jumlah * harga;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B4513).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              "${idx + 1}",
                              style: const TextStyle(
                                color: Color(0xFF8B4513),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e['nama'] ?? "Barang",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "Rp ${rupiah.format(harga)}/item",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "$jumlah x",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "Rp ${rupiah.format(totalItem)}",
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard({
    required String nama,
    required int jumlah,
    required String time,
    required String keterangan,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.money_off_outlined,
            color: Color(0xFFD32F2F),
            size: 24,
          ),
        ),
        title: Text(
          nama,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "Rp ${rupiah.format(jumlah)}",
              style: const TextStyle(
                color: Color(0xFFD32F2F),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (keterangan.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                keterangan,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF8B4513),
          ),
          const SizedBox(height: 16),
          Text(
            "Memuat riwayat...",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Riwayat akan muncul di sini",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}