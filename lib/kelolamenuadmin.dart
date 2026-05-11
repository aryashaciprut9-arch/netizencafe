import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'models/menu_models.dart';
import 'services/api_services.dart';

// ─── Constants (selaras dengan beranda, minuman, makanan, snack, keranjang) ──
class AppColors {
  static const Color primary        = Color(0xFFB86B2B);
  static const Color accent         = Color(0xFF8D5524);
  static const Color textDark       = Color(0xFF6D4C41);
  static const Color cardColor      = Color(0xFFFFFBF5);
  static const Color primaryLight   = Color(0xFFF5CC9E);
  static const Color primaryLighter = Color(0xFFFFF8F2);
  static const Color white          = Colors.white;
  static const Color success        = Color(0xFF2E7D32);
  static const Color danger         = Color(0xFFC62828);

  static const List<Color> bgGradient = [
    Color(0xFFFFF8F2),
    Color(0xFFFDE8D7),
    Color(0xFFE8CBB0),
    Color(0xFFD4A57A),
  ];
}

class KelolaManuAdmin extends StatefulWidget {
  const KelolaManuAdmin({super.key});

  @override
  State<KelolaManuAdmin> createState() => _KelolaManuAdminState();
}

class _KelolaManuAdminState extends State<KelolaManuAdmin> {
  // --- VARIABEL & LOGIKA ---
  List<MenuModel> _menus = [];
  bool _isLoading = true;
  String _selectedKategori = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final List<String> _kategoriList = ['Semua', 'Makanan', 'Minuman', 'Snack'];
  XFile? _pickedXFile;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMenu();
      setState(() {
        _menus = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error Load: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(StateSetter setModalState) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setModalState(() {
        _pickedXFile = pickedFile;
        _webImage = bytes;
      });
    }
  }

  List<MenuModel> get _filteredMenus {
    return _menus.where((m) {
      final matchKat = _selectedKategori == 'Semua' || m.kategori == _selectedKategori;
      final matchSearch = m.nama.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchKat && matchSearch;
    }).toList();
  }

  // --- UI: FORM MODAL (DIPERCANTIK SESUAI THEME) ---
  void _showForm({MenuModel? menu}) {
    final isEdit = menu != null;
    final namaCtrl = TextEditingController(text: menu?.nama ?? '');
    final hargaCtrl = TextEditingController(text: menu?.harga.toString() ?? '');
    final descCtrl = TextEditingController(text: menu?.deskripsi ?? '');
    String kategori = menu?.kategori ?? 'Makanan';
    String tampil = menu?.tampil ?? 'Normal';

    _pickedXFile = null;
    _webImage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, AppColors.cardColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(color: AppColors.primary, blurRadius: 20, offset: Offset(0, -8)),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle drag
                Center(
                  child: Container(
                    width: 42, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isEdit ? 'Edit Menu' : 'Tambah Menu Baru',
                  style: GoogleFonts.poppins(
                    color: AppColors.accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 22),

                _buildLabel('Foto Menu'),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _pickImage(setModalState),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.white, AppColors.primaryLighter]),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                    ),
                    child: _webImage != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.memory(_webImage!, fit: BoxFit.cover))
                        : (isEdit && menu.foto.isNotEmpty)
                            ? ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.network("${ApiService.baseUrl}/menu/uploads/${menu.foto}", fit: BoxFit.cover))
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.primary.withOpacity(0.4)),
                                  const SizedBox(height: 8),
                                  Text('Pilih Foto', style: GoogleFonts.openSans(color: AppColors.primary.withOpacity(0.5), fontSize: 13)),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 22),

                _buildLabel('Nama Menu'),
                const SizedBox(height: 8),
                _buildInput(namaCtrl, 'Masukkan nama menu...'),
                const SizedBox(height: 18),

                _buildLabel('Kategori'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ['Makanan', 'Minuman', 'Snack'].map((k) {
                    final isActive = kategori == k;
                    return GestureDetector(
                      onTap: () => setModalState(() => kategori = k),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? const LinearGradient(colors: [AppColors.primary, AppColors.accent])
                              : const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isActive ? Colors.transparent : AppColors.primary.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: isActive
                              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                              : [],
                        ),
                        child: Text(
                          k,
                          style: GoogleFonts.poppins(
                            color: isActive ? Colors.white : AppColors.primary,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                _buildLabel('Harga'),
                const SizedBox(height: 8),
                _buildInput(hargaCtrl, 'Contoh: 15000', isNumber: true),
                const SizedBox(height: 18),

                _buildLabel('Deskripsi'),
                const SizedBox(height: 8),
                _buildInput(descCtrl, 'Masukkan deskripsi singkat...', maxLines: 3),
                const SizedBox(height: 30),

                // Tombol Simpan
                GestureDetector(
                  onTap: () async {
                    if (namaCtrl.text.isEmpty || hargaCtrl.text.isEmpty) return;
                    bool success;
                    if (isEdit) {
                      success = await ApiService.editMenu(
                        id: menu.id, nama: namaCtrl.text, kategori: kategori,
                        harga: int.parse(hargaCtrl.text), deskripsi: descCtrl.text,
                        tampil: tampil, fotoLama: menu.foto,
                        fotoBytes: _webImage, fotoFileName: _pickedXFile?.name,
                      );
                    } else {
                      success = await ApiService.tambahMenu(
                        nama: namaCtrl.text, kategori: kategori,
                        harga: int.parse(hargaCtrl.text), deskripsi: descCtrl.text,
                        tampil: tampil, fotoBytes: _webImage, fotoFileName: _pickedXFile?.name,
                      );
                    }
                    if (success) { Navigator.pop(ctx); _loadMenu(); }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                      borderRadius: BorderRadius.circular(29),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 12)),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isEdit ? 'Update Menu' : 'Simpan Menu',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(MenuModel menu) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_forever_rounded, color: AppColors.danger, size: 32),
              ),
              const SizedBox(height: 20),
              Text('Hapus Menu?', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text('Yakin ingin menghapus "${menu.nama}"?', textAlign: TextAlign.center, style: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.6), fontSize: 14)),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                        ),
                        child: Center(child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w700))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final ok = await ApiService.hapusMenu(menu.id);
                        if (ok) { Navigator.pop(ctx); _loadMenu(); }
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: AppColors.danger.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Center(child: Text('Hapus', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700))),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- UI UTAMA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Gradient Background
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
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  _buildSearchBar(),
                  _buildCategoryFilter(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 3,
                              backgroundColor: AppColors.primary.withOpacity(0.2),
                            ),
                          )
                        : _filteredMenus.isEmpty
                            ? _buildEmptyState()
                            : GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.78,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: _filteredMenus.length,
                                itemBuilder: (ctx, i) {
                                  final menu = _filteredMenus[i];
                                  return _buildGridCard(menu);
                                },
                              ),
                  ),
                ],
              ),
              // Custom FAB Positioning
              Positioned(
                bottom: 24,
                right: 24,
                child: _buildCustomFAB(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, AppColors.cardColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Manajemen Menu',
            style: GoogleFonts.poppins(
              color: AppColors.accent,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              shadows: [
                Shadow(color: Colors.black.withOpacity(0.08), offset: const Offset(0, 2), blurRadius: 4),
              ],
            ),
          ),
          const Spacer(),
          // Tombol Refresh — Style Card
          GestureDetector(
            onTap: _loadMenu,
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
              child: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // --- SEARCH BAR ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: GoogleFonts.openSans(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Cari menu favorit...',
            hintStyle: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.45), fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.primary, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
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

  // --- CATEGORY FILTER ---
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _kategoriList.length,
        itemBuilder: (ctx, i) {
          final k = _kategoriList[i];
          final isActive = k == _selectedKategori;
          return GestureDetector(
            onTap: () => setState(() => _selectedKategori = k),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(colors: [AppColors.primary, AppColors.accent])
                    : const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isActive ? Colors.transparent : AppColors.primary.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Center(
                child: Text(
                  k,
                  style: GoogleFonts.poppins(
                    color: isActive ? Colors.white : AppColors.primary,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- GRID CARD ---
  Widget _buildGridCard(MenuModel menu) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              child: menu.foto.isNotEmpty
                  ? Image.network(
                      "${ApiService.baseUrl}/menu/uploads/${menu.foto}",
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cardColor,
                        child: Center(child: Icon(Icons.broken_image_outlined, color: AppColors.primary.withOpacity(0.3), size: 40)),
                      ),
                    )
                  : Container(
                      color: AppColors.cardColor,
                      child: Center(child: Icon(Icons.fastfood_rounded, color: AppColors.primary.withOpacity(0.4), size: 40)),
                    ),
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 4),
            child: Text(
              menu.nama,
              style: GoogleFonts.poppins(
                color: AppColors.textDark,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              'Rp ${menu.harga}',
              style: GoogleFonts.openSans(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          // Aksi Tombol
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton(Icons.edit_outlined, AppColors.primary.withOpacity(0.1), AppColors.primary, () => _showForm(menu: menu)),
                const SizedBox(width: 8),
                _actionButton(Icons.delete_outline, AppColors.danger.withOpacity(0.1), AppColors.danger, () => _confirmDelete(menu)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmptyState() {
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
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Icon(Icons.inventory_2_outlined, size: 52, color: AppColors.primary.withOpacity(0.35)),
          ),
          const SizedBox(height: 24),
          Text(
            'Menu tidak ditemukan',
            style: GoogleFonts.poppins(
              color: AppColors.textDark.withOpacity(0.5),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau kata kunci',
            style: GoogleFonts.openSans(
              color: AppColors.textDark.withOpacity(0.35),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- CUSTOM FAB ---
  Widget _buildCustomFAB() {
    return GestureDetector(
      onTap: () => _showForm(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(29),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              'Tambah',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                shadows: const [
                  Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODAL HELPERS ---
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: AppColors.accent,
        fontWeight: FontWeight.w700,
        fontSize: 15,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: GoogleFonts.openSans(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.45), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}