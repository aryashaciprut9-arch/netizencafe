import 'package:flutter/material.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainNavigator(),
    );
  }
}
// MAIN NAVIGATOR – mengelola bottom nav global
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0; // 0=Home, 1=Search, 2=Keranjang, 3=Profil

  // Halaman yang sudah ada di project kamu
  final List<Widget> _pages = const [
    BerandaPage(),
    SearchPage(),
    KeranjangPage(),
    ProfilPage(),
  ];

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
// CUSTOM BOTTOM NAV BAR
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
    _NavItem(icon: Icons.search_rounded, label: 'Cari'),
    _NavItem(icon: Icons.shopping_bag_rounded, label: 'Keranjang'),
    _NavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5CC9E),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 4),
            color: Colors.black26,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_items.length, (i) {
          final isActive = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF8A4607)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _items[i].icon,
                    color: isActive ? Colors.white : const Color(0xFF8A4607),
                    size: 24,
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 6),
                    Text(
                      _items[i].label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
// HALAMAN PESANAN BERHASIL
// (Dipanggil setelah checkout, lalu push ke MainNavigator)
class PuPesananBerhasil extends StatelessWidget {
  const PuPesananBerhasil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // ICON SUCCESS
            // Ganti Image.network dengan Image.asset jika pakai asset lokal
            Image.network(
              'https://via.placeholder.com/143x143/8A4607/ffffff?text=✓',
              width: 143,
              errorBuilder: (_, __, ___) => Container(
                width: 143,
                height: 143,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5CC9E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF8A4607),
                  size: 80,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TITLE
            const Text(
              'Pesanan Berhasil',
              style: TextStyle(
                color: Color(0xFF8A4607),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // SUBTITLE
            const Text(
              'Terimakasih pesanan\nsegera di proses',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8A4607),
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 30),

            // TOMBOL KEMBALI KE BERANDA
            ElevatedButton.icon(
              onPressed: () {
                // Navigasi ke MainNavigator, tab Home (index 0)
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const MainNavigator(),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.home_rounded),
              label: const Text('Kembali ke Beranda'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A4607),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
// HALAMAN BERANDA  →  beranda.dart
class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_rounded, size: 80, color: Color(0xFF8A4607)),
          SizedBox(height: 16),
          Text(
            'Beranda',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8A4607),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Konten beranda.dart di sini',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
// HALAMAN SEARCH  →  search.dart
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Cari menu...',
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Color(0xFF8A4607)),
              filled: true,
              fillColor: const Color(0xFFF5CC9E).withOpacity(0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Icon(Icons.search_rounded, size: 80, color: Color(0xFF8A4607)),
          const SizedBox(height: 16),
          const Text(
            'Cari Menu',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8A4607),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Konten search.dart di sini',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
// HALAMAN KERANJANG  →  detailkeranjang.dart
class KeranjangPage extends StatelessWidget {
  const KeranjangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        const Icon(Icons.shopping_bag_rounded,
            size: 80, color: Color(0xFF8A4607)),
        const SizedBox(height: 16),
        const Text(
          'Keranjang Belanja',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8A4607),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Konten detailkeranjang.dart di sini',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 30),
        // Tombol Checkout → akan push ke PuPesananBerhasil
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const PuPesananBerhasil(),
              ),
            );
          },
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Checkout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8A4607),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
// HALAMAN PROFIL  →  profil_pelanggan.dart
class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFFF5CC9E),
            child: Icon(Icons.person_rounded,
                size: 60, color: Color(0xFF8A4607)),
          ),
          SizedBox(height: 16),
          Text(
            'Profil Pelanggan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8A4607),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Konten profil_pelanggan.dart di sini',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}