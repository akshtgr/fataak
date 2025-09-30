// lib/providers/cart_provider.dart

import 'package:flutter/material.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final Map<String, Product> _items = {};
  final Map<String, int> _quantities = {};

  // Getter for cart items
  Map<String, Product> get items => {..._items};

  // Getter for quantities
  Map<String, int> get quantities => {..._quantities};

  // Getter for item count
  int get itemCount => _items.length;

  // Calculate total amount
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, product) {
      total += product.ourPrice * (_quantities[key] ?? 0);
    });
    return total;
  }

  // Add item to cart
  void addItem(Product product) {
    if (_quantities.containsKey(product.id)) {
      _quantities.update(product.id, (existingValue) => existingValue + 1);
    } else {
      _items.putIfAbsent(product.id, () => product);
      _quantities.putIfAbsent(product.id, () => 1);
    }
    notifyListeners();
  }

  // Remove a single quantity of an item
  void removeSingleItem(String productId) {
    if (!_quantities.containsKey(productId)) {
      return;
    }
    if (_quantities[productId]! > 1) {
      _quantities.update(productId, (existingValue) => existingValue - 1);
    } else {
      _items.remove(productId);
      _quantities.remove(productId);
    }
    notifyListeners();
  }

  // Clear the cart
  void clear() {
    _items.clear();
    _quantities.clear();
    notifyListeners();
  }
}