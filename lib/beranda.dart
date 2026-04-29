import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// === TAMBAHKAN IMPORT INI ===
import 'kategoriminuman.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const FigmaToCodeApp());
}

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

class AppColors {
  static const Color primary = Color(0xFF8A4607);
  static const Color primaryLight = Color(0xFFF5CC9E);
  static const Color primaryLighter = Color(0xFFFFF4E6);
  static const Color white = Colors.white;
}

// === MODEL DATA PRODUK ===
class Product {
  final String name;
  final String price;
  final String category;
  final String image;

  const Product({
    required this.name,
    required this.price,
    required this.image,
    this.category = 'Makanan',
  });
}

// === MODEL DATA KERANJANG ===
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

const List<Product> kProducts = [
  Product(name: 'Choffe Cheese', price: 'IDR 12.000', category: 'Minuman', image: 'assets/Choffe_Cheese.png'), 
  Product(name: 'Orange Noise', price: 'IDR 15.000', category: 'Minuman', image: 'assets/Orange Noise.png'),
  Product(name: 'Matcha Cheese', price: 'IDR 17.000', category: 'Minuman', image: 'assets/Matcha_cheese.png'),
  Product(name: 'Chicken Teriyaki', price: 'IDR 25.000', category: 'Makanan', image: 'assets/Chicken_teriyaki.png'),
  Product(name: 'Rice Mushroom', price: 'IDR 15.000', category: 'Makanan', image: 'assets/Rice_mushroom.png'),
  Product(name: 'Choco Lava', price: 'IDR 18.000', category: 'Minuman', image: 'assets/Chocolava.png'),
  Product(name: 'Bakso Spesial', price: 'IDR 10.000', category: 'Makanan', image: 'assets/imgbakso.png'),
  Product(name: 'Risol Mayonise', price: 'IDR 10.000', category: 'Snack', image: 'assets/apanamanya.png'),
  Product(name: 'Milky Cookies', price: 'IDR 15.000', category: 'Minuman', image: 'assets/milky cookies.png'),
  Product(name: 'Ricechicken Blackpaper', price: 'IDR 17.000', category: 'Makanan', image: 'assets/ricechickenblackpaper.png'),
  Product(name: 'Es Coklat', price: 'IDR 15.000', category: 'Minuman', image: 'assets/Escoklat.png'),
];

class PuBeranda extends StatefulWidget {
  const PuBeranda({super.key});

  @override
  State<PuBeranda> createState() => _PuBerandaState();
}

class _PuBerandaState extends State<PuBeranda> {
  int _currentIndex = 0;
  List<CartItem> _cartItems = [];
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  List<Product> get _filteredProducts {
    return kProducts.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Semua' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  int get _totalCartItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  void _addToCart(Product product) {
    setState(() {
      int index = _cartItems.indexWhere((item) => item.product.name == product.name);
      if (index != -1) {
        _cartItems[index].quantity++;
      } else {
        _cartItems.add(CartItem(product: product));
      }
    });
    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.name} ditambahkan ke keranjang'),
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

  int _getCrossAxisCount(double width) {
    if (width < 500) return 2; 
    if (width < 850) return 3; 
    if (width < 1100) return 4; 
    if (width < 1400) return 5; 
    return 6; 
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
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

  // ─── Header (TOMBOL PANAH KE KANAN SUDAH DITAMBAHKAN NAVIGASINYA) ──────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hai, Kenzi!',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Selamat datang kembali',
                  style: TextStyle(
                    color: const Color(0xFFB36A2B),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // TOMBOL PANAH KE KANAN
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // === FUNGSI NAVIGASI KE HALAMAN KATEGORI MINUMAN ===
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PaMenuJenisMinuman()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primary,
                size: 16,
              ),
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
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)),
              ),
            ),
            Positioned(
              right: 20, bottom: -30, 
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)),
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
                      fontSize: 28,
                      fontWeight: FontWeight.w800, 
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Pesan Sekarang Nikmati Nongkimu',
                    style: TextStyle(
                      color: Colors.white70, 
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Solusi Nongkimu',
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

  Widget _buildCategories(BuildContext context) {
    final categories = [
      {'label': 'Semua', 'icon': Icons.apps},
      {'label': 'Makanan', 'icon': Icons.fastfood},
      {'label': 'Minuman', 'icon': Icons.local_cafe},
      {'label': 'Snack', 'icon': Icons.cookie},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: categories.map((item) {
          final label = item['label'] as String;
          final icon = item['icon'] as IconData;
          final isSelected = _selectedCategory == label;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = label),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200), 
                  width: 60, height: 60, 
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.primaryLighter,
                    shape: BoxShape.circle,
                    boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))] : [],
                  ),
                  child: Icon(icon, color: isSelected ? Colors.white : AppColors.primary, size: 26),
                ),
                const SizedBox(height: 8), 
                Text(label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.5), fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400, fontSize: 12)),
              ],
            ),
          );
        }).toList(), 
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    final title = _searchQuery.isNotEmpty ? 'Hasil Pencarian' : _selectedCategory == 'Semua' ? 'Rekomendasi untukmu' : _selectedCategory; 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Text(title, style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
          Text('${_filteredProducts.length} menu', style: TextStyle(color: AppColors.primary.withOpacity(0.45), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, double screenWidth) {
    final products = _filteredProducts;
    int crossAxisCount = _getCrossAxisCount(screenWidth);

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
                Text('Menu tidak ditemukan', style: TextStyle(color: AppColors.primary.withOpacity(0.4), fontSize: 15)),
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
          (context, index) => _ProductCard(product: products[index], onAddToCart: () => _addToCart(products[index])),
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
          _NavItem(icon: Icons.home, index: 0, currentIndex: _currentIndex, onTap: _onNavTap),
          _NavItem(icon: Icons.search, index: 1, currentIndex: _currentIndex, onTap: _onNavTap),
          _NavItem(icon: Icons.shopping_bag, index: 2, currentIndex: _currentIndex, badgeCount: _totalCartItems, onTap: _onNavTap),
          _NavItem(icon: Icons.person, index: 3, currentIndex: _currentIndex, onTap: _onNavTap),
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
            Image.asset(
              product.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.primaryLighter,
                  child: Center(
                    child: Icon(Icons.broken_image, color: AppColors.primary.withOpacity(0.3), size: 40),
                  ),
                );
              },
            ),
            
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0),
                      Colors.white.withOpacity(0.85),
                      AppColors.white,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.price,
                      style: TextStyle(color: AppColors.primary.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w500),
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
                              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text('Tersedia', style: TextStyle(color: AppColors.primary.withOpacity(0.5), fontSize: 10)),
                          ],
                        ),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: Colors.white, size: 18),
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
              child: Icon(icon, size: 24, color: isSelected ? Colors.white : AppColors.primary.withOpacity(0.35)),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}