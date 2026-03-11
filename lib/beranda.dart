import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
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
      home: const PuBeranda(),
    );
  }
}

// ─── Constants ────────────────────────────────────────────────────────────────

class AppColors {
  static const Color primary = Color(0xFF8A4607);
  static const Color primaryLight = Color(0xFFF5CC9E);
  static const Color primaryLighter = Color(0xFFFFF4E6);
  static const Color white = Colors.white;
}

// ─── Model ────────────────────────────────────────────────────────────────────

class Product {
  final String name;
  final String price;
  final String category;
  final String image; // Ditambahkan properti image

  const Product({
    required this.name,
    required this.price,
    required this.image, // Wajib diisi
    this.category = 'Makanan',
  });
}

// ─── Data ─────────────────────────────────────────────────────────────────────

const List<Product> kProducts = [
  // Produk dengan asset yang Anda minta
  Product(
    name: 'Choffe Cheese',
    price: 'IDR 12.000',
    category: 'Snack',
    image: 'assets/Choofe cheese.png', 
  ),
  Product(
    name: 'Orange Noise',
    price: 'IDR 15.000',
    category: 'Minuman',
    image: 'assets/Orange noise.png',
  ),
  Product(
    name: 'Matcha Cheese',
    price: 'IDR 17.000',
    category: 'Minuman',
    image: 'assets/Matcha Cheese.png',
  ),
  Product(
    name: 'Chicken Teriyaki',
    price: 'IDR 25.000',
    category: 'Makanan',
    image: 'assets/Chicken teriyaki.png',
  ),
  
  // Produk tambahan (placeholder untuk asset lain jika ada)
  Product(
    name: 'Rice Mushroom',
    price: 'IDR 15.000',
    category: 'Makanan',
    image: 'assets/placeholder.png', // Ganti dengan nama file asset Anda
  ),
  Product(
    name: 'Choco Lava',
    price: 'IDR 18.000',
    category: 'Makanan',
    image: 'assets/placeholder.png', // Ganti dengan nama file asset Anda
  ),
];

// ─── Main Screen ──────────────────────────────────────────────────────────────

class PuBeranda extends StatefulWidget {
  const PuBeranda({super.key});

  @override
  State<PuBeranda> createState() => _PuBerandaState();
}

class _PuBerandaState extends State<PuBeranda> {
  int _currentIndex = 0;
  int _cartCount = 0;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final TextEditingController _searchController = TextEditingController();

  List<Product> get _filteredProducts {
    return kProducts.where((p) {
      final matchesSearch =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'Semua' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _addToCart(String productName) {
    setState(() => _cartCount++);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$productName ditambahkan ke keranjang'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive Helper
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallDevice = screenWidth < 360;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: SizedBox(height: isSmallDevice ? 12 : 20)),
            SliverToBoxAdapter(child: _buildSearchBar(context)),
            SliverToBoxAdapter(child: SizedBox(height: isSmallDevice ? 12 : 20)),
            SliverToBoxAdapter(child: _buildPromoBanner(context)),
            SliverToBoxAdapter(child: SizedBox(height: isSmallDevice ? 16 : 24)),
            SliverToBoxAdapter(child: _buildCategories(context)),
            SliverToBoxAdapter(child: SizedBox(height: isSmallDevice ? 16 : 24)),
            SliverToBoxAdapter(child: _buildSectionTitle(context)),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            _buildProductGrid(context),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ─── Header (Modified) ────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.07, // Responsive horizontal padding
        16,
        size.width * 0.07,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Greeting Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hai, Kenzi! 👋',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: size.width < 360 ? 22 : 28, // Responsive font
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Selamat datang kembali',
                  style: TextStyle(
                    color: const Color(0xFFB36A2B),
                    fontSize: size.width < 360 ? 13 : 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          
          // Profile Picture (Replacing Bell Icon)
          GestureDetector(
            onTap: () {
              // Aksi ketika profil di tap
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                // Menggunakan image dari internet (ganti URL sesuai kebutuhan)
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://i.pravatar.cc/150?img=11', // Contoh gambar user
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search Bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
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

  // ─── Promo Banner ──────────────────────────────────────────────────────────

  Widget _buildPromoBanner(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
      child: Container(
        height: size.width < 360 ? 130 : 155, // Tinggi responsif
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
              right: -20,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ready!!',
                    style: TextStyle(
                      color: const Color(0xFFF5CC9E),
                      fontSize: size.width < 360 ? 24 : 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Chocolate Series 🍫',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: size.width < 360 ? 12 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '🚀 GRATIS ONGKIR',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.3,
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

  // ─── Categories (MODIFIED) ────────────────────────────────────────────────────

  Widget _buildCategories(BuildContext context) {
    final categories = [
      ('Semua', Icons.apps_rounded),
      ('Makanan', Icons.fastfood_outlined),
      ('Minuman', Icons.local_cafe_outlined),
      ('Snack', Icons.cookie_outlined),
    ];

    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    // Ukuran container icon menyesuaikan lebar layar
    final double iconContainerSize = screenWidth < 360 ? 55 : 62;
    final double iconSize = screenWidth < 360 ? 24 : 28;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding luar
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceEvenly, // Membuat jarak merata dan posisi di tengah
        children: categories.map((item) {
          final (label, icon) = item;
          final isSelected = _selectedCategory == label;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = label),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primaryLighter,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : AppColors.primary,
                    size: iconSize,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.5),
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
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

  // ─── Section Title ─────────────────────────────────────────────────────────

  Widget _buildSectionTitle(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final title = _searchQuery.isNotEmpty
        ? 'Hasil Pencarian'
        : _selectedCategory == 'Semua'
            ? 'Rekomendasi untukmu'
            : _selectedCategory;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: size.width < 360 ? 16 : 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            '${_filteredProducts.length} menu',
            style: TextStyle(
              color: AppColors.primary.withOpacity(0.45),
              fontSize: size.width < 360 ? 12 : 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Product Grid (Responsive) ─────────────────────────────────────────────

  Widget _buildProductGrid(BuildContext context) {
    final products = _filteredProducts;
    final size = MediaQuery.of(context).size;
    
    // Menyesuaikan jarak dan rasio grid berdasarkan lebar layar
    final double crossAxisSpacing = size.width < 360 ? 10 : 14;
    final double mainAxisSpacing = size.width < 360 ? 10 : 14;
    final double childAspectRatio = size.width < 360 ? 0.72 : 0.75;

    if (products.isEmpty) {
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
                  color: AppColors.primary.withOpacity(0.2),
                ),
                const SizedBox(height: 10),
                Text(
                  'Menu tidak ditemukan',
                  style: TextStyle(
                    color: AppColors.primary.withOpacity(0.4),
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
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _ProductCard(
            product: products[index],
            onAddToCart: () => _addToCart(products[index].name),
          ),
          childCount: products.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
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
            onTap: (i) => setState(() => _currentIndex = i),
          ),
          _NavItem(
            icon: Icons.search_rounded,
            index: 1,
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
          ),
          _NavItem(
            icon: Icons.shopping_bag_rounded,
            index: 2,
            currentIndex: _currentIndex,
            badgeCount: _cartCount,
            onTap: (i) => setState(() => _currentIndex = i),
          ),
          _NavItem(
            icon: Icons.person_rounded,
            index: 3,
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
          ),
        ],
      ),
    );
  }
}

// ─── Product Card Widget ──────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(isSmall ? 14 : 18),
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
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(isSmall ? 14 : 18),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Menggunakan Image.asset untuk memanggil gambar lokal
                  Image.asset(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback jika gambar tidak ditemukan
                      return Container(
                        color: AppColors.primaryLighter,
                        child: Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: AppColors.primary.withOpacity(0.3),
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
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
                        product.category,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmall ? 8 : 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(isSmall ? 8 : 10, 10, isSmall ? 8 : 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: isSmall ? 12 : 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.price,
                  style: TextStyle(
                    color: AppColors.primary.withOpacity(0.6),
                    fontSize: isSmall ? 10 : 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isSmall ? 6 : 8),
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
                            fontSize: isSmall ? 9 : 10,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        width: isSmall ? 26 : 28,
                        height: isSmall ? 26 : 28,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: isSmall ? 16 : 18,
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