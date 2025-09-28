import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import './providers/cart_provider.dart';
import './screens/tabs_screen.dart'; // Changed from home_screen
import './providers/product_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const FataakApp());
}

class FataakApp extends StatelessWidget {
  const FataakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        ChangeNotifierProvider(create: (ctx) => ProductProvider()),
      ],
      child: MaterialApp(
        title: 'Fataak',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.white, // Pure white background
          fontFamily: 'Roboto',

          // Updated AppBar Theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0, // No shadow
            iconTheme: IconThemeData(color: Color(0xFF333333)),
            titleTextStyle: TextStyle(
              fontFamily: 'Roboto',
              color: Color(0xFF333333),
              fontSize: 22, // Slightly larger
              fontWeight: FontWeight.bold,
            ),
          ),

          // Updated Text Theme
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF333333), fontSize: 16),
            bodyMedium: TextStyle(color: Color(0xFF333333), fontSize: 14),
            headlineSmall: TextStyle(color: Color(0xFF333333), fontSize: 20, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(color: Color(0xFF333333), fontSize: 18, fontWeight: FontWeight.bold),
          ),

          // Updated Button Theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green, // Default to green
              foregroundColor: Colors.white, // Default text to white
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        home: const TabsScreen(), // Use TabsScreen as home
      ),
    );
  }
}