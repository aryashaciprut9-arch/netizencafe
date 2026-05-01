import 'package:flutter/material.dart';



class FoodApp extends StatelessWidget {
  const FoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF8A4607),
          secondary: Color(0xFFF5CC9E),
          error: Color(0xFFB50000),
        ),
      ),
      home: const MainWrapper(),
    );
  }
}

// ─── Main Wrapper untuk Navigasi Global ──────────────────────────────────────
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 1; // Default ke Search (index 1)
  
  final List<Widget> _pages = [
    const HomePage(),      // 0: Home
    const SearchPage(),    // 1: Search
    const CartPage(),      // 2: Cart
    const ProfilePage(),   // 3: Profile
  ];

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      decoration: ShapeDecoration(
        color: const Color(0xFFF5CC9E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        shadows: const [BoxShadow(color: Color(0x3F000000), blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home_outlined, Icons.home_rounded, 'Home', 0),
          _navItem(Icons.search_outlined, Icons.search_rounded, 'Cari', 1),
          _navItem(Icons.shopping_cart_outlined, Icons.shopping_cart_rounded, 'Keranjang', 2),
          _navItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profil', 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData inactive, IconData active, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8A4607).withOpacity(0.15) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? active : inactive, color: const Color(0xFF8A4607), size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: const Color(0xFF8A4607), fontSize: 10, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

// ─── Home Page ───────────────────────────────────────────────────────────────
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hai, Selamat Datang!', style: TextStyle(color: Color(0xFF8A4607), fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Temukan makanan dan minuman favoritmu', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF8A4607), Color(0xFFB35A0A)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Special Offer!', style: TextStyle(color: Color(0xFFF5CC9E), fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Diskon 20% untuk semua menu', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final mainWrapper = context.findAncestorStateOfType<_MainWrapperState>();
                        mainWrapper?._onTabChanged(1);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF8A4607)),
                      child: const Text('Mulai Belanja'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data Model ──────────────────────────────────────────────────────────────
class FoodItem {
  final String id;
  final String name;
  final String price;
  final int priceValue;
  final String status;
  final String image;
  final String category;
  final double rating;

  const FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.priceValue,
    required this.status,
    required this.image,
    this.category = 'Makanan',
    this.rating = 4.5,
  });
}

// ─── Search Page ─────────────────────────────────────────────────────────────
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  final List<String> _recentSearches = [
    'Gelato Matcha',
    'Risol Mayo',
    'Ricebowl Chicken Blackpaper',
  ];

  int _cartCount = 0;
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  late AnimationController _fabController;

  final List<FoodItem> _allFoodItems = const [
    FoodItem(id: '1', name: 'Chocolate Cheese', price: 'IDR 17.000', priceValue: 17000, status: 'Tersedia', image: 'assets/Choffe cheese.png', category: 'Minuman', rating: 4.9),
    FoodItem(id: '2', name: 'Bakso Special', price: 'IDR 13.000', priceValue: 13000, status: 'Tersedia', image: 'assets/imgbakso.png', category: 'Makanan', rating: 4.8),
    FoodItem(id: '3', name: 'Chocolate Cheesecake', price: 'IDR 17.000', priceValue: 17000, status: 'Tersedia', image: 'assets/mieayam.png', category: 'Makanan', rating: 4.7),
    FoodItem(id: '4', name: 'Chicken Teriyaki', price: 'IDR 15.000', priceValue: 15000, status: 'Tersedia', image: 'assets/ricebowl teriyaki.png', category: 'Makanan', rating: 4.6),
    FoodItem(id: '5', name: 'Es Coklat', price: 'IDR 12.000', priceValue: 12000, status: 'Tersedia', image: 'assets/Escoklat.png', category: 'Minuman', rating: 4.5),
    FoodItem(id: '6', name: 'Matcha Cheese', price: 'IDR 17.000', priceValue: 17000, status: 'Tersedia', image: 'assets/matcha1.png', category: 'Minuman', rating: 4.9),
    FoodItem(id: '7', name: 'Orange Noise', price: 'IDR 15.000', priceValue: 15000, status: 'Tersedia', image: 'assets/Orange Noise.png', category: 'Minuman', rating: 4.8),
    FoodItem(id: '8', name: 'Rice Mushroom', price: 'IDR 15.000', priceValue: 15000, status: 'Tersedia', image: 'assets/Rice mushroom.png', category: 'Makanan', rating: 4.7),
  ];

  Set<String> _wishlistItems = {};

  List<FoodItem> get _filteredItems {
    var items = _allFoodItems;
    
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    if (_selectedFilter != 'Semua') {
      items = items.where((item) => item.category == _selectedFilter).toList();
    }
    
    return items;
  }

  List<FoodItem> get _trendingItems {
    return _allFoodItems.where((item) => item.rating >= 4.7).take(4).toList();
  }

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fabController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _addToCart(FoodItem item) {
    setState(() => _cartCount++);
    _showSnackBar('${item.name} ditambahkan ke keranjang', isSuccess: true);
  }

  void _addToWishlist(FoodItem item) {
    setState(() {
      if (_wishlistItems.contains(item.id)) {
        _wishlistItems.remove(item.id);
        _showSnackBar('${item.name} dihapus dari favorit', isSuccess: false);
      } else {
        _wishlistItems.add(item.id);
        _showSnackBar('${item.name} ditambahkan ke favorit', isSuccess: true);
      }
    });
  }

  void _removeRecentSearch(int index) {
    setState(() => _recentSearches.removeAt(index));
  }

  void _clearAllRecentSearches() {
    setState(() => _recentSearches.clear());
    _showSnackBar('Riwayat pencarian dihapus', isSuccess: false);
  }

  void _submitSearch(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        _recentSearches.remove(value.trim());
        _recentSearches.insert(0, value.trim());
        _searchQuery = value.trim();
      });
      _searchController.clear();
      _searchFocus.unfocus();
    }
  }

  void _tapRecentSearch(String text) {
    setState(() => _searchQuery = text);
    _searchFocus.unfocus();
  }

  void _clearSearch() {
    setState(() => _searchQuery = '');
    _searchFocus.requestFocus();
  }

  void _showSnackBar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.info, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: isSuccess ? const Color(0xFF2E7D32) : const Color(0xFF8A4607),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.046;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(horizontalPadding),
            _buildFilterChips(),
            _buildDivider(),
            Expanded(child: _buildContent(horizontalPadding)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.black.withOpacity(0.05));
  }

  Widget _buildSearchBar(double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 10, padding, 10),
      child: Row(
        children: [
          _backButton(),
          const SizedBox(width: 10),
          Expanded(child: _searchField()),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(width: 8),
            _clearSearchButton(),
          ],
        ],
      ),
    );
  }

  Widget _backButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          final mainWrapper = context.findAncestorStateOfType<_MainWrapperState>();
          mainWrapper?._onTabChanged(0);
        },
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF8A4607)),
        ),
      ),
    );
  }

  Widget _searchField() {
    return Container(
      height: 42,
      decoration: ShapeDecoration(
        color: const Color(0xFFF8F8F8),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.2, color: Color(0xFF8A4607)),
          borderRadius: BorderRadius.circular(35),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search, color: Color(0xFF8A4607), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              style: const TextStyle(color: Color(0xFF8A4607), fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Cari Makanan, Minuman...',
                hintStyle: TextStyle(color: Color(0x998A4607), fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
              onSubmitted: _submitSearch,
            ),
          ),
        ],
      ),
    );
  }

  Widget _clearSearchButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _clearSearch,
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: const Color(0xFFB50000).withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.close_rounded, size: 20, color: Color(0xFFB50000)),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Semua', 'Makanan', 'Minuman'];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedFilter = filter);
                },
                backgroundColor: const Color(0xFFF8F8F8),
                selectedColor: const Color(0xFF8A4607),
                labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF8A4607)),
                shape: StadiumBorder(side: BorderSide(color: const Color(0xFF8A4607).withOpacity(0.3))),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContent(double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchQuery.isEmpty && _selectedFilter == 'Semua') ...[
            _buildRecentSearchesSection(),
            const SizedBox(height: 28),
            _buildTrendingSection(),
          ] else ...[
            _buildSearchResultSection(),
          ],
          const SizedBox(height: 80), // ✅ Tambahan space agar tidak tertutup bottom nav
        ],
      ),
    );
  }

  Widget _buildRecentSearchesSection() {
    if (_recentSearches.isEmpty) return const SizedBox.shrink();

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pencarian terakhir', style: TextStyle(color: Color(0xFF8A4607), fontSize: 20, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: _clearAllRecentSearches,
                child: const Text('Hapus semua', style: TextStyle(color: Color(0xFFB50000), fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_recentSearches.length, (i) => _recentSearchTile(_recentSearches[i], i)),
        ],
      ),
    );
  }

  Widget _recentSearchTile(String text, int index) {
    return Dismissible(
      key: ValueKey('recent_$text'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeRecentSearch(index),
      background: _dismissBackground(),
      child: InkWell(
        onTap: () => _tapRecentSearch(text),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.history_rounded, size: 18, color: Color(0xFFB50000)),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF8A4607), fontSize: 15), overflow: TextOverflow.ellipsis)),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF767070)),
                onPressed: () => _removeRecentSearch(index),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dismissBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(color: const Color(0xFFB50000), borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sedang Trending 🔥', style: TextStyle(color: Color(0xFF8A4607), fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: cardWidth / (cardWidth * 1.10),
              ),
              itemCount: _trendingItems.length,
              itemBuilder: (context, index) => _foodCard(_trendingItems[index], index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchResultSection() {
    final items = _filteredItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _searchQuery.isNotEmpty ? 'Hasil pencarian "$_searchQuery"' : 'Menu ${_selectedFilter}',
          style: const TextStyle(color: Color(0xFF8A4607), fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty) ...[
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(Icons.search_off_rounded, size: 70, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('Tidak ditemukan', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Coba kata kunci lain', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
              ],
            ),
          ),
        ] else ...[
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 12) / 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: cardWidth / (cardWidth * 1.10),
                ),
                itemCount: items.length,
                itemBuilder: (context, index) => _foodCard(items[index], index),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _foodCard(FoodItem item, int index) {
    final isInWishlist = _wishlistItems.contains(item.id);
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: Duration(milliseconds: 200 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: GestureDetector(
        onTap: () => _showDetailSheet(item),
        child: Container(
          decoration: ShapeDecoration(
            color: const Color(0xFF8A4607),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            shadows: const [BoxShadow(color: Color(0x3F000000), blurRadius: 6, offset: Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF6B3605), child: const Icon(Icons.broken_image_rounded, color: Colors.white38, size: 36)),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(color: const Color(0xFF6B3605), child: Center(child: CircularProgressIndicator(strokeWidth: 2, value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes! : null, color: const Color(0xFFF5CC9E))));
                        },
                      ),
                      // Rating badge
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              const Icon(Icons.star, size: 12, color: Color(0xFFFFA000)),
                              const SizedBox(width: 4),
                              Text('${item.rating}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      // Favorite icon
                      Positioned(
                        top: 6, right: 6,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _addToWishlist(item),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), shape: BoxShape.circle),
                              child: Icon(isInWishlist ? Icons.favorite : Icons.favorite_border, size: 16, color: isInWishlist ? Colors.red : const Color(0xFFB50000)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Info
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 4, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(item.price, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFF5CC9E).withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                            child: Text(item.status, style: const TextStyle(color: Color(0xFFF5CC9E), fontSize: 8)),
                          ),
                          _addButton(item),
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

  Widget _addButton(FoodItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _addToCart(item),
        child: Container(
          width: 28, height: 28,
          decoration: const ShapeDecoration(color: Colors.white, shape: OvalBorder()),
          child: const Center(child: Text('+', style: TextStyle(color: Color(0xFF8A4607), fontSize: 22, fontWeight: FontWeight.w800, height: 1))),
        ),
      ),
    );
  }

  void _showDetailSheet(FoodItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _DetailSheet(
        item: item,
        isInWishlist: _wishlistItems.contains(item.id),
        onAdd: () {
          Navigator.pop(context);
          _addToCart(item);
        },
        onToggleWishlist: () => _addToWishlist(item),
      ),
    );
  }
}

// ─── Cart Page ───────────────────────────────────────────────────────────────
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text('Keranjang belanja masih kosong', style: TextStyle(color: Color(0xFF8A4607), fontSize: 16)),
              const SizedBox(height: 8),
              Text('Yuk mulai belanja!', style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Profile Page ────────────────────────────────────────────────────────────
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(radius: 50, backgroundColor: Color(0xFFF5CC9E), child: Icon(Icons.person, size: 50, color: Color(0xFF8A4607))),
              const SizedBox(height: 16),
              const Text('Halo, Pengguna!', style: TextStyle(color: Color(0xFF8A4607), fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Fitur profil sedang dalam pengembangan', style: TextStyle(color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Detail Bottom Sheet ─────────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final FoodItem item;
  final bool isInWishlist;
  final VoidCallback onAdd;
  final VoidCallback onToggleWishlist;

  const _DetailSheet({required this.item, required this.isInWishlist, required this.onAdd, required this.onToggleWishlist});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(item.image, height: 200, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 200, color: const Color(0xFF6B3605), child: const Icon(Icons.broken_image_rounded, color: Colors.white38, size: 48))),
              ),
              Positioned(
                top: 12, right: 12,
                child: GestureDetector(
                  onTap: onToggleWishlist,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                    child: Icon(isInWishlist ? Icons.favorite : Icons.favorite_border, color: isInWishlist ? Colors.red : const Color(0xFFB50000), size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF8A4607))),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF8A4607))),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFF5CC9E).withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                child: Text(item.status, style: const TextStyle(fontSize: 11, color: Color(0xFF8A4607), fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF8A4607)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Tutup', style: TextStyle(color: Color(0xFF8A4607), fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A4607),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Tambah ke Keranjang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }
}