import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/api_services.dart';
import 'models/menu_models.dart';
import 'kategoriminuman.dart';
import 'beranda.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

class _AppColors {
  static const Color primary        = Color(0xFF8A4607);
  static const Color primaryLight   = Color(0xFFF5CC9E);
  static const Color primaryLighter = Color(0xFFFFF4E6);
  static const Color white          = Colors.white;
}

// ─── Halaman Snack ───────────────────────────────────────────────────────────

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  // =====================
  //  STATE & DATA
  // =====================
  List<MenuModel> _snackItems    = [];
  List<MenuModel> _filteredItems = [];
  bool _isLoading                = true;
  int _selectedNavIndex          = 0;
  String _searchQuery            = '';
  final TextEditingController _searchCtrl = TextEditingController();

  int _getCrossAxisCount(double width) {
    if (width < 500)  return 2;
    if (width < 850)  return 3;
    if (width < 1100) return 4;
    if (width < 1400) return 5;
    return 6;
  }

  // =====================
  //  FUNGSI / LOGIKA
  // =====================
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
        _snackItems = data.where((m) {
          String kat = m.kategori.toLowerCase().trim();
          return kat.contains('snack');
        }).toList();
        _filteredItems = _snackItems;
        _isLoading     = false;
      });
    } catch (e) {
      print("ERROR SNACK: $e");
      setState(() => _isLoading = false);
    }
  }

  void _onSearch() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _searchQuery   = query;
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

  void _onNavTap(int index) {
    if (index == 0) {
      // Home → kembali ke beranda
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PuBeranda()),
        (route) => false,
      );
      return;
    }
    setState(() => _selectedNavIndex = index);
    HapticFeedback.selectionClick();
  }

  // =====================
  //  UI / BUILD
  // =====================
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
                      SliverToBoxAdapter(child: _buildHeader(context)),
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),
                      SliverToBoxAdapter(child: _buildSearchBar(context)),
                      const SliverToBoxAdapter(child: SizedBox(height: 15)),
                      SliverToBoxAdapter(child: _buildSectionTitle(context)),
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),
                      _buildSnackGrid(context, constraints.maxWidth),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  );
                },
              ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Panah kiri → ke halaman Minuman
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PaMenuJenisMinuman()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _AppColors.primaryLighter,
                    shape: BoxShape.circle,
                    border: Border.all(color: _AppColors.primary.withOpacity(0.1)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: _AppColors.primary, size: 16),
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                'Snack',
                style: TextStyle(
                  color: _AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          // Panah kanan → kembali ke Beranda
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const PuBeranda()),
                (route) => false,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _AppColors.primaryLighter,
                shape: BoxShape.circle,
                border: Border.all(color: _AppColors.primary.withOpacity(0.1)),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  color: _AppColors.primary, size: 16),
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
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: _AppColors.primary, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
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
    final title = _searchQuery.isNotEmpty ? 'Hasil Pencarian' : 'Semua Snack';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                color: _AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              )),
          Text('${_filteredItems.length} menu',
              style: TextStyle(color: _AppColors.primary.withOpacity(0.45), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSnackGrid(BuildContext context, double screenWidth) {
    final items        = _filteredItems;
    int crossAxisCount = _getCrossAxisCount(screenWidth);

    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded, size: 52, color: _AppColors.primary.withOpacity(0.2)),
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
          (context, index) => _SnackCard(
            item: items[index],
            imageUrl: _buildImageUrl(items[index].foto),
            onAddToCart: () {
              // TODO: tambah ke keranjang
            },
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

  // =====================
  //  NAVBAR BAWAH
  // =====================
  Widget _buildBottomNavBar() {
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
          _NavItem(icon: Icons.shopping_bag_rounded, index: 2, currentIndex: _selectedNavIndex, onTap: _onNavTap),
          _NavItem(icon: Icons.person_rounded,       index: 3, currentIndex: _selectedNavIndex, onTap: _onNavTap),
        ],
      ),
    );
  }
}

// ─── Snack Card Widget ────────────────────────────────────────────────────────

class _SnackCard extends StatelessWidget {
  final MenuModel item;
  final String imageUrl;
  final VoidCallback onAddToCart;

  const _SnackCard({required this.item, required this.imageUrl, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: _AppColors.primary.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: _AppColors.primaryLighter,
                      child: Center(child: Icon(Icons.broken_image_rounded, color: _AppColors.primary.withOpacity(0.3), size: 40)),
                    ))
                : Container(color: _AppColors.primaryLighter,
                    child: const Center(child: Icon(Icons.fastfood, color: _AppColors.primary, size: 40))),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white.withOpacity(0), Colors.white.withOpacity(0.85), _AppColors.white],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.nama, style: const TextStyle(color: _AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('IDR ${item.harga}', style: TextStyle(color: _AppColors.primary.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: item.tersedia ? Colors.green : Colors.red, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text(item.tersedia ? 'Tersedia' : 'Habis', style: TextStyle(color: _AppColors.primary.withOpacity(0.5), fontSize: 10)),
                        ]),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(color: _AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
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
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56, height: 56,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? 48 : 36,
          height: isSelected ? 48 : 36,
          decoration: BoxDecoration(
            color: isSelected ? _AppColors.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: isSelected ? Colors.white : _AppColors.primary.withOpacity(0.35)),
        ),
      ),
    );
  }
}