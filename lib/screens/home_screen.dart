// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:badges/badges.dart' as badges;

import '../providers/product_provider.dart'; // Import the new provider
import '../models/product.dart';
import '../providers/cart_provider.dart';
import './cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch products when the screen loads
    Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  final List<String> _bannerImages = [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
  ];

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fataak'),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, ch) => badges.Badge(
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              badgeContent: Text(
                cart.itemCount.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              showBadge: cart.itemCount > 0,
              child: ch,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const CartScreen()));
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Carousel
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 180.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.9,
                ),
                items: _bannerImages.map((imagePath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Text('Image not found'));
                          },),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),

            // Product Listing
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Text('Fresh Vegetables', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            GridView.builder(
              padding: const EdgeInsets.all(8.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (ctx, i) => ProductCard(product: products[i]),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Product Card Widget (Moved Outside) ---
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Image.network( // Use Image.network for firebase images
                  product.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40,));
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('₹${product.price.toStringAsFixed(2)} / ${product.stock}', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  cart.addItem(product);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}