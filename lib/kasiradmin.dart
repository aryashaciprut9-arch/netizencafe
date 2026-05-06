import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/menu_models.dart';
import '../services/api_services.dart';
import 'kelolamenuadmin.dart';
import 'kelolapesanan.dart';
import 'admin_dashboard.dart';

// ==================== WARNA ====================
class _C {
  static const bg = Color(0xFFFFF8F0);
  static const primary = Color(0xFF8A4607);
  static const primaryDark = Color(0xFF5C2E00);
  static const accent = Color(0xFFF5CC9E);
  static const accentSoft = Color(0xFFFAEBD7);
  static const border = Color(0xFFDCC8AE);
  static const textDark = Color(0xFF3D1F00);
  static const textMuted = Color(0xFFB08A60);
  static const surface = Color(0xFFFFFFFF);
  static const danger = Color(0xFFC62828);
}

// ==================== MODEL KERANJANG KASIR ====================
class _CartItem {
  final MenuModel menu;
  int qty;
  _CartItem({required this.menu, this.qty = 1});
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
      if (mounted) setState(() { _daftarMenu = data; _isLoading = false; });
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
        const SnackBar(content: Text('Masukkan nama pelanggan dulu!')),
      );
      return;
    }
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang masih kosong!')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isProses = false);
    }
  }

  void _showBerhasilDialog(String kodeInvoice) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 60),
            const SizedBox(height: 12),
            const Text('Pesanan Berhasil!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _C.textDark)),
            const SizedBox(height: 8),
            Text(kodeInvoice,
                style: const TextStyle(fontSize: 14, color: _C.textMuted)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: _C.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryFilter(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _C.primary))
                  : _buildMenuGrid(),
            ),
            _buildCartSection(),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: _C.surface,
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: _C.accentSoft,
            backgroundImage: const AssetImage('assets/nettyzencafe.png'),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Selamat datang,",
                  style: TextStyle(fontSize: 13, color: _C.textMuted)),
              Text("Di Kasir",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _C.textDark)),
            ],
          ),
          const Spacer(),
          // Tombol Kelola Menu
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KelolaManuAdmin()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _C.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant_menu_rounded, size: 24, color: _C.primary),
            ),
          ),
          const SizedBox(width: 8),
          // Tombol Kelola Pesanan
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KelolaPesananPage()),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _C.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long_rounded, size: 24, color: _C.primary),
            ),
          ),
            const SizedBox(width: 8),

// 🔥 Tombol Dashboard Admin
          GestureDetector(
            onTap: () => Navigator.push(
              context,
               MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
            ),
             child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _C.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
               child: const Icon(Icons.dashboard_rounded, size: 24, color: _C.primary),
             ),
         ),
        ],
      ),
    );
  }

  // ==================== FILTER KATEGORI ====================
  Widget _buildCategoryFilter() {
    return Container(
      color: _C.surface,
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 14),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _kategoriList.length,
          itemBuilder: (ctx, i) {
            final k = _kategoriList[i];
            final active = k == _selectedKategori;
            return GestureDetector(
              onTap: () => setState(() => _selectedKategori = k),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: active ? _C.primary : _C.accentSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(k,
                      style: TextStyle(
                        color: active ? Colors.white : _C.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      )),
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
      return const Center(child: Text('Tidak ada menu', style: TextStyle(color: _C.textMuted)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: kIsWeb ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: _filteredMenus.length,
      itemBuilder: (ctx, i) {
        final menu = _filteredMenus[i];
        final qtyDiKeranjang = _cart
            .where((c) => c.menu.id == menu.id)
            .fold(0, (sum, c) => sum + c.qty);
        return _buildMenuCard(menu, qtyDiKeranjang);
      },
    );
  }

  Widget _buildMenuCard(MenuModel menu, int qty) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: qty > 0 ? _C.primary.withOpacity(0.4) : _C.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: menu.foto.isNotEmpty
                  ? Image.network(
                      "${ApiService.baseUrl}/menu/uploads/${menu.foto}",
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _C.accentSoft,
                        child: const Icon(Icons.fastfood, color: _C.accent),
                      ),
                    )
                  : Container(color: _C.accentSoft, child: const Icon(Icons.fastfood, color: _C.accent)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(menu.nama,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: _C.textDark, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(_formatRupiah(menu.harga),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: _C.primary)),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tersedia", style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                    GestureDetector(
                      onTap: () => _tambahKeKeranjang(menu),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: _C.primary, shape: BoxShape.circle),
                        child: qty > 0
                            ? Text('$qty',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))
                            : const Icon(Icons.add, color: Colors.white, size: 16),
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
        color: _C.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: TextField(
              controller: _namaController,
              style: const TextStyle(color: _C.textDark, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Nama pelanggan...',
                hintStyle: const TextStyle(color: _C.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.person_outline, color: _C.primary, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: _C.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _C.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _C.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _C.primary, width: 1.5),
                ),
              ),
            ),
          ),
          if (_cart.isNotEmpty) ...[
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 160),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _cart.length,
                itemBuilder: (ctx, i) => _buildCartItem(i),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              children: [
                if (_cart.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal ($_totalItem item)',
                          style: const TextStyle(color: _C.textMuted, fontSize: 13)),
                      Text(_formatRupiah(_totalHarga),
                          style: const TextStyle(color: _C.textMuted, fontSize: 13)),
                    ],
                  ),
                  const Divider(height: 16, color: Color(0xFFE8D5C0)),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Pembayaran',
                        style: TextStyle(fontWeight: FontWeight.bold, color: _C.primary, fontSize: 14)),
                    Text(_formatRupiah(_totalHarga),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: _C.primary, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.payments_rounded, size: 16, color: _C.textMuted),
                    const SizedBox(width: 6),
                    const Text('Metode: ', style: TextStyle(color: _C.textMuted, fontSize: 12)),
                    _metodePill('Tunai'),
                    const SizedBox(width: 8),
                    _metodePill('Transfer'),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                onPressed: _isProses ? null : _prosesOrder,
                child: _isProses
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Proses & Cetak',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.menu.foto.isNotEmpty
                ? Image.network(
                    "${ApiService.baseUrl}/menu/uploads/${item.menu.foto}",
                    width: 44, height: 44, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 44, height: 44, color: _C.accentSoft),
                  )
                : Container(width: 44, height: 44, color: _C.accentSoft),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.menu.nama,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: _C.textDark),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(_formatRupiah(item.subtotal),
                    style: const TextStyle(color: _C.primary, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: _C.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => _updateQty(index, -1),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.remove, size: 14, color: _C.primary),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('${item.qty}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _C.textDark)),
                ),
                GestureDetector(
                  onTap: () => _updateQty(index, 1),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.add, size: 14, color: _C.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _cart.removeAt(index)),
            child: const Icon(Icons.delete_outline_rounded, size: 18, color: _C.danger),
          ),
        ],
      ),
    );
  }

  Widget _metodePill(String label) {
    final selected = _metodePembayaran == label;
    return GestureDetector(
      onTap: () => setState(() => _metodePembayaran = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? _C.primary : _C.accentSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? Colors.white : _C.primary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            )),
      ),
    );
  }
}