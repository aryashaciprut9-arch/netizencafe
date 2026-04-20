import 'package:flutter/material.dart';

void main() {
  runApp(const FoodApp());
}

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
      home: const SearchPage(),
    );
  }
}

// ─── Data Model ───────────────────────────────────────────────
class FoodItem {
  final String name;
  final String price;
  final String status;
  final String image;

  const FoodItem({
    required this.name,
    required this.price,
    required this.status,
    required this.image,
  });
}

// ─── Search Page ──────────────────────────────────────────────
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<String> _recentSearches = [
    'Gelato Matcha',
    'Risol Mayo',
    'Ricebowl Chicken Blackpaper',
  ];

  int _cartCount = 0;
  int _selectedNavIndex = 1;
  String _searchQuery = '';

  late AnimationController _fabController;

  final List<FoodItem> _trendingItems = const [
    FoodItem(
      name: 'Chocolato Cheese',
      price: 'IDR 17.000',
      status: 'Tersedia',
      image: 'assets/Choffe cheese.png',
    ),
    FoodItem(
      name: 'Bakso',
      price: 'IDR 13.000',
      status: 'Tersedia',
      image: 'assets/imgbakso.png',
    ),
    FoodItem(
      name: 'Mie Ayam Cakalang',
      price: 'IDR 15.000',
      status: 'Tersedia',
      image: 'assets/mieayam.png',
    ),
    FoodItem(
      name: 'Chiken Teriyaki',
      price: 'IDR 15.000',
      status: 'Tersedia',
      image: 'assets/ricebowl teriyaki.png'
    )
  ];

  List<FoodItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _trendingItems;
    return _trendingItems
        .where((item) =>
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
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
    _showSnackBar('${item.name} ditambahkan ke keranjang');
  }

  void _removeRecentSearch(int index) {
    setState(() => _recentSearches.removeAt(index));
  }

  void _clearAllRecentSearches() {
    setState(() => _recentSearches.clear());
    _showSnackBar('Riwayat pencarian dihapus');
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF8A4607),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.046; // ~20px on 430

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(horizontalPadding),
            _buildDivider(),
            Expanded(child: _buildContent(horizontalPadding)),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.black.withOpacity(0.1));
  }

  // ── Search Bar ──
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
        onTap: () => Navigator.maybePop(context),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF8A4607),
          ),
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
              style: const TextStyle(
                color: Color(0xFF8A4607),
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                hintText: 'Cari Makanan, Minuman...',
                hintStyle: TextStyle(
                  color: Color(0x998A4607),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
              onSubmitted: _submitSearch,
              onChanged: (val) {
                if (_searchQuery.isEmpty && val.isNotEmpty) {
                  // User is typing fresh search
                }
              },
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
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFB50000).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 20,
            color: Color(0xFFB50000),
          ),
        ),
      ),
    );
  }

  // ── Content Area ──
  Widget _buildContent(double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchQuery.isEmpty) ...[
            _buildRecentSearchesSection(),
            const SizedBox(height: 28),
          ],
          _buildTrendingSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Recent Searches ──
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
              const Text(
                'Pencarian terakhir',
                style: TextStyle(
                  color: Color(0xFF8A4607),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: _clearAllRecentSearches,
                child: const Text(
                  'Hapus semua',
                  style: TextStyle(
                    color: Color(0xFFB50000),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(
            _recentSearches.length,
            (i) => _recentSearchTile(_recentSearches[i], i),
          ),
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
              const Icon(Icons.history_rounded,
                  size: 18, color: Color(0xFFB50000)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF8A4607),
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: Color(0xFF767070)),
                onPressed: () => _removeRecentSearch(index),
                visualDensity: VisualDensity.compact,
                tooltip: 'Hapus',
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
      decoration: BoxDecoration(
        color: const Color(0xFFB50000),
        borderRadius: BorderRadius.circular(10),
      ),
      child:
          const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
    );
  }

  // ── Trending Section ──
  Widget _buildTrendingSection() {
    final items = _filteredItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _searchQuery.isEmpty ? 'Sedang Trending' : 'Hasil pencarian',
          style: const TextStyle(
            color: Color(0xFF8A4607),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (_searchQuery.isNotEmpty && items.isEmpty) ...[
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(Icons.search_off_rounded,
                    size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  '"$_searchQuery" tidak ditemukan',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                  ),
                ),
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTap: () => _showDetailSheet(item),
        child: Container(
          decoration: ShapeDecoration(
            color: const Color(0xFF8A4607),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF6B3605),
                          child: const Icon(Icons.broken_image_rounded,
                              color: Colors.white38, size: 36),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFF6B3605),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                    : null,
                                color: const Color(0xFFF5CC9E),
                              ),
                            ),
                          );
                        },
                      ),
                      // Favorite icon
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _favButton(item),
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
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.price,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.status,
                            style: const TextStyle(
                              color: Color(0xFFF5CC9E),
                              fontSize: 8,
                            ),
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

  Widget _favButton(FoodItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showSnackBar('${item.name} ditambahkan ke favorit'),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_border_rounded,
            size: 16,
            color: Color(0xFFB50000),
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
          width: 28,
          height: 28,
          decoration: const ShapeDecoration(
            color: Colors.white,
            shape: OvalBorder(),
          ),
          child: const Center(
            child: Text(
              '+',
              style: TextStyle(
                color: Color(0xFF8A4607),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Detail Bottom Sheet ──
  void _showDetailSheet(FoodItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _DetailSheet(item: item, onAdd: () {
        Navigator.pop(context);
        _addToCart(item);
      }),
    );
  }

  // ── Bottom Navigation ──
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      decoration: ShapeDecoration(
        color: const Color(0xFFF5CC9E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home_outlined, Icons.home_rounded, 'Home', 0),
          _navItem(Icons.search_outlined, Icons.search_rounded, 'Cari', 1),
          _navCartItem(),
          _navItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profil', 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData inactive, IconData active, String label, int index) {
    final isSelected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedNavIndex = index);
        if (index != 1) {
          _showSnackBar('Halaman $label (segera hadir)');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8A4607).withOpacity(0.15)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? active : inactive,
              color: const Color(0xFF8A4607),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF8A4607),
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navCartItem() {
    final isSelected = _selectedNavIndex == 2;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedNavIndex = 2);
        _showSnackBar('Keranjang: $_cartCount item (segera hadir)');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8A4607).withOpacity(0.15)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              isLabelVisible: _cartCount > 0,
              label: Text('$_cartCount',
                  style: const TextStyle(fontSize: 10, color: Colors.white)),
              backgroundColor: const Color(0xFFB50000),
              offset: const Offset(-2, -2),
              child: Icon(
                isSelected
                    ? Icons.shopping_cart_rounded
                    : Icons.shopping_cart_outlined,
                color: const Color(0xFF8A4607),
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Keranjang',
              style: TextStyle(
                color: const Color(0xFF8A4607),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Detail Bottom Sheet ──────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onAdd;

  const _DetailSheet({required this.item, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item.image,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: const Color(0xFF6B3605),
                child: const Icon(Icons.broken_image_rounded,
                    color: Colors.white38, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8A4607),
            ),
          ),
          const SizedBox(height: 6),
          // Price + Status
          Row(
            children: [
              Text(
                item.price,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A4607),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5CC9E).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.status,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8A4607),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF8A4607)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: Color(0xFF8A4607),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A4607),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Tambah ke Keranjang',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
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