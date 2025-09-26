// lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill the address from the provider
    _addressController.text = Provider.of<CartProvider>(context, listen: false).customerAddress;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _placeOrder(CartProvider cart) async {
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty!')),
      );
      return;
    }

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a delivery address.')),
      );
      return;
    }

    // Save the address for next time
    await cart.saveAddress(address);

    // --- Create the WhatsApp message ---
    String message = "New Order from Fataak App:\n\n";
    message += "Items:\n";
    cart.items.forEach((productId, product) {
      final quantity = cart.quantities[productId];
      message += "- ${product.name} (x$quantity)\n";
    });
    message += "\nTotal Amount: ₹${cart.totalAmount.toStringAsFixed(2)}\n";
    message += "\nDelivery Address:\n$address";
    // ------------------------------------

    // --- Replace with your WhatsApp number ---
    const String whatsappNumber = "+918770783359"; // IMPORTANT: Use your actual number
    // -----------------------------------------

    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}",
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        cart.clear(); // Clear cart after placing order
      } else {
        throw 'Could not launch $whatsappUrl';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open WhatsApp. Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(
              child: Text('Your cart is empty.', style: TextStyle(fontSize: 18)),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                final productId = cart.items.keys.elementAt(i);
                final product = cart.items.values.elementAt(i);
                final quantity = cart.quantities[productId] ?? 0;
                return Card(
                  color: const Color(0xFFFAFAFA),
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Image.asset(product.imagePath, width: 50, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image)),
                    title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Total: ₹${(product.price * quantity).toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: () {
                            cart.removeSingleItem(productId);
                          },
                        ),
                        Text('$quantity', style: const TextStyle(fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () {
                            cart.addItem(product);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Total and Order Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Delivery Address',
                    hintText: 'Enter your full address',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('₹${cart.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send), // Changed to a valid icon
                  label: const Text('Place Order on WhatsApp'),
                  onPressed: () => _placeOrder(cart),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}