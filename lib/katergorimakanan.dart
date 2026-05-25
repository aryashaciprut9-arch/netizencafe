// FILE: menu_makanan.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:netizencafe/detailkeranjang.dart';
import 'models/menu_models.dart';
import 'services/api_services.dart';
import 'kategoriminuman.dart';
import 'beranda.dart';

// ─── Constants ───────────────────────────────────────────────────────────────
class AppColors {
  static const Color primary        = Color(0xFFB86B2B);
  static const Color accent         = Color(0xFF8D5524);
  static const Color textDark       = Color(0xFF6D4C41);
  static const Color cardColor      = Color(0xFFFFFBF5);
  static const Color primaryLight   = Color(0xFFF5CC9E);
  static const Color primaryLighter = Color(0xFFFFF8F2);
  static const Color white          = Colors.white;

  static const List<Color> bgGradient = [
    Color(0xFFFFF8F2),
    Color(0xFFFDE8D7),
    Color(0xFFE8CBB0),
    Color(0xFFD4A57A),
  ];
}

class CartItem {
  final MenuModel product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class MenuPage extends StatefulWidget {
  final List<KeranjangItem> keranjang;
  final void Function(MenuModel) onAddToCart;

  const MenuPage({
    super.key,
    required this.keranjang,
    required this.onAddToCart,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  List<MenuModel> _allMenuItems = [];
  bool _isLoading               = true;
  int _currentIndex             = 1; // index 1 = Home (tengah)
  String _searchQuery           = '';
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int get _keranjangCount =>
      widget.keranjang.fold(0, (sum, item) => sum + item.qty);

  List<MenuModel> get _filteredMenuItems {
    final items = _allMenuItems
        .where((m) => m.kategori.toLowerCase().trim().contains('makanan'))
        .toList();
    if (_searchQuery.isEmpty) return items;
    return items
        .where((m) =>
            m.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack));

    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMenu();
      setState(() {
        _allMenuItems = data;
        _isLoading = false;
      });
      _fadeController.forward(from: 0);
    } catch (e) {
      debugPrint("ERROR MAKANAN: $e");
      setState(() => _isLoading = false);
    }
  }

  String _buildImageUrl(String foto) {
    if (foto.isEmpty) return '';
    if (foto.startsWith('http')) return foto;
    return "${ApiService.baseUrl}/menu/uploads/$foto";
  }

  int _getCrossAxisCount(double width) {
    if (width < 500) return 2;
    if (width < 850) return 3;
    if (width < 1100) return 4;
    if (width < 1400) return 5;
    return 6;
  }

  void _addToCart(MenuModel item) {
    widget.onAddToCart(item);
    setState(() {});
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${item.nama} ditambahkan ke keranjang',
                  style: GoogleFonts.openSans(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  void _addToCartWithQty(MenuModel item, int quantity) {
    for (int i = 0; i < quantity; i++) {
      widget.onAddToCart(item);
    }
    HapticFeedback.lightImpact();
  }

  void _showDetailSheet(MenuModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailSheet(
        item: item,
        imageUrl: _buildImageUrl(item.foto),
        onAddToCart: (qty) {
          _addToCartWithQty(item, qty);
          Navigator.pop(context);
        },
      ),
    );
  }

  // index: 0 = Keranjang, 1 = Home (tengah), 2 = Profil
  void _onNavTap(int index) {
    HapticFeedback.selectionClick();
    if (index == 1) {
      // Home
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PuBeranda()),
        (route) => false,
      );
      return;
    }
    if (index == 0) {
      // Keranjang
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PuDetailKeranjang(
            items: List.from(widget.keranjang),
            userId: 0,
            namaPelanggan: 'User',
          ),
        ),
      );
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.bgGradient,
            stops: [0.0, 0.3, 0.7, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                                child: _buildHeader(context)),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 14)),
                            SliverToBoxAdapter(
                                child: _buildSearchBar(context)),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 18)),
                            SliverToBoxAdapter(
                                child: _buildSectionTitle(context)),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 12)),
                            _buildMenuGrid(context, constraints.maxWidth),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 90)),
                          ],
                        );
                      },
                    ),
                  ),
                ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, AppColors.cardColor],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.2), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: AppColors.primary, size: 16),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                'Makanan',
                style: GoogleFonts.poppins(
                  color: AppColors.accent,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.08),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PaMenuJenisMinuman(
                    keranjang: widget.keranjang,
                    onAddToCart: widget.onAddToCart,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, AppColors.cardColor],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.primary, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, AppColors.cardColor],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
              color: AppColors.primary.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: GoogleFonts.openSans(
            color: AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Cari makanan...',
            hintStyle: GoogleFonts.openSans(
              color: AppColors.textDark.withOpacity(0.45),
              fontSize: 14,
            ),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.primary, size: 22),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.primary, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 17),
          ),
        ),
      ),
    );
  }

  // ─── Section Title ────────────────────────────────────────────────────────────
  Widget _buildSectionTitle(BuildContext context) {
    final title =
        _searchQuery.isNotEmpty ? 'Hasil Pencarian' : 'Semua Makanan';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.accent,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.2), width: 1),
            ),
            child: Text(
              '${_filteredMenuItems.length} menu',
              style: GoogleFonts.openSans(
                color: AppColors.textDark.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Menu Grid ───────────────────────────────────────────────────────────────
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
                Icon(Icons.search_off_rounded,
                    size: 52, color: AppColors.primary.withOpacity(0.2)),
                const SizedBox(height: 10),
                Text(
                  'Menu tidak ditemukan',
                  style: GoogleFonts.poppins(
                    color: AppColors.textDark.withOpacity(0.4),
                    fontSize: 14,
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
            imageUrl: _buildImageUrl(items[index].foto),
            onAddToCart: () => _addToCart(items[index]),
            onTap: () => _showDetailSheet(items[index]),
          ),
          childCount: items.length,
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

  // ─── Bottom Nav Bar (3 item: Keranjang — Home — Profil) ──────────────────────
  Widget _buildBottomNavBar() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, AppColors.cardColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(
          top: BorderSide(
              color: AppColors.primary.withOpacity(0.15), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
              icon: Icons.shopping_bag_rounded,
              index: 0,
              currentIndex: _currentIndex,
              onTap: _onNavTap,
              badgeCount: _keranjangCount),
          _NavItem(
              icon: Icons.home_rounded,
              index: 1,
              currentIndex: _currentIndex,
              onTap: _onNavTap),
          _NavItem(
              icon: Icons.person_rounded,
              index: 2,
              currentIndex: _currentIndex,
              onTap: _onNavTap),
        ],
      ),
    );
  }
}

// ─── Food Card Widget ─────────────────────────────────────────────────────────
class _FoodCard extends StatelessWidget {
  final MenuModel item;
  final String imageUrl;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  const _FoodCard({
    required this.item,
    required this.imageUrl,
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.cardColor,
                        child: Center(
                          child: Icon(Icons.broken_image_outlined,
                              color: AppColors.primary.withOpacity(0.3),
                              size: 40),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.cardColor,
                      child: const Center(
                        child: Icon(Icons.fastfood_rounded,
                            color: AppColors.primary, size: 40),
                      ),
                    ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 44, 10, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFFB86B2B).withOpacity(0.55),
                        const Color(0xFF8D5524).withOpacity(0.92),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.nama,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          shadows: const [
                            Shadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'IDR ${item.harga}',
                        style: GoogleFonts.openSans(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: item.tersedia
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                item.tersedia ? 'Tersedia' : 'Habis',
                                style: GoogleFonts.openSans(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: onAddToCart,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.white, AppColors.cardColor],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: AppColors.primary,
                                size: 20,
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

// ─── Nav Item Widget ──────────────────────────────────────────────────────────
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
        width: 58,
        height: 58,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: isSelected ? 50 : 38,
              height: isSelected ? 50 : 38,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? Colors.white
                    : AppColors.primary.withOpacity(0.35),
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

// ─── Detail Bottom Sheet ──────────────────────────────────────────────────────
class _DetailSheet extends StatefulWidget {
  final MenuModel item;
  final String imageUrl;
  final Function(int) onAddToCart;

  const _DetailSheet(
      {required this.item, required this.imageUrl, required this.onAddToCart});

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
        gradient: LinearGradient(
          colors: [Colors.white, AppColors.cardColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
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
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    child: widget.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.imageUrl,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              height: 220,
                              color: AppColors.cardColor,
                              child: Center(
                                child: Icon(Icons.broken_image_outlined,
                                    color:
                                        AppColors.primary.withOpacity(0.3),
                                    size: 50),
                              ),
                            ),
                          )
                        : Container(
                            height: 220,
                            color: AppColors.cardColor,
                            child: const Center(
                              child: Icon(Icons.fastfood_rounded,
                                  color: AppColors.primary, size: 50),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.nama,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'IDR ${widget.item.harga}',
                          style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.item.deskripsi.isNotEmpty
                              ? widget.item.deskripsi
                              : 'Tidak ada deskripsi.',
                          style: GoogleFonts.openSans(
                            color: AppColors.textDark.withOpacity(0.6),
                            height: 1.6,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Jumlah',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.accent,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.white, AppColors.cardColor],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => setState(() {
                                      if (_quantity > 1) _quantity--;
                                    }),
                                    icon: const Icon(Icons.remove_rounded,
                                        color: AppColors.primary),
                                  ),
                                  Text(
                                    '$_quantity',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        setState(() => _quantity++),
                                    icon: const Icon(Icons.add_rounded,
                                        color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () => widget.onAddToCart(_quantity),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                              shadowColor: AppColors.primary.withOpacity(0.4),
                            ),
                            child: Text(
                              'Tambah ke Keranjang',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
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