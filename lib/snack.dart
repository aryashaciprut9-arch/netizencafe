import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/api_services.dart';
import 'models/menu_models.dart';
import 'detailkeranjang.dart';

// ================= COLORS =================
class _AppColors {
  static const Color primary        = Color(0xFF8A4607);
  static const Color primaryLight   = Color(0xFFF5CC9E);
  static const Color primaryLighter = Color(0xFFFFF4E6);
  static const Color white          = Colors.white;
}

// ================= PAGE =================
class MenuPage extends StatefulWidget {
  final List<KeranjangItem> keranjang;
  final Function(MenuModel) onAddToCart;

  const MenuPage({
    super.key,
    required this.keranjang,
    required this.onAddToCart,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<MenuModel> _snackItems = [];
  List<MenuModel> _filteredItems = [];
  bool _isLoading = true;
  int _selectedNavIndex = 0;

  final TextEditingController _searchCtrl = TextEditingController();

  int get _keranjangCount => widget.keranjang.fold(0, (sum, item) => sum + item.qty);

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMenu();
      setState(() {
        _snackItems = data.where((m) =>
            m.kategori.toLowerCase().contains('snack')).toList();
        _filteredItems = _snackItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredItems = _snackItems.where((m) =>
          m.nama.toLowerCase().contains(query)).toList();
    });
  }

  String _buildImageUrl(String foto) {
    if (foto.isEmpty) return '';
    if (foto.startsWith('http')) return foto;
    return "${ApiService.baseUrl}/menu/uploads/$foto";
  }

  int _getCrossAxisCount(double width) {
    if (width < 500) return 2;
    if (width < 900) return 3;
    return 4;
  }

  void _addToCart(MenuModel item) {
    if (!item.tersedia) return;
    widget.onAddToCart(item);
    setState(() {}); // langsung refresh badge
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('${item.nama} ditambahkan ke keranjang'),
        backgroundColor: _AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ));
  }

  void _onNavTap(int index) {
    setState(() => _selectedNavIndex = index);
    HapticFeedback.selectionClick();

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PuDetailKeranjang(
            items: widget.keranjang,
            userId: 0,
            namaPelanggan: 'User',
          ),
        ),
      ).then((_) => setState(() {}));
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _AppColors.primary))
            : LayoutBuilder(
                builder: (context, constraints) {
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader()),
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),
                      SliverToBoxAdapter(child: _buildSearchBar()),
                      const SliverToBoxAdapter(child: SizedBox(height: 15)),
                      SliverToBoxAdapter(child: _buildTitle()),
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),
                      _buildGrid(constraints.maxWidth),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  );
                },
              ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _AppColors.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: _AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Snack",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: _AppColors.primaryLighter,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _AppColors.primary.withOpacity(0.15)),
        ),
        child: TextField(
          controller: _searchCtrl,
          style: const TextStyle(color: _AppColors.primary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Cari snack...',
            hintStyle: TextStyle(color: _AppColors.primary.withOpacity(0.4), fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: _AppColors.primary, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Semua Snack",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _AppColors.primary,
            ),
          ),
          Text('${_filteredItems.length} menu',
              style: TextStyle(color: _AppColors.primary.withOpacity(0.45), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildGrid(double width) {
    final crossAxisCount = _getCrossAxisCount(width);

    if (_filteredItems.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 52, color: _AppColors.primary.withOpacity(0.2)),
                const SizedBox(height: 10),
                Text('Menu tidak ditemukan',
                    style: TextStyle(color: _AppColors.primary.withOpacity(0.4), fontSize: 15)),
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
          (context, index) {
            final item = _filteredItems[index];
            return _SnackCard(
              item: item,
              imageUrl: _buildImageUrl(item.foto),
              onAddToCart: () => _addToCart(item),
            );
          },
          childCount: _filteredItems.length,
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

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: _AppColors.primaryLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(icon: Icons.home_rounded,         index: 0, currentIndex: _selectedNavIndex, onTap: _onNavTap),
          _NavItem(icon: Icons.search_rounded,       index: 1, currentIndex: _selectedNavIndex, onTap: _onNavTap),
          _NavItem(icon: Icons.shopping_bag_rounded, index: 2, currentIndex: _selectedNavIndex, onTap: _onNavTap, badgeCount: _keranjangCount),
          _NavItem(icon: Icons.person_rounded,       index: 3, currentIndex: _selectedNavIndex, onTap: _onNavTap),
        ],
      ),
    );
  }
}

// ================= CARD (sama seperti makanan) =================
class _SnackCard extends StatelessWidget {
  final MenuModel item;
  final String imageUrl;
  final VoidCallback onAddToCart;

  const _SnackCard({
    required this.item,
    required this.imageUrl,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _AppColors.primary.withOpacity(0.15),
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
            imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: _AppColors.primaryLighter,
                      child: Center(child: Icon(Icons.broken_image,
                          color: _AppColors.primary.withOpacity(0.3), size: 40)),
                    ))
                : Container(
                    color: _AppColors.primaryLighter,
                    child: const Center(child: Icon(Icons.fastfood,
                        color: _AppColors.primary, size: 40))),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF8A4607).withOpacity(0.6),
                      const Color(0xFF5C2D00).withOpacity(0.92),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.nama,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('IDR ${item.harga}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Container(
                            width: 7, height: 7,
                            decoration: BoxDecoration(
                              color: item.tersedia ? Colors.greenAccent : Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(item.tersedia ? 'Tersedia' : 'Habis',
                              style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        ]),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 30, height: 30,
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.add_rounded,
                                color: _AppColors.primary, size: 20),
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

// ================= NAV ITEM =================
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
        width: 56, height: 56,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 48 : 36,
              height: isSelected ? 48 : 36,
              decoration: BoxDecoration(
                color: isSelected ? _AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24,
                  color: isSelected ? Colors.white : _AppColors.primary.withOpacity(0.35)),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 4, right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Text('$badgeCount',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}