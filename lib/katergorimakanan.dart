import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Geologica',
        useMaterial3: true,
      ),
      home: const MenuPage(),
    );
  }
}

// MODEL DATA
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

// HALAMAN UTAMA
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // Data Dummy Menu
  final List<MenuItem> _allMenuItems = [
    MenuItem(id: '1', name: 'Rice Chicken Mushroom', price: 'IDR 15.000', imageUrl: 'https://placehold.co/400x300/FFFFFF/8A4607?text=Mushroom', rating: 4.9),
    MenuItem(id: '2', name: 'Rice Chicken Blackpapper', price: 'IDR 15.000', imageUrl: 'https://placehold.co/400x300/FFFFFF/8A4607?text=Blackpaper', rating: 4.7),
    MenuItem(id: '3', name: 'Rice Sambal Goreng Cumi', price: 'IDR 18.000', imageUrl: 'https://placehold.co/400x300/FFFFFF/8A4607?text=Cumi', rating: 4.8),
    MenuItem(id: '4', name: 'Chicken Teriyaki', price: 'IDR 17.000', imageUrl: 'https://placehold.co/400x300/FFFFFF/8A4607?text=Teriyaki', rating: 4.6),
    MenuItem(id: '5', name: 'Bakso Special', price: 'IDR 13.000', imageUrl: 'https://placehold.co/400x300/FFFFFF/8A4607?text=Bakso', rating: 4.9),
    MenuItem(id: '6', name: 'Bakso Urat', price: 'IDR 15.000', imageUrl: 'https://placehold.co/400x300/FFFFFF/8A4607?text=Bakso+Urat', rating: 4.5),
    MenuItem(id: '7', name: 'Mie Ayam Cakalang', price: 'IDR 12.000', imageUrl: 'https://placehold.co/400x300/FFFFFF/8A4607?text=Mie+Ayam', rating: 4.7),
    MenuItem(id: '8', name: 'Es Teh Manis', price: 'IDR 5.000', imageUrl: 'https://placehold.co/400x300/FFFFFF/8A4607?text=Es+Teh', rating: 5.0),
  ];

  final TextEditingController _searchController = TextEditingController();
  List<MenuItem> _filteredMenuItems = [];
  
  // State Keranjang
  final Map<String, int> _cartItems = {};
  int _totalCartCount = 0;

  // State untuk Navbar
  int _selectedIndex = 0; // 0: Home, 1: Search, 2: Cart, 3: Profile

  @override
  void initState() {
    super.initState();
    _filteredMenuItems = _allMenuItems;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMenu(String query) {
    setState(() {
      _filteredMenuItems = _allMenuItems
          .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _addToCart(MenuItem item, int quantity) {
    setState(() {
      _cartItems.update(item.id, (value) => value + quantity, ifAbsent: () => quantity);
      _totalCartCount += quantity;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(15),
        backgroundColor: const Color(0xFFF5CC9E),
        content: Text('${item.name} (x$quantity) ditambahkan', style: const TextStyle(color: Color(0xFF5C2E05), fontWeight: FontWeight.w600)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDetailSheet(MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailSheet(
        item: item,
        onAddToCart: (qty) {
          _addToCart(item, qty);
          Navigator.pop(context);
        },
      ),
    );
  }

  // Logika navigasi navbar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Tambahkan logika navigasi ke halaman lain jika ada
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8A4607), // Warna dasar body
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8A4607), Color(0xFF5C2E05)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
      // --- PERUBAHAN UTAMA: BOTTOM NAVBAR ---
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Widget Navbar Baru
  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFFF5CC9E), // Warna pembungkus sesuai permintaan
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_filled, 0),
          _buildNavItem(Icons.search, 1),
          _buildNavItem(Icons.shopping_bag_outlined, 2, showBadge: true), // Ikon Keranjang
          _buildNavItem(Icons.person_outline, 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, {bool showBadge = false}) {
    final bool isSelected = _selectedIndex == index;
    final Color activeColor = const Color(0xFF8A4607); // Coklat Gelap
    final Color inactiveColor = Colors.brown.withOpacity(0.4); // Coklat Transparan

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque, // Agar area kosong bisa diklik
      child: SizedBox(
        width: 60,
        height: 50,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? activeColor : inactiveColor,
            ),
            // Badge untuk Keranjang
            if (showBadge && _totalCartCount > 0)
              Positioned(
                top: 0,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red, 
                    shape: BoxShape.circle
                  ),
                  child: Text(
                    '$_totalCartCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu Makanan',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Pilih menu favoritmu',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white24),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMenu,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari menu lezat...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.8)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_filteredMenuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 60, color: Colors.white.withOpacity(0.5)),
            const SizedBox(height: 10),
            Text("Menu tidak ditemukan", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20), // Padding bawah dikurangi karena tidak ada FAB
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: _filteredMenuItems.length,
      itemBuilder: (context, index) {
        return _buildMenuCard(_filteredMenuItems[index]);
      },
    );
  }

  Widget _buildMenuCard(MenuItem item) {
    return GestureDetector(
      onTap: () => _showDetailSheet(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'image_${item.id}',
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        image: DecorationImage(
                          image: NetworkImage(item.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(item.rating.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.price,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF8A4607)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tersedia', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                      GestureDetector(
                        onTap: () => _addToCart(item, 1),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Color(0xFF8A4607),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET DETAIL BOTTOM SHEET
class _DetailSheet extends StatefulWidget {
  final MenuItem item;
  final Function(int) onAddToCart;

  _DetailSheet({required this.item, required this.onAddToCart});

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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'image_${widget.item.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                      child: Image.network(
                        widget.item.imageUrl,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
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
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF333333)),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.item.price,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF8A4607)),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          "Deskripsi makanan yang lezat dan bergizi, cocok untuk makan siang atau malam bersama keluarga.",
                          style: TextStyle(color: Colors.grey[600], height: 1.5, fontSize: 13),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Jumlah", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => setState(() => _quantity > 1 ? _quantity-- : null),
                                    icon: const Icon(Icons.remove, color: Color(0xFF8A4607)),
                                  ),
                                  Text(_quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  IconButton(
                                    onPressed: () => setState(() => _quantity++),
                                    icon: const Icon(Icons.add, color: Color(0xFF8A4607)),
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
                              backgroundColor: const Color(0xFF8A4607),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const Text(
                              "Tambah ke Keranjang",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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