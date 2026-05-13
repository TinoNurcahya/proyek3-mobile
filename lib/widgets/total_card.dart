import 'package:flutter/material.dart';
import 'package:proyek3_mobile/models/order_model.dart';

class TotalCard extends StatelessWidget {
  final OrderModel order;
  final String Function(double) formatRupiah;
  final Color kBrown, kDark, kCard, kTextSecondary;

  const TotalCard({
    required this.order,
    required this.formatRupiah,
    required this.kBrown,
    required this.kDark,
    required this.kCard,
    required this.kTextSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final ppn = order.totalHarga * 0.12;
    final grandTotal = order.totalHarga + ppn;

    return Container(
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
          // Header total
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: kDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.receipt_outlined, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Ringkasan Pembayaran',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Rows
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _TotalRow(
                  label: 'Subtotal (${order.totalItem} item)',
                  value: formatRupiah(order.totalHarga),
                  kTextSecondary: kTextSecondary,
                ),
                const SizedBox(height: 8),
                _TotalRow(
                  label: 'PPN 12%',
                  value: formatRupiah(ppn),
                  kTextSecondary: kTextSecondary,
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      formatRupiah(grandTotal),
                      style: TextStyle(
                        color: kBrown,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Badge sudah lunas
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF27AE60).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        color: Color(0xFF27AE60),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Pembayaran Telah Dikonfirmasi',
                        style: TextStyle(
                          color: Color(0xFF27AE60),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label, value;
  final Color kTextSecondary;

  const _TotalRow({
    required this.label,
    required this.value,
    required this.kTextSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: kTextSecondary, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
