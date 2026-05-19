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

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: '${json['id'] ?? ''}',
      nama: json['product_name'] ?? json['name'] ?? '',
      kategori: json['category'] ?? '',
      jumlah: (json['quantity'] as num?)?.toInt() ?? 1,
      harga: (json['price'] as num?)?.toDouble() ?? 0.0,
      catatan: json['notes'],
      imageUrl: json['product']?['main_image'],
    );
  }
}

class OrderModel {
  final String orderId;
  final String namaPelanggan;
  final String nomorMeja;
  final DateTime waktuOrder;
  final List<MenuItemModel> items;
  final String? status;
  final String? paymentStatus;
  final String? queueNumber;

  OrderModel({
    required this.orderId,
    required this.namaPelanggan,
    required this.nomorMeja,
    required this.waktuOrder,
    required this.items,
    this.status,
    this.paymentStatus,
    this.queueNumber,
  });

  double get totalHarga => items.fold(0, (sum, item) => sum + item.subtotal);
  int get totalItem => items.fold(0, (sum, item) => sum + item.jumlah);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['order_items'] ?? [];
    final items = (rawItems as List)
        .map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return OrderModel(
      orderId: json['order_number'] ?? '${json['id'] ?? ''}',
      namaPelanggan: json['customer_name'] ?? json['user']?['name'] ?? '-',
      nomorMeja: json['table_number']?.toString() ?? json['table_id']?.toString() ?? '-',
      waktuOrder: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      items: items,
      status: json['status'],
      paymentStatus: json['payment_status'],
      queueNumber: json['queue_number']?.toString(),
    );
  }
}
