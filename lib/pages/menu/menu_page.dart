import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyek3_mobile/models/order_model.dart';
import 'package:proyek3_mobile/providers/order_provider.dart';
import 'package:proyek3_mobile/widgets/info_card.dart';
import 'package:proyek3_mobile/widgets/kategori.dart';
import 'package:proyek3_mobile/widgets/total_card.dart';
import 'package:proyek3_mobile/widgets/bottom_navbar.dart';

class MenuPelangganPage extends StatefulWidget {
  const MenuPelangganPage({super.key});

  @override
  State<MenuPelangganPage> createState() => _MenuPelangganPageState();
}

class _MenuPelangganPageState extends State<MenuPelangganPage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const Color kDark = Color(0xFF1A1A1A);
  static const Color kBrown = Color(0xFFB5714A);
  static const Color kBg = Color(0xFFF2F2F2);
  static const Color kCard = Color(0xFFFFFFFF);
  static const Color kTextPrimary = Color(0xFF1A1A1A);
  static const Color kTextSecondary = Color(0xFF888888);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
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
    final bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${bulan[dt.month]} ${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Map<String, List<MenuItemModel>> _groupByKategori(List<MenuItemModel> items) {
    final map = <String, List<MenuItemModel>>{};
    for (final item in items) {
      map.putIfAbsent(item.kategori, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan global OrderProvider
    final order = context.watch<OrderProvider>().selectedOrder;

    if (order == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F2F2),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFB5714A)),
        ),
      );
    }

    final grouped = _groupByKategori(order.items);

    return Scaffold(
      backgroundColor: kBg,
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
          switch (index) {
            case 0: Navigator.pushReplacementNamed(context, '/home'); break;
            case 1: Navigator.pushReplacementNamed(context, '/order'); break;
            case 2: Navigator.pushReplacementNamed(context, '/scan'); break;
            case 3: Navigator.pushReplacementNamed(context, '/notification'); break;
            case 4: Navigator.pushReplacementNamed(context, '/profile'); break;
          }
        },
        onProfile: () => Navigator.pushReplacementNamed(context, '/profile'),
        onLogout: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: kDark,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
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
                      padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            order.namaPelanggan,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Meja ${order.nomorMeja}  ·  ${order.orderId}',
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

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: InfoCard(
                  waktu: _formatWaktu(order.waktuOrder),
                  totalItem: order.totalItem,
                  kBrown: kBrown,
                  kCard: kCard,
                  kTextSecondary: kTextSecondary,
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final kategori = grouped.keys.toList()[index];
                final items = grouped[kategori]!;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: KategoriSection(
                    kategori: kategori,
                    items: items,
                    formatRupiah: _formatRupiah,
                    kBrown: kBrown,
                    kCard: kCard,
                    kTextPrimary: kTextPrimary,
                    kTextSecondary: kTextSecondary,
                  ),
                );
              }, childCount: grouped.length),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TotalCard(
                  order: order,
                  formatRupiah: _formatRupiah,
                  kBrown: kBrown,
                  kDark: kDark,
                  kCard: kCard,
                  kTextSecondary: kTextSecondary,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
