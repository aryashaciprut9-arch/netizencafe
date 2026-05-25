import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api_services.dart';
import 'models/menu_models.dart';
import 'katergorimakanan.dart' as makanan;
import 'kategoriminuman.dart';
import 'snack.dart' as snack;
import 'profil_pelanggan.dart';
import 'detailkeranjang.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

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

// ─── Beranda Utama ────────────────────────────────────────────────────────────

class PuBeranda extends StatefulWidget {
  const PuBeranda({super.key});

  @override
  State<PuBeranda> createState() => _PuBerandaState();
}

class _PuBerandaState extends State<PuBeranda> with TickerProviderStateMixin {
  int _currentIndex          = 0;
  List<MenuModel> _allMenus  = [];
  bool _isLoading            = true;
  String _searchQuery        = '';
  String _selectedCategory   = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<KeranjangItem> _keranjang = [];

  int get _keranjangCount => _keranjang.fold(0, (sum, item) => sum + item.qty);

  List<MenuModel> get _filteredProducts {
    return _allMenus.where((m) {
      final matchSearch   = m.nama.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCategory = _selectedCategory == 'Semua' || m.kategori == _selectedCategory;
      return matchSearch && matchCategory;
    }).toList();
  }

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
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack));

    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
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
      _fadeController.forward(from: 0);
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
    if (!item.tersedia) return;
    HapticFeedback.lightImpact();

    setState(() {
      final existing = _keranjang.where((k) => k.menuId == item.id).toList();
      if (existing.isNotEmpty) {
        existing.first.qty++;
      } else {
        _keranjang.add(KeranjangItem(
          menuId: int.tryParse(item.id) ?? 0,
          namaMenu: item.nama,
          harga: item.harga,
          qty: 1,
          foto: item.foto,
        ));
      }
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${item.nama} ditambahkan ke keranjang',
                  style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    // index 0 = Home, index 1 = Keranjang, index 2 = Profil
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PuDetailKeranjang(
            items: List.from(_keranjang),
            userId: 0,
            namaPelanggan: 'User',
          ),
        ),
      ).then((_) {
        setState(() => _keranjang.clear());
      });
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _navigateToCategory(String kategori) {
    HapticFeedback.lightImpact();
    if (kategori == 'Makanan') {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => makanan.MenuPage(keranjang: _keranjang, onAddToCart: _addToCart),
      ));
    } else if (kategori == 'Minuman') {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PaMenuJenisMinuman(keranjang: _keranjang, onAddToCart: _addToCart),
      ));
    } else if (kategori == 'Snack') {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => snack.MenuPage(keranjang: _keranjang, onAddToCart: _addToCart),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == 2) {
      return const ProfilePage();
    }

    return Scaffold(
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
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(child: _buildHeader(context)),
                            const SliverToBoxAdapter(child: SizedBox(height: 14)),
                            SliverToBoxAdapter(child: _buildSearchBar(context)),
                            const SliverToBoxAdapter(child: SizedBox(height: 18)),
                            SliverToBoxAdapter(child: _buildPromoBanner(context)),
                            const SliverToBoxAdapter(child: SizedBox(height: 22)),
                            SliverToBoxAdapter(child: _buildCategories(context)),
                            const SliverToBoxAdapter(child: SizedBox(height: 22)),
                            SliverToBoxAdapter(child: _buildSectionTitle(context)),
                            const SliverToBoxAdapter(child: SizedBox(height: 12)),
                            _buildProductGrid(context, constraints.maxWidth),
                            const SliverToBoxAdapter(child: SizedBox(height: 90)),
                          ],
                        );
                      },
                    ),
                  ),
                ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hai, Selamat Datang!',
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
                const SizedBox(height: 2),
                Text(
                  'Mau pesan apa hari ini?',
                  style: GoogleFonts.openSans(
                    color: AppColors.textDark.withOpacity(0.75),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadData,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 18),
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
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, AppColors.cardColor],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: GoogleFonts.openSans(
            color: AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Cari makanan, minuman...',
            hintStyle: GoogleFonts.openSans(
              color: AppColors.textDark.withOpacity(0.45),
              fontSize: 14,
            ),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.primary, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 17),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 145,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB86B2B), Color(0xFF8D5524)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -25, top: -25,
              child: Container(
                width: 150, height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              right: 40, bottom: -40,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ready!!',
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryLight,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Pesan Sekarang Nikmati Nongkimu',
                    style: GoogleFonts.openSans(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'Solusi Nongkimu',
                      style: GoogleFonts.poppins(
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
      {'label': 'Semua',   'icon': Icons.apps_rounded},
      {'label': 'Makanan', 'icon': Icons.fastfood_rounded},
      {'label': 'Minuman', 'icon': Icons.local_cafe_rounded},
      {'label': 'Snack',   'icon': Icons.cookie_outlined},
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
              setState(() => _selectedCategory = label);
              if (label != 'Semua') _navigateToCategory(label);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 62, height: 62,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Colors.white, AppColors.cardColor],
                          ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.primary.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.textDark.withOpacity(0.5),
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
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.accent,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Text(
              '${_filteredProducts.length} menu',
              style: GoogleFonts.openSans(
                color: AppColors.textDark.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, double screenWidth) {
    final products     = _filteredProducts;
    int crossAxisCount = _getCrossAxisCount(screenWidth);

    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded,
                    size: 52, color: AppColors.primary.withOpacity(0.2)),
                const SizedBox(height: 10),
                Text(
                  'Menu tidak ditemukan',
                  style: GoogleFonts.poppins(
                    color: AppColors.textDark.withOpacity(0.4),
                    fontSize: 14,
                  ),
                ),
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
          childAspectRatio: 0.75,
        ),
      ),
    );
  }

  // ─── Bottom Nav Bar (3 item: Home, Keranjang, Profil) ────────────────────────

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
          top: BorderSide(color: AppColors.primary.withOpacity(0.15), width: 1),
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
          _NavItem(icon: Icons.shopping_bag_rounded, index: 1, currentIndex: _currentIndex, onTap: _onNavTap, badgeCount: _keranjangCount),
          _NavItem(icon: Icons.home_rounded,         index: 0, currentIndex: _currentIndex, onTap: _onNavTap),
          _NavItem(icon: Icons.person_rounded,       index: 2, currentIndex: _currentIndex, onTap: _onNavTap),
        ],
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.cardColor,
                      child: Center(
                        child: Icon(Icons.broken_image_outlined,
                            color: AppColors.primary.withOpacity(0.3), size: 40),
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.cardColor,
                    child: const Center(
                      child: Icon(Icons.fastfood_rounded,
                          color: AppColors.primary, size: 40),
                    ),
                  ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 44, 10, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFFB86B2B).withOpacity(0.55),
                      const Color(0xFF8D5524).withOpacity(0.92),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.nama,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'IDR ${item.harga}',
                      style: GoogleFonts.openSans(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 7, height: 7,
                              decoration: BoxDecoration(
                                color: item.tersedia
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              item.tersedia ? 'Tersedia' : 'Habis',
                              style: GoogleFonts.openSans(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.white, AppColors.cardColor],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
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

// ─── Nav Item Widget ──────────────────────────────────────────────────────────

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
        width: 58, height: 58,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: isSelected ? 50 : 38,
              height: isSelected ? 50 : 38,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? Colors.white
                    : AppColors.primary.withOpacity(0.35),
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 4, right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}