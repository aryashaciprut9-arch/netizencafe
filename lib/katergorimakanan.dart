import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'beranda.dart';
import 'search.dart';
import 'detailkeranjang.dart';
import 'profil_pelanggan.dart';


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
  runApp(const MyApp());
}

// ─── App ─────────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Geologica',
        primaryColor: AppColors.primary,
        useMaterial3: true,
      ),
      home: const MenuPage(),
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

// ─── Model Data ──────────────────────────────────────────────────────────────

class MenuItem {
  final String id;
  final String name;
  final String price;
  final String status;
  final String imageUrl;
  final double rating;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.status = 'Tersedia',
    required this.imageUrl,
    this.rating = 4.8,
  });
}

// ─── Model Keranjang ─────────────────────────────────────────────────────────

class CartItem {
  final MenuItem product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

// ─── Halaman Utama ───────────────────────────────────────────────────────────

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final List<MenuItem> _allMenuItems = [
    MenuItem(id: '1', name: 'Rice Chicken Mushroom', price: 'IDR 15.000', imageUrl: 'assets/Rice mushroom.png', rating: 4.9),
    MenuItem(id: '2', name: 'Rice Chicken Blackpapper', price: 'IDR 15.000', imageUrl: 'assets/blakpaper.png', rating: 4.7),
    MenuItem(id: '3', name: 'Rice Sambal Goreng Cumi', price: 'IDR 18.000', imageUrl: 'assets/sambel cumi.png', rating: 4.8),
    MenuItem(id: '4', name: 'Chicken Teriyaki', price: 'IDR 17.000', imageUrl: 'assets/ricebowl teriyaki.png', rating: 4.6),
    MenuItem(id: '5', name: 'Bakso Special', price: 'IDR 13.000', imageUrl: 'assets/imgbakso.png', rating: 4.9),
    MenuItem(id: '6', name: 'Bakso Urat', price: 'IDR 15.000', imageUrl: 'assets/imgbakso.png', rating: 4.5),
    MenuItem(id: '7', name: 'Mie Ayam Cakalang', price: 'IDR 12.000', imageUrl: 'assets/mieayam.png', rating: 4.7),
    MenuItem(id: '8', name: 'Nasi Sambel Cakalang', price: 'IDR 12.000', imageUrl: 'assets/nasisambelcakalang.png', rating: 5.0),
  ];

  final TextEditingController _searchController = TextEditingController();
  List<CartItem> _cartItems = [];
  int _currentIndex = 0;
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

  List<MenuItem> get _filteredMenuItems {
    if (_searchQuery.isEmpty) return _allMenuItems;
    return _allMenuItems
        .where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(MenuItem item) {
    setState(() {
      int index = _cartItems.indexWhere((cartItem) => cartItem.product.id == item.id);
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

  void _addToCartWithQty(MenuItem item, int quantity) {
    setState(() {
      int index = _cartItems.indexWhere((cartItem) => cartItem.product.id == item.id);
      if (index != -1) {
        _cartItems[index].quantity += quantity;
      } else {
        _cartItems.add(CartItem(product: item, quantity: quantity));
      }
    });
    HapticFeedback.lightImpact();
  }

  void _showDetailSheet(MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailSheet(
        item: item,
        onAddToCart: (qty) {
          _addToCartWithQty(item, qty);
          Navigator.pop(context);
        },
      ),
    );
  }

  // ========== FUNGSI NAVIGASI DENGAN ANIMASI SMOUTH ==========
  void _navigateWithAnimation(Widget page, {bool replace = false}) {
    final route = PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
    
    if (replace) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.push(context, route);
    }
  }

  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    
    if (index == 0) {
      // Kembali ke halaman Beranda dengan animasi smooth
      _navigateWithAnimation(const PuBeranda(), replace: true);
    } else if (index == 1) {
      // Buka halaman Search dengan animasi smooth
      _navigateWithAnimation(const SearchPage());
    } else if (index == 2) {
      // Buka halaman Keranjang dengan animasi smooth
      _navigateWithAnimation(const PuDetailKeranjang());
    } else if (index == 3) {
      // Buka halaman Profil dengan animasi smooth
      _navigateWithAnimation(const ProfilPelanggan());
    }
    
    // Update current index after navigation
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _currentIndex = index);
    });
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
                _buildMenuGrid(context, constraints.maxWidth),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

// Header (HANYA PANAH KIRI, PANAH KANAN DIHAPUS)
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // POJOK KIRI ATAS: Panah Kembali dengan animasi smooth
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _navigateWithAnimation(const PuBeranda(), replace: true);
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
                'Makanan',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          
          // PANAH KANAN DIHAPUS - Biarkan kosong
          const SizedBox(width: 10),
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
    final title = _searchQuery.isNotEmpty ? 'Hasil Pencarian' : 'Semua Makanan';

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
            '${_filteredMenuItems.length} menu',
            style: TextStyle(
              color: AppColors.primary.withValues(alpha: 0.45),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context, double screenWidth) {
    final items = _filteredMenuItems;
    int crossAxisCount = _getCrossAxisCount(screenWidth);

    if (items.isEmpty) {
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
          (context, index) => _FoodCard(
            item: items[index],
            onAddToCart: () => _addToCart(items[index]),
            onTap: () => _showDetailSheet(items[index]),
          ),
          childCount: items.length,
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

// ─── Food Card Widget ──────────────────────────────────────────────────────

class _FoodCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const _FoodCard({
    required this.item,
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              // LAYER 1: GAMBAR FULL BACKGROUND
              Image.asset(
                item.imageUrl,
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

              // LAYER 2: GRADIENT PUTIH DARI BAWAH
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
                        item.name,
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
                        item.price,
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

// ─── Halaman Detail Bottom Sheet ─────────────────────────────────────────────

class _DetailSheet extends StatefulWidget {
  final MenuItem item;
  final Function(int) onAddToCart;

  const _DetailSheet({required this.item, required this.onAddToCart});

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                    child: Image.asset(
                      widget.item.imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 220,
                        color: AppColors.primaryLighter,
                        child: Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: AppColors.primary.withValues(alpha: 0.3),
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.item.price,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Deskripsi makanan yang lezat dan bergizi, cocok untuk makan siang atau malam bersama keluarga.",
                          style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.6),
                            height: 1.5,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Jumlah",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryLighter,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => setState(() {
                                      if (_quantity > 1) _quantity--;
                                    }),
                                    icon: const Icon(
                                      Icons.remove,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    _quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() => _quantity++),
                                    icon: const Icon(
                                      Icons.add,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => widget.onAddToCart(_quantity),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Tambah ke Keranjang",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}