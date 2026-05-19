import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  // Order yang sedang dibuka di halaman detail
  OrderModel? currentOrder;

  // Daftar semua order dari API
  List<OrderModel> _confirmedOrders = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _filterStatus;

  List<OrderModel> get confirmedOrders => _confirmedOrders;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get filterStatus => _filterStatus;

  OrderProvider() {
    loadOrders();
  }

  // ==================== LOAD / REFRESH ====================
  Future<void> loadOrders({bool refresh = true, String? status}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _filterStatus = status;
    }

    _isLoading = true;
    notifyListeners();

    final result = await OrderService.getOrders(
      status: _filterStatus,
      page: _currentPage,
    );

    _isLoading = false;

    if (result['success'] == true) {
      final raw = result['data'] as List<dynamic>? ?? [];
      final fetched = raw
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (refresh) {
        _confirmedOrders = fetched;
      } else {
        _confirmedOrders.addAll(fetched);
      }

      if (fetched.length < 15) _hasMore = false;
    }

    notifyListeners();
  }

  // ==================== LOAD MORE ====================
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    _currentPage++;
    await loadOrders(refresh: false);
  }

  // ==================== SET CURRENT ORDER ====================
  void setCurrentOrder(OrderModel order) {
    currentOrder = order;
    notifyListeners();
  }

  // ==================== LOAD DETAIL FROM API ====================
  Future<void> loadOrderDetail(int orderId) async {
    final result = await OrderService.getOrderDetail(orderId);
    if (result['success'] == true && result['data'] != null) {
      currentOrder =
          OrderModel.fromJson(result['data'] as Map<String, dynamic>);
      notifyListeners();
    }
  }

  // ==================== UPDATE STATUS ====================
  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    final result = await OrderService.updateOrderStatus(orderId, newStatus);
    if (result['success'] == true) {
      // Update di list lokal
      final idx = _confirmedOrders.indexWhere(
        (o) => o.orderId == orderId.toString(),
      );
      if (idx != -1) {
        final old = _confirmedOrders[idx];
        _confirmedOrders[idx] = OrderModel(
          orderId: old.orderId,
          namaPelanggan: old.namaPelanggan,
          nomorMeja: old.nomorMeja,
          waktuOrder: old.waktuOrder,
          items: old.items,
          status: newStatus,
          paymentStatus: old.paymentStatus,
          queueNumber: old.queueNumber,
        );
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  void clearCurrentOrder() {
    currentOrder = null;
    notifyListeners();
  }
}
