import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand / Primary (Seven Coffee — cokelat kopi) ─────────────────────
  static const Color primary      = Color(0xFFC67C4E); // Cokelat utama
  static const Color primaryDark  = Color(0xFF9E5C33); // Cokelat tua / hover
  static const Color primaryLight = Color(0xFFF9E5BE); // Krem / latar terang
  static const Color accent       = Color(0xFF6F4E37); // Cokelat espresso

  // ── Neutral ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F0E8); // Krem hangat
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFFFF8F2); // Surface alternatif

  // ── Text ──────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary  = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Teks di atas primary

  // ── Status ────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF28A745);
  static const Color error   = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info    = Color(0xFF17A2B8);

  // ── Status Meja ───────────────────────────────────────────────────────
  static const Color tableEmpty       = Color(0xFF4CAF50); // Hijau — kosong
  static const Color tableOccupied    = Color(0xFFF44336); // Merah — terisi
  static const Color tableReserved    = Color(0xFFFF9800); // Oranye — reserved
  static const Color tableMaintenance = Color(0xFF9E9E9E); // Abu — maintenance

  // ── Dekorasi ──────────────────────────────────────────────────────────
  static const Color border  = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFF0F0F0);

  // ── Gradien Utama ─────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC67C4E), Color(0xFF9E5C33)],
  );
}
