import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../services/api_services.dart';

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

// ==================== MODEL ====================
class PesananModel {
  final String kodeInvoice;
  final String namaPelanggan;
  final String sumber;
  final String metodePembayaran;
  final int total;
  final String createdAt;

  PesananModel({
    required this.kodeInvoice,
    required this.namaPelanggan,
    required this.sumber,
    required this.metodePembayaran,
    required this.total,
    required this.createdAt,
  });

  factory PesananModel.fromJson(Map<String, dynamic> json) {
    return PesananModel(
      kodeInvoice: json['kode_invoice'] ?? '',
      namaPelanggan: json['nama_pelanggan'] ?? '',
      sumber: json['sumber'] ?? '',
      metodePembayaran: json['metode_pembayaran'] ?? 'Tunai',
      total: int.tryParse(json['total'].toString()) ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class DetailPesananItem {
  final String namaMenu;
  final int harga;
  final int qty;
  final int subtotal;

  DetailPesananItem({
    required this.namaMenu,
    required this.harga,
    required this.qty,
    required this.subtotal,
  });

  factory DetailPesananItem.fromJson(Map<String, dynamic> json) {
    return DetailPesananItem(
      namaMenu: json['nama_menu'] ?? '',
      harga: int.tryParse(json['harga'].toString()) ?? 0,
      qty: int.tryParse(json['qty'].toString()) ?? 0,
      subtotal: int.tryParse(json['subtotal'].toString()) ?? 0,
    );
  }
}

// ==================== HALAMAN KELOLA PESANAN ====================
class KelolaPesananPage extends StatefulWidget {
  const KelolaPesananPage({super.key});

  @override
  State<KelolaPesananPage> createState() => _KelolaPesananPageState();
}

class _KelolaPesananPageState extends State<KelolaPesananPage> {
  List<PesananModel> _semuaPesanan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _ambilPesanan();
  }

  Future<void> _ambilPesanan() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/pesanan/get_pesanan.php'),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        final list = (data['data'] as List)
            .map((e) => PesananModel.fromJson(e))
            .toList();
        setState(() {
          _semuaPesanan = list;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _formatWaktu(String createdAt) {
    if (createdAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt);
      return '${dt.hour.toString().padLeft(2, '0')}.${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return createdAt;
    }
  }

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
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                        ),
                      )
                    : _semuaPesanan.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            onRefresh: _ambilPesanan,
                            color: AppColors.primary,
                            backgroundColor: AppColors.white,
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              itemCount: _semuaPesanan.length,
                              itemBuilder: (ctx, i) =>
                                  _buildPesananCard(_semuaPesanan[i]),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- APP BAR ---
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.white, AppColors.cardColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tombol kembali — style card
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Kelola Pesanan',
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
          const Spacer(),
          // Tombol refresh — style card
          GestureDetector(
            onTap: _ambilPesanan,
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
              child: const Icon(Icons.refresh_rounded,
                  size: 20, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // --- PESANAN CARD ---
  Widget _buildPesananCard(PesananModel pesanan) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PaDetailPesananPage(kodeInvoice: pesanan.kodeInvoice),
        ),
      ).then((_) => _ambilPesanan()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.white, AppColors.cardColor],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: AppColors.primary.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris atas: Kode Invoice & Waktu
            Row(
              children: [
                Expanded(
                  child: Text(
                    pesanan.kodeInvoice,
                    style: GoogleFonts.poppins(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatWaktu(pesanan.createdAt),
                    style: GoogleFonts.openSans(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Nama Pelanggan
            Text(
              pesanan.namaPelanggan,
              style: GoogleFonts.poppins(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            // Total Harga
            Text(
              _formatRupiah(pesanan.total),
              style: GoogleFonts.openSans(
                color: AppColors.textDark.withOpacity(0.5),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            // Baris bawah: Sumber & Tombol Detail
            Row(
              children: [
                // Badge Sumber
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: pesanan.sumber == 'kasir'
                        ? const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent])
                        : const LinearGradient(
                            colors: [AppColors.white, AppColors.cardColor]),
                    borderRadius: BorderRadius.circular(20),
                    border: pesanan.sumber != 'kasir'
                        ? Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 1)
                        : null,
                    boxShadow: pesanan.sumber == 'kasir'
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    pesanan.sumber == 'kasir' ? 'Kasir' : 'User',
                    style: GoogleFonts.poppins(
                      color: pesanan.sumber == 'kasir'
                          ? Colors.white
                          : AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                // Tombol Detail
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Detail',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- EMPTY STATE ---
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, AppColors.cardColor],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.15), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.receipt_long_outlined,
                size: 52, color: AppColors.primary.withOpacity(0.35)),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada pesanan',
            style: GoogleFonts.poppins(
              color: AppColors.textDark.withOpacity(0.5),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pesanan baru akan muncul di sini',
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
}

// ==================== HALAMAN DETAIL PESANAN (ADMIN) ====================
class PaDetailPesananPage extends StatefulWidget {
  final String kodeInvoice;

  const PaDetailPesananPage({super.key, required this.kodeInvoice});

  @override
  State<PaDetailPesananPage> createState() => _PaDetailPesananPageState();
}

class _PaDetailPesananPageState extends State<PaDetailPesananPage> {
  PesananModel? _pesanan;
  List<DetailPesananItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _ambilDetail();
  }

  Future<void> _ambilDetail() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiService.baseUrl}/pesanan/get_detail_pesanan.php?kode_invoice=${widget.kodeInvoice}'),
      );
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        final d = data['data'];
        setState(() {
          _pesanan = PesananModel.fromJson(d);
          _items = (d['items'] as List)
              .map((e) => DetailPesananItem.fromJson(e))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

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
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 3,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                  ),
                )
              : _pesanan == null
                  ? Center(
                      child: Text(
                        'Data tidak ditemukan',
                        style: GoogleFonts.openSans(
                          color: AppColors.textDark.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        _buildAppBar(),
                        Expanded(
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            children: [
                              _buildInvoiceCard(),
                              const SizedBox(height: 16),
                              _buildInfoPelanggan(),
                              const SizedBox(height: 16),
                              _buildDetailItem(),
                              const SizedBox(height: 16),
                              _buildTotalCard(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  // --- APP BAR ---
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.white, AppColors.cardColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Detail Pesanan',
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
    );
  }

  // --- INVOICE CARD ---
  Widget _buildInvoiceCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_rounded,
                color: AppColors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kode Invoice',
                  style: GoogleFonts.openSans(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.kodeInvoice,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    shadows: const [
                      Shadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Badge Sumber
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _pesanan!.sumber == 'kasir' ? 'Kasir' : 'User',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- INFO PELANGGAN ---
  Widget _buildInfoPelanggan() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.white, AppColors.cardColor],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pelanggan',
            style: GoogleFonts.poppins(
              color: AppColors.accent,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryLight.withOpacity(0.4),
                      AppColors.primaryLighter.withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                _pesanan!.namaPelanggan,
                style: GoogleFonts.poppins(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- DETAIL ITEM ---
  Widget _buildDetailItem() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.white, AppColors.cardColor],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Item',
            style: GoogleFonts.poppins(
              color: AppColors.accent,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          ..._items.asMap().entries.map((e) {
            final item = e.value;
            final isLast = e.key == _items.length - 1;
            return Column(
              children: [
                Row(
                  children: [
                    // Badge Qty
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryLight.withOpacity(0.3),
                            AppColors.primaryLighter.withOpacity(0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${item.qty}x',
                        style: GoogleFonts.poppins(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Nama Menu
                    Expanded(
                      child: Text(
                        item.namaMenu,
                        style: GoogleFonts.openSans(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Subtotal
                    Text(
                      _formatRupiah(item.subtotal),
                      style: GoogleFonts.poppins(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      color: AppColors.primary.withOpacity(0.1),
                      height: 1,
                      thickness: 1,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // --- TOTAL CARD ---
  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.white, AppColors.cardColor],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Metode Pembayaran
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metode Pembayaran',
                style: GoogleFonts.openSans(
                  color: AppColors.textDark.withOpacity(0.55),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _pesanan!.metodePembayaran,
                style: GoogleFonts.openSans(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              color: AppColors.primary.withOpacity(0.1),
              height: 1,
              thickness: 1,
            ),
          ),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _formatRupiah(_pesanan!.total),
                style: GoogleFonts.poppins(
                  color: AppColors.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  shadows: const [
                    Shadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}