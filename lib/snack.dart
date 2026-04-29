import 'package:flutter/material.dart'; // Import library Flutter untuk membangun UI
import 'package:flutter/services.dart'; // Import untuk fitur getaran (HapticFeedback)
import 'services/api_services.dart';    // Import service untuk komunikasi dengan API/database
import 'models/menu_models.dart';       // Import model data menu

// ─── Constants ───────────────────────────────────────────────────────────────

// Kelas untuk menyimpan warna-warna yang dipakai di seluruh halaman
class _AppColors {
  static const Color primary        = Color(0xFF8A4607); // Warna coklat utama
  static const Color primaryLight   = Color(0xFFF5CC9E); // Coklat muda untuk navbar
  static const Color primaryLighter = Color(0xFFFFF4E6); // Krem sangat muda untuk background input
  static const Color white          = Colors.white;       // Putih murni
}

// ─── Halaman Snack ───────────────────────────────────────────────────────────

// Widget utama halaman Snack, bersifat StatefulWidget karena datanya bisa berubah
class MenuPage extends StatefulWidget {
  const MenuPage({super.key}); // Constructor dengan key untuk identifikasi widget

  @override
  State<MenuPage> createState() => _MenuPageState(); // Membuat state untuk widget ini
}

class _MenuPageState extends State<MenuPage> {
  // =====================
  //  STATE & DATA
  // =====================

  List<MenuModel> _snackItems   = []; // Menyimpan semua data snack dari database
  List<MenuModel> _filteredItems = []; // Menyimpan data snack setelah difilter pencarian
  bool _isLoading               = true; // Status loading saat mengambil data
  int _currentIndex             = 0;    // Index navbar yang sedang aktif
  String _searchQuery           = '';   // Teks pencarian yang sedang diketik user
  final TextEditingController _searchCtrl = TextEditingController(); // Controller untuk input pencarian

  // Fungsi menentukan jumlah kolom grid berdasarkan lebar layar (responsif)
  int _getCrossAxisCount(double width) {
    if (width < 500)  return 2; // HP kecil: 2 kolom
    if (width < 850)  return 3; // Tablet kecil: 3 kolom
    if (width < 1100) return 4; // Tablet besar: 4 kolom
    if (width < 1400) return 5; // Desktop kecil: 5 kolom
    return 6;                   // Desktop besar: 6 kolom
  }

  // =====================
  //  FUNGSI / LOGIKA
  // =====================

  @override
  void initState() {
    super.initState();
    _loadData();                           // Ambil data dari database saat halaman pertama dibuka
    _searchCtrl.addListener(_onSearch);   // Pantau perubahan teks di kolom pencarian
  }

  @override
  void dispose() {
    _searchCtrl.dispose(); // Hapus controller dari memori saat halaman ditutup
    super.dispose();
  }

  // Fungsi mengambil data menu dari database melalui API
  Future<void> _loadData() async {
    setState(() => _isLoading = true); // Tampilkan loading spinner
    try {
      final data = await ApiService.getMenu(); // Panggil API untuk ambil semua menu
      setState(() {
        // Filter hanya menu dengan kategori 'snack'
        _snackItems = data.where((m) {
          return m.kategori.toLowerCase().trim().contains('snack');
        }).toList();
        _filteredItems = _snackItems; // Awalnya tampilkan semua snack tanpa filter
        _isLoading = false;           // Sembunyikan loading spinner
      });
    } catch (e) {
      print("ERROR SNACK: $e");          // Tampilkan error di console untuk debugging
      setState(() => _isLoading = false); // Sembunyikan loading meski error
    }
  }

  // Fungsi yang dipanggil setiap kali user mengetik di kolom pencarian
  void _onSearch() {
    final query = _searchCtrl.text.toLowerCase(); // Ambil teks dan ubah ke huruf kecil
    setState(() {
      _searchQuery = query; // Simpan query untuk keperluan tampilan judul section
      // Filter daftar snack yang namanya mengandung kata pencarian
      _filteredItems = _snackItems.where((m) {
        return m.nama.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Fungsi saat user menekan tombol '+' pada kartu menu (tambah ke keranjang)
  void _addToCart(MenuModel item) {
    HapticFeedback.lightImpact(); // Getarkan HP sedikit sebagai feedback sentuhan
    // Tampilkan notifikasi kecil di bawah layar
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar() // Sembunyikan notifikasi sebelumnya jika masih muncul
      ..showSnackBar(
        SnackBar(
          content: Text('${item.nama} ditambahkan ke keranjang'),
          backgroundColor: _AppColors.primary,
          behavior: SnackBarBehavior.floating,   // Notifikasi mengambang di atas navbar
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 1),  // Muncul selama 1 detik
        ),
      );
  }

  // Fungsi untuk membentuk URL lengkap foto menu
  String _buildImageUrl(String foto) {
    if (foto.isEmpty) return '';             // Jika tidak ada foto, kembalikan string kosong
    if (foto.startsWith('http')) return foto; // Jika sudah URL lengkap, langsung pakai
    return "${ApiService.baseUrl}/menu/uploads/$foto"; // Gabungkan base URL dengan nama file foto
  }

  // Fungsi saat user menekan salah satu item navbar bawah
  void _onNavTap(int index) {
    setState(() => _currentIndex = index); // Update index navbar yang aktif
    HapticFeedback.selectionClick();       // Getarkan HP saat ganti tab
  }

  // =====================
  //  UI / BUILD
  // =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.white, // Background halaman putih
      body: SafeArea(
        // SafeArea memastikan konten tidak tertimpa notch atau status bar
        child: _isLoading
            // Jika masih loading, tampilkan spinner di tengah layar
            ? const Center(
                child: CircularProgressIndicator(color: _AppColors.primary))
            // Jika sudah selesai loading, tampilkan konten
            : LayoutBuilder(
                builder: (context, constraints) {
                  // CustomScrollView untuk menggabungkan berbagai jenis scroll widget
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader(context)),          // Header judul + panah
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),    // Jarak
                      SliverToBoxAdapter(child: _buildSearchBar(context)),       // Kolom pencarian
                      const SliverToBoxAdapter(child: SizedBox(height: 15)),    // Jarak
                      SliverToBoxAdapter(child: _buildSectionTitle(context)),    // Judul section + jumlah menu
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),    // Jarak
                      _buildSnackGrid(context, constraints.maxWidth),            // Grid kartu menu
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),    // Jarak bawah agar tidak ketutup navbar
                    ],
                  );
                },
              ),
      ),
      bottomNavigationBar: _buildBottomNavBar(), // Navbar bawah
    );
  }

  // Widget header: tombol panah kiri (kembali) + judul 'Snack' + tombol panah kanan
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Kiri dan kanan berjauhan
        children: [
          Row(
            children: [
              // Tombol kembali (panah kiri)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                },
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: _AppColors.primaryLighter, // Background krem muda
                    shape: BoxShape.circle,           // Bentuk lingkaran
                    border: Border.all(color: _AppColors.primary.withOpacity(0.1)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: _AppColors.primary, size: 16),
                ),
              ),
              const SizedBox(width: 15), // Jarak antara tombol dan judul
              // Judul halaman
              const Text(
                'Snack',
                style: TextStyle(
                  color: _AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          // Tombol panah kanan (navigasi ke halaman lain jika perlu)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              // Tambahkan navigasi ke halaman lain di sini jika diperlukan
            },
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: _AppColors.primaryLighter,
                shape: BoxShape.circle,
                border: Border.all(color: _AppColors.primary.withOpacity(0.1)),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  color: _AppColors.primary, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Widget kolom pencarian menu
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: _AppColors.primaryLighter,          // Background krem muda
          borderRadius: BorderRadius.circular(16),   // Sudut melengkung
          border: Border.all(color: _AppColors.primary.withOpacity(0.15)), // Border tipis
        ),
        child: TextField(
          controller: _searchCtrl,                                    // Hubungkan ke controller
          style: const TextStyle(color: _AppColors.primary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Cari snack...',                               // Teks placeholder
            hintStyle: TextStyle(color: _AppColors.primary.withOpacity(0.4), fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded,             // Icon kaca pembesar di kiri
                color: _AppColors.primary, size: 22),
            // Tampilkan tombol X hanya jika ada teks pencarian
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: _AppColors.primary, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();                           // Hapus teks
                      setState(() => _searchQuery = '');             // Reset query
                    },
                  )
                : null,
            border: InputBorder.none,                                // Hapus border default TextField
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  // Widget judul section dan jumlah menu yang ditampilkan
  Widget _buildSectionTitle(BuildContext context) {
    // Ganti judul jika sedang dalam mode pencarian
    final title = _searchQuery.isNotEmpty ? 'Hasil Pencarian' : 'Semua Snack';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Judul section
          Text(
            title,
            style: const TextStyle(
              color: _AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          // Jumlah menu yang tampil
          Text(
            '${_filteredItems.length} menu',
            style: TextStyle(
                color: _AppColors.primary.withOpacity(0.45), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Widget grid kartu-kartu menu snack
  Widget _buildSnackGrid(BuildContext context, double screenWidth) {
    final items = _filteredItems;                          // Data yang akan ditampilkan
    int crossAxisCount = _getCrossAxisCount(screenWidth); // Jumlah kolom sesuai lebar layar

    // Jika tidak ada menu (hasil pencarian kosong), tampilkan pesan
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded,
                    size: 52, color: _AppColors.primary.withOpacity(0.2)),
                const SizedBox(height: 10),
                Text('Menu tidak ditemukan',
                    style: TextStyle(
                        color: _AppColors.primary.withOpacity(0.4), fontSize: 15)),
              ],
            ),
          ),
        ),
      );
    }

    // Tampilkan grid kartu menu
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          // Buat kartu untuk setiap item menu
          (context, index) => _SnackCard(
            item: items[index],                          // Data menu
            imageUrl: _buildImageUrl(items[index].foto), // URL foto
            onAddToCart: () => _addToCart(items[index]), // Aksi tambah keranjang
          ),
          childCount: items.length, // Jumlah total kartu
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, // Jumlah kolom
          mainAxisSpacing: 14,            // Jarak antar baris
          crossAxisSpacing: 14,           // Jarak antar kolom
          childAspectRatio: 0.8,          // Rasio lebar:tinggi kartu
        ),
      ),
    );
  }

  // =====================
  //  NAVBAR BAWAH
  // =====================

  // Widget navbar bawah dengan 4 tombol
  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: _AppColors.primaryLight,                               // Background coklat muda
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // Sudut atas melengkung
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Tombol tersebar merata
        children: [
          _NavItem(icon: Icons.home_rounded,         index: 0, currentIndex: _currentIndex, onTap: _onNavTap), // Tombol Home
          _NavItem(icon: Icons.search_rounded,       index: 1, currentIndex: _currentIndex, onTap: _onNavTap), // Tombol Search
          _NavItem(icon: Icons.shopping_bag_rounded, index: 2, currentIndex: _currentIndex, onTap: _onNavTap), // Tombol Keranjang
          _NavItem(icon: Icons.person_rounded,       index: 3, currentIndex: _currentIndex, onTap: _onNavTap), // Tombol Profil
        ],
      ),
    );
  }
}

// ─── Snack Card Widget ────────────────────────────────────────────────────────

// Widget kartu menu snack (foto penuh + gradient + info di bawah)
class _SnackCard extends StatelessWidget {
  final MenuModel item;        // Data menu yang ditampilkan
  final String imageUrl;       // URL foto menu
  final VoidCallback onAddToCart; // Fungsi yang dipanggil saat tombol '+' ditekan

  const _SnackCard({
    required this.item,
    required this.imageUrl,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A4607).withOpacity(0.1), // Bayangan tipis di bawah kartu
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18), // Potong sudut gambar agar melengkung
        child: Stack(
          fit: StackFit.expand, // Stack memenuhi seluruh area kartu
          children: [

            // LAYER 1: Foto menu sebagai background penuh
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover, // Foto memenuhi area tanpa distorsi
                    errorBuilder: (context, error, stackTrace) => Container(
                      // Jika foto gagal dimuat, tampilkan icon pengganti
                      color: _AppColors.primaryLighter,
                      child: Center(
                        child: Icon(Icons.broken_image_rounded,
                            color: _AppColors.primary.withOpacity(0.3), size: 40),
                      ),
                    ),
                  )
                : Container(
                    // Jika tidak ada foto, tampilkan icon fastfood
                    color: _AppColors.primaryLighter,
                    child: const Center(
                      child: Icon(Icons.fastfood, color: _AppColors.primary, size: 40),
                    ),
                  ),

            // LAYER 2: Gradient putih dari bawah + informasi menu
            Positioned(
              bottom: 0, left: 0, right: 0, // Tempel di bagian bawah kartu
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0),    // Transparan di atas
                      Colors.white.withOpacity(0.85), // Setengah transparan di tengah
                      _AppColors.white,               // Putih penuh di bawah
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nama menu
                    Text(
                      item.nama,
                      style: const TextStyle(
                        color: _AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,                    // Maksimal 2 baris
                      overflow: TextOverflow.ellipsis, // Potong dengan '...' jika terlalu panjang
                    ),
                    const SizedBox(height: 2),
                    // Harga menu
                    Text(
                      'IDR ${item.harga}',
                      style: TextStyle(
                        color: _AppColors.primary.withOpacity(0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status ketersediaan menu (dot hijau/merah + teks)
                        Row(
                          children: [
                            Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                color: item.tersedia ? Colors.green : Colors.red, // Hijau = tersedia, merah = habis
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.tersedia ? 'Tersedia' : 'Habis',
                              style: TextStyle(
                                  color: _AppColors.primary.withOpacity(0.5), fontSize: 10),
                            ),
                          ],
                        ),
                        // Tombol tambah ke keranjang
                        GestureDetector(
                          onTap: onAddToCart, // Panggil fungsi tambah keranjang
                          child: Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(
                              color: _AppColors.primary,
                              shape: BoxShape.circle, // Tombol berbentuk lingkaran
                            ),
                            child: const Icon(Icons.add_rounded,
                                color: Colors.white, size: 18),
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
}

// ─── Nav Item Widget ─────────────────────────────────────────────────────────

// Widget satu tombol di navbar bawah
class _NavItem extends StatelessWidget {
  final IconData icon;         // Icon yang ditampilkan
  final int index;             // Index tombol ini
  final int currentIndex;      // Index tombol yang sedang aktif
  final int badgeCount;        // Jumlah badge (misal: jumlah item di keranjang)
  final ValueChanged<int> onTap; // Fungsi saat tombol ditekan

  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.badgeCount = 0, // Default 0 (tidak ada badge)
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index; // Cek apakah tombol ini yang aktif
    return GestureDetector(
      onTap: () => onTap(index),             // Panggil fungsi dengan index tombol ini
      behavior: HitTestBehavior.opaque,      // Area sentuh seluas widget
      child: SizedBox(
        width: 56, height: 56,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Lingkaran background + icon (animasi ukuran saat aktif/tidak)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200), // Durasi animasi
              width: isSelected ? 48 : 36,   // Lebih besar saat aktif
              height: isSelected ? 48 : 36,
              decoration: BoxDecoration(
                color: isSelected ? _AppColors.primary : Colors.transparent, // Background coklat saat aktif
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 24,
                  color: isSelected
                      ? Colors.white                          // Putih saat aktif
                      : _AppColors.primary.withOpacity(0.35)), // Abu-abu saat tidak aktif
            ),
            // Badge merah (muncul jika badgeCount > 0)
            if (badgeCount > 0)
              Positioned(
                top: 4, right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Text('$badgeCount',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}