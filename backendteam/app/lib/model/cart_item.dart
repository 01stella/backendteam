class CartItem {
  final String itemType; // 'menu' or 'bundle'
  final int? menuId;
  final int? bundleId;  
  final String name;
  final String description;
  final int price;
  final String? imgUrl;
  int quantity;
  bool isSelected;
  
  // NEW: Add the modifiers
  final String iceLevel;
  final String sugarLevel;
  final String coffeeStrength;

  CartItem({
    required this.itemType,
    this.menuId,
    this.bundleId,

    required this.name,
    required this.description,
    required this.price,
    required this.imgUrl,

    this.quantity = 1,
    this.isSelected = true,
    
    required this.iceLevel,
    required this.sugarLevel,
    required this.coffeeStrength,
  });
}