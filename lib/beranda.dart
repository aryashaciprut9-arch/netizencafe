import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'kategoriminuman.dart';
import 'katergorimakanan.dart';
import 'search.dart'; // ✅ Import halaman search
=======
import 'services/api_services.dart';
import 'models/menu_models.dart';
import 'katergorimakanan.dart' as makanan;
import 'kategoriminuman.dart';
import 'snack.dart' as snack;
import 'profil_pelanggan.dart';
import 'login.dart';
>>>>>>> efb1ba3028692d013ed4dd95a9d12260a8a864b4

// ─── Constants ───────────────────────────────────────────────────────────────

class AppColors {
  static const Color primary        = Color(0xFF8A4607);
  static const Color primaryLight   = Color(0xFFF5CC9E);
  static const Color primaryLighter = Color(0xFFFFF4E6);
  static const Color white          = Colors.white;
}

// ─── Beranda Utama ───────────────────────────────────────────────────────────

class PuBeranda extends StatefulWidget {
  const PuBeranda({super.key});

  @override
  State<PuBeranda> createState() => _PuBerandaState();
}

class _PuBerandaState extends State<PuBeranda> {
  // =====================
  //  STATE & DATA
  // =====================
  int _currentIndex          = 0;
  List<MenuModel> _allMenus  = [];
  bool _isLoading            = true;
  String _searchQuery        = '';
  String _selectedCategory   = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  List<MenuModel> get _filteredProducts {
    return _allMenus.where((m) {
      final matchSearch   = m.nama.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCategory = _selectedCategory == 'Semua' || m.kategori == _selectedCategory;
      return matchSearch && matchCategory;
    }).toList();
  }

  // =====================
  //  FUNGSI / LOGIKA
  // =====================
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMenu();
      setState(() {
        _allMenus  = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR BERANDA: $e");
      setState(() => _isLoading = false);
    }
  }

  String _buildImageUrl(String foto) {
    if (foto.isEmpty) return '';
    if (foto.startsWith('http')) return foto;
    return "${ApiService.baseUrl}/menu/uploads/$foto";
  }

  int _getCrossAxisCount(double width) {
    if (width < 500)  return 2;
    if (width < 850)  return 3;
    if (width < 1100) return 4;
    if (width < 1400) return 5;
    return 6;
  }

  void _addToCart(MenuModel item) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.nama} ditambahkan ke keranjang'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 1),
        ),
      );
  }

<<<<<<< HEAD
  void _onNavTap(int index) async {
    setState(() => _currentIndex = index);
    HapticFeedback.selectionClick();
    
    // ✅ LOGIKA NAVIGASI BOTTOM NAVIGATION BAR
    if (index == 0) {
      // Home - tetap di halaman ini (beranda)
    } else if (index == 1) {
      // Search - navigasi ke halaman search
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchPage()),
      );
      // Optional: jika perlu refresh setelah kembali dari search
      if (result == true) {
        setState(() {});
      }
    } else if (index == 2) {
      // Keranjang
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fitur keranjang akan segera hadir'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    } else if (index == 3) {
      // Profil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fitur profil akan segera hadir'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
=======
  void _onNavTap(int index) {
  if (index == 0) {
    // Sudah di beranda, scroll ke atas saja
    setState(() => _currentIndex = 0);
    HapticFeedback.selectionClick();
    return;
  }
  setState(() => _currentIndex = index);
  HapticFeedback.selectionClick();
}

  void _navigateToCategory(String kategori) {
    HapticFeedback.lightImpact();
    if (kategori == 'Makanan') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const makanan.MenuPage()));
    } else if (kategori == 'Minuman') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PaMenuJenisMinuman()));
    } else if (kategori == 'Snack') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const snack.MenuPage()));
>>>>>>> efb1ba3028692d013ed4dd95a9d12260a8a864b4
    }
  }

  // =====================
  //  UI / BUILD
  // =====================
  @override
Widget build(BuildContext context) {
  // Kalau profil, return ProfilePage langsung (dia punya navbar sendiri)
  if (_currentIndex == 3) {
    return const ProfilePage();
  }

  return Scaffold(
    backgroundColor: AppColors.white,
    body: SafeArea(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : LayoutBuilder(
              builder: (context, constraints) {
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(context)),
                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    SliverToBoxAdapter(child: _buildSearchBar(context)),
                    const SliverToBoxAdapter(child: SizedBox(height: 15)),
                    SliverToBoxAdapter(child: _buildPromoBanner(context)),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(child: _buildCategories(context)),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(child: _buildSectionTitle(context)),
                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    _buildProductGrid(context, constraints.maxWidth),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                );
              },
            ),
    ),
    bottomNavigationBar: _buildBottomNavBar(),
  );
}
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hai, Selamat Datang!',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Mau pesan apa hari ini?',
                  style: TextStyle(
                    color: Color(0xFFB36A2B),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Tombol refresh
          GestureDetector(
            onTap: _loadData,
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: const Icon(Icons.refresh, color: AppColors.primary, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primaryLighter,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(color: AppColors.primary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Cari makanan, minuman...',
            hintStyle: TextStyle(color: AppColors.primary.withOpacity(0.4), fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 22),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: AppColors.primary, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8A4607), Color(0xFFB35A0A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20, top: -20,
              child: Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Ready!!',
                    style: TextStyle(
                      color: Color(0xFFF5CC9E),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Pesan Sekarang Nikmati Nongkimu',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Solusi Nongkimu',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      {'label': 'Semua',   'icon': Icons.apps},
      {'label': 'Makanan', 'icon': Icons.fastfood},
      {'label': 'Minuman', 'icon': Icons.local_cafe},
      {'label': 'Snack',   'icon': Icons.cookie},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: categories.map((item) {
          final label      = item['label'] as String;
          final icon       = item['icon'] as IconData;
          final isSelected = _selectedCategory == label;

          return GestureDetector(
            onTap: () {
<<<<<<< HEAD
              // ✅ LOGIKA NAVIGASI KATEGORI
              if (label == 'Makanan') {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MenuPage()),
                );
              } else if (label == 'Minuman') {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaMenuJenisMinuman()),
                );
              } else if (label == 'Snack') {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur snack akan segera hadir')),
                );
              } else {
                // Untuk kategori Semua, tetap filter di halaman ini
                setState(() => _selectedCategory = label);
              }
=======
              setState(() => _selectedCategory = label);
              // Navigasi ke halaman kategori jika bukan 'Semua'
              if (label != 'Semua') _navigateToCategory(label);
>>>>>>> efb1ba3028692d013ed4dd95a9d12260a8a864b4
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.primaryLighter,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Icon(icon,
                      color: isSelected ? Colors.white : AppColors.primary, size: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.5),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    final title = _searchQuery.isNotEmpty
        ? 'Hasil Pencarian'
        : _selectedCategory == 'Semua'
            ? 'Rekomendasi untukmu'
            : _selectedCategory;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3)),
          Text('${_filteredProducts.length} menu',
              style: TextStyle(
                  color: AppColors.primary.withOpacity(0.45), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, double screenWidth) {
    final products       = _filteredProducts;
    int crossAxisCount   = _getCrossAxisCount(screenWidth);

    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 52, color: AppColors.primary.withOpacity(0.2)),
                const SizedBox(height: 10),
                Text('Menu tidak ditemukan',
                    style: TextStyle(
                        color: AppColors.primary.withOpacity(0.4), fontSize: 15)),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _MenuCard(
            item: products[index],
            imageUrl: _buildImageUrl(products[index].foto),
            onAddToCart: () => _addToCart(products[index]),
          ),
          childCount: products.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.8,
        ),
      ),
    );
  }

  // =====================
  //  NAVBAR BAWAH
  // =====================
  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(icon: Icons.home_rounded,         index: 0, currentIndex: _currentIndex, onTap: _onNavTap),
          _NavItem(icon: Icons.search_rounded,       index: 1, currentIndex: _currentIndex, onTap: _onNavTap),
          _NavItem(icon: Icons.shopping_bag_rounded, index: 2, currentIndex: _currentIndex, onTap: _onNavTap),
          _NavItem(icon: Icons.person_rounded,       index: 3, currentIndex: _currentIndex, onTap: _onNavTap),
        ],
      ),
    );
  }
}

// ─── Product Card Widget ──────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Product product;

// ─── Menu Card Widget ─────────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  final MenuModel item;
  final String imageUrl;
  final VoidCallback onAddToCart;

  const _MenuCard({
    required this.item,
    required this.imageUrl,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Foto dari database
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.primaryLighter,
                      child: Center(
                        child: Icon(Icons.broken_image,
                            color: AppColors.primary.withOpacity(0.3), size: 40),
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.primaryLighter,
                    child: const Center(
                      child: Icon(Icons.fastfood, color: AppColors.primary, size: 40),
                    ),
                  ),

            // Gradient + info bawah
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0), // Transparan ke coklat
                      AppColors.primary.withOpacity(0.85), // Mulai pekat
                      AppColors.primary, // Coklat solid di bagian bawah
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- NAMA MENU (PUTIH) ---
                    Text(
                      product.name,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                      item.nama,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // --- HARGA / IDR (PUTIH) ---
                    Text(
                      product.price,
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w500),
                      'IDR ${item.harga}',
                      style: TextStyle(
                          color: AppColors.primary.withOpacity(0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            // --- TERSEDIA (PUTIH) ---
                            const Text('Tersedia', style: TextStyle(color: Colors.white, fontSize: 10)),
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                color: item.tersedia ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.tersedia ? 'Tersedia' : 'Habis',
                              style: TextStyle(
                                  color: AppColors.primary.withOpacity(0.5),
                                  fontSize: 10),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 28,
                            height: 28,
                            // Diubah ke putih agar kontras dengan background coklat
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: AppColors.primary, size: 18),
                            width: 28, height: 28,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Nav Item Widget ─────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final int badgeCount;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56, height: 56,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 48 : 36,
              height: isSelected ? 48 : 36,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 24,
                  color: isSelected
                      ? Colors.white
                      : AppColors.primary.withOpacity(0.35)),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 4, right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: Text('$badgeCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}