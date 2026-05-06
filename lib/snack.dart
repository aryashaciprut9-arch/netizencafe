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
      _filteredItems = _snackItems.where((m) {
        return m.nama.toLowerCase().contains(query);
      }).toList();
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
      ).then((_) {
        setState(() {}); // refresh badge setelah balik
      });
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
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: "Cari snack...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: _AppColors.primaryLighter,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Text(
        "Semua Snack",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildGrid(double width) {
    final crossAxisCount = _getCrossAxisCount(width);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = _filteredItems[index];

            return _SnackCard(
              item: item,
              imageUrl: _buildImageUrl(item.foto),
              onAddToCart: () => widget.onAddToCart(item),
              

            );
          },
          childCount: _filteredItems.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
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
          _NavItem(icon: Icons.home_rounded, index: 0, currentIndex: _selectedNavIndex, onTap: _onNavTap),
          _NavItem(icon: Icons.search_rounded, index: 1, currentIndex: _selectedNavIndex, onTap: _onNavTap),
          _NavItem(
            icon: Icons.shopping_bag_rounded,
            index: 2,
            currentIndex: _selectedNavIndex,
            onTap: _onNavTap,
            badgeCount: widget.keranjang.fold(0, (s, i) => s + i.qty),
          ),
          _NavItem(icon: Icons.person_rounded, index: 3, currentIndex: _selectedNavIndex, onTap: _onNavTap),
        ],
      ),
    );
  }
}

// ================= CARD =================
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
    return GestureDetector(
      onTap: onAddToCart,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _AppColors.primary.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Container(color: _AppColors.primaryLighter),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.nama,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('IDR ${item.harga}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add,
                                size: 18, color: _AppColors.primary),
                          ),
                        ),
                      )
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
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 48 : 36,
              height: isSelected ? 48 : 36,
              decoration: BoxDecoration(
                color: isSelected ? _AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : _AppColors.primary.withOpacity(0.4),
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
                    style: const TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}