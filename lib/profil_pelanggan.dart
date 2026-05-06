import 'package:flutter/material.dart';
import 'beranda.dart';
// IMPORT halaman login (sesuaikan dengan nama file login Anda)
import 'login.dart'; // ← TAMBAHKAN import halaman login

// ─── Data Model ───────────────────────────────────────────────
class ProfileMenuItem {
  final String label;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    required this.label,
    this.onTap,
  });
}

// ─── Profile Page ─────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedNavIndex = 3;

  final String _name = 'Ambaput';

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF8A4607),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  // FUNGSI LOGOUT - DIEDIT
  void _logout() {
    // Hapus semua data session/user (jika ada)
    // Misal: SharedPreferences.clear() atau hapus token
    
    // Navigasi ke halaman login dan hapus semua halaman sebelumnya
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()), // ← Ganti dengan nama class login Anda
      (route) => false, // Menghapus semua halaman dalam stack
    );
    
    // Tampilkan snackbar (opsional)
    _showSnackBar('Berhasil keluar dari akun');
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar Akun?',
          style: TextStyle(
            color: Color(0xFF8A4607),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Kamu yakin ingin keluar dari akun Ambaput?',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Color(0xFF8A4607),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Tutup dialog
              _logout(); // ← PANGGIL FUNGSI LOGOUT
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB50000),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  List<ProfileMenuItem> get _menuItems => [
        ProfileMenuItem(
          label: 'Edit Nama',
          onTap: () => _showSnackBar('Membuka Edit Nama...'),
        ),
        ProfileMenuItem(
          label: 'Alamat',
          onTap: () => _showSnackBar('Membuka Alamat...'),
        ),
        ProfileMenuItem(
          label: 'No.Telpon',
          onTap: () => _showSnackBar('Membuka No.Telpon...'),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildContent()),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildProfileCard(),
          const SizedBox(height: 40),
          _buildLogoutButton(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ─── Header dengan back button dan title ───
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF8A4607),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const PuBeranda()),
                (route) => false,
              );
            },
            child: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.chevron_left_rounded,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 20),
          const Text(
            'Profil Saya',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Profile Card dengan user info dan menu items ───
  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar section
          Transform.translate(
            offset: const Offset(0, -45),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF5CC9E),
                border: Border.all(color: const Color(0xFF8A4607), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8A4607).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 52,
                color: Color(0xFF8A4607),
              ),
            ),
          ),
          // Name
          Text(
            _name,
            style: const TextStyle(
              color: Color(0xFF8A4607),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          // Menu Items
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: List.generate(_menuItems.length, (index) {
                final item = _menuItems[index];
                final isLast = index == _menuItems.length - 1;
                return _menuTile(item, isLast);
              }),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Menu Tile ───
  Widget _menuTile(ProfileMenuItem item, bool isLast) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: isLast
              ? null
              : const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF0E8E4), width: 1),
                  ),
                ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    color: Color(0xFF8A4607),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: Color(0xFF8A4607),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Logout Button ───
  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60),
      child: GestureDetector(
        onTap: _showLogoutDialog,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF8A4607),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8A4607).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            'KELUAR',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Bottom Navigation ───
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      decoration: ShapeDecoration(
        color: const Color(0xFFF5CC9E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home_outlined, Icons.home_rounded, 'Home', 0),
          _navItem(Icons.search_outlined, Icons.search_rounded, 'Cari', 1),
          _navItem(
            Icons.shopping_cart_outlined,
            Icons.shopping_cart_rounded,
            'Keranjang',
            2,
          ),
          _navItem(
            Icons.person_outline_rounded,
            Icons.person_rounded,
            'Profil',
            3,
          ),
        ],
      ),
    );
  }

  // ─── Navigation Item ───
  Widget _navItem(IconData inactive, IconData active, String label, int index) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        // Kembali ke Home/Beranda
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const PuBeranda()),
            (route) => false,
          );
          return;
        }
        setState(() => _selectedNavIndex = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8A4607).withOpacity(0.15) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? active : inactive,
              color: const Color(0xFF8A4607),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF8A4607),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}