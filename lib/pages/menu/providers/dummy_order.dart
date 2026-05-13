import 'package:proyek3_mobile/models/order_model.dart';

// ============================================================
// DUMMY DATA (ganti dengan data dari API/provider kamu)
// ============================================================

final dummyOrders = [
  OrderModel(
    orderId: 'ORD-20260512-001',
    namaPelanggan: 'Budi Santoso',
    nomorMeja: '5',
    waktuOrder: DateTime(2026, 5, 12, 19, 30),
    items: [
      MenuItemModel(
        id: '1',
        nama: 'Caramel Latte',
        kategori: 'Coffee',
        jumlah: 2,
        harga: 32000,
        catatan: 'Less sugar',
      ),
      MenuItemModel(
        id: '2',
        nama: 'Croissant Butter',
        kategori: 'Dessert',
        jumlah: 1,
        harga: 22000,
        catatan: '',
      ),
    ],
  ),

  OrderModel(
    orderId: 'ORD-20260512-002',
    namaPelanggan: 'Cindy Aurelia',
    nomorMeja: '2',
    waktuOrder: DateTime(2026, 5, 12, 20, 10),
    items: [
      MenuItemModel(
        id: '3',
        nama: 'Matcha Latte',
        kategori: 'Non Coffee',
        jumlah: 1,
        harga: 34000,
        catatan: 'Oat milk',
      ),
      MenuItemModel(
        id: '4',
        nama: 'Red Velvet Cake',
        kategori: 'Dessert',
        jumlah: 2,
        harga: 27000,
        catatan: '',
      ),
    ],
  ),

  OrderModel(
    orderId: 'ORD-20260512-003',
    namaPelanggan: 'Kevin Wijaya',
    nomorMeja: '8',
    waktuOrder: DateTime(2026, 5, 12, 20, 45),
    items: [
      MenuItemModel(
        id: '5',
        nama: 'Americano',
        kategori: 'Coffee',
        jumlah: 1,
        harga: 25000,
        catatan: 'Hot',
      ),
      MenuItemModel(
        id: '6',
        nama: 'Chicken Katsu Curry',
        kategori: 'Main Course',
        jumlah: 1,
        harga: 52000,
        catatan: 'Pedas sedang',
      ),
    ],
  ),

  OrderModel(
    orderId: 'ORD-20260512-004',
    namaPelanggan: 'Nadya Putri',
    nomorMeja: '1',
    waktuOrder: DateTime(2026, 5, 12, 21, 05),
    items: [
      MenuItemModel(
        id: '7',
        nama: 'Chocolate Milkshake',
        kategori: 'Non Coffee',
        jumlah: 2,
        harga: 30000,
        catatan: '',
      ),
      MenuItemModel(
        id: '8',
        nama: 'Cheesecake Lotus',
        kategori: 'Dessert',
        jumlah: 1,
        harga: 33000,
        catatan: '',
      ),
    ],
  ),

  OrderModel(
    orderId: 'ORD-20260512-005',
    namaPelanggan: 'Rizky Ramadhan',
    nomorMeja: '10',
    waktuOrder: DateTime(2026, 5, 12, 21, 20),
    items: [
      MenuItemModel(
        id: '9',
        nama: 'Beef Burger Deluxe',
        kategori: 'Main Course',
        jumlah: 1,
        harga: 58000,
        catatan: 'Extra cheese',
      ),
      MenuItemModel(
        id: '10',
        nama: 'Truffle French Fries',
        kategori: 'Snack',
        jumlah: 1,
        harga: 28000,
        catatan: '',
      ),
    ],
  ),
];
