import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/api_services.dart';
import 'models/menu_models.dart';
import 'detailkeranjang.dart';

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

  static const Color _primary = Color(0xFF8A4607);
  static const Color _primaryLight = Color(0xFFF5CC9E);
  static const Color _primaryLighter = Color(0xFFFFF4E6);
  static const Color _danger = Color(0xFFB50000);

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
      ..showSnackBar(SnackBar(
        content: Text('${item.nama} ditambahkan ke keranjang'),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _primary))
                  : _buildContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildSearchBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.046;

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 10, padding, 10),
      child: Row(
        children: [
          // Tombol back
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: _primary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Search field
          Expanded(
            child: Container(
              height: 42,
              decoration: ShapeDecoration(
                color: const Color(0xFFF8F8F8),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1.2, color: _primary),
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search, color: _primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      style: const TextStyle(color: _primary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Cari Makanan, Minuman...',
                        hintStyle: TextStyle(color: Color(0x998A4607), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                      onSubmitted: _submitSearch,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _clearSearch,
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: _danger.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 18, color: _danger),
                        ),
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

  Widget _buildContent() {
    if (_searchQuery.isNotEmpty) {
      return _buildHasilPencarian();
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildRecentSection(),
          const SizedBox(height: 28),
        ] else
          const SizedBox(height: 16),
        _buildTrendingSection(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildRecentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Pencarian terakhir',
                style: TextStyle(color: _primary, fontSize: 20, fontWeight: FontWeight.w700)),
            GestureDetector(
              onTap: () => setState(() => _recentSearches.clear()),
              child: const Text('Hapus semua',
                  style: TextStyle(color: _danger, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._recentSearches.asMap().entries.map((e) => Dismissible(
          key: ValueKey('recent_${e.value}'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _hapusRecent(e.key),
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(color: _danger, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 24),
          ),
          child: InkWell(
            onTap: () => _tapRecent(e.value),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded, size: 18, color: _danger),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(e.value,
                        style: const TextStyle(color: _primary, fontSize: 15),
                        overflow: TextOverflow.ellipsis),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF767070)),
                    onPressed: () => _hapusRecent(e.key),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildTrendingSection() {
    final menus = _trendingMenus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sedang Trending 🔥',
            style: TextStyle(color: _primary, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: menus.length,
          itemBuilder: (_, i) => _buildMenuCard(menus[i], i),
        ),
      ],
    );
  }

  Widget _buildHasilPencarian() {
    final results = _filteredMenus;
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 70, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Tidak ditemukan', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Coba kata kunci lain', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: results.length,
      itemBuilder: (_, i) => _buildMenuCard(results[i], i),
    );
  }

  Widget _buildMenuCard(MenuModel item, int index) {
    final imageUrl = _buildImageUrl(item.foto);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: Duration(milliseconds: 200 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        decoration: ShapeDecoration(
          color: _primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          shadows: const [BoxShadow(color: Color(0x3F000000), blurRadius: 6, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: imageUrl.isNotEmpty
                    ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF6B3605),
                          child: const Center(child: Icon(Icons.broken_image_rounded,
                              color: Colors.white38, size: 36)),
                        ),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFF6B3605),
                            child: Center(child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _primaryLight,
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                  : null,
                            )),
                          );
                        })
                    : Container(
                        color: const Color(0xFF6B3605),
                        child: const Center(child: Icon(Icons.fastfood,
                            color: Colors.white38, size: 36))),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 4, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.nama,
                        style: const TextStyle(color: Colors.white, fontSize: 11,
                            fontWeight: FontWeight.w600, height: 1.3),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('IDR ${item.harga}',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 11, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _primaryLight.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.tersedia ? 'Tersedia' : 'Habis',
                            style: const TextStyle(color: _primaryLight, fontSize: 8),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _addToCart(item),
                            child: Container(
                              width: 28, height: 28,
                              decoration: const ShapeDecoration(
                                  color: Colors.white, shape: OvalBorder()),
                              child: const Center(
                                child: Text('+',
                                    style: TextStyle(color: _primary, fontSize: 22,
                                        fontWeight: FontWeight.w800, height: 1)),
                              ),
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

  Widget _buildBottomNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      decoration: ShapeDecoration(
        color: _primaryLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        shadows: const [BoxShadow(color: Color(0x3F000000), blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home_outlined, Icons.home_rounded, 'Home', 0),
          _navItem(Icons.search_outlined, Icons.search_rounded, 'Cari', 1, isActive: true),
          _navItemBadge(),
          _navItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profil', 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData inactive, IconData active, String label, int index,
      {bool isActive = false}) {
    return GestureDetector(
      onTap: () {
        if (index == 0) Navigator.pop(context);
        if (index == 3) Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _primary.withOpacity(0.15) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? active : inactive, color: _primary, size: 22),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: _primary,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget _navItemBadge() {
    return GestureDetector(
      onTap: _bukaKeranjang,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_cart_outlined, color: _primary, size: 22),
                const SizedBox(height: 2),
                Text('Keranjang',
                    style: TextStyle(
                        color: _primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          if (_keranjangCount > 0)
            Positioned(
              top: 0, right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text('$_keranjangCount',
                    style: const TextStyle(color: Colors.white, fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}