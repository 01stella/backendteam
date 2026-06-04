class CartItem {
  final int menuId; 
  final String name;
  final String description;
  final int price;
  int quantity;
  bool isSelected;
  
  // NEW: Add the modifiers
  final String iceLevel;
  final String sugarLevel;
  final String coffeeStrength;

  CartItem({
    required this.menuId,
    required this.name,
    required this.description,
    required this.price,
    this.quantity = 1,
    this.isSelected = true,
    // NEW: Require them in the constructor
    required this.iceLevel,
    required this.sugarLevel,
    required this.coffeeStrength,
  });
}