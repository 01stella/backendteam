class CartItem {
  final int menuId; 
  final String name;
  final String description;
  final int price;
  int quantity;
  bool isSelected;

  CartItem({
    required this.menuId,
    required this.name,
    required this.description,
    required this.price,
    this.quantity = 1,
    this.isSelected = true,
  });
}