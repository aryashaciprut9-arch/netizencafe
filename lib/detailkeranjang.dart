import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cart_provider.dart';

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5EFE6),
        fontFamily: 'Inter',
      ),
      home: const Scaffold(
        body: SafeArea(child: PuDetailKeranjang()),
      ),
    );
  }
}

// ==================== KONSISTENSI WARNA ====================
class CartAppColors {
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
  static const Color surfaceAlt = Color(0xFFFBF6F0);
  static const Color divider = Color(0xFFE8D5C0);
  static const Color border = Color(0xFFDCC8AE);

  static const Color success = Color(0xFF2E7D32);
  static const Color danger = Color(0xFFC62828);
}

class PuDetailKeranjang extends StatefulWidget {
  const PuDetailKeranjang({super.key});

  @override
  State<PuDetailKeranjang> createState() => _PuDetailKeranjangState();
}

class _PuDetailKeranjangState extends State<PuDetailKeranjang> {
  // Ambil data dari CartProvider (singleton global)
  CartProvider get _cart => CartProvider();

  List<CartItemData> get cartItems => _cart.items.toList();

  // State untuk snackbar feedback
  void showCustomSnackbar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? CartAppColors.success : CartAppColors.danger,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Update quantity item
  void updateQuantity(String id, int newQuantity) {
    _cart.updateQuantity(id, newQuantity);
    setState(() {});
    if (newQuantity <= 0) {
      showCustomSnackbar('Item dihapus dari keranjang');
    }
  }

  // Hapus semua item
  void clearAllItems() {
    if (cartItems.isEmpty) return;
    _cart.clearAll();
    setState(() {});
    showCustomSnackbar('Semua item dihapus dari keranjang');
  }

  // Hitung subtotal
  int getSubtotal() => _cart.totalHarga;

  // Total pembayaran (tanpa diskon)
  int getTotalPayment() => _cart.totalHarga;

  // Fungsi pesan sekarang
  void placeOrder() {
    if (cartItems.isEmpty) {
      showCustomSnackbar('Keranjang kosong! Tambahkan item terlebih dahulu.', isSuccess: false);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Column(
          children: [
            Icon(Icons.check_circle_rounded, color: CartAppColors.success, size: 56),
            SizedBox(height: 12),
            Text('Konfirmasi Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Apakah Anda yakin ingin memesan ${cartItems.length} item dengan total ${formatRupiah(getTotalPayment())}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: CartAppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cart.clearAll();
              setState(() {});
              showCustomSnackbar('Pesanan berhasil dibuat! Terima kasih 🙏');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CartAppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Pesan Sekarang',style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String formatRupiah(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CartAppColors.accentPale,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: cartItems.isEmpty
                  ? _buildEmptyCart()
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        const SizedBox(height: 20),
                        ...cartItems.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildFoodItem(item),
                        )),
                        const SizedBox(height: 24),
                        _buildRincianSection(),
                        const SizedBox(height: 20),
                        _buildTotalSection(),
                        const SizedBox(height: 24),
                        _buildPaymentMethod(),
                        const SizedBox(height: 24),
                        _buildOrderButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EMPTY CART ====================
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: CartAppColors.textLight),
          const SizedBox(height: 16),
          Text(
            'Keranjang Kosong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: CartAppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Yuk tambahin pesanan kamu!',
            style: TextStyle(color: CartAppColors.textMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              showCustomSnackbar('Fitur akan segera hadir 🚀');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CartAppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Mulai Belanja',style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==================== APP BAR ====================
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: CartAppColors.surface,
        boxShadow: [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              showCustomSnackbar('Kembali ke halaman utama');
              Navigator.pop(context);
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: CartAppColors.accentSoft, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: CartAppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          const Text('Detail Pesanan', style: TextStyle(color: CartAppColors.textDark, fontSize: 20, fontWeight: FontWeight.w700)),
          const Spacer(),
          if (cartItems.isNotEmpty)
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Hapus Semua Item?'),
                    content: const Text('Item di keranjang akan dihapus permanen.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                      TextButton(onPressed: () { Navigator.pop(context); clearAllItems(); }, child: const Text('Hapus', style: TextStyle(color: CartAppColors.danger))),
                    ],
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: CartAppColors.accentSoft, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.delete_outline_rounded, size: 20, color: CartAppColors.danger),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== FOOD ITEM CARD ====================
  Widget _buildFoodItem(CartItemData item) {
    return Hero(
      tag: 'food_${item.id}',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CartAppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CartAppColors.border, width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(item.image, width: 72, height: 72, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(color: CartAppColors.accentSoft, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.restaurant, color: CartAppColors.primaryLight),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(color: CartAppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('@ ${formatRupiah(item.pricePerItem)}', style: const TextStyle(color: CartAppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: CartAppColors.accentSoft, borderRadius: BorderRadius.circular(10), border: Border.all(color: CartAppColors.border)),
                        child: Row(
                          children: [
                            _stepperButton(Icons.remove_rounded, () {
                              if (item.quantity > 1) updateQuantity(item.id, item.quantity - 1);
                              else updateQuantity(item.id, 0);
                            }),
                            Container(width: 36, alignment: Alignment.center,
                              child: Text('${item.quantity}', style: const TextStyle(color: CartAppColors.primaryDark, fontSize: 14, fontWeight: FontWeight.w700))),
                            _stepperButton(Icons.add_rounded, () => updateQuantity(item.id, item.quantity + 1)),
                          ],
                        ),
                      ),
                      Text(formatRupiah(item.pricePerItem * item.quantity), style: const TextStyle(color: CartAppColors.primaryDark, fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return Material(color: Colors.transparent, child: InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(width: 30, height: 30, alignment: Alignment.center, child: Icon(icon, size: 16, color: CartAppColors.primary)),
    ));
  }

  // ==================== RINCIAN SECTION ====================
  Widget _buildRincianSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: CartAppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: CartAppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Rincian', style: TextStyle(color: CartAppColors.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
              Text('INV/III/2026/001', style: TextStyle(color: CartAppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          _rincianRow('Subtotal (${cartItems.length} item)', formatRupiah(getSubtotal())),
          const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(color: CartAppColors.divider, height: 1)),
          _rincianRow('Biaya Layanan', 'Rp -'),
        ],
      ),
    );
  }

  Widget _rincianRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: CartAppColors.textMuted, fontSize: 14)),
        Text(value, style: const TextStyle(color: CartAppColors.textDark, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ==================== TOTAL SECTION ====================
  Widget _buildTotalSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [CartAppColors.primaryDark, CartAppColors.primary], begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: CartAppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Pembayaran', style: TextStyle(color: CartAppColors.accent, fontSize: 15, fontWeight: FontWeight.w500)),
          Text(formatRupiah(getTotalPayment()), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  // ==================== PAYMENT METHOD (Tunai Only) ====================
  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: CartAppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: CartAppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Metode Pembayaran', style: TextStyle(color: CartAppColors.textDark, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: CartAppColors.accentPale,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CartAppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: CartAppColors.primary, width: 2)),
                  child: Container(margin: const EdgeInsets.all(3), decoration: const BoxDecoration(shape: BoxShape.circle, color: CartAppColors.primary)),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: CartAppColors.accent, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.payments_rounded, size: 18, color: CartAppColors.primaryDark),
                ),
                const SizedBox(width: 10),
                const Text('Tunai', style: TextStyle(color: CartAppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ORDER BUTTON ====================
  Widget _buildOrderButton() {
    return GestureDetector(
      onTap: placeOrder,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [CartAppColors.primary, CartAppColors.primaryMedium], begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: CartAppColors.primary.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Pesan Sekarang', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // ==================== BOTTOM NAV ====================
  Widget _buildBottomNav() {
    return Container(
      height: 60,
      decoration: BoxDecoration(color: CartAppColors.primaryDark, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: CartAppColors.primaryDark.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.home_rounded, 'Home', false),
          _navItem(Icons.receipt_long_rounded, 'Pesanan', true),
          _navItem(Icons.favorite_border_rounded, 'Favorit', false),
          _navItem(Icons.person_outline_rounded, 'Akun', false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    final color = isActive ? CartAppColors.accent : CartAppColors.accent.withOpacity(0.45);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (label == 'Home') {
          Navigator.pop(context); // Kembali ke Beranda
        } else {
          showCustomSnackbar('Navigasi ke $label');
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
        ],
      ),
    );
  }
}