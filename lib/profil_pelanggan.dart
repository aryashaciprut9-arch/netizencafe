import 'package:flutter/material.dart';

// ─── Data Model ───────────────────────────────────────────────
class ProfileMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

// ─── Profile Page ─────────────────────────────────────────────
class ProfilPelanggan extends StatefulWidget {
  const ProfilPelanggan({super.key});

  @override
  State<ProfilPelanggan> createState() => _ProfilPelangganState();
}

class _ProfilPelangganState extends State<ProfilPelanggan> {
  int _selectedNavIndex = 3;
  bool _notificationsOn = true;

  final String _name = 'Ambaput';
  final String _email = 'Email@contoh.com';
  final int _orderCount = 456;
  final int _favCount = 12;
  final int _reviewCount = 50;

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
              Navigator.pop(ctx);
              _showSnackBar('Berhasil keluar dari akun');
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
          icon: Icons.person_outline_rounded,
          label: 'Edit Profil',
          onTap: () => _showSnackBar('Membuka Edit Profil...'),
        ),
        ProfileMenuItem(
          icon: Icons.location_on_outlined,
          label: 'Alamat Saya',
          onTap: () => _showSnackBar('Membuka Alamat Saya...'),
        ),
        ProfileMenuItem(
          icon: Icons.notifications_none_rounded,
          label: 'Notifikasi',
          onTap: () {
            setState(() => _notificationsOn = !_notificationsOn);
            _showSnackBar(
              _notificationsOn ? 'Notifikasi aktif' : 'Notifikasi nonaktif',
            );
          },
        ),
        ProfileMenuItem(
          icon: Icons.payment_outlined,
          label: 'Metode Pembayaran',
          onTap: () => _showSnackBar('Membuka Metode Pembayaran...'),
        ),
        ProfileMenuItem(
          icon: Icons.help_outline_rounded,
          label: 'Bantuan & FAQ',
          onTap: () => _showSnackBar('Membuka Bantuan & FAQ...'),
        ),
        ProfileMenuItem(
          icon: Icons.settings_outlined,
          label: 'Pengaturan',
          onTap: () => _showSnackBar('Membuka Pengaturan...'),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.088;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildContent(horizontalPadding)),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildStatsRow(),
          const SizedBox(height: 28),
          _buildMenuList(),
          const SizedBox(height: 24),
          _buildQuickAccessCards(),
          const SizedBox(height: 28),
          _buildLogoutButton(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF5CC9E),
            border: Border.all(color: const Color(0xFF8A4607), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8A4607).withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.person_rounded, size: 44, color: Color(0xFF8A4607)),
        ),
        const SizedBox(height: 14),
        Text(
          _name,
          style: const TextStyle(
            color: Color(0xFF8A4607),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _email,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showSnackBar('Membuka Edit Profil...'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFE0D5D0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                color: Color(0xFF8B6C60),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0E8E4)),
      ),
      child: Row(
        children: [
          _statItem('$_orderCount', 'Pesanan'),
          _statDivider(),
          _statItem('$_favCount', 'Favorite'),
          _statDivider(),
          _statItem('$_reviewCount', 'Ulasan'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF8A4607),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8A4607),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      height: 40,
      width: 1,
      color: const Color(0xFFEAEAEA),
    );
  }

  Widget _buildMenuList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0E8E4)),
      ),
      child: Column(
        children: List.generate(_menuItems.length, (index) {
          final item = _menuItems[index];
          final isLast = index == _menuItems.length - 1;
          return _menuTile(item, isLast);
        }),
      ),
    );
  }

  Widget _menuTile(ProfileMenuItem item, bool isLast) {
    final isNotification = item.label == 'Notifikasi';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: isLast
              ? null
              : const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF0E8E4), width: 1)),
                ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5CC9E).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 20, color: const Color(0xFF8A4607)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    color: Color(0xFF8A4607),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isNotification) ...[
                AnimatedSwitch(
                  value: _notificationsOn,
                  onChanged: (_) => item.onTap?.call(),
                  activeColor: const Color(0xFF8A4607),
                ),
              ] else ...[
                const Icon(Icons.chevron_right_rounded, size: 22, color: Color(0xFF8B6C60)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCards() {
    return Row(
      children: [
        Expanded(
          child: _quickCard(
            icon: Icons.receipt_long_rounded,
            title: 'Pesanan Saya',
            subtitle: 'Lihat Riwayat',
            onTap: () => _showSnackBar('Membuka Pesanan Saya...'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickCard(
            icon: Icons.favorite_outline_rounded,
            title: 'Favorite',
            subtitle: 'Menu Kesukaan',
            onTap: () => _showSnackBar('Membuka Favorite...'),
          ),
        ),
      ],
    );
  }

  Widget _quickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5CC9E).withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: const Color(0xFF8A4607)),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF8A4607),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFFA47C7A),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFB50000),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB50000).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'KELUAR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      decoration: ShapeDecoration(
        color: const Color(0xFFF5CC9E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
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
          _navItem(Icons.shopping_cart_outlined, Icons.shopping_cart_rounded, 'Keranjang', 2),
          _navItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profil', 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData inactive, IconData active, String label, int index) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedNavIndex = index);
        if (index != 3) {
          _showSnackBar('Halaman $label (segera hadir)');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8A4607).withOpacity(0.15)
              : Colors.transparent,
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

// ─── Animated Switch ─────────────────────
class AnimatedSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const AnimatedSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      activeTrackColor: activeColor.withOpacity(0.3),
      inactiveThumbColor: Colors.grey.shade400,
      inactiveTrackColor: Colors.grey.shade200,
      splashRadius: 20,
    );
  }
}