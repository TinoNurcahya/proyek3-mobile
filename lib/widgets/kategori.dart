import 'package:flutter/material.dart';
import 'package:proyek3_mobile/models/order_model.dart';
import 'menu_row.dart';

class KategoriSection extends StatelessWidget {
  final String kategori;
  final List<MenuItemModel> items;
  final String Function(double) formatRupiah;
  final Color kBrown, kCard, kTextPrimary, kTextSecondary;

  const KategoriSection({
    super.key,
    required this.kategori,
    required this.items,
    required this.formatRupiah,
    required this.kBrown,
    required this.kCard,
    required this.kTextPrimary,
    required this.kTextSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label kategori
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: kBrown,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                kategori,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
        // Card daftar item
        Container(
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
            children: items
                .asMap()
                .entries
                .map(
                  (entry) => MenuRow(
                    item: entry.value,
                    isLast: entry.key == items.length - 1,
                    formatRupiah: formatRupiah,
                    kBrown: kBrown,
                    kTextPrimary: kTextPrimary,
                    kTextSecondary: kTextSecondary,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
