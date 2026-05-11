import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'kelolapesanan.dart';
import 'login.dart';

// ==================== WARNA (SELARAS GLOBAL) ====================
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

// ==================== HALAMAN DASHBOARD ADMIN ====================
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with TickerProviderStateMixin {
  // Animasi masuk (selaras halaman lain)
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, AppColors.cardColor],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: AppColors.primary.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.danger, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                'Konfirmasi Logout',
                style: GoogleFonts.poppins(
                  color: AppColors.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Apakah kamu yakin ingin keluar?',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  color: AppColors.textDark.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, false),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.white, AppColors.cardColor],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            'Batal',
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, true),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.danger.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Logout',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const FigmaToCodeApp()),
          (route) => false,
        );
      }
    }
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
              _buildAppBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          // Card Menu
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
                          // Tombol Logout
                          _buildLogoutButton(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- APP BAR ---
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, AppColors.cardColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ikon Admin — style card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, AppColors.cardColor],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Text(
            'Panel Admin',
            style: GoogleFonts.poppins(
              color: AppColors.accent,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MENU CARD ---
  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, AppColors.cardColor],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: AppColors.primary.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ikon Menu — style card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryLight.withOpacity(0.4),
                    AppColors.primaryLighter.withOpacity(0.6),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Panah navigasi
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.primary.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGOUT BUTTON ---
  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _logout(context),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.06),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
              color: AppColors.danger.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.danger.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded,
                color: AppColors.danger, size: 20),
            const SizedBox(width: 10),
            Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: AppColors.danger,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}