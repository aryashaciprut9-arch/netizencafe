import 'dart:convert';        // untuk mengubah data menjadi JSON dan sebaliknya
import 'package:flutter/material.dart';  // library utama Flutter
import 'package:http/http.dart' as http; // untuk melakukan request HTTP ke API
import 'package:google_fonts/google_fonts.dart'; // untuk menggunakan font Poppins & OpenSans

// ==================== GANTI DENGAN IP KAMU ====================
const String baseUrl = 'http://127.0.0.1/kasir_api'; // BASE URL API (ganti dengan IP server kamu)

// ==================== KELAS WARNA (konsisten dengan halaman lain) ====================
class AppColors {
  static const Color primary        = Color(0xFFB86B2B);   // warna utama orange
  static const Color accent         = Color(0xFF8D5524);   // warna aksen coklat
  static const Color textDark       = Color(0xFF6D4C41);   // warna teks gelap
  static const Color cardColor      = Color(0xFFFFFBF5);   // warna background card
  static const Color primaryLight   = Color(0xFFF5CC9E);   // orange terang
  static const Color primaryLighter = Color(0xFFFFF8F2);   // orange lebih terang
  static const Color white          = Colors.white;        // putih
  static const Color success        = Color(0xFF2E7D32);   // hijau untuk sukses
  static const Color danger         = Color(0xFFC62828);   // merah untuk error/hapus

  // gradien latar belakang (dari terang ke gelap)
  static const List<Color> bgGradient = [
    Color(0xFFFFF8F2),
    Color(0xFFFDE8D7),
    Color(0xFFE8CBB0),
    Color(0xFFD4A57A),
  ];
}

// ==================== MODEL ITEM KERANJANG ====================
// Fungsi kelas ini: menyimpan data satu item yang ada di keranjang belanja
class KeranjangItem {
  final int menuId;      // ID menu (dari database)
  final String namaMenu; // nama makanan/minuman
  final int harga;       // harga satuan
  int qty;               // jumlah beli (bisa diubah)
  final String foto;     // nama file foto

  KeranjangItem({
    required this.menuId,
    required this.namaMenu,
    required this.harga,
    required this.qty,
    required this.foto,
  });

  // fungsi getter: menghitung subtotal (harga x qty)
  int get subtotal => harga * qty;
}

// ==================== HALAMAN DETAIL KERANJANG ====================
// Fungsi kelas ini: menampilkan isi keranjang, mengedit qty, memilih pembayaran, dan memproses pesanan
class PuDetailKeranjang extends StatefulWidget {
  final List<KeranjangItem> items;           // daftar item di keranjang
  final int userId;                          // ID user yang login
  final String namaPelanggan;                // nama pelanggan
  final VoidCallback? onPesananBerhasil;     // callback saat pesanan sukses

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

class _PuDetailKeranjangState extends State<PuDetailKeranjang>
    with TickerProviderStateMixin {  // TickerProviderStateMixin untuk animasi
  late List<KeranjangItem> _items;           // list item (bisa berubah)
  String _metodePembayaran = 'Tunai';        // metode bayar (default Tunai)
  bool _isLoading = false;                   // status loading saat proses pesan

  // Animasi masuk (fade + slide)
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ==================== FUNGSI INIT STATE (dijalankan pertama kali) ====================
  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);  // copy item dari parameter

    // setup animasi fade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    // setup animasi slide dari bawah
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack));

    _fadeController.forward();  // jalankan animasi
  }

  @override
  void dispose() {
    _fadeController.dispose();  // bersihkan controller animasi
    super.dispose();
  }

  // ==================== FUNGSI GETTER ====================
  // fungsi: menghitung total subtotal semua item
  int get _subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);
  // fungsi: total akhir (belum ada diskon/pajak)
  int get _total => _subtotal;

  // ==================== FUNGSI EDIT QTY ====================
  // fungsi: mengubah jumlah item (delta = +1 atau -1)
  void _updateQty(int index, int delta) {
    setState(() {
      _items[index].qty += delta;
      if (_items[index].qty <= 0) {  // jika qty habis, hapus item
        _items.removeAt(index);
      }
    });
  }

  // fungsi: menghapus item dari keranjang
  void _hapusItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  // ==================== FUNGSI FORMAT RUPIAH ====================
  // fungsi: mengubah angka (int) menjadi format mata uang Rupiah (contoh: Rp 10.000)
  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  // ==================== FUNGSI PESAN SEKARANG (CORE) ====================
  // fungsi: mengirim data pesanan ke server via API
  Future<void> _pesanSekarang() async {
    // validasi: cek keranjang tidak boleh kosong
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Keranjang kosong!', style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);  // tampilkan loading

    try {
      // siapkan data yang akan dikirim ke API
      final body = {
        'nama_pelanggan': widget.namaPelanggan,
        'sumber': 'user',
        'user_id': widget.userId,
        'metode_pembayaran': _metodePembayaran,
        'total': _total,
        'items': _items.map((e) => {
          'menu_id': e.menuId,
          'nama_menu': e.namaMenu,
          'harga': e.harga,
          'qty': e.qty,
        }).toList(),
      };

      // kirim POST request ke API
      final response = await http.post(
        Uri.parse('$baseUrl/pesanan/buat_pesanan.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        // pesanan berhasil
        if (mounted) {
          widget.onPesananBerhasil?.call();  // panggil callback jika ada
          // pindah ke halaman sukses
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
      // tampilkan error jika gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text('Error: $e', style: GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w600))),
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
      if (mounted) setState(() => _isLoading = false);  // matikan loading
    }
  }

  // ==================== FUNGSI BUILD UI (utama) ====================
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
              _buildAppBar(),  // app bar dengan tombol back dan hapus semua
              Expanded(
                child: _items.isEmpty
                    ? _buildKeranjangKosong()  // tampilkan pesan kosong
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              const SizedBox(height: 20),
                              ..._items.asMap().entries.map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _buildFoodItem(e.key, e.value),
                              )),
                              const SizedBox(height: 14),
                              _buildRincianSection(),   // subtotal
                              const SizedBox(height: 16),
                              _buildTotalSection(),     // total pembayaran
                              const SizedBox(height: 16),
                              _buildPaymentMethod(),    // pilih metode bayar
                              const SizedBox(height: 28),
                              _buildOrderButton(),      // tombol pesan
                              const SizedBox(height: 32),
                            ],
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

  // ==================== FUNGSI APP BAR ====================
  // fungsi: membuat header dengan tombol back dan tombol hapus semua
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.white, AppColors.cardColor]),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),  // kembali ke halaman sebelumnya
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 14, offset: const Offset(0, 6))],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          Text('Detail Keranjang', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          const Spacer(),
          if (_items.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _items.clear()),  // hapus semua item
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.danger.withOpacity(0.25), width: 1.5),
                  boxShadow: [BoxShadow(color: AppColors.danger.withOpacity(0.1), blurRadius: 14, offset: const Offset(0, 6))],
                ),
                child: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== FUNGSI FOOD ITEM CARD ====================
  // fungsi: menampilkan satu item makanan/minuman di keranjang (gambar, nama, harga, qty stepper)
  Widget _buildFoodItem(int index, KeranjangItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              '$baseUrl/menu/uploads/${item.foto}',  // ambil gambar dari server
              width: 76,
              height: 76,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(  // jika gambar gagal, tampilkan icon default
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.cardColor, AppColors.primaryLighter]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
                ),
                child: Icon(Icons.restaurant_rounded, color: AppColors.primary.withOpacity(0.4), size: 28),
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
                      child: Text(item.namaMenu, style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    GestureDetector(
                      onTap: () => _hapusItem(index),  // hapus item per item
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.08), shape: BoxShape.circle),
                        child: Icon(Icons.close_rounded, size: 16, color: AppColors.danger.withOpacity(0.7)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text('@ ${_formatRupiah(item.harga)}', style: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: Row(
                        children: [
                          _stepperButton(Icons.remove_rounded, () => _updateQty(index, -1)),  // tombol kurang
                          Container(width: 36, alignment: Alignment.center, child: Text('${item.qty}', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w700))),
                          _stepperButton(Icons.add_rounded, () => _updateQty(index, 1)),      // tombol tambah
                        ],
                      ),
                    ),
                    Text(_formatRupiah(item.subtotal), style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // fungsi: tombol +/- untuk mengubah jumlah
  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 32, height: 32, alignment: Alignment.center, child: Icon(icon, size: 18, color: AppColors.primary)),
    );
  }

  // ==================== FUNGSI RINCIAN SECTION ====================
  // fungsi: menampilkan rincian subtotal dan biaya layanan
  Widget _buildRincianSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rincian', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
          const SizedBox(height: 18),
          _rincianRow('Subtotal (${_items.length} item)', _formatRupiah(_subtotal)),
          Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(color: AppColors.primary.withOpacity(0.1), height: 1, thickness: 1)),
          _rincianRow('Biaya Layanan', 'Rp -'),
        ],
      ),
    );
  }

  // fungsi: helper untuk membuat baris rincian (label + value)
  Widget _rincianRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.55), fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value, style: GoogleFonts.openSans(color: isDiscount ? AppColors.success : AppColors.textDark, fontSize: 14, fontWeight: isDiscount ? FontWeight.w700 : FontWeight.w600)),
      ],
    );
  }

  // ==================== FUNGSI TOTAL SECTION ====================
  // fungsi: menampilkan total pembayaran dengan background gradien
  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total Pembayaran', style: GoogleFonts.openSans(color: AppColors.primaryLight, fontSize: 15, fontWeight: FontWeight.w600)),
          Text(_formatRupiah(_total), style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, shadows: const [Shadow(color: Colors.black26, blurRadius: 6)])),
        ],
      ),
    );
  }

  // ==================== FUNGSI METODE PEMBAYARAN ====================
  // fungsi: menampilkan pilihan metode pembayaran (hanya Tunai untuk contoh)
  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Metode Pembayaran', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
          const SizedBox(height: 14),
          _paymentOption('Tunai', Icons.payments_rounded),
        ],
      ),
    );
  }

  // fungsi: satu opsi metode pembayaran (radio button styling custom)
  Widget _paymentOption(String label, IconData icon) {
    final bool isSelected = _metodePembayaran == label;
    return GestureDetector(
      onTap: () => setState(() => _metodePembayaran = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(colors: [Colors.white, Color(0xFFFFF5EB)]) : const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.15), width: isSelected ? 2.0 : 1.0),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 14, offset: const Offset(0, 4))] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.35), width: 2),
              ),
              child: isSelected ? AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.all(3),
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent])),
              ) : null,
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: isSelected ? [AppColors.primaryLight, AppColors.primaryLighter] : [AppColors.primaryLight.withOpacity(0.5), AppColors.primaryLighter.withOpacity(0.5)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: isSelected ? AppColors.accent : AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.poppins(color: isSelected ? AppColors.accent : AppColors.textDark, fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ==================== FUNGSI TOMBOL ORDER ====================
  // fungsi: tombol "Pesan Sekarang" dengan efek loading
  Widget _buildOrderButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _pesanSekarang,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(29),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 12))],
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(width: 26, height: 26, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3, backgroundColor: Colors.white.withOpacity(0.3)))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text('Pesan Sekarang', style: GoogleFonts.poppins(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.5, shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))])),
                  ],
                ),
        ),
      ),
    );
  }

  //  FUNGSI KERANJANG KOSONG 
  // fungsi: menampilkan pesan ketika keranjang tidak ada isinya
  Widget _buildKeranjangKosong() {
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
            child: Icon(Icons.shopping_cart_outlined, size: 52, color: AppColors.primary.withOpacity(0.35)),
          ),
          const SizedBox(height: 24),
          Text('Keranjang kosong', style: GoogleFonts.poppins(color: AppColors.textDark.withOpacity(0.5), fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Tambahkan menu terlebih dahulu', style: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.35), fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ==================== HALAMAN PESANAN BERHASIL ====================
// Fungsi kelas ini: menampilkan halaman sukses setelah pesanan berhasil dibuat
class PesananBerhasilPage extends StatefulWidget {
  final String kodeInvoice;  // kode invoice dari server
  final int total;            // total pembayaran

  const PesananBerhasilPage({super.key, required this.kodeInvoice, required this.total});

  @override
  State<PesananBerhasilPage> createState() => _PesananBerhasilPageState();
}

class _PesananBerhasilPageState extends State<PesananBerhasilPage>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;  // controller animasi scale (zoom)
  late Animation<double> _scaleAnimation;
  late AnimationController _fadeController;   // controller animasi fade
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // animasi ikon centang (zoom in dengan efek elastis)
    _scaleController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));
    // animasi fade untuk konten lainnya
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // fungsi: format rupiah (sama seperti di halaman keranjang)
  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.success.withOpacity(0.15), AppColors.success.withOpacity(0.05)]),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.success.withOpacity(0.2), width: 2),
                          boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.15), blurRadius: 25, offset: const Offset(0, 10))],
                        ),
                        child: const Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text('Pesanan Berhasil!', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    const SizedBox(height: 8),
                    Text('Pesananmu sedang diproses', style: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.55), fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 36),
                    // card info invoice
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.white, AppColors.cardColor]),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.primary.withOpacity(0.15), width: 1),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 18, offset: const Offset(0, 8))],
                      ),
                      child: Column(
                        children: [
                          _infoRow('Kode Invoice', widget.kodeInvoice),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Divider(color: AppColors.primary.withOpacity(0.1), height: 1, thickness: 1)),
                          _infoRow('Total', _formatRupiah(widget.total)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    GestureDetector(
                      onTap: () {
                        Navigator.popUntil(context, (route) => route.isFirst);  // kembali ke halaman pertama (beranda)
                      },
                      child: Container(
                        width: double.infinity,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(29),
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 12))],
                        ),
                        child: Center(
                          child: Text('Kembali ke Beranda', style: GoogleFonts.poppins(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.5, shadows: const [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))])),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // fungsi: helper baris info (label + value) pengulangan code agar saya gak perlu kode row text dll
  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.openSans(color: AppColors.textDark.withOpacity(0.55), fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value, style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}