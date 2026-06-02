import '../model/cart_item.dart';

class CartService {
  // Singleton Pattern
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  // The actual cart data
  List<CartItem> items = [];

  void addItem(CartItem newItem) {
    // Check if item is already in cart. If yes, just increase quantity.
    var existingItem = items.where((i) => i.menuId == newItem.menuId).firstOrNull;
    
    if (existingItem != null) {
      existingItem.quantity += newItem.quantity;
    } else {
      items.add(newItem);
    }
  }

  void clearCart() {
    items.clear();
  }
}