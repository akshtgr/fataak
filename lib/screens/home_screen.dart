import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import './cart_screen.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_loader.dart';

// Enum for sorting options
enum SortOptions { defaultSort, nameAZ, nameZA, priceLowHigh, priceHighLow }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'All';
  SortOptions _selectedSort = SortOptions.defaultSort;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  Future<void> _refreshProducts() async {
    await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  // Helper widget to build the sort menu items with a checkmark for the active one
  PopupMenuItem<SortOptions> _buildSortMenuItem(SortOptions option, String title) {
    return PopupMenuItem<SortOptions>(
      value: option,
      child: Row(
        children: [
          // FIX: Show a check icon if this option is currently selected
          Icon(
            _selectedSort == option ? Icons.check : null,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    // Filtering and Sorting Logic
    final filteredProducts = productProvider.products.where((product) {
      final category = product.category.trim().toLowerCase();
      switch (_selectedFilter) {
        case 'All':
          return true;
        case 'Vegetables':
          return category == 'vegetable';
        case 'Fruits':
          return category == 'fruit';
        default:
          return false;
      }
    }).toList();

    List<dynamic> sortedProducts = List.from(filteredProducts);

    switch (_selectedSort) {
      case SortOptions.nameAZ:
        sortedProducts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOptions.nameZA:
        sortedProducts.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case SortOptions.priceLowHigh:
        sortedProducts.sort((a, b) => a.ourPrice.compareTo(b.ourPrice));
        break;
      case SortOptions.priceHighLow:
        sortedProducts.sort((a, b) => b.ourPrice.compareTo(a.ourPrice));
        break;
      case SortOptions.defaultSort:
        break;
    }

    final inStockProducts = sortedProducts.where((p) => p.inStock).toList();
    final outOfStockProducts = sortedProducts.where((p) => !p.inStock).toList();
    sortedProducts = [...inStockProducts, ...outOfStockProducts];

    const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 3 / 5.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    );

    // Dynamic Styling
    const Color orangeColor = Color(0xFFF07706);
    const Color greenColor = Color(0xFF1DAD03);

    final isVegOrFruitSelected = _selectedFilter == 'Vegetables' || _selectedFilter == 'Fruits';
    final segmentSelectedColor = isVegOrFruitSelected ? greenColor : orangeColor;
    final segmentOutlineColor = isVegOrFruitSelected ? greenColor : orangeColor;

    final isSorted = _selectedSort != SortOptions.defaultSort;
    final fabBackgroundColor = isSorted ? greenColor : Colors.transparent;
    final fabIconColor = isSorted ? Colors.white : orangeColor;
    final fabOutlineColor = isSorted ? greenColor : orangeColor;

    final ButtonStyle segmentedButtonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return segmentSelectedColor;
        }
        return Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.black54;
      }),
      side: WidgetStateProperty.all(BorderSide(color: segmentOutlineColor, width: 1.5)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      minimumSize: WidgetStateProperty.all(const Size(0, 40)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fataak'),
        scrolledUnderElevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            onPressed: () {},
          ),
          Consumer<CartProvider>(
            builder: (_, cart, ch) => badges.Badge(
              position: badges.BadgePosition.topEnd(top: 0, end: 3),
              badgeContent: Text(
                cart.itemCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              showBadge: cart.itemCount > 0,
              child: ch,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, size: 28),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const CartScreen()));
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<String>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(value: 'All', label: Text('All')),
                            ButtonSegment(value: 'Vegetables', label: Text('Vegetables')),
                            ButtonSegment(value: 'Fruits', label: Text('Fruits')),
                          ],
                          selected: {_selectedFilter},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _selectedFilter = newSelection.first;
                            });
                          },
                          style: segmentedButtonStyle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      PopupMenuButton<SortOptions>(
                        onSelected: (SortOptions result) {
                          setState(() {
                            _selectedSort = result;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        color: Colors.white,
                        offset: const Offset(0, 50),
                        // Use the helper to build the menu items
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOptions>>[
                          _buildSortMenuItem(SortOptions.defaultSort, 'Default'),
                          _buildSortMenuItem(SortOptions.nameAZ, 'Name: A to Z'),
                          _buildSortMenuItem(SortOptions.nameZA, 'Name: Z to A'),
                          _buildSortMenuItem(SortOptions.priceLowHigh, 'Price: Low to High'),
                          _buildSortMenuItem(SortOptions.priceHighLow, 'Price: High to Low'),
                        ],
                        child: Container(
                          // FIX: Reduced padding to make the button slightly smaller.
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: fabBackgroundColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: fabOutlineColor, width: 1.5),
                          ),
                          child: Icon(
                            Icons.sort,
                            color: fabIconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Consumer<ProductProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 6,
                          gridDelegate: gridDelegate,
                          itemBuilder: (ctx, i) => const SkeletonLoader(),
                        );
                      } else if (sortedProducts.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40.0),
                            child: Text('No products found.'),
                          ),
                        );
                      } else {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: GridView.builder(
                            key: ValueKey('$_selectedFilter-$_selectedSort'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: sortedProducts.length,
                            gridDelegate: gridDelegate,
                            itemBuilder: (ctx, i) => ProductCard(product: sortedProducts[i]),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}