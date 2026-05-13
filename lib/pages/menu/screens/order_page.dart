import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyek3_mobile/pages/menu/providers/order_provider.dart';
import 'package:proyek3_mobile/models/order_model.dart';
import 'package:proyek3_mobile/widgets/bottom_navbar.dart';

class DaftarOrderPage extends StatefulWidget {
  const DaftarOrderPage({Key? key}) : super(key: key);

  @override
  State<DaftarOrderPage> createState() => _DaftarOrderPageState();
}

class _DaftarOrderPageState extends State<DaftarOrderPage> {
  int _currentIndex = 1;

  static const Color kDark = Color(0xFF1A1A1A);
  static const Color kBrown = Color(0xFFB5714A);
  static const Color kBg = Color(0xFFF2F2F2);
  static const Color kCard = Color(0xFFFFFFFF);
  static const Color kTextSecondary = Color(0xFF888888);

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
    final bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${bulan[dt.month]} ${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Ambil semua order yang sudah terkonfirmasi dari provider
    final orders = context.watch<OrderProvider>().confirmedOrders;

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
      body: CustomScrollView(
        slivers: [
          // ── HEADER ──────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 110,
            backgroundColor: kDark,
            automaticallyImplyLeading: false,
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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
                          '${orders.length} order aktif terkonfirmasi',
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

          // ── KOSONG ──────────────────────────────────────────────
          if (orders.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 56,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada order terkonfirmasi',
                      style: TextStyle(color: kTextSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // ── DAFTAR ORDER ─────────────────────────────────────────
          if (orders.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _OrderCard(
                    order: orders[index],
                    formatRupiah: _formatRupiah,
                    formatWaktu: _formatWaktu,
                    kBrown: kBrown,
                    kCard: kCard,
                    kTextSecondary: kTextSecondary,
                    onTap: () {
                      // Set order yang dipilih ke provider lalu buka detail
                      context.read<OrderProvider>().setCurrentOrder(
                        orders[index],
                      );
                      Navigator.pushNamed(context, '/menu');
                    },
                  ),
                  childCount: orders.length,
                ),
              ),
            ),
        ],
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

  const _OrderCard({
    required this.order,
    required this.formatRupiah,
    required this.formatWaktu,
    required this.kBrown,
    required this.kCard,
    required this.kTextSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ppn = order.totalHarga * 0.11;
    final grandTotal = order.totalHarga + ppn;

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
            // ── Baris atas: meja + waktu ─────────────────────────
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kBrown,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Meja ${order.nomorMeja}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        order.namaPelanggan,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right_rounded, color: kBrown, size: 20),
                ],
              ),
            ),

            // ── Daftar ringkasan item ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: order.items
                    .take(3) // tampilkan max 3 item
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
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
                                Text(
                                  item.nama,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
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

            // Jika item lebih dari 3, tampilkan "+N item lainnya"
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

            // ── Divider ─────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Divider(height: 1),
            ),

            // ── Total + ID order ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
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
                        'Total',
                        style: TextStyle(color: kTextSecondary, fontSize: 11),
                      ),
                      Text(
                        formatRupiah(grandTotal),
                        style: TextStyle(
                          color: kBrown,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
