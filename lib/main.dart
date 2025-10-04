import 'package:fataak/providers/theme_provider.dart';
import 'package:fataak/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import './providers/cart_provider.dart';
import './screens/tabs_screen.dart';
import './providers/product_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
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
        ChangeNotifierProvider(create: (ctx) => UserProvider()),
        ChangeNotifierProvider(create: (ctx) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Fataak',
            debugShowCheckedModeBanner: false,
            themeMode:
            themeProvider.getIsDarkTheme ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              primarySwatch: Colors.green,
              scaffoldBackgroundColor: const Color(0xFFFAFAFA),
              cardColor: const Color(0xFFFFFFFF),
              fontFamily: 'Roboto',
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFFAFAFA),
                elevation: 0,
                iconTheme: IconThemeData(color: Color(0xFF333333)),
                titleTextStyle: TextStyle(
                  fontFamily: 'Roboto',
                  color: Color(0xFF333333),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color(0xFFFAFAFA),
                selectedItemColor: Colors.green,
                unselectedItemColor: Colors.grey,
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
                labelStyle: TextStyle(color: Colors.grey.shade600),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF2F2F2F),
              cardColor: const Color(0xFF3A3A3A),
              fontFamily: 'Roboto',
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF2F2F2F),
                elevation: 0,
                iconTheme: IconThemeData(color: Color(0xFFE0E0E0)),
                titleTextStyle: TextStyle(
                  fontFamily: 'Roboto',
                  color: Color(0xFFE0E0E0),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color(0xFF2F2F2F),
                selectedItemColor: Colors.green,
                unselectedItemColor: Colors.grey,
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
                labelStyle: TextStyle(color: Colors.grey.shade400),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              colorScheme: const ColorScheme.dark(
                  primary: Colors.green,
                  surface: Color(0xFF2F2F2F),
                  onSurface: Color(0xFFE0E0E0)),
            ),
            home: const TabsScreen(),
          );
        },
      ),
    );
  }
}