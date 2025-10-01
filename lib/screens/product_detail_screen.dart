import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({required this.product, super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate a network request
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        scrolledUnderElevation: 0,
      ),
      // The body is now a SingleChildScrollView to prevent all overflows
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading ? _buildSkeleton() : _buildProductDetails(),
      ),
    );
  }

  // Skeleton view for loading state
  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton for the square image
          Container(
            height: MediaQuery.of(context).size.width - 32, // Square shape
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0)
            ),
          ),
          const SizedBox(height: 20),
          // Skeletons for the text
          Container(height: 24, width: 200, color: Colors.white),
          const SizedBox(height: 10),
          Container(height: 20, width: 150, color: Colors.white),
          const SizedBox(height: 10),
          Container(height: 20, width: 100, color: Colors.white),
          const SizedBox(height: 20),
          // Skeleton for the button
          Container(height: 50, width: double.infinity, decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0)
          ),),
        ],
      ),
    );
  }

  // The main widget for displaying product details
  Widget _buildProductDetails() {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: AspectRatio(
            aspectRatio: 1 / 1, // Square container
            child: CachedNetworkImage(
              imageUrl: widget.product.imageUrl,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
              ),
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        const SizedBox(height: 10),
        Row(
          children: [
            Text('₹${widget.product.ourPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(width: 12),
            Text('₹${widget.product.marketPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, decoration: TextDecoration.lineThrough, fontSize: 18)),
          ],
        ),
        const SizedBox(height: 10),
        Text('Stock: ${widget.product.stock} ${widget.product.unit}', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.product.inStock && widget.product.stock > 0
                ? () {
              cart.addItem(widget.product);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.product.name} added to cart!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.product.inStock && widget.product.stock > 0 ? Colors.green : Colors.grey.shade300,
              foregroundColor: widget.product.inStock && widget.product.stock > 0 ? Colors.white : Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              widget.product.inStock && widget.product.stock > 0 ? 'Add to Cart' : 'Out of Stock',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}