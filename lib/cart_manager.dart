import '../models/menu_models.dart';

class CartItem {
  final MenuModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;

  CartManager._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalItems =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  void add(MenuModel item, {int qty = 1}) {
    int index = _items.indexWhere((c) => c.product.id == item.id);

    if (index != -1) {
      _items[index].quantity += qty;
    } else {
      _items.add(CartItem(product: item, quantity: qty));
    }
  }

  void clear() {
    _items.clear();
  }
}