import 'package:flutter/material.dart';
import 'package:proyek3_mobile/models/order_model.dart';
import 'dummy_order.dart';

class OrderProvider extends ChangeNotifier {
  // Order yang sedang dibuka di halaman detail
  OrderModel? currentOrder;

  // Daftar semua order yang sudah terkonfirmasi
  // Nanti ganti dengan fetch dari API
  List<OrderModel> confirmedOrders = dummyOrders;

  // Dipanggil saat user klik salah satu card di DaftarOrderPage
  void setCurrentOrder(OrderModel order) {
    currentOrder = order;
    notifyListeners();
  }

  void clearCurrentOrder() {
    currentOrder = null;
    notifyListeners();
  }
}
