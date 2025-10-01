import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fataak/models/user_data.dart';
import 'package:fataak/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../providers/cart_provider.dart';

const Color customGreen = Color(0xFF1DAD03);

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  bool _isOrderable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    _nameController.addListener(_validateFields);
    _addressController.addListener(_validateFields);
    _phoneController.addListener(_validateFields);
    cartProvider.addListener(_validateFields);
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUserData();
    final userData = userProvider.userData;

    setState(() {
      _nameController.text =
          '${userData.firstName} ${userData.lastName}'.trim();
      _addressController.text = userData.address;
      _phoneController.text = userData.phone;
      _isLoading = false;
      _validateFields();
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateFields);
    _addressController.removeListener(_validateFields);
    _phoneController.removeListener(_validateFields);
    Provider.of<CartProvider>(context, listen: false)
        .removeListener(_validateFields);
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validateFields() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    if (mounted) {
      setState(() {
        _isOrderable = cart.itemCount > 0 &&
            name.isNotEmpty &&
            address.isNotEmpty &&
            phone.isNotEmpty;
      });
    }
  }

  Future<bool> _promptToSaveChanges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentName =
    '${userProvider.userData.firstName} ${userProvider.userData.lastName}'
        .trim();
    final currentAddress = userProvider.userData.address;
    final currentPhone = userProvider.userData.phone;

    final newName = _nameController.text.trim();
    final newAddress = _addressController.text.trim();
    final newPhone = _phoneController.text.trim();

    final bool detailsChanged = newName != currentName ||
        newAddress != currentAddress ||
        newPhone != currentPhone;

    if (detailsChanged) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Update Profile?'),
          content: const Text(
              'Do you want to save this as your default name/address/phone?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (shouldSave == true) {
        List<String> nameParts = newName.split(' ');
        String firstName = nameParts.isNotEmpty ? nameParts.first : '';
        String lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        await userProvider.saveUserData(UserData(
          firstName: firstName,
          lastName: lastName,
          address: newAddress,
          phone: newPhone,
        ));

        // FIX: Check if the widget is still mounted before showing SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Information updated or saved')),
          );
        }
      }
      return true;
    }
    return false;
  }

  void _placeOrder(CartProvider cart) async {
    final bool dialogShown = await _promptToSaveChanges();
    if (dialogShown) {
      return;
    }
    _sendOrderToWhatsApp(cart);
  }

  void _sendOrderToWhatsApp(CartProvider cart) async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();

    var uuid = const Uuid();
    final orderData = {
      'orderId': uuid.v4(),
      'customerName': name,
      'phone': phone,
      'address': address,
      'items': cart.items.entries.map((entry) {
        final product = entry.value;
        final quantity = cart.quantities[entry.key] ?? 0;
        return {
          'name': product.name,
          'qty': quantity,
          'price': product.ourPrice,
        };
      }).toList(),
      'totalAmount': cart.totalAmount,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    };

    String message = "🌿 New Order from Fataak App 🌿\n\n";
    message += "👤 Customer Name: $name\n";
    message += "📞 Phone: $phone\n\n";
    message += "🛒 Items:\n";
    cart.items.forEach((productId, product) {
      final quantity = cart.quantities[productId];
      message += "- ${product.name} x$quantity\n";
    });
    message += "\n💰 Total: ₹${cart.totalAmount.toStringAsFixed(2)}\n\n";
    message += "📍 Delivery Address:\n$address";

    const String whatsappNumber = "+918770783359";
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}",
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await FirebaseFirestore.instance.collection('orders').add(orderData);
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        cart.clear();
      } else {
        throw 'Could not launch $whatsappUrl';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open WhatsApp. Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Your Cart'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(
              child: Text('Your cart is empty.',
                  style: TextStyle(fontSize: 18)),
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
                    leading: Image.network(product.imageUrl,
                        width: 50,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image)),
                    title: Text(product.name,
                        style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'Total: ₹${(product.ourPrice * quantity).toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: () {
                            cart.removeSingleItem(productId);
                          },
                        ),
                        Text('$quantity',
                            style: const TextStyle(fontSize: 16)),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              border:
              Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Delivery Address',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Your Phone Number',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('₹${cart.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isOrderable)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Place Order on WhatsApp'),
                    onPressed: () => _placeOrder(cart),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  OutlinedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Place Order on WhatsApp'),
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: customGreen,
                      side: const BorderSide(color: customGreen, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
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