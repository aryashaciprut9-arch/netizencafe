import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; // ✅ FIX: Import yang sebelumnya hilang
import 'services/api_services.dart';
import 'models/menu_models.dart';
import 'detailkeranjang.dart';

// ─── Constants (Selaras Global) ───────────────────────────────────────────────
class AppColors {
  static const Color primary        = Color(0xFFB86B2B);
  static const Color accent         = Color(0xFF8D5524);
  static const Color textDark       = Color(0xFF6D4C41);
  static const Color cardColor      = Color(0xFFFFFBF5);
  static const Color primaryLight   = Color(0xFFF5CC9E);
  static const Color primaryLighter = Color(0xFFFFF8F2);
  static const Color white          = Colors.white;
  static const Color danger         = Color(0xFFC62828);

  static const List<Color> bgGradient = [
    Color(0xFFFFF8F2),
    Color(0xFFFDE8D7),
    Color(0xFFE8CBB0),
    Color(0xFFD4A57A),
  ];
}

class PuSearch extends StatefulWidget {
  final List<KeranjangItem> keranjang;
  final void Function(int menuId, String namaMenu, int harga, String foto) onTambahKeranjang;

  const PuSearch({
    super.key,
    required this.keranjang,
    required this.onTambahKeranjang,
  });

  @override
  State<PuSearch> createState() => _PuSearchState();
}

class _PuSearchState extends State<PuSearch> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<MenuModel> _allMenus = [];
  bool _isLoading = true;
  String _searchQuery = '';
  List<String> _recentSearches = [
    'Gelato Matcha',
    'Risol Mayo',
    'Ricebowl Chicken Blackpaper',
  ];

  int get _keranjangCount => widget.keranjang.fold(0, (sum, item) => sum + item.qty);

  List<MenuModel> get _filteredMenus {
    if (_searchQuery.isEmpty) return [];
    return _allMenus
        .where((m) => m.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<MenuModel> get _trendingMenus {
    final list = List<MenuModel>.from(_allMenus);
    list.shuffle();
    return list.take(6).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMenu();
      setState(() {
        _allMenus = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR SEARCH: $e");
      setState(() => _isLoading = false);
    }
  }

  String _buildImageUrl(String foto) {
    if (foto.isEmpty) return '';
    if (foto.startsWith('http')) return foto;
    return "${ApiService.baseUrl}/menu/uploads/$foto";
  }

  void _submitSearch(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _recentSearches.remove(trimmed);
      _recentSearches.insert(0, trimmed);
      if (_recentSearches.length > 5) _recentSearches = _recentSearches.take(5).toList();
      _searchQuery = trimmed;
    });
    _searchFocus.unfocus();
  }

  void _tapRecent(String text) {
    _searchController.text = text;
    setState(() => _searchQuery = text);
    _searchFocus.unfocus();
  }

  void _hapusRecent(int index) {
    setState(() => _recentSearches.removeAt(index));
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
    _searchFocus.requestFocus();
  }

  void _addToCart(MenuModel item) {
    if (!item.tersedia) return;
    HapticFeedback.lightImpact();
    widget.onTambahKeranjang(
      int.tryParse(item.id) ?? 0,
      item.nama,
      item.harga,
      item.foto,
    );
    setState(() {});
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
                  style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  void _bukaKeranjang() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PuDetailKeranjang(
          items: List.from(widget.keranjang),
          userId: 0,
          namaPelanggan: 'User',
        ),
      ),
    ).then((_) => setState(() {}));
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
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                        ),
                      )
                    : _buildContent(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ─── Search Bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 14, offset: const Offset(0, 6)),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      style: GoogleFonts.openSans(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Cari Makanan, Minuman...',
                        hintStyle: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.45), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 17),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                      onSubmitted: _submitSearch,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 18, color: AppColors.danger),
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

  // ─── Content Switcher ──────────────────────────────────────────────────────
  Widget _buildContent() {
    if (_searchQuery.isNotEmpty) {
      return _buildHasilPencarian();
    }
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildRecentSection(),
          const SizedBox(height: 28),
        ] else
          const SizedBox(height: 16),
        _buildTrendingSection(),
        const SizedBox(height: 90),
      ],
    );
  }

  // ─── Recent Searches ────────────────────────────────────────────────────────
  Widget _buildRecentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pencarian terakhir', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.w700)),
            GestureDetector(
              onTap: () => setState(() => _recentSearches.clear()),
              child: Text('Hapus semua', style: GoogleFonts.openSans(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._recentSearches.asMap().entries.map((e) => Dismissible(
          key: ValueKey('recent_${e.value}'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _hapusRecent(e.key),
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque, // ✅ FIX: Mencegah konflik gesture
            onTap: () => _tapRecent(e.value),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.12), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, size: 20, color: AppColors.primary.withOpacity(0.6)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(e.value,
                        style: GoogleFonts.openSans(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis),
                  ),
                  GestureDetector(
                    onTap: () => _hapusRecent(e.key),
                    child: Icon(Icons.close_rounded, size: 18, color: AppColors.textDark.withOpacity(0.3)),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  // ─── Trending Section ───────────────────────────────────────────────────────
  Widget _buildTrendingSection() {
    final menus = _trendingMenus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sedang Trending 🔥', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75, 
          ),
          itemCount: menus.length,
          itemBuilder: (_, i) => _buildMenuCard(menus[i], i),
        ),
      ],
    );
  }

  // ─── Search Results ────────────────────────────────────────────────────────
  Widget _buildHasilPencarian() {
    final results = _filteredMenus;
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1.5),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Icon(Icons.search_off_rounded, size: 52, color: AppColors.primary.withOpacity(0.35)),
            ),
            const SizedBox(height: 24),
            Text('Tidak ditemukan', style: GoogleFonts.poppins(color: AppColors.textDark.withOpacity(0.5), fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Coba kata kunci lain', style: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.35), fontSize: 14)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: results.length,
      itemBuilder: (_, i) => _buildMenuCard(results[i], i),
    );
  }

  // ─── Menu Card (Selarus dengan _MenuCard/_DrinkCard di beranda) ────────────
  Widget _buildMenuCard(MenuModel item, int index) {
    final imageUrl = _buildImageUrl(item.foto);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: Duration(milliseconds: 200 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cardColor,
                        child: Center(child: Icon(Icons.broken_image_outlined, color: AppColors.primary.withOpacity(0.3), size: 40)),
                      ))
                  : Container(
                      color: AppColors.cardColor,
                      child: const Center(child: Icon(Icons.fastfood_rounded, color: AppColors.primary, size: 40))),
              
              Positioned(
                bottom: 0, left: 0, right: 0,
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
                          shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'IDR ${item.harga}',
                        style: GoogleFonts.openSans(color: Colors.white.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 7, height: 7,
                                decoration: BoxDecoration(
                                  color: item.tersedia ? Colors.greenAccent : Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                item.tersedia ? 'Tersedia' : 'Habis',
                                style: GoogleFonts.openSans(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => _addToCart(item),
                            child: Container(
                              width: 30, height: 30,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3)),
                                ],
                              ),
                              child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
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

  // ─── Bottom Navigation Bar (Selarus Kasir/Beranda) ────────────────────────
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
        border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.15), width: 1)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, -6)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home_rounded, 'Home', 0),
          _navItem(Icons.search_rounded, 'Cari', 1, isActive: true),
          _navItemBadge(),
          _navItem(Icons.person_rounded, 'Profil', 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, {bool isActive = false}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (index == 0 || index == 3) Navigator.pop(context);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58, height: 58,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: isActive ? 50 : 38,
              height: isActive ? 50 : 38,
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : null,
                color: isActive ? null : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))]
                    : [],
              ),
              child: Icon(icon, size: 24, color: isActive ? Colors.white : AppColors.primary.withOpacity(0.35)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItemBadge() {
    return GestureDetector(
      onTap: _bukaKeranjang,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 58, height: 58,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.shopping_bag_rounded, size: 24, color: AppColors.primary.withOpacity(0.35)),
            if (_keranjangCount > 0)
              Positioned(
                top: 4, right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Text('$_keranjangCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}