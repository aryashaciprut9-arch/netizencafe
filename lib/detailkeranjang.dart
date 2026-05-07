import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ==================== GANTI DENGAN IP KAMU ====================
const String baseUrl = 'http://192.168.1.x/kasir_api'; // ganti IP PC kamu!

// ==================== KONSISTENSI WARNA ====================
class AppColors {
  static const Color primaryDark = Color(0xFF5C2E00);
  static const Color primary = Color(0xFF8A4607);
  static const Color primaryMedium = Color(0xFFA85A1B);
  static const Color primaryLight = Color(0xFFC47A3A);
  static const Color accent = Color(0xFFF5CC9E);
  static const Color accentSoft = Color(0xFFFAEBD7);
  static const Color accentPale = Color(0xFFFFF8F0);
  static const Color textDark = Color(0xFF3D1F00);
  static const Color textMedium = Color(0xFF8A4607);
  static const Color textMuted = Color(0xFFB08A60);
  static const Color textLight = Color(0xFFD4B896);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE8D5C0);
  static const Color border = Color(0xFFDCC8AE);
  static const Color success = Color(0xFF2E7D32);
  static const Color danger = Color(0xFFC62828);
}

// ==================== MODEL ITEM KERANJANG ====================
class KeranjangItem {
  final int menuId;
  final String namaMenu;
  final int harga;
  int qty;
  final String foto;

  KeranjangItem({
    required this.menuId,
    required this.namaMenu,
    required this.harga,
    required this.qty,
    required this.foto,
  });

  int get subtotal => harga * qty;
}

// ==================== HALAMAN DETAIL KERANJANG ====================
class PuDetailKeranjang extends StatefulWidget {
  final List<KeranjangItem> items;
  final int userId;
  final String namaPelanggan;
  final VoidCallback? onPesananBerhasil;

  const PuDetailKeranjang({
    super.key,
    required this.items,
    required this.userId,
    required this.namaPelanggan,
    this.onPesananBerhasil,
  });

  @override
  State<PuDetailKeranjang> createState() => _PuDetailKeranjangState();
}

class _PuDetailKeranjangState extends State<PuDetailKeranjang> {
  late List<KeranjangItem> _items;
  String _metodePembayaran = 'Tunai';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  int get _subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);
  int get _total => _subtotal;

  void _updateQty(int index, int delta) {
    setState(() {
      _items[index].qty += delta;
      if (_items[index].qty <= 0) {
        _items.removeAt(index);
      }
    });
  }

  void _hapusItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _pesanSekarang() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang kosong!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final body = {
        'nama_pelanggan': widget.namaPelanggan,
        'sumber': 'user',
        'user_id': widget.userId,
        'metode_pembayaran': _metodePembayaran,
        'total': _total,
        'items': _items
            .map((e) => {
                  'menu_id': e.menuId,
                  'nama_menu': e.namaMenu,
                  'harga': e.harga,
                  'qty': e.qty,
                })
            .toList(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/pesanan/buat_pesanan.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        if (mounted) {
          widget.onPesananBerhasil?.call();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PesananBerhasilPage(
                kodeInvoice: data['kode_invoice'],
                total: _total,
              ),
            ),
          );
        }
      } else {
        throw Exception(data['message'] ?? 'Gagal membuat pesanan');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentPale,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _items.isEmpty
                  ? _buildKeranjangKosong()
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        const SizedBox(height: 20),
                        ..._items.asMap().entries.map(
                              (e) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildFoodItem(e.key, e.value),
                              ),
                            ),
                        const SizedBox(height: 12),
                        _buildRincianSection(),
                        const SizedBox(height: 16),
                        _buildTotalSection(),
                        const SizedBox(height: 16),
                        _buildPaymentMethod(),
                        const SizedBox(height: 24),
                        _buildOrderButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== APP BAR ====================
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Detail Keranjang',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (_items.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _items.clear()),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 20, color: AppColors.danger),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== FOOD ITEM CARD ====================
  Widget _buildFoodItem(int index, KeranjangItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              '$baseUrl/menu/uploads/${item.foto}',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.restaurant,
                    color: AppColors.primaryLight),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.namaMenu,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _hapusItem(index),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@ ${_formatRupiah(item.harga)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          _stepperButton(Icons.remove_rounded,
                              () => _updateQty(index, -1)),
                          Container(
                            width: 36,
                            alignment: Alignment.center,
                            child: Text(
                              '${item.qty}',
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _stepperButton(
                              Icons.add_rounded, () => _updateQty(index, 1)),
                        ],
                      ),
                    ),
                    Text(
                      _formatRupiah(item.subtotal),
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  // ==================== RINCIAN SECTION ====================
  Widget _buildRincianSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _rincianRow(
              'Subtotal (${_items.length} item)', _formatRupiah(_subtotal)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.divider, height: 1),
          ),
          _rincianRow('Biaya Layanan', 'Rp -'),
        ],
      ),
    );
  }

  Widget _rincianRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? AppColors.success : AppColors.textDark,
            fontSize: 14,
            fontWeight: isDiscount ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ==================== TOTAL SECTION ====================
  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(color: AppColors.accent, fontSize: 15),
          ),
          Text(
            _formatRupiah(_total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PAYMENT METHOD ====================
  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pembayaran',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          _paymentOption('Tunai', Icons.payments_rounded),
        ],
      ),
    );
  }

  Widget _paymentOption(String label, IconData icon) {
    final bool isSelected = _metodePembayaran == label;
    return GestureDetector(
      onTap: () => setState(() => _metodePembayaran = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPale : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AppColors.primaryDark),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ORDER BUTTON ====================
  Widget _buildOrderButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _pesanSekarang,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryMedium],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Pesan Sekarang',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ==================== KERANJANG KOSONG ====================
  Widget _buildKeranjangKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80, color: AppColors.textLight),
          const SizedBox(height: 16),
          const Text(
            'Keranjang kosong',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan menu terlebih dahulu',
            style: TextStyle(color: AppColors.textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ==================== HALAMAN PESANAN BERHASIL ====================
class PesananBerhasilPage extends StatelessWidget {
  final String kodeInvoice;
  final int total;

  const PesananBerhasilPage({
    super.key,
    required this.kodeInvoice,
    required this.total,
  });

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentPale,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded,
                      size: 60, color: AppColors.success),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pesanan Berhasil!',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pesananmu sedang diproses',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 32),
                // ✅ FIX: Container info invoice dikembalikan
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _infoRow('Kode Invoice', kodeInvoice),
                      const Divider(color: AppColors.divider, height: 24),
                      _infoRow('Total', _formatRupiah(total)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}