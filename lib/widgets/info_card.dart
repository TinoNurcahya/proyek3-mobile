import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String waktu;
  final int totalItem;
  final Color kBrown, kCard, kTextSecondary;

  const InfoCard({
    super.key,
    required this.waktu,
    required this.totalItem,
    required this.kBrown,
    required this.kCard,
    required this.kTextSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        children: [
          _InfoItem(
            icon: Icons.access_time_outlined,
            label: 'Waktu Order',
            value: waktu,
            kBrown: kBrown,
            kTextSecondary: kTextSecondary,
          ),
          Container(
            width: 1,
            height: 36,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          _InfoItem(
            icon: Icons.shopping_bag_outlined,
            label: 'Total Item',
            value: '$totalItem item',
            kBrown: kBrown,
            kTextSecondary: kTextSecondary,
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color kBrown, kTextSecondary;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.kBrown,
    required this.kTextSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          const SizedBox(width: 4),
          Icon(icon, size: 18, color: kBrown),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: kTextSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2, // ← 2 baris supaya waktu tidak terpotong
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
