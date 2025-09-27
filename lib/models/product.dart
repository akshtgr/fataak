class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double marketPrice;
  final double ourPrice;
  final int stock;
  final bool inStock;
  final String unit;
  final String category;
  final bool isFeatured;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.marketPrice,
    required this.ourPrice,
    required this.stock,
    required this.inStock,
    required this.unit,
    required this.category,
    required this.isFeatured,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json, String id) {
    return Product(
      id: id,
      name: json['name'],
      imageUrl: json['image_url'],
      marketPrice: json['market_price'].toDouble(),
      ourPrice: json['our_price'].toDouble(),
      stock: json['stock'],
      inStock: json['in_stock'],
      unit: json['unit'],
      category: json['category'],
      isFeatured: json['is_featured'],
      tags: List<String>.from(json['tags']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}