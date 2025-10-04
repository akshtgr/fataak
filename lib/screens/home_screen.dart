import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_loader.dart';
import 'product_detail_screen.dart';

// Enum for sorting options
enum SortOptions { defaultSort, nameAZ, nameZA, priceLowHigh, priceHighLow }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State for original screen
  String _selectedFilter = 'All';
  SortOptions _selectedSort = SortOptions.defaultSort;

  // State for search functionality
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedSearchFilter = 'All';
  static const _recentSearchKey = 'recent_searches';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _refreshProducts() async {
    await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  // --- RECENT SEARCHES MANAGEMENT ---
  Future<void> _addRecentSearch(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final recentSearches = prefs.getStringList(_recentSearchKey) ?? [];
    recentSearches.remove(productId);
    recentSearches.insert(0, productId);
    if (recentSearches.length > 10) {
      recentSearches.removeLast();
    }
    await prefs.setStringList(_recentSearchKey, recentSearches);
  }

  Future<void> _removeRecentSearch(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final recentSearches = prefs.getStringList(_recentSearchKey) ?? [];
    recentSearches.remove(productId);
    await prefs.setStringList(_recentSearchKey, recentSearches);
    setState(() {});
  }

  Future<List<Product>> _getRecentSearches() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final recentSearchIds = prefs.getStringList(_recentSearchKey) ?? [];
    if (recentSearchIds.isEmpty) return [];

    return recentSearchIds
        .map((id) => productProvider.products.firstWhere(
          (p) => p.id == id,
      orElse: () => Product(
          id: '',
          name: 'Not Found',
          imageUrl: '',
          marketPrice: 0,
          ourPrice: 0,
          stock: 0,
          inStock: false,
          unit: '',
          category: '',
          isFeatured: false,
          tags: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          priceUnit: '',
          stockUnit: '',
          stockLabel: ''),
    ))
        .where((p) => p.id.isNotEmpty)
        .toList();
  }
  // --- END RECENT SEARCHES ---

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _stopSearch() {
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  // --- WIDGET BUILDERS ---

  Widget _buildFloatingSearchUI() {
    final cardHeight = MediaQuery.of(context).size.height * 0.55;

    return Stack(
      children: [
        GestureDetector(
          onTap: _stopSearch,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 350),
            opacity: _isSearching ? 1.0 : 0.0,
            child: Container(color: const Color.fromRGBO(0, 0, 0, 0.6)),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          top: _isSearching ? 0 : -(cardHeight + 100),
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
            child: Material(
              borderRadius: BorderRadius.circular(16.0),
              elevation: 8.0,
              color: const Color(0xFFFAFAFA),
              child: _buildSearchCardContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchCardContent() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final suggestionList = _searchController.text.isEmpty
        ? []
        : productProvider.products.where((product) {
      final nameMatches = product.name
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      final categoryMatches = _selectedSearchFilter == 'All' ||
          product.category.toLowerCase() ==
              _selectedSearchFilter.toLowerCase();
      return nameMatches && categoryMatches;
    }).toList();

    return SafeArea(
      top: true,
      bottom: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.55,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.grey),
                      onPressed: _stopSearch,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: const InputDecoration(
                          hintText: 'Search for vegetables & fruits...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: SegmentedButton<String>(
                  style: ButtonStyle(
                    backgroundColor:
                    WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFFE0E0E0);
                      }
                      return Colors.transparent;
                    }),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0))),
                    side: WidgetStateProperty.all(
                        const BorderSide(color: Colors.grey, width: 1.0)),
                  ),
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'All', label: Text('All')),
                    ButtonSegment(
                        value: 'Vegetable', label: Text('Vegetables')),
                    ButtonSegment(value: 'Fruit', label: Text('Fruits')),
                  ],
                  selected: {_selectedSearchFilter},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() => _selectedSearchFilter = newSelection.first);
                  },
                ),
              ),
              Flexible(
                child: _searchController.text.isEmpty
                    ? _buildRecentSearches()
                    : ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: suggestionList.length,
                  itemBuilder: (context, index) {
                    return _buildProductListItem(
                      product: suggestionList.elementAt(index),
                      onTap: () {
                        _addRecentSearch(
                            suggestionList.elementAt(index).id);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => ProductDetailScreen(
                                  product:
                                  suggestionList.elementAt(index))),
                        );
                        _stopSearch();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return FutureBuilder<List<Product>>(
      future: _getRecentSearches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No recent searches.'),
              ));
        }
        final recentProducts = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
              child: Text('Recent',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: recentProducts.length,
                itemBuilder: (context, index) {
                  final product = recentProducts[index];
                  return _buildProductListItem(
                    product: product,
                    onTap: () {
                      _addRecentSearch(product.id);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (ctx) =>
                                ProductDetailScreen(product: product)),
                      );
                      _stopSearch();
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => _removeRecentSearch(product.id),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  ListTile _buildProductListItem(
      {required Product product, required VoidCallback onTap, Widget? trailing}) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        backgroundImage: CachedNetworkImageProvider(product.imageUrl),
      ),
      title:
      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(product.category),
      trailing: trailing,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Fataak'),
      scrolledUnderElevation: 0.0,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, size: 28),
          onPressed: _startSearch,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMainContent() {
    final productProvider = Provider.of<ProductProvider>(context);
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
        sortedProducts.sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOptions.nameZA:
        sortedProducts.sort(
                (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
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
    final outOfStockProducts =
    sortedProducts.where((p) => !p.inStock).toList();
    sortedProducts = [...inStockProducts, ...outOfStockProducts];

    // --- MODIFICATION START ---
    // The childAspectRatio has been adjusted to make the cards taller,
    // providing more space for content and fixing the overflow.
    const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16);
    // --- MODIFICATION END ---

    const Color orangeColor = Color(0xFFF07706);
    const Color greenColor = Color(0xFF1DAD03);
    final isVegOrFruitSelected =
        _selectedFilter == 'Vegetables' || _selectedFilter == 'Fruits';
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
      side: WidgetStateProperty.all(
          BorderSide(color: segmentOutlineColor, width: 1.5)),
      shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
      minimumSize: WidgetStateProperty.all(const Size(0, 40)),
    );

    return AbsorbPointer(
      absorbing: _isSearching,
      child: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: Container(
          color: const Color(0xFFFAFAFA),
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
                            ButtonSegment(
                                value: 'Vegetables', label: Text('Vegetables')),
                            ButtonSegment(
                                value: 'Fruits', label: Text('Fruits')),
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
                            borderRadius: BorderRadius.circular(12.0)),
                        color: Colors.white,
                        offset: const Offset(0, 50),
                        itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<SortOptions>>[
                          _buildSortMenuItem(SortOptions.defaultSort, 'Default'),
                          _buildSortMenuItem(SortOptions.nameAZ, 'Name: A to Z'),
                          _buildSortMenuItem(SortOptions.nameZA, 'Name: Z to A'),
                          _buildSortMenuItem(
                              SortOptions.priceLowHigh, 'Price: Low to High'),
                          _buildSortMenuItem(
                              SortOptions.priceHighLow, 'Price: High to Low'),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                              color: fabBackgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: fabOutlineColor, width: 1.5)),
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
                            itemBuilder: (ctx, i) => const SkeletonLoader());
                      } else if (sortedProducts.isEmpty) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.only(top: 40.0),
                                child: Text('No products found.')));
                      } else {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: GridView.builder(
                              key: ValueKey('$_selectedFilter-$_selectedSort'),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: sortedProducts.length,
                              gridDelegate: gridDelegate,
                              itemBuilder: (ctx, i) =>
                                  ProductCard(product: sortedProducts[i])),
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

  PopupMenuItem<SortOptions> _buildSortMenuItem(SortOptions option, String title) {
    return PopupMenuItem<SortOptions>(
      value: option,
      child: Row(
        children: [
          Icon(_selectedSort == option ? Icons.check : null,
              color: Colors.green),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSearching,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        if (_isSearching) {
          _stopSearch();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            _buildMainContent(),
            IgnorePointer(
              ignoring: !_isSearching,
              child: _buildFloatingSearchUI(),
            ),
          ],
        ),
      ),
    );
  }
}