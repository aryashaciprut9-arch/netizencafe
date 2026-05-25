import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api_services.dart';
import 'models/menu_models.dart';
import 'detailkeranjang.dart';
import 'kategoriminuman.dart';
import 'beranda.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

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

// ─── Halaman Snack ────────────────────────────────────────────────────────────

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

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  List<MenuModel> _snackItems     = [];
  List<MenuModel> _filteredItems  = [];
  bool _isLoading                 = true;
  int _selectedNavIndex           = 1; // index 1 = Home (tengah)
  String _searchQuery             = '';
  final TextEditingController _searchCtrl = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int get _keranjangCount =>
      widget.keranjang.fold(0, (sum, item) => sum + item.qty);

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
    _searchCtrl.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMenu();
      setState(() {
        _snackItems = data
            .where((m) => m.kategori.toLowerCase().contains('snack'))
            .toList();
        _filteredItems = _snackItems;
        _isLoading = false;
      });
      _fadeController.forward(from: 0);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch(String value) {
    setState(() {
      _searchQuery = value;
      _filteredItems = _snackItems
          .where((m) => m.nama.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
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
    if (!item.tersedia) return;
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
    setState(() => _selectedNavIndex = index);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════════════

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
                            SliverToBoxAdapter(child: _buildHeader()),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 14)),
                            SliverToBoxAdapter(child: _buildSearchBar()),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 18)),
                            SliverToBoxAdapter(child: _buildTitle()),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 12)),
                            _buildGrid(constraints.maxWidth),
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaMenuJenisMinuman(
                        keranjang: widget.keranjang,
                        onAddToCart: widget.onAddToCart as void Function(MenuModel),
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
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: AppColors.primary, size: 16),
                ),
              ),
              const SizedBox(width: 15),
              Text(
                'Snack',
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
              child: const Icon(Icons.home_rounded,
                  color: AppColors.primary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
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
          controller: _searchCtrl,
          onChanged: _onSearch,
          style: GoogleFonts.openSans(
            color: AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Cari snack...',
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
                      _searchCtrl.clear();
                      _onSearch('');
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

  Widget _buildTitle() {
    final title =
        _searchQuery.isNotEmpty ? 'Hasil Pencarian' : 'Semua Snack';
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
              '${_filteredItems.length} menu',
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

  // ─── Grid ────────────────────────────────────────────────────────────────────

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

  // ─── Bottom Nav Bar (3 item: Keranjang — Home — Profil) ──────────────────────

  Widget _buildBottomNav() {
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
              currentIndex: _selectedNavIndex,
              onTap: _onNavTap,
              badgeCount: _keranjangCount),
          _NavItem(
              icon: Icons.home_rounded,
              index: 1,
              currentIndex: _selectedNavIndex,
              onTap: _onNavTap),
          _NavItem(
              icon: Icons.person_rounded,
              index: 2,
              currentIndex: _selectedNavIndex,
              onTap: _onNavTap),
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

  const _SnackCard({
    required this.item,
    required this.imageUrl,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                      child: Icon(Icons.cookie_outlined,
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