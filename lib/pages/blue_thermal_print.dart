import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';

class StrukPrinter {
  final bluetooth = BlueThermalPrinter.instance;
  final NumberFormat rupiah = NumberFormat("#,###", "id_ID");

  Future<void> printStruk({
    required String namaPembeli,
    required String metode,
    required bool diantar,
    required String alamat,
    required int total,
    required int uangCustomer,
    required int kembalian,
    required List<Map<String, dynamic>> daftarBarang,
  }) async {

    List<BluetoothDevice> bonded = await bluetooth.getBondedDevices();
    if (bonded.isEmpty) {
      print("Tidak ada printer yang terhubung!");
      return;
    }

    BluetoothDevice device = bonded.first;

    try {
      await bluetooth.connect(device);
    } catch (e) {
      print("Gagal connect: $e");
    }

    bluetooth.printNewLine();
    bluetooth.printCustom("TOKO BANGUNAN MAKMUR JAYA", 1, 1);
    bluetooth.printCustom("Jl. Raya Makmur No. 123, Jakarta", 0, 1);

    bluetooth.printNewLine();
    bluetooth.printCustom("--------------------------------", 0, 1);

    bluetooth.printLeftRight("Pembeli", namaPembeli, 0);
    bluetooth.printLeftRight("Pembayaran", metode, 0);
    bluetooth.printLeftRight("Pengantaran", diantar ? "Ya" : "Tidak", 0);
    if (diantar) {
      bluetooth.printLeftRight("Alamat", alamat, 0);
    }

    bluetooth.printCustom("--------------------------------", 0, 1);
    bluetooth.printCustom("Daftar Barang", 1, 1);
    bluetooth.printNewLine();

    for (var item in daftarBarang) {
      bluetooth.printLeftRight(
        "${item['nama']} (${item['jumlah']}x)",
        "Rp ${rupiah.format(item['harga'])}",
        0,
      );
    }

    bluetooth.printCustom("--------------------------------", 0, 1);

    bluetooth.printLeftRight("Uang Customer", "Rp ${rupiah.format(uangCustomer)}", 0);
    bluetooth.printLeftRight("Kembalian", "Rp ${rupiah.format(kembalian)}", 0);
    bluetooth.printLeftRight("TOTAL", "Rp ${rupiah.format(total)}", 1);

    bluetooth.printNewLine();
    bluetooth.printCustom("Terima kasih telah berbelanja!", 0, 1);

    bluetooth.printNewLine();
    bluetooth.paperCut();
    bluetooth.disconnect();
  }
}
