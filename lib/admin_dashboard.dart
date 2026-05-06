import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'kelolapesanan.dart'; // sesuaikan import path
import 'login.dart'; // sesuaikan import path

// ==================== WARNA ====================
class _C {
  static const bg = Color(0xFFFFF8F0);
  static const primary = Color(0xFF8A4607);
  static const primaryDark = Color(0xFF5C2E00);
  static const accent = Color(0xFFF5CC9E);
  static const accentSoft = Color(0xFFFAEBD7);
  static const border = Color(0xFFDCC8AE);
  static const textDark = Color(0xFF3D1F00);
  static const textMuted = Color(0xFFB08A60);
  static const surface = Color(0xFFFFFFFF);
  static const danger = Color(0xFFC62828);
}

// ==================== HALAMAN DASHBOARD ADMIN ====================
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _C.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout',
            style: TextStyle(
                color: _C.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
        content: const Text('Apakah kamu yakin ingin keluar?',
            style: TextStyle(color: _C.textMuted, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: _C.textMuted, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout',
                style: TextStyle(color: _C.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildMenuCard(
                      context,
                      icon: Icons.receipt_long_rounded,
                      label: 'Kelola Pesanan',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const KelolaPesananPage()),
                      ),
                    ),
                    const Spacer(),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: _C.surface,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _C.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: _C.primary, size: 22),
          ),
          const SizedBox(width: 12),
          const Text('Panel Admin',
              style: TextStyle(
                  color: _C.textDark, fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _C.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _C.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(
                    color: _C.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: _C.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _logout(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _C.danger.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.danger.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: _C.danger, size: 20),
            SizedBox(width: 8),
            Text('Logout',
                style: TextStyle(
                    color: _C.danger, fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}