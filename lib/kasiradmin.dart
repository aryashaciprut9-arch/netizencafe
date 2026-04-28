import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/menu_models.dart';
import '../services/api_services.dart';

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  List<MenuModel> _daftarMenu = [];
  bool _isLoading = true;
  String _selectedKategori = 'Makanan';
  final List<String> _kategoriList = ['Makanan', 'Minuman', 'Snack'];

  @override
  void initState() {
    super.initState();
    _ambilDataDariDatabase();
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
      debugPrint("Error ambil data: $e");
    }
  }

  List<MenuModel> get _filteredMenus {
    return _daftarMenu.where((m) => m.kategori == _selectedKategori).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryFilter(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF8A4607)))
                  : _buildMenuGrid(),
            ),
            _buildCartSection(),
          ],
        ),
      ),
    );
  }

  // 1. Header Profil (Sesuai Figma)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            backgroundImage: const AssetImage('assets/nettyzencafe.png'), // Ganti sesuai path logo kamu
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Selamat datang,", style: TextStyle(fontSize: 14, color: Colors.black54)),
              Text("Di Kasir", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.person_outline, size: 30),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  // 2. Filter Kategori Bulat (Sesuai Figma)
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: _kategoriList.length,
        itemBuilder: (ctx, i) {
          final k = _kategoriList[i];
          final active = k == _selectedKategori;
          return GestureDetector(
            onTap: () => setState(() => _selectedKategori = k),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF8A4607) : Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(k, 
                  style: TextStyle(
                    color: active ? Colors.white : Colors.black87, 
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 3. Grid Menu (Sesuai Figma)
  Widget _buildMenuGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: kIsWeb ? 4 : 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredMenus.length,
      itemBuilder: (ctx, i) {
        final menu = _filteredMenus[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: menu.foto.isNotEmpty
                      ? Image.network("${ApiService.baseUrl}/menu/uploads/${menu.foto}", width: double.infinity, fit: BoxFit.cover)
                      : Container(color: Colors.grey[100], child: const Icon(Icons.fastfood, color: Colors.grey)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(menu.nama, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13), maxLines: 1),
                    Text("IDR ${menu.harga}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Tersedia", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        GestureDetector(
                          onTap: () { /* Logika tambah ke keranjang */ },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Color(0xFF8A4607), shape: BoxShape.circle),
                            child: const Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // 4. Bagian Keranjang Bawah (Sesuai Figma)
  Widget _buildCartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Item di keranjang (Contoh statis sesuai UI Figma)
          _buildCartItem("Chicken Teriyaki", 20000, 2),
          const Divider(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A4607))),
              Text("Rp 55.000", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A4607))),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A4607),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: () {},
              child: const Text("Proses & Cetak", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCartItem(String nama, int harga, int qty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(width: 50, height: 50, color: Colors.grey[300], child: const Icon(Icons.image)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text("IDR $harga", style: const TextStyle(color: Colors.orange, fontSize: 11)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(5)),
            child: Row(
              children: [
                const Icon(Icons.remove, size: 16),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text("$qty")),
                const Icon(Icons.add, size: 16),
              ],
            ),
          )
        ],
      ),
    );
  }
}