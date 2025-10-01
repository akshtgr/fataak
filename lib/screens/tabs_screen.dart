import 'package:fataak/providers/cart_provider.dart';
import 'package:fataak/screens/cart_screen.dart';
import 'package:fataak/screens/home_screen.dart';
import 'package:fataak/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Using WillPopScope to control the back button behavior
    return WillPopScope(
      onWillPop: () async {
        // If the current page is not the home page (index 0)
        if (_selectedPageIndex != 0) {
          // Select the home page
          _selectPage(0);
          // Prevent the app from closing
          return false;
        }
        // If it is the home page, allow the app to close
        return true;
      },
      child: Scaffold(
        body: _pages[_selectedPageIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: _selectPage,
          currentIndex: _selectedPageIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            // Cart icon is now wrapped with a Consumer to get cart data
            BottomNavigationBarItem(
              icon: Consumer<CartProvider>(
                builder: (_, cart, ch) => badges.Badge(
                  position: badges.BadgePosition.topEnd(top: -12, end: -12),
                  badgeContent: Text(
                    cart.itemCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  showBadge: cart.itemCount > 0,
                  child: ch,
                ),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              activeIcon: const Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}