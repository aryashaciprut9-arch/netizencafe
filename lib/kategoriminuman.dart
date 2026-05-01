import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'katergorimakanan.dart';
import 'beranda.dart'; // ✅ Import halaman beranda/home

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // === PENGATURAN ORIENTASI (AUTO-ROTATE) ===
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

// ─── Constants ───────────────────────────────────────────────────────────────

class AppColors {
  static const Color primary = Color(0xFF8A4607);
  static const Color primaryLight = Color(0xFFF5CC9E);
  static const Color primaryLighter = Color(0xFFFFF4E6);
  static const Color white = Colors.white;
}

// ─── Model Produk ────────────────────────────────────────────────────────────

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

// ─── Model Keranjang ─────────────────────────────────────────────────────────

class CartItem {
  final DrinkItem product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

// ─── Halaman Utama ───────────────────────────────────────────────────────────

class PaMenuJenisMinuman extends StatefulWidget {
  const PaMenuJenisMinuman({super.key});

  @override
  State<PaMenuJenisMinuman> createState() => _PaMenuJenisMinumanState();
}

class _PaMenuJenisMinumanState extends State<PaMenuJenisMinuman> {
  final List<DrinkItem> _allDrinks = [
    DrinkItem(name: 'Orange Noise', price: 'IDR 15.000', imageUrl: 'assets/Orange Noise.png'),
    DrinkItem(name: 'Matcha Cheese', price: 'IDR 17.000', imageUrl: 'assets/matcha1.png'),
    DrinkItem(name: 'Choffe Cheese', price: 'IDR 12.000', imageUrl: 'assets/coffe_cheese.png'),
    DrinkItem(name: 'Vietnam Coffe', price: 'IDR 14.000', imageUrl: 'assets/vietnam_coffe.png'),
    DrinkItem(name: 'Sakura Blossom', price: 'IDR 12.000', imageUrl: 'assets/sakura_blossom.png'),
    DrinkItem(name: 'Taro', price: 'IDR 12.000', imageUrl: 'assets/Taro.png'),
    DrinkItem(name: 'Chocolato', price: 'IDR 10.000', imageUrl: 'assets/chocolato.png'),
    DrinkItem(name: 'Blue Cotton Candy', price: 'IDR 12.000', imageUrl: 'assets/Bluecattoncandy.png'),
  ];

  final TextEditingController _searchController = TextEditingController();

  List<CartItem> _cartItems = [];
  int _currentIndex = 1; // ✅ Set ke 1 karena halaman ini adalah search/minuman
  String _searchQuery = '';

  int get _totalCartItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  int _getCrossAxisCount(double width) {
    if (width < 500) return 2;
    if (width < 850) return 3;
    if (width < 1100) return 4;
    if (width < 1400) return 5;
    return 6;
  }

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

  void _addToCart(DrinkItem item) {
    setState(() {
      int index = _cartItems.indexWhere((cartItem) => cartItem.product.name == item.name);
      if (index != -1) {
        _cartItems[index].quantity++;
      } else {
        _cartItems.add(CartItem(product: item));
      }
    });
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.name} ditambahkan ke keranjang'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  void _onNavTap(int index) async {
    HapticFeedback.selectionClick();
    
    // ✅ Navigasi berdasarkan index yang dipilih
    if (index == 0) {
      // Navigasi ke Home (Beranda)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PuBeranda()),
      );
    } else if (index == 1) {
      // Tetap di halaman ini (Minuman)
      setState(() => _currentIndex = index);
    } else if (index == 2) {
      // Keranjang
      setState(() => _currentIndex = index);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CartPage(cartItems: _cartItems),
        ),
      ).then((_) {
        // Refresh state setelah kembali dari cart
        setState(() {});
      });
    } else if (index == 3) {
      // Navigasi ke Profil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fitur profil akan segera hadir'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
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
                SliverToBoxAdapter(child: _buildSectionTitle(context)),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                _buildDrinkGrid(context, constraints.maxWidth),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  HEADER: PANAH KIRI (KEMBALI) + TEKS + PANAH KANAN (KE MAKANAN)           ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ─── KIRI: Panah Kembali + Teks "Minuman" ───
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // ✅ Kembali ke halaman Home
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const PuBeranda()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                'Minuman',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          // ─── KANAN: Panah Ke Halaman Kategori Makanan ───
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MenuPage(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
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
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
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
              color: AppColors.primary.withValues(alpha: 0.4),
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

  Widget _buildSectionTitle(BuildContext context) {
    final title = _searchQuery.isNotEmpty ? 'Hasil Pencarian' : 'Semua Minuman';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            '${_filteredDrinks.length} menu',
            style: TextStyle(
              color: AppColors.primary.withValues(alpha: 0.45),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkGrid(BuildContext context, double screenWidth) {
    final drinks = _filteredDrinks;
    int crossAxisCount = _getCrossAxisCount(screenWidth);

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
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 10),
                Text(
                  'Menu tidak ditemukan',
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.4),
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
            badgeCount: _totalCartItems,
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
}

// ─── Drink Card Widget ───────────────────────────────────────────────────────

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
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
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
              drink.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.primaryLighter,
                  child: Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: AppColors.primary.withValues(alpha: 0.3),
                      size: 40,
                    ),
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
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.85),
                      AppColors.white,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      drink.name,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      drink.price,
                      style: TextStyle(
                        color: AppColors.primary.withValues(alpha: 0.6),
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
                                color: AppColors.primary.withValues(alpha: 0.5),
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
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? Colors.white
                    : AppColors.primary.withValues(alpha: 0.35),
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

// ─── Halaman Keranjang ───────────────────────────────────────────────────────

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;

  const CartPage({super.key, required this.cartItems});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<CartItem> _localCartItems;

  @override
  void initState() {
    super.initState();
    _localCartItems = List.from(widget.cartItems);
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      _localCartItems[index].quantity += change;
      if (_localCartItems[index].quantity <= 0) {
        _localCartItems.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Keranjang Saya",
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _localCartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Keranjang masih kosong',
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _localCartItems.length,
                    itemBuilder: (context, index) {
                      final item = _localCartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                item.product.imageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey[200],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.product.price,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _updateQuantity(index, -1),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLighter,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.remove,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "${item.quantity}",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => _updateQuantity(index, 1),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}