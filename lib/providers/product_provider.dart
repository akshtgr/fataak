import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Product> get products => [..._products];

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      _products = snapshot.docs
          .map((doc) => Product.fromJson(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}