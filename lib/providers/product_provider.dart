import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true; // Add loading state

  List<Product> get products => [..._products];
  bool get isLoading => _isLoading; // Getter for loading state

  Future<void> fetchProducts() async {
    // No need to set isLoading to true here, it's handled on init.
    // Let's make refresh instant for the user.
    try {
      final snapshot = await _firestore.collection('products').get();
      _products = snapshot.docs
          .map((doc) => Product.fromJson(doc.data(), doc.id))
          .toList();
    } catch (error) {
      // You might want to handle this error more gracefully
      print(error);
    } finally {
      _isLoading = false; // Set loading to false after fetching
      notifyListeners();
    }
  }
}