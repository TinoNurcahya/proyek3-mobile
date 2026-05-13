class MenuItemModel {
  final String id;
  final String nama;
  final String kategori;
  final int jumlah;
  final double harga;
  final String? catatan;
  final String? imageUrl;

  MenuItemModel({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.jumlah,
    required this.harga,
    this.catatan,
    this.imageUrl,
  });

  double get subtotal => jumlah * harga;
}

class OrderModel {
  final String orderId;
  final String namaPelanggan;
  final String nomorMeja;
  final DateTime waktuOrder;
  final List<MenuItemModel> items;

  OrderModel({
    required this.orderId,
    required this.namaPelanggan,
    required this.nomorMeja,
    required this.waktuOrder,
    required this.items,
  });

  double get totalHarga => items.fold(0, (sum, item) => sum + item.subtotal);
  int get totalItem => items.fold(0, (sum, item) => sum + item.jumlah);
}
