import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'beranda.dart';
import 'profil_pelanggan.dart';

// ──────────────────────────────────────────────────────────────────────────────
// 1. KONSTANTA WARNA GLOBAL (AppColors)
// ──────────────────────────────────────────────────────────────────────────────
// Digunakan untuk konsistensi tema di seluruh aplikasi.
// primary (coklat) → warna utama brand.
// bgGradient → background gradasi halus dari krem hingga coklat muda.
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

// ──────────────────────────────────────────────────────────────────────────────
// 2. APLIKASI UTAMA (FigmaToCodeApp)
// ──────────────────────────────────────────────────────────────────────────────
// - Menonaktifkan banner debug.
// - Menentukan halaman pertama: PuPesananBerhasil.
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

// ──────────────────────────────────────────────────────────────────────────────
// 3. HALAMAN PESANAN BERHASIL (PuPesananBerhasil)
// ──────────────────────────────────────────────────────────────────────────────
// Menampilkan konfirmasi setelah pengguna berhasil melakukan pemesanan.
// Fitur utama:
// - Animasi masuk (scale + fade) untuk pengalaman visual yang menarik.
// - Background gradasi yang menenangkan.
// - Bottom navigation bar untuk akses cepat ke halaman lain.
class PuPesananBerhasil extends StatefulWidget {
  const PuPesananBerhasil({super.key});

  @override
  State<PuPesananBerhasil> createState() => _PuPesananBerhasilState();
}

class _PuPesananBerhasilState extends State<PuPesananBerhasil>
    with TickerProviderStateMixin {
  
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

    // Mulai animasi scale
    _scaleController.forward();
    // Tunda fade sebentar agar efeknya berurutan
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

  // ────────────────────────────────────────────────────────────────────────────
  // 5. FUNGSI NAVIGASI
  // ────────────────────────────────────────────────────────────────────────────
  // Mengganti halaman dengan efek transisi fade.
  // Digunakan bottom nav bar untuk berpindah ke Beranda atau Profile.
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
      body: Container(
        // Background gradasi dari AppColors.bgGradient
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

              // ──────────────────────────────────────────────────────────────
              // 6. IKON SUKSES DENGAN ANIMASI SCALE
              // ──────────────────────────────────────────────────────────────
              // - Lingkaran dekoratif dengan border & shadow.
              // - Gambar "Escoklat.png" dari aset lokal.
              // - ScaleTransition membuat ikon membesar dari kecil.
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

              // ──────────────────────────────────────────────────────────────
              // 7. TEKS KONFIRMASI (Fade Animation)
              // ──────────────────────────────────────────────────────────────
              // - "Pesanan Berhasil" dengan font Poppins tebal.
              // - Subteks ucapan terima kasih.
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

              // ──────────────────────────────────────────────────────────────
              // 8. BOTTOM NAVIGATION BAR
              // ──────────────────────────────────────────────────────────────
              // - Menyediakan akses ke Beranda, Keranjang, Riwayat, Profile.
              // - Memiliki gradasi putih hingga cardColor.
              // - Menggunakan _NavItem untuk setiap tombol.
              _buildBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // 9. MEMBANGUN BOTTOM NAV BAR
  // ────────────────────────────────────────────────────────────────────────────
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
              // TODO: nanti dihubungkan ke halaman riwayat pesanan
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

// ──────────────────────────────────────────────────────────────────────────────
// 10. WIDGET TOMBOL NAVIGASI (_NavItem)
// ──────────────────────────────────────────────────────────────────────────────
// - Menampilkan ikon dengan efek sentuh (GesturDetector).
// - Ukuran tetap 58x58 untuk konsistensi.
// - Warna ikon menggunakan primary dengan opacity rendah (tidak aktif).
//   (Jika ingin menandai halaman aktif, bisa ditambahkan kondisi)
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
              color: AppColors.primary.withOpacity(0.45), // warna tidak aktif
            ),
          ],
        ),
      ),
    );
  }
}