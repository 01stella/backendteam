class BundleIncludedItem {
  final int menuId;
  final String name;

  BundleIncludedItem({
    required this.menuId,
    required this.name,
  });

  factory BundleIncludedItem.fromJson(Map<String, dynamic> json) {
    return BundleIncludedItem(
      menuId: json['menu_id'],
      name: json['name'],
    );
  }
}

class Bundle {
  final int id;
  final String name;
  final int price;
  final String imageUrl;
  final List<BundleIncludedItem> includedItems;

  Bundle({
    required this.id, 
    required this.name, 
    required this.price, 
    required this.imageUrl, 
    required this.includedItems
  });


  factory Bundle.fromJson(Map<String, dynamic> json) {
    return Bundle(
      id: json['id'],
      name: json['name'],
      price: int.parse(json['price'].toString().split('.')[0]),
      imageUrl: json['image_url'] ?? '',
      includedItems: (json['included_items'] as List? ?? [])
          .map((item) => BundleIncludedItem.fromJson(item))
          .toList(),
    );
  }
}