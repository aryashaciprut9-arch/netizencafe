import 'package:flutter/material.dart';
import 'models/menu_models.dart';

// ─── Model item keranjang ─────────────────────────────────────────────────────

class CartItemData {
  final String id;
  final String name;
  final int pricePerItem;
  int quantity;
  final String image;

  CartItemData({
    required this.id,
    required this.name,
    required this.pricePerItem,
    required this.quantity,
    required this.image,
  });
}

// ─── Singleton CartProvider ───────────────────────────────────────────────────

class CartProvider extends ChangeNotifier {
  // Singleton instance
  static final CartProvider _instance = CartProvider._internal();
  factory CartProvider() => _instance;
  CartProvider._internal();

  final List<CartItemData> _items = [];

  List<CartItemData> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalHarga =>
      _items.fold(0, (sum, item) => sum + (item.pricePerItem * item.quantity));

  // Tambah item dari MenuModel
  void addFromMenu(MenuModel menu, {int quantity = 1, String imageUrl = ''}) {
    final index = _items.indexWhere((i) => i.id == menu.id.toString());
    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItemData(
        id: menu.id.toString(),
        name: menu.nama,
        pricePerItem: _parseHarga(menu.harga),
        quantity: quantity,
        image: imageUrl,
      ));
    }
    notifyListeners();
  }

  // Update quantity
  void updateQuantity(String id, int newQuantity) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  // Hapus semua
  void clearAll() {
    _items.clear();
    notifyListeners();
  }

  // Hapus satu item
  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  // Helper parse harga (bisa String atau int)
  int _parseHarga(dynamic harga) {
    if (harga is int) return harga;
    if (harga is double) return harga.toInt();
    return int.tryParse(harga.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
}