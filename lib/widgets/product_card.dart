import 'package:fataak/models/product.dart';
import 'package:fataak/providers/cart_provider.dart';
import 'package:fataak/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

const Color customGreen = Color(0xFF1DAD03);

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final quantity = cart.quantities[product.id] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          // Using theme's card color instead of a hardcoded value
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.image_not_supported,
                          color: Colors.grey, size: 40),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // --- MODIFICATION START ---
              // The layout is now more flexible to accommodate long product names.
              Container(
                height: 42, // Allocate space for two lines of text
                alignment: Alignment.topLeft,
                child: Text(
                  product.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                      text: '₹${product.ourPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: product.priceUnit,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: ' • ',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    TextSpan(
                      text: '₹${product.marketPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.red,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // --- MODIFICATION END ---
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 36,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: (product.inStock && product.stock > 0)
                          ? (quantity == 0
                          ? OutlinedButton.icon(
                        key: const ValueKey('addButton'),
                        onPressed: () {
                          cart.addItem(product);
                          ScaffoldMessenger.of(context)
                              .hideCurrentSnackBar();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${product.name} added to cart!'),
                              duration:
                              const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: customGreen,
                          side: const BorderSide(
                              color: customGreen, width: 1.5),
                          shape: const StadiumBorder(),
                        ),
                      )
                          : Container(
                        key: const ValueKey('stepper'),
                        decoration: BoxDecoration(
                          color: customGreen,
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove,
                                  color: Colors.white,
                                  size: 16),
                              onPressed: () => cart
                                  .removeSingleItem(product.id),
                              constraints:
                              const BoxConstraints(),
                              padding: const EdgeInsets
                                  .symmetric(
                                  horizontal: 8,
                                  vertical: 4),
                            ),
                            Text(
                              quantity.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add,
                                  color: Colors.white,
                                  size: 16),
                              onPressed: () =>
                                  cart.addItem(product),
                              constraints:
                              const BoxConstraints(),
                              padding: const EdgeInsets
                                  .symmetric(
                                  horizontal: 8,
                                  vertical: 4),
                            ),
                          ],
                        ),
                      ))
                          : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Out of Stock',
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}