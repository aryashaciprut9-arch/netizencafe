import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../models/menu_models.dart';
import '../services/api_services.dart';
import 'kelolamenuadmin.dart';
import 'kelolapesanan.dart';
import 'admin_dashboard.dart';

// ==================== WARNA (SELARAS GLOBAL) ====================
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

// ==================== MODEL KERANJANG KASIR ====================
class _CartItem {
  final MenuModel menu;
  int qty = 1; // ✅ Pindahkan default value ke sini
  _CartItem({required this.menu}); // ✅ Dibersihkan
  int get subtotal => menu.harga * qty;
}

// ==================== HALAMAN KASIR ====================
class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  List<MenuModel> _daftarMenu = [];
  bool _isLoading = true;
  bool _isProses = false;
  String _selectedKategori = 'Makanan';
  final List<String> _kategoriList = ['Makanan', 'Minuman', 'Snack'];
  final List<_CartItem> _cart = [];
  String _metodePembayaran = 'Tunai';
  final TextEditingController _namaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ambilDataDariDatabase();
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _ambilDataDariDatabase() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getMenu();
      if (mounted) {
        setState(() {
          _daftarMenu = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<MenuModel> get _filteredMenus =>
      _daftarMenu.where((m) => m.kategori == _selectedKategori).toList();

  int get _totalHarga => _cart.fold(0, (sum, item) => sum + item.subtotal);
  int get _totalItem => _cart.fold(0, (sum, item) => sum + item.qty);

  void _tambahKeKeranjang(MenuModel menu) {
    setState(() {
      final idx = _cart.indexWhere((c) => c.menu.id == menu.id);
      if (idx >= 0) {
        _cart[idx].qty++;
      } else {
        _cart.add(_CartItem(menu: menu));
      }
    });
  }

  void _updateQty(int index, int delta) {
    setState(() {
      _cart[index].qty += delta;
      if (_cart[index].qty <= 0) _cart.removeAt(index);
    });
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _prosesOrder() async {
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Masukkan nama pelanggan dulu!',
                  style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Keranjang masih kosong!',
                  style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isProses = true);

    try {
      final body = {
        'nama_pelanggan': _namaController.text.trim(),
        'sumber': 'kasir',
        'user_id': null,
        'metode_pembayaran': _metodePembayaran,
        'total': _totalHarga,
        'items': _cart.map((e) => {
          'menu_id': e.menu.id,
          'nama_menu': e.menu.nama,
          'harga': e.menu.harga,
          'qty': e.qty,
        }).toList(),
      };

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/pesanan/buat_pesanan.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        if (mounted) {
          setState(() {
            _cart.clear();
            _namaController.clear();
          });
          _showBerhasilDialog(data['kode_invoice']);
        }
      } else {
        throw Exception(data['message'] ?? 'Gagal memproses pesanan');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Error: $e',
                    style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProses = false);
    }
  }

  void _showBerhasilDialog(String kodeInvoice) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white, AppColors.cardColor],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 60),
              ),
              const SizedBox(height: 20),
              Text(
                'Pesanan Berhasil!',
                style: GoogleFonts.poppins(
                  color: AppColors.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  kodeInvoice,
                  style: GoogleFonts.openSans(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Center(
                      child: Text('OK', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              _buildHeader(),
              _buildCategoryFilter(),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                        ),
                      )
                    : _buildMenuGrid(),
              ),
              _buildCartSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [AppColors.primary.withOpacity(0.2), Colors.transparent]),
              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 3),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 25, offset: const Offset(0, 12)),
              ],
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              backgroundImage: const AssetImage('assets/nettyzencafe.png'),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Selamat datang,", style: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.55), fontSize: 13, fontWeight: FontWeight.w500)),
              Text("Di Kasir", style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ],
          ),
          const Spacer(),
          _headerActionButton(Icons.restaurant_menu_rounded, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const KelolaManuAdmin()));
          }),
          const SizedBox(width: 10),
          _headerActionButton(Icons.receipt_long_rounded, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const KelolaPesananPage()));
          }),
          const SizedBox(width: 10),
          _headerActionButton(Icons.dashboard_rounded, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
          }),
        ],
      ),
    );
  }

  Widget _headerActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }

  // ==================== FILTER KATEGORI ====================
  Widget _buildCategoryFilter() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
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
      ),
    );
  }

  // ==================== GRID MENU ====================
  Widget _buildMenuGrid() {
    if (_filteredMenus.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 52, color: AppColors.primary.withOpacity(0.2)),
            const SizedBox(height: 10),
            Text('Tidak ada menu', style: GoogleFonts.poppins(color: AppColors.textDark.withOpacity(0.4), fontSize: 14)),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemCount: _filteredMenus.length,
      itemBuilder: (ctx, i) {
        final menu = _filteredMenus[i];
        final qtyDiKeranjang = _cart.where((c) => c.menu.id == menu.id).fold(0, (sum, c) => sum + c.qty);
        return _buildMenuCard(menu, qtyDiKeranjang);
      },
    );
  }

  // ==================== CARD MENU ====================
  Widget _buildMenuCard(MenuModel menu, int qty) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: qty > 0 ? AppColors.primary : AppColors.primary.withOpacity(0.15),
          width: qty > 0 ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ PERBAIKAN: Expanded diganti AspectRatio agar gambar proporsional
          AspectRatio(
            aspectRatio: 1.1,
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
                      child: Center(child: Icon(Icons.fastfood_rounded, color: AppColors.primary.withOpacity(0.4), size: 40))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(menu.nama, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.textDark, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(_formatRupiah(menu.harga), style: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.accent)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tersedia", style: GoogleFonts.openSans(fontSize: 10, color: AppColors.textDark.withOpacity(0.4))),
                    GestureDetector(
                      onTap: () => _tambahKeKeranjang(menu),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                          shape: BoxShape.circle,
                          border: qty > 0 ? Border.all(color: AppColors.primary, width: 2) : null,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        child: qty > 0
                            ? Text('$qty', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700))
                            : const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CART SECTION ====================
  Widget _buildCartSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.15), width: 1)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, -6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 42,
            height: 4,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 5))],
              ),
              child: TextField(
                controller: _namaController,
                style: GoogleFonts.openSans(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Nama pelanggan...',
                  hintStyle: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.45), fontSize: 14),
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 17),
                ),
              ),
            ),
          ),
          if (_cart.isNotEmpty) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _cart.length,
                itemBuilder: (ctx, i) => _buildCartItem(i),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                if (_cart.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal ($_totalItem item)', style: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.55), fontSize: 13, fontWeight: FontWeight.w500)),
                      Text(_formatRupiah(_totalHarga), style: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.55), fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: AppColors.primary.withOpacity(0.1), height: 1, thickness: 1),
                  ),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Pembayaran', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.accent, fontSize: 15)),
                    Text(_formatRupiah(_totalHarga), style: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: AppColors.accent, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isProses ? null : _prosesOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(29),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 12)),
                    ],
                  ),
                  child: Center(
                    child: _isProses
                        ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3, backgroundColor: Colors.white24))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Proses',
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.5, shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = _cart[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.menu.foto.isNotEmpty
                ? Image.network(
                    "${ApiService.baseUrl}/menu/uploads/${item.menu.foto}",
                    width: 46, height: 46, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 46, height: 46,
                      color: AppColors.cardColor,
                      child: Icon(Icons.broken_image_outlined, color: AppColors.primary.withOpacity(0.3), size: 20),
                    ),
                  )
                : Container(
                    width: 46, height: 46,
                    color: AppColors.cardColor,
                    child: Icon(Icons.fastfood_rounded, color: AppColors.primary.withOpacity(0.4), size: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.menu.nama, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(_formatRupiah(item.subtotal), style: GoogleFonts.openSans(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _updateQty(index, -1),
                  child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.remove_rounded, size: 16, color: AppColors.primary)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('${item.qty}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.accent)),
                ),
                GestureDetector(
                  onTap: () => _updateQty(index, 1),
                  child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.add_rounded, size: 16, color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _cart.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }
}