// lib/models/product.dart

class Product {
  final String id;
  final String name;
  final String imagePath;
  final double price;
  final String stock; // e.g., "1 kg", "500 gm"

  Product({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.price,
    required this.stock,
  });
}