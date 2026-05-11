import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'beranda.dart';
import 'login.dart'; 
import 'utils/session_manager.dart';

// ─── Constants (Selaras Global) ───────────────────────────────────────────────
class AppColors {
  static const Color primary        = Color(0xFFB86B2B);
  static const Color accent         = Color(0xFF8D5524);
  static const Color textDark       = Color(0xFF6D4C41);
  static const Color cardColor      = Color(0xFFFFFBF5);
  static const Color primaryLight   = Color(0xFFF5CC9E);
  static const Color primaryLighter = Color(0xFFFFF8F2);
  static const Color white          = Colors.white;
  static const Color danger         = Color(0xFFC62828);

  static const List<Color> bgGradient = [
    Color(0xFFFFF8F2),
    Color(0xFFFDE8D7),
    Color(0xFFE8CBB0),
    Color(0xFFD4A57A),
  ];
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = '';
  String _userEmail = '';
  String _userAddress = '';
  String _userPhone = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final email = await SessionManager.getEmail();
    final username = await SessionManager.getUsername();
    final phone = await SessionManager.getPhone();
    final address = await SessionManager.getAddress();

    if (mounted) {
      setState(() {
        _userEmail = email.isNotEmpty ? email : 'Email tidak tersedia';
        _userName = username.isNotEmpty ? username : _extractNameFromEmail(email);
        _userPhone = phone.isNotEmpty ? phone : 'Belum ditambahkan';
        _userAddress = address.isNotEmpty ? address : 'Belum ditambahkan';
        _isLoading = false;
      });
    }
  }

  String _extractNameFromEmail(String email) {
    if (email.contains('@')) return email.split('@')[0];
    return 'User';
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.primary : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEditDialog(String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit $title', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 5))],
                ),
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.openSans(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Masukkan $title',
                    hintStyle: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.45), fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                        ),
                        child: Center(child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w700))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (controller.text.isNotEmpty) {
                          onSave(controller.text);
                          Navigator.pop(ctx);
                          _showSnackBar('$title berhasil diperbarui');
                        }
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Center(child: Text('Simpan', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700))),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateAndSaveName(String newName) async {
    setState(() => _userName = newName);
    await SessionManager.updateUsername(newName);
  }

  Future<void> _updateAndSavePhone(String newPhone) async {
    setState(() => _userPhone = newPhone);
    await SessionManager.updatePhone(newPhone);
  }

  Future<void> _updateAndSaveAddress(String newAddress) async {
    setState(() => _userAddress = newAddress);
    await SessionManager.updateAddress(newAddress);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.delete_forever_rounded, color: AppColors.danger, size: 32),
              ),
              const SizedBox(height: 20),
              Text('Keluar Akun?', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text('Kamu yakin ingin keluar dari akun $_userName?', textAlign: TextAlign.center, style: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.6), fontSize: 14)),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                        ),
                        child: Center(child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w700))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(ctx);
                        await SessionManager.clearSession();
                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const Scaffold(body: LoginPage())),
                            (route) => false,
                          );
                        }
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: AppColors.danger.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Center(child: Text('Keluar', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700))),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Gradient Background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.bgGradient,
            stops: [0.0, 0.3, 0.7, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: _buildContent()),
              _buildBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 40),
            _buildLoadingSkeleton(),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildInfoCard(),
          const SizedBox(height: 32),
          _buildLogoutButton(),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        children: List.generate(4, (index) => Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 12, width: 80, decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.2), borderRadius: BorderRadius.circular(6))),
                      const SizedBox(height: 8),
                      Container(height: 14, width: 180, decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.2), borderRadius: BorderRadius.circular(6))),
                    ],
                  ),
                ),
              ],
            ),
            if (index < 3) ...[
              const SizedBox(height: 20),
              Divider(color: AppColors.primary.withOpacity(0.08), thickness: 1),
              const SizedBox(height: 20),
            ],
          ],
        )),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          // Top Bar
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const PuBeranda()), (route) => false),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 14, offset: const Offset(0, 6))],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
                ),
              ),
              const Spacer(),
              Text('Profil Saya', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ],
          ),
          const SizedBox(height: 36),
          // Avatar
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppColors.primary.withOpacity(0.2), Colors.transparent]),
              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 3),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 25, offset: const Offset(0, 12))],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.cardColor,
              child: Icon(Icons.person_rounded, size: 50, color: AppColors.primary.withOpacity(0.6)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isLoading ? 'Memuat...' : _userName,
            style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 22, fontWeight: FontWeight.w800, shadows: [Shadow(color: Colors.black.withOpacity(0.08), offset: const Offset(0, 2), blurRadius: 4)]),
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail,
            style: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          _infoField(label: 'Nama Lengkap', value: _userName, icon: Icons.person_outline_rounded, onEdit: () => _showEditDialog('Nama Lengkap', _userName, _updateAndSaveName)),
          const SizedBox(height: 20),
          Divider(color: AppColors.primary.withOpacity(0.08), thickness: 1),
          const SizedBox(height: 20),
          _infoField(label: 'Email', value: _userEmail, icon: Icons.email_outlined, isEditable: false),
          const SizedBox(height: 20),
          Divider(color: AppColors.primary.withOpacity(0.08), thickness: 1),
          const SizedBox(height: 20),
          _infoField(label: 'Alamat', value: _userAddress, icon: Icons.location_on_outlined, onEdit: () => _showEditDialog('Alamat', _userAddress, _updateAndSaveAddress)),
          const SizedBox(height: 20),
          Divider(color: AppColors.primary.withOpacity(0.08), thickness: 1),
          const SizedBox(height: 20),
          _infoField(label: 'No. Telepon', value: _userPhone, icon: Icons.phone_outlined, onEdit: () => _showEditDialog('No. Telepon', _userPhone, _updateAndSavePhone)),
        ],
      ),
    );
  }

  Widget _infoField({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onEdit,
    bool isEditable = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primaryLight.withOpacity(0.4), AppColors.primaryLighter.withOpacity(0.6)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.55), fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(value, style: GoogleFonts.openSans(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        if (isEditable && onEdit != null) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(29),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 12))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('KELUAR', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 1, shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))])),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Navigation Bar (Selaras Global) ────────────────────────────────
  Widget _buildBottomNavBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.15), width: 1)),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, -6))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home_rounded, 'Home', 0),
          _navItem(Icons.search_rounded, 'Cari', 1),
          _navItem(Icons.shopping_bag_rounded, 'Keranjang', 2),
          _navItem(Icons.person_rounded, 'Profil', 3, isActive: true),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, {bool isActive = false}) {
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const PuBeranda()), (route) => false);
          return;
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58, height: 58,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: isActive ? 50 : 38,
              height: isActive ? 50 : 38,
              decoration: BoxDecoration(
                gradient: isActive ? const LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
                color: isActive ? null : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))] : [],
              ),
              child: Icon(icon, size: 24, color: isActive ? Colors.white : AppColors.primary.withOpacity(0.35)),
            ),
          ],
        ),
      ),
    );
  }
}