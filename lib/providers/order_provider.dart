import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _filterStatus;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<OrderModel> get orders => _orders;
  // Alias dipakai di UI lama
  List<OrderModel> get confirmedOrders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get hasMore => _hasMore;
  String? get filterStatus => _filterStatus;

  Future<void> fetchOrders({String? status, int page = 1}) async {
    if (page == 1) {
      _currentPage = 1;
      _hasMore = true;
      _filterStatus = status;
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    final result = await OrderService.getOrders(status: _filterStatus, page: _currentPage);

    if (result['success'] == true) {
      final data = result['data'] as List<dynamic>? ?? [];
      final List<OrderModel> newItems = data
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();

      if (page == 1) {
        _orders = newItems;
      } else {
        _orders.addAll(newItems);
      }

      if (newItems.length < 15) _hasMore = false;
    } else {
      if (page == 1) _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Alias untuk kompatibilitas dengan kode lama
  Future<void> loadOrders({bool refresh = true, String? status}) =>
      fetchOrders(status: status, page: 1);

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    _currentPage++;
    await fetchOrders(page: _currentPage);
  }

  Future<void> fetchOrderDetail(int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await OrderService.getOrderDetail(orderId);

    if (result['success'] == true) {
      _selectedOrder = OrderModel.fromJson(result['data'] as Map<String, dynamic>);
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCurrentOrder(OrderModel order) {
    _selectedOrder = order;
    notifyListeners();
  }

  void clearCurrentOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  Future<bool> updateOrderStatus(int orderId, String status) async {
    final result = await OrderService.updateOrderStatus(orderId, status);

    if (result['success'] == true) {
      final index = _orders.indexWhere((o) => o.orderId == orderId.toString());
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: status);
      }
      if (_selectedOrder?.orderId == orderId.toString()) {
        _selectedOrder = _selectedOrder?.copyWith(status: status);
      }
      notifyListeners();
      return true;
    }

    _errorMessage = result['message'];
    notifyListeners();
    return false;
  }
}
