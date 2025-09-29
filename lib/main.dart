import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- 1. ADD THIS IMPORT
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import './providers/cart_provider.dart';
import './screens/tabs_screen.dart';
import './providers/product_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 2. ADD THIS CODE BLOCK to enable edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    // Make the navigation bar background transparent
    systemNavigationBarColor: Colors.transparent,
  ));

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
          // 3. ADD THIS LINE to enable Material 3 styling
          useMaterial3: true,

          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Colors.white, // Pure white background
          fontFamily: 'Roboto',

          // Your existing theme settings are preserved
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
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF333333), fontSize: 16),
            bodyMedium: TextStyle(color: Color(0xFF333333), fontSize: 14),
            headlineSmall: TextStyle(color: Color(0xFF333333), fontSize: 20, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(color: Color(0xFF333333), fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
        home: const TabsScreen(),
      ),
    );
  }
}