import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import './providers/cart_provider.dart';
import './screens/home_screen.dart';
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
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF333333)),
            titleTextStyle: TextStyle(
              color: Color(0xFF333333),
              fontSize: 20,
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
              backgroundColor: const Color(0xFFF5F5F5),
              foregroundColor: const Color(0xFF333333),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}