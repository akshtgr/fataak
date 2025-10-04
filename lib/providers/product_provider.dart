import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  List<Product> get products => [..._products];
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('items').get();

      // --- DEBUG LINE ADDED HERE ---
      debugPrint('Found ${snapshot.docs.length} documents in the items collection.');

      _products = snapshot.docs
          .map((doc) => Product.fromJson(doc.data(), doc.id))
          .toList();

      // --- MODIFICATION START ---
      // Sort products by stock in descending order by default
      _products.sort((a, b) => b.stock.compareTo(a.stock));
      // --- MODIFICATION END ---

    } catch (error) {
      debugPrint('Error fetching products: $error');
      //
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}