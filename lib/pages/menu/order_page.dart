import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/bottom_navbar.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/empty_state_widget.dart';

class DaftarOrderPage extends StatefulWidget {
  const DaftarOrderPage({super.key});

  @override
  State<DaftarOrderPage> createState() => _DaftarOrderPageState();
}

class _DaftarOrderPageState extends State<DaftarOrderPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  static const Color kDark = Color(0xFF1A1A1A);
  static const Color kBrown = Color(0xFFB5714A);
  static const Color kBg = Color(0xFFF2F2F2);
  static const Color kCard = Color(0xFFFFFFFF);
  static const Color kTextSecondary = Color(0xFF888888);

  static const _tabs = [
    {'label': 'Semua', 'status': null},
    {'label': 'Pending', 'status': 'pending_confirmation'},
    {'label': 'Proses', 'status': 'processing'},
    {'label': 'Siap', 'status': 'ready_for_pickup'},
    {'label': 'Selesai', 'status': 'completed'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final selectedStatus = _tabs[_tabController.index]['status'];
        context.read<OrderProvider>().fetchOrders(status: selectedStatus);
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<OrderProvider>().loadMore();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatRupiah(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }

  String _formatWaktu(DateTime dt) {
    return DateFormat('d MMM yyyy  HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/scan');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/notification');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        onProfile: () => Navigator.pushReplacementNamed(context, '/profile'),
        onLogout: () =>
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── HEADER ──────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                expandedHeight: 130,
                backgroundColor: kDark,
                automaticallyImplyLeading: false,
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: kBrown,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: _tabs
                      .map((t) => Tab(text: t['label'] as String))
                      .toList(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 52),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Order Pelanggan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              provider.isLoading && provider.orders.isEmpty
                                  ? 'Memuat...'
                                  : '${provider.orders.length} order',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── LOADING AWAL ────────────────────────────────────
              if (provider.isLoading && provider.orders.isEmpty)
                const SliverFillRemaining(
                  child: LoadingWidget(message: 'Memuat daftar pesanan...'),
                ),

              // ── KOSONG ──────────────────────────────────────────
              if (!provider.isLoading && provider.orders.isEmpty)
                SliverFillRemaining(
                  child: RefreshIndicator(
                    onRefresh: () => provider.fetchOrders(),
                    color: kBrown,
                    child: const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 400,
                        child: EmptyStateWidget(
                          title: 'Belum Ada Order',
                          message: 'Order pelanggan akan muncul di sini.',
                          icon: Icons.receipt_long_outlined,
                        ),
                      ),
                    ),
                  ),
                ),

              // ── DAFTAR ORDER ─────────────────────────────────────
              if (provider.orders.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == provider.orders.length) {
                          return provider.isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        color: kBrown),
                                  ),
                                )
                              : const SizedBox();
                        }

                        final order = provider.orders[index];
                        return _OrderCard(
                          order: order,
                          formatRupiah: _formatRupiah,
                          formatWaktu: _formatWaktu,
                          kBrown: kBrown,
                          kCard: kCard,
                          kTextSecondary: kTextSecondary,
                          onTap: () {
                            context.read<OrderProvider>().setCurrentOrder(order);
                            Navigator.pushNamed(context, '/menu');
                          },
                          onStatusChanged: (newStatus) async {
                            final idStr = order.orderId
                                .replaceAll(RegExp(r'[^0-9]'), '');
                            final id = int.tryParse(idStr) ?? 0;
                            if (id > 0) {
                              await provider.updateOrderStatus(id, newStatus);
                            }
                          },
                        );
                      },
                      childCount: provider.orders.length + 1,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// WIDGET: CARD SATU ORDER
// ============================================================

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final String Function(double) formatRupiah;
  final String Function(DateTime) formatWaktu;
  final Color kBrown, kCard, kTextSecondary;
  final VoidCallback onTap;
  final Future<void> Function(String newStatus) onStatusChanged;

  const _OrderCard({
    required this.order,
    required this.formatRupiah,
    required this.formatWaktu,
    required this.kBrown,
    required this.kCard,
    required this.kTextSecondary,
    required this.onTap,
    required this.onStatusChanged,
  });

  static const _statusConfig = {
    'pending_confirmation': {'label': 'Pending', 'color': 0xFFF59E0B},
    'processing': {'label': 'Diproses', 'color': 0xFF3B82F6},
    'ready_for_pickup': {'label': 'Siap', 'color': 0xFF8B5CF6},
    'completed': {'label': 'Selesai', 'color': 0xFF10B981},
    'cancelled': {'label': 'Dibatalkan', 'color': 0xFFEF4444},
  };

  static const _nextStatus = {
    'pending_confirmation': 'processing',
    'processing': 'ready_for_pickup',
    'ready_for_pickup': 'completed',
  };

  static const _nextLabel = {
    'pending_confirmation': 'Proses',
    'processing': 'Siap',
    'ready_for_pickup': 'Selesai',
  };

  @override
  Widget build(BuildContext context) {
    final grandTotal = order.totalHarga;
    final statusCfg =
        _statusConfig[order.status ?? ''] ?? {'label': '-', 'color': 0xFF888888};
    final badgeColor = Color(statusCfg['color'] as int);
    final badgeLabel = statusCfg['label'] as String;
    final nextStatus = _nextStatus[order.status];
    final nextLabel = _nextLabel[order.status];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: kBrown.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kBrown,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Meja ${order.nomorMeja}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            order.namaPelanggan,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (order.queueNumber != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#${order.queueNumber}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: badgeColor.withValues(alpha: 0.4), width: 1),
                    ),
                    child: Text(
                      badgeLabel,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: order.items
                    .take(3)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: kBrown.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${item.jumlah}x',
                                        style: TextStyle(
                                          color: kBrown,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.nama,
                                      style: const TextStyle(fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatRupiah(item.subtotal),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            if (order.items.length > 3)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    Text(
                      '+${order.items.length - 3} item lainnya',
                      style: TextStyle(
                        color: kTextSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Divider(height: 1),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderId,
                        style: TextStyle(color: kTextSecondary, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatWaktu(order.waktuOrder),
                        style: TextStyle(color: kTextSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatRupiah(grandTotal),
                        style: TextStyle(
                          color: kBrown,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (nextStatus != null)
                        GestureDetector(
                          onTap: () => onStatusChanged(nextStatus),
                          child: Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: kBrown,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '→ $nextLabel',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
