// lib/providers/cart_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  final Map<String, Product> _items = {};
  final Map<String, int> _quantities = {};
  String _customerAddress = '';

  CartProvider() {
    _loadAddress();
  }

  // Getter for cart items
  Map<String, Product> get items => {..._items};

  // Getter for quantities
  Map<String, int> get quantities => {..._quantities};

  // Getter for item count
  int get itemCount => _items.length;

  // Getter for customer address
  String get customerAddress => _customerAddress;

  // Calculate total amount
  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, product) {
      total += product.price * (_quantities[key] ?? 0);
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

  // Load address from device storage
  Future<void> _loadAddress() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('deliveryAddress')) {
      _customerAddress = prefs.getString('deliveryAddress')!;
      notifyListeners();
    }
  }

  // Save address to device storage
  Future<void> saveAddress(String newAddress) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('deliveryAddress', newAddress);
    _customerAddress = newAddress;
    notifyListeners();
  }
}