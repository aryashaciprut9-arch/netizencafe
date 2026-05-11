import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'beranda.dart';
import 'profil_pelanggan.dart';

// ─── Constants (Selaras Global) ───────────────────────────────────────────────
class AppColors {
  static const Color primary        = Color(0xFFB86B2B);
  static const Color accent         = Color(0xFF8D5524);
  static const Color textDark       = Color(0xFF6D4C41);
  static const Color cardColor      = Color(0xFFFFFBF5);
  static const Color primaryLight   = Color(0xFFF5CC9E);
  static const Color primaryLighter = Color(0xFFFFF8F2);
  static const Color white          = Colors.white;

  static const List<Color> bgGradient = [
    Color(0xFFFFF8F2),
    Color(0xFFFDE8D7),
    Color(0xFFE8CBB0),
    Color(0xFFD4A57A),
  ];
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PuPesananBerhasil(),
    );
  }
}

class PuPesananBerhasil extends StatefulWidget {
  const PuPesananBerhasil({super.key});

  @override
  State<PuPesananBerhasil> createState() => _PuPesananBerhasilState();
}

class _PuPesananBerhasilState extends State<PuPesananBerhasil>
    with TickerProviderStateMixin {
  // Animasi masuk (sama seperti di detailkeranjang.dart)
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
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
              const Spacer(flex: 2),

              // Gambar Ilustrasi dengan Animasi Scale & Lingkaran Dekoratif
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppColors.primary.withOpacity(0.2), Colors.transparent],
                    ),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/Escoklat.png",
                    width: 140,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Teks Judul dengan Animasi Fade
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Pesanan Berhasil',
                  style: GoogleFonts.poppins(
                    color: AppColors.accent,
                    fontSize: 30,
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
              ),

              const SizedBox(height: 14),

              // Teks Subjudul
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Terimakasih pesanan\nsegera di proses',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    color: AppColors.textDark.withOpacity(0.6),
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // ✅ Bottom Navigation Bar (Selaras dengan Beranda, Minuman, dll)
              _buildBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Bottom Nav Bar ─────────────────────────────────────────────────────────
  Widget _buildBottomNavBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, AppColors.cardColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(
          top: BorderSide(
              color: AppColors.primary.withOpacity(0.15), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            onTap: () => _navigateTo(const PuBeranda()),
          ),
          _NavItem(
            icon: Icons.shopping_cart_rounded,
            onTap: () => _navigateTo(const PuBeranda()),
          ),
          _NavItem(
            icon: Icons.receipt_rounded,
            onTap: () {
              // TODO: Tambahkan navigasi riwayat pesanan jika sudah ada
            },
          ),
          _NavItem(
            icon: Icons.person_rounded,
            onTap: () => _navigateTo(const ProfilePage()),
          ),
        ],
      ),
    );
  }
}

// ─── Nav Item Widget (Selaras Global) ────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58,
        height: 58,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: 24,
              // Karena tidak ada halaman yang aktif, gunakan warna non-aktif
              color: AppColors.primary.withOpacity(0.45),
            ),
          ],
        ),
      ),
    );
  }
}