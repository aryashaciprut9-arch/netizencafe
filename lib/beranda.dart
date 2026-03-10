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

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Geologica',
        primaryColor: const Color(0xFF8A4607),
        useMaterial3: true,
      ),
      home: const PuBeranda(),
    );
  }
}

// 1. Model Data Sederhana untuk Produk
class Product {
  final String name;
  final String price;

  Product({required this.name, required this.price});
}

class PuBeranda extends StatefulWidget {
  const PuBeranda({super.key});

  @override
  State<PuBeranda> createState() => _PuBerandaState();
}

class _PuBerandaState extends State<PuBeranda> {
  // State Navbar & Keranjang
  int _currentIndex = 0;
  int _cartCount = 0;

  // 2. State untuk Pencarian
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // 3. Data Produk (Simulasi Database)
  final List<Product> _allProducts = [
    Product(name: 'Rice Mushroom', price: 'IDR 15.000'),
    Product(name: 'Orange Noise', price: 'IDR 15.000'),
    Product(name: 'Matcha Cheese', price: 'IDR 17.000'),
    Product(name: 'Choffe Cheese', price: 'IDR 12.000'),
    // Tambahkan produk lain jika perlu
  ];

  // 4. Logika Filter Pencarian
  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) {
      return _allProducts;
    }
    return _allProducts
        .where((product) =>
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchBar(), // Search Bar sekarang interaktif
              const SizedBox(height: 25),
              _buildPromoBanner(),
              const SizedBox(height: 25),
              _buildCategories(),
              const SizedBox(height: 30),
              _buildRecommendationSection(context), // Section ini sekarang dinamis
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- WIDGET BAGIAN ---

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hai, Kenzi!',
            style: TextStyle(
              color: Color(0xFF8A4607),
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Selamat datang kembali',
            style: TextStyle(
              color: Color(0xFF8A4607),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // MODIFIKASI: Search Bar menjadi Interaktif
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 45,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF8A4607)),
          borderRadius: BorderRadius.circular(35),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value; // Update state saat mengetik
            });
          },
          style: const TextStyle(color: Color(0xFF8A4607)),
          decoration: InputDecoration(
            hintText: 'Cari Makanan, Minuman..',
            hintStyle: TextStyle(color: Colors.brown[300], fontSize: 15),
            icon: const Icon(Icons.search, color: Color(0xFF8A4607)),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF8A4607),
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: NetworkImage("https://placehold.co/400x200/8A4607/white?text=Promo+Banner"),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Ready!!',
                style: TextStyle(
                  color: Color(0xFFF5CC9E),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Chocolate',
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'GRATIS ONGKIR',
                  style: TextStyle(
                    color: Color(0xFF8A4607),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCategoryItem('Makanan', Icons.fastfood_outlined),
          _buildCategoryItem('Minuman', Icons.local_cafe_outlined),
          _buildCategoryItem('Snack', Icons.cookie_outlined),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            color: Color(0xFFF5CC9E),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF8A4607), size: 35),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A4607),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection(BuildContext context) {
    // Ambil daftar produk yang sudah difilter
    final productsToShow = _filteredProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30, bottom: 15),
          child: Text(
            // Ubah judul jika sedang mencari
            _searchQuery.isEmpty ? 'Rekomendasi untukmu' : 'Hasil Pencarian',
            style: const TextStyle(
              color: Color(0xFF8A4607),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: productsToShow.isEmpty
              ? SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      "Menu tidak ditemukan",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                )
              : GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 0.75,
                  // Generate kartu produk secara dinamis
                  children: productsToShow
                      .map((product) => _buildProductCard(product.name, product.price))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildProductCard(String name, String price) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8A4607),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                image: DecorationImage(
                  image: NetworkImage("https://placehold.co/200x150/FFFFFF/8A4607?text=$name"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tersedia',
                      style: TextStyle(color: Color(0xFFF5CC9E), fontSize: 9),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _cartCount++;
                        });
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$name ditambahkan ke keranjang'),
                            backgroundColor: const Color(0xFF8A4607),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('+', style: TextStyle(color: Color(0xFF8A4607), fontWeight: FontWeight.bold)),
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

  // --- BOTTOM NAVBAR INTERAKTIF ---
  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFFF5CC9E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_filled, 0),
          _buildNavItem(Icons.search, 1),
          _buildNavItem(Icons.shopping_bag_outlined, 2),
          _buildNavItem(Icons.person_outline, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _currentIndex == index;

    if (index == 2 && _cartCount > 0) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? const Color(0xFF8A4607) : Colors.brown.withOpacity(0.4),
            ),
            Positioned(
              top: -5,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text(
                  '$_cartCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Icon(
        icon,
        size: 28,
        color: isSelected ? const Color(0xFF8A4607) : Colors.brown.withOpacity(0.4),
      ),
    );
  }
}