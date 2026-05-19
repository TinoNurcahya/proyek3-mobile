import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../widgets/bottom_navbar.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ── Dialog edit generik ────────────────────────────────────────────────────
  void _showEditDialog(
    BuildContext context, {
    required String title,
    required String initialValue,
    required ValueChanged<String> onSave,
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
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
              borderSide: const BorderSide(color: Color(0xFFC67C4E), width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style:
                  TextStyle(color: Colors.grey.shade400, fontFamily: 'Sora'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) onSave(value);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC67C4E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Simpan',
                style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Dialog Ganti Password ─────────────────────────────────────────────────
  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool isLoading = false;
    String? error;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDlg) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Ganti Password',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(error!,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12, fontFamily: 'Sora')),
                ),
              _pwField(currentCtrl, 'Password Lama'),
              const SizedBox(height: 10),
              _pwField(newCtrl, 'Password Baru'),
              const SizedBox(height: 10),
              _pwField(confirmCtrl, 'Konfirmasi Password Baru'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal',
                  style: TextStyle(
                      color: Colors.grey.shade400, fontFamily: 'Sora')),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setStateDlg(() {
                        isLoading = true;
                        error = null;
                      });
                      final result = await AuthService.changePassword(
                        currentPassword: currentCtrl.text,
                        newPassword: newCtrl.text,
                        confirmPassword: confirmCtrl.text,
                      );
                      if (!ctx.mounted) return;
                      if (result['success'] == true) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password berhasil diganti!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        setStateDlg(() {
                          isLoading = false;
                          error = result['message'] ?? 'Gagal mengganti password';
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC67C4E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child:
                          CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan',
                      style:
                          TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _pwField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      obscureText: true,
      style: const TextStyle(color: Colors.white, fontFamily: 'Sora', fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.grey.shade600, fontFamily: 'Sora', fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFC67C4E), width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  // ── Logout dengan panggil API ─────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Sora',
                fontWeight: FontWeight.w600,
                fontSize: 16)),
        content: const Text('Yakin mau logout?',
            style: TextStyle(
                color: Color(0xFF888888), fontFamily: 'Sora', fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: TextStyle(
                    color: Colors.grey.shade400, fontFamily: 'Sora')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Panggil API logout lalu hapus token lokal
              await AuthService.logout();
              await StorageService.clearAll();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBE4B4B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout',
                style:
                    TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600)),
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
            child: provider.isLoading && user.name.isEmpty
                ? const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFFC67C4E)))
                : RefreshIndicator(
                    onRefresh: provider.loadProfile,
                    color: const Color(0xFFC67C4E),
                    child: ListView(
                      children: [
                        _buildHeader(context, user, provider),
                        const SizedBox(height: 10),
                        _buildSettings(context, user, provider),
                      ],
                    ),
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

  // ── Header: Avatar + Nama + Role + Status ─────────────────────────────────
  Widget _buildHeader(
      BuildContext context, UserModel user, ProfileProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFFC67C4E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC67C4E).withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Role badge
          if (user.role != null && user.role!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFC67C4E).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFC67C4E).withValues(alpha: 0.4)),
              ),
              child: Text(
                user.role!.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFC67C4E),
                  fontSize: 10,
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),

          // Status Online dot
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                const Text(
                  'Online',
                  style: TextStyle(
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

          // Nama + edit
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.name.isNotEmpty ? user.name : '-',
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
                child: const Icon(Icons.edit_rounded,
                    color: Color(0xFF888888), size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Settings: Info + Actions ──────────────────────────────────────────────
  Widget _buildSettings(
      BuildContext context, UserModel user, ProfileProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Akun',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Sora',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Nomor HP
          _buildSettingRow(
            icon: Icons.phone_rounded,
            label: 'Nomor HP',
            value: user.phone.isNotEmpty ? user.phone : '-',
            onEdit: () => _showEditDialog(
              context,
              title: 'Nomor HP',
              initialValue: user.phone,
              onSave: provider.updatePhone,
              keyboardType: TextInputType.phone,
            ),
          ),

          const SizedBox(height: 10),

          // Email
          _buildSettingRow(
            icon: Icons.email_rounded,
            label: 'Email',
            value: user.email.isNotEmpty ? user.email : '-',
            onEdit: () => _showEditDialog(
              context,
              title: 'Email',
              initialValue: user.email,
              onSave: provider.updateEmail,
              keyboardType: TextInputType.emailAddress,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Keamanan',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Sora',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Ganti Password
          _buildActionRow(
            icon: Icons.lock_rounded,
            label: 'Ganti Password',
            onTap: () => _showChangePasswordDialog(context),
          ),

          const SizedBox(height: 24),

          // Tombol Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout_rounded,
                  color: Color(0xFFBE4B4B), size: 18),
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
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                Text(label,
                    style: const TextStyle(
                        color: Color(0xFF888888),
                        fontFamily: 'Sora',
                        fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Sora',
                        fontSize: 14)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: const Icon(Icons.edit_rounded,
                color: Color(0xFF888888), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Sora',
                      fontSize: 14)),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF888888), size: 18),
          ],
        ),
      ),
    );
  }
}
