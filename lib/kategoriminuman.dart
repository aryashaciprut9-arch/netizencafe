import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci orientasi hanya portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FigmaToCodeApp());
}

// ─── App ─────────────────────────────────────────────────────────────────────

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Geologica',
        primaryColor: AppColors.primary,
        useMaterial3: true,
      ),
      home: const PaMenuJenisMinuman(),
    );
  }
}

// ─── Constants ────────────────────────────────────────────────────────────────

class AppColors {
  static const Color primary = Color(0xFF8A4607);
  static const Color primaryDark = Color(0xFF5C2E05);
  static const Color primaryLight = Color(0xFFF5CC9E);
  static const Color primaryLighter = Color(0xFFFFF4E6);
  static const Color white = Colors.white;
}

// ─── Model ────────────────────────────────────────────────────────────────────

class DrinkItem {
  final String name;
  final String price;
  final String imageUrl;
  final String category;

  DrinkItem({
    required this.name,
    required this.price,
    this.imageUrl = 'https://placehold.co/200x150/FFFFFF/8A4607?text=Drink',
    this.category = 'Minuman',
  });
}

// ─── Halaman Utama ────────────────────────────────────────────────────────────

class PaMenuJenisMinuman extends StatefulWidget {
  const PaMenuJenisMinuman({super.key});

  @override
  State<PaMenuJenisMinuman> createState() => _PaMenuJenisMinumanState();
}

class _PaMenuJenisMinumanState extends State<PaMenuJenisMinuman> {
  // ── Data ──
  final List<DrinkItem> _allDrinks = [
    DrinkItem(name: 'Orange Noice', price: 'IDR 15.000', category: 'Jus'),
    DrinkItem(name: 'Matcha Cheese', price: 'IDR 17.000', category: 'Matcha'),
    DrinkItem(name: 'Chocolato Cheese', price: 'IDR 12.000', category: 'Coklat'),
    DrinkItem(name: 'Vietnam Coffe', price: 'IDR 14.000', category: 'Kopi'),
    DrinkItem(name: 'Sakura Blossom', price: 'IDR 12.000', category: 'Spesial'),
    DrinkItem(name: 'Coffe Cheese', price: 'IDR 12.000', category: 'Kopi'),
    DrinkItem(name: 'Chocolato', price: 'IDR 10.000', category: 'Coklat'),
    DrinkItem(name: 'Blue Cotton Candy', price: 'IDR 12.000', category: 'Spesial'),
  ];

  final TextEditingController _searchController = TextEditingController();

  // ── State ──
  int _currentIndex = 0;
  int _cartCount = 0;
  String _searchQuery = '';

  // ── Filter produk (hanya berdasarkan pencarian) ──
  List<DrinkItem> get _filteredDrinks {
    if (_searchQuery.isEmpty) return _allDrinks;
    return _allDrinks
        .where((d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Tambah keranjang ──
  void _addToCart(DrinkItem item) {
    setState(() => _cartCount++);
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.name} ditambahkan ke keranjang',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    HapticFeedback.selectionClick();
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              child: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(child: _buildHeader()),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // Search bar
                    SliverToBoxAdapter(child: _buildSearchBar()),
                    const SliverToBoxAdapter(child: SizedBox(height: 22)),

                    // Judul seksi
                    SliverToBoxAdapter(child: _buildSectionTitle()),
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),

                    // Grid minuman
                    _buildDrinkGrid(),

                    // Spacer bawah
                    const SliverToBoxAdapter(child: SizedBox(height: 90)),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _buildBottomNavBar(),
          ),
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                'Minuman',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            _showAddMenuSheet();
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 17),
                SizedBox(width: 4),
                Text(
                  'Tambah',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Search Bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primaryLighter,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.15),
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Cari makanan, minuman...',
            hintStyle: TextStyle(
              color: AppColors.primary.withOpacity(0.4),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
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

  // ─── Judul Seksi ───────────────────────────────────────────────────────────

  Widget _buildSectionTitle() {
    final title = _searchQuery.isNotEmpty ? 'Hasil Pencarian' : 'Semua Minuman';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            '${_filteredDrinks.length} menu',
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Grid Minuman ──────────────────────────────────────────────────────────

  Widget _buildDrinkGrid() {
    final drinks = _filteredDrinks;

    if (drinks.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 52,
                  color: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(height: 10),
                Text(
                  'Minuman tidak ditemukan',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 15,
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
          (context, index) => _DrinkCard(
            drink: drinks[index],
            onAddToCart: () => _addToCart(drinks[index]),
          ),
          childCount: drinks.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.75,
        ),
      ),
    );
  }

  // ─── Bottom Nav Bar ────────────────────────────────────────────────────────

  Widget _buildBottomNavBar() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            index: 0,
            currentIndex: _currentIndex,
            onTap: _onNavTap,
          ),
          _NavItem(
            icon: Icons.search_rounded,
            index: 1,
            currentIndex: _currentIndex,
            onTap: _onNavTap,
          ),
          _NavItem(
            icon: Icons.shopping_bag_rounded,
            index: 2,
            currentIndex: _currentIndex,
            badgeCount: _cartCount,
            onTap: _onNavTap,
          ),
          _NavItem(
            icon: Icons.person_rounded,
            index: 3,
            currentIndex: _currentIndex,
            onTap: _onNavTap,
          ),
        ],
      ),
    );
  }

  // ─── Bottom Sheet Tambah Menu ──────────────────────────────────────────────

  void _showAddMenuSheet() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final catCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Menu Baru',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildSheetField(
                            'Nama Minuman',
                            'Contoh: Coklat Hangat',
                            nameCtrl,
                          ),
                          const SizedBox(height: 12),
                          _buildSheetField(
                            'Harga (IDR)',
                            'Contoh: 15000',
                            priceCtrl,
                            isNumber: true,
                          ),
                          const SizedBox(height: 12),
                          _buildSheetField(
                            'Kategori',
                            'Contoh: Kopi, Teh, Jus',
                            catCtrl,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                final name = nameCtrl.text.trim();
                                final price = priceCtrl.text.trim();
                                final cat = catCtrl.text.trim();

                                if (name.isEmpty || price.isEmpty) {
                                  ScaffoldMessenger.of(sheetCtx).showSnackBar(
                                    const SnackBar(
                                      content: Text('Nama dan harga wajib diisi'),
                                      backgroundColor: Color(0xFFE53935),
                                      behavior: SnackBarBehavior.floating,
                                      shape: StadiumBorder(),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _allDrinks.insert(
                                    0,
                                    DrinkItem(
                                      name: name,
                                      price: 'IDR $price',
                                      category: cat.isNotEmpty ? cat : 'Minuman',
                                    ),
                                  );
                                });

                                Navigator.pop(sheetCtx);
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$name berhasil ditambahkan'),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('Simpan Menu'),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetField(
    String label,
    String hint,
    TextEditingController ctrl, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions()
              : TextInputType.text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: const Color(0xFFF9F5F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
      ],
    );
  }
}

// ─── Drink Card Widget ────────────────────────────────────────────────────────

class _DrinkCard extends StatelessWidget {
  final DrinkItem drink;
  final VoidCallback onAddToCart;

  const _DrinkCard({
    required this.drink,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gambar ──
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    drink.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primaryLighter,
                      child: Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: AppColors.primary.withOpacity(0.3),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  // Badge kategori
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        drink.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Info ──
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drink.name,
                  style: const TextStyle(
                    color: Color(0xFFD4741B),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  drink.price,
                  style: TextStyle(
                    color: AppColors.primary.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
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
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tersedia',
                          style: TextStyle(
                            color: AppColors.primary.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        width: 56,
        height: 56,
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
                top: 4,
                right: 4,
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