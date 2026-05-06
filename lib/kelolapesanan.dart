import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_services.dart';

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
  static const textLight = Color(0xFFD4B896);
  static const surface = Color(0xFFFFFFFF);
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
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _C.primary))
                  : _semuaPesanan.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: _ambilPesanan,
                          color: _C.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _semuaPesanan.length,
                            itemBuilder: (ctx, i) =>
                                _buildPesananCard(_semuaPesanan[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: _C.surface,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: _C.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: _C.primary),
            ),
          ),
          const SizedBox(width: 16),
          const Text('Kelola Pesanan',
              style: TextStyle(
                  color: _C.textDark, fontSize: 20, fontWeight: FontWeight.w700)),
          const Spacer(),
          GestureDetector(
            onTap: _ambilPesanan,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _C.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.refresh_rounded, size: 20, color: _C.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPesananCard(PesananModel pesanan) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaDetailPesananPage(kodeInvoice: pesanan.kodeInvoice),
        ),
      ).then((_) => _ambilPesanan()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(pesanan.kodeInvoice,
                      style: const TextStyle(
                          color: _C.primary, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
                Text(_formatWaktu(pesanan.createdAt),
                    style: const TextStyle(color: _C.textMuted, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            Text(pesanan.namaPelanggan,
                style: const TextStyle(
                    color: _C.textDark, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(_formatRupiah(pesanan.total),
                style: const TextStyle(color: _C.textMuted, fontSize: 13)),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pesanan.sumber == 'kasir' ? _C.accent : _C.accentSoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pesanan.sumber == 'kasir' ? 'Kasir' : 'User',
                    style: TextStyle(
                      color: pesanan.sumber == 'kasir' ? _C.primaryDark : _C.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _C.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Detail',
                      style: TextStyle(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 70, color: _C.textLight),
          const SizedBox(height: 12),
          const Text('Belum ada pesanan',
              style: TextStyle(color: _C.textMuted, fontSize: 15)),
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
      backgroundColor: _C.bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: _C.primary))
            : _pesanan == null
                ? const Center(child: Text('Data tidak ditemukan'))
                : Column(
                    children: [
                      _buildAppBar(),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _buildInvoiceCard(),
                            const SizedBox(height: 12),
                            _buildInfoPelanggan(),
                            const SizedBox(height: 12),
                            _buildDetailItem(),
                            const SizedBox(height: 12),
                            _buildTotalCard(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: _C.surface,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: _C.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: _C.primary),
            ),
          ),
          const SizedBox(width: 16),
          const Text('Detail Pesanan',
              style: TextStyle(
                  color: _C.textDark, fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_C.primaryDark, _C.primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: _C.accent, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kode Invoice',
                  style: TextStyle(color: _C.accent, fontSize: 12)),
              Text(widget.kodeInvoice,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _pesanan!.sumber == 'kasir' ? 'Kasir' : 'User',
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPelanggan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Pelanggan',
              style: TextStyle(
                  color: _C.textDark, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _C.accentSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_rounded, color: _C.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(_pesanan!.namaPelanggan,
                  style: const TextStyle(
                      color: _C.textDark, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detail Item',
              style: TextStyle(
                  color: _C.textDark, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ..._items.asMap().entries.map((e) {
            final item = e.value;
            final isLast = e.key == _items.length - 1;
            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: _C.accentSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('${item.qty}x',
                            style: const TextStyle(
                                color: _C.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item.namaMenu,
                          style: const TextStyle(
                              color: _C.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ),
                    Text(_formatRupiah(item.subtotal),
                        style: const TextStyle(
                            color: _C.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                if (!isLast)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Color(0xFFE8D5C0), height: 1),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Metode Pembayaran',
                  style: TextStyle(color: _C.textMuted, fontSize: 14)),
              Text(_pesanan!.metodePembayaran,
                  style: const TextStyle(
                      color: _C.textDark, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Color(0xFFE8D5C0), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      color: _C.textDark, fontSize: 15, fontWeight: FontWeight.w700)),
              Text(_formatRupiah(_pesanan!.total),
                  style: const TextStyle(
                      color: _C.primary, fontSize: 17, fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}