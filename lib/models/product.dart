// lib/models/product.dart

import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String priceUnit;
  final String stockUnit;
  final String stockLabel;

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
    required this.priceUnit,
    required this.stockUnit,
    required this.stockLabel,
  });

  factory Product.fromJson(Map<String, dynamic> json, String id) {
    return Product(
      id: id,
      // --- MODIFICATION START ---
      // The .trim() method has been added to all string fields to remove whitespace.
      name: (json['name'] ?? 'No Name').trim(),
      imageUrl: (json['image_url'] ?? '').trim(),
      marketPrice: (json['market_price'] ?? 0).toDouble(),
      ourPrice: (json['our_price'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      inStock: json['in_stock'] ?? false,
      unit: (json['unit'] ?? 'N/A').trim(),
      category: (json['category'] ?? 'Uncategorized').trim(),
      isFeatured: json['is_featured'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: (json['created_at'] is Timestamp)
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: (json['updated_at'] is Timestamp)
          ? (json['updated_at'] as Timestamp).toDate()
          : DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      priceUnit: (json['price_unit'] ?? '').trim(),
      stockUnit: (json['stock_unit'] ?? '').trim(),
      stockLabel: (json['stock_label'] ?? '').trim(),
      // --- MODIFICATION END ---
    );
  }
}