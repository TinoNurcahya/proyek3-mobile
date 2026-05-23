import 'package:flutter/material.dart';
import 'package:proyek3_mobile/models/order_model.dart';

class MenuRow extends StatelessWidget {
  final MenuItemModel item;
  final bool isLast;
  final String Function(double) formatRupiah;
  final Color kBrown, kTextPrimary, kTextSecondary;

  const MenuRow({
    super.key,
    required this.item,
    required this.isLast,
    required this.formatRupiah,
    required this.kBrown,
    required this.kTextPrimary,
    required this.kTextSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge jumlah
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: kBrown.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${item.jumlah}x',
                    style: TextStyle(
                      color: kBrown,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nama & catatan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama,
                      style: TextStyle(
                        color: kTextPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (item.catatan != null && item.catatan!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.notes_outlined,
                            size: 12,
                            color: kTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              item.catatan!,
                              style: TextStyle(
                                color: kTextSecondary,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${formatRupiah(item.harga)} / pcs',
                      style: TextStyle(color: kTextSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Subtotal
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatRupiah(item.subtotal),
                    style: TextStyle(
                      color: kTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 62,
            endIndent: 16,
            color: Colors.grey.shade100,
          ),
      ],
    );
  }
}
