import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../widgets/bottom_navbar.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ── Dialog edit generik — dipakai untuk nama, HP, email ──────────────────
  void _showEditDialog(
    BuildContext context, {
    required String title,
    required String initialValue,
    required ValueChanged<String> onSave,
  }) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit $title',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontFamily: 'Sora'),
          decoration: InputDecoration(
            hintText: title,
            hintStyle: TextStyle(
              color: Colors.grey.shade600,
              fontFamily: 'Sora',
            ),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFC67C4E),
                width: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.grey.shade400, fontFamily: 'Sora'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                onSave(value);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC67C4E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Simpan',
              style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Konfirmasi sebelum logout ─────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6), // diperbaiki
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Sora',
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        content: const Text(
          'Yakin mau logout?',
          style: TextStyle(
            color: Color(0xFF888888),
            fontFamily: 'Sora',
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.grey.shade400, fontFamily: 'Sora'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBE4B4B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final user = provider.user;

        return Scaffold(
          backgroundColor: const Color(0xFF111111),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, user, provider),
                const SizedBox(height: 30),
                Expanded(child: _buildSettings(context, user, provider)),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavbar(
            currentIndex: 4,

            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/home');
                  break;

                case 1:
                  Navigator.pushReplacementNamed(context, '/order');
                  break;

                case 2:
                  Navigator.pushReplacementNamed(context, '/scan');
                  break;

                case 3:
                  Navigator.pushReplacementNamed(context, '/notification');
                  break;

                case 4:
                  // sudah di profile
                  break;
              }
            },

            onProfile: () {},

            onLogout: () => _showLogoutDialog(context),
          ),
        );
      },
    );
  }

  // ── Header: avatar + nama (bisa diedit) + status ─────────────────────────
  Widget _buildHeader(
    BuildContext context,
    UserModel user,
    ProfileProvider provider,
  ) {
    // tambah tipe UserModel
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFC67C4E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFFC67C4E,
                  ).withValues(alpha: 0.35), // diperbaiki
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),

          const SizedBox(height: 16),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A2F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  user.status,
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontFamily: 'Sora',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Nama + tombol edit nama
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Sora',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showEditDialog(
                  context,
                  title: 'Nama',
                  initialValue: user.name,
                  onSave: provider.updateName,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Color(0xFF888888),
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Settings: HP + Email ──────────────────────────────────────────────────
  Widget _buildSettings(
    BuildContext context,
    UserModel user, // tambah tipe UserModel
    ProfileProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // Nomor HP
          _buildSettingRow(
            icon: Icons.phone_rounded,
            label: 'Nomor HP',
            value: user.phone,
            onEdit: () => _showEditDialog(
              context,
              title: 'Nomor HP',
              initialValue: user.phone,
              onSave: provider.updatePhone,
            ),
          ),

          const SizedBox(height: 12),

          // Email
          _buildSettingRow(
            icon: Icons.email_rounded,
            label: 'Email',
            value: user.email,
            onEdit: () => _showEditDialog(
              context,
              title: 'Email',
              initialValue: user.email,
              onSave: provider.updateEmail,
            ),
          ),

          const Spacer(),

          // Tombol logout di bawah
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFBE4B4B),
                size: 18,
              ),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFFBE4B4B),
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFBE4B4B), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Row item setting ──────────────────────────────────────────────────────
  Widget _buildSettingRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC67C4E), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontFamily: 'Sora',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: const Icon(
              Icons.edit_rounded,
              color: Color(0xFF888888),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
