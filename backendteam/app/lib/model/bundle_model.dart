class Bundle {
  final int id;
  final String name;
  final int price;
  final String imageUrl;
  final List<String> includedItems;

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
      price: json['price'],
      imageUrl: json['image_url'] ?? '',
      // Converting the JSON array into a Dart List of Strings
      includedItems: List<String>.from(json['included_items'] ?? []),
    );
  }
}