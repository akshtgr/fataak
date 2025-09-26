class Product {
  final String id;
  final String name;
  final double price;
  final String stock;
  final String imagePath; // Assuming you store the image path in Firestore

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imagePath,
  });

  factory Product.fromJson(Map<String, dynamic> json, String id) {
    return Product(
      id: id,
      name: json['name'],
      price: json['ourPrice'].toDouble(), // Assuming 'ourPrice' is the customer price
      stock: json['stock'].toString(), // Convert stock to string
      imagePath: json['imageUrl'], // Assuming you have an 'imageUrl' field
    );
  }
}