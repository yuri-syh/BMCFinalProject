import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/address_provider.dart';
import 'screens/admin_home_screen.dart'; // Siguraduhin na ito ang tama
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/products_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
// Alisin ang import na ito:
// import 'package:stationery_store/admin/admin_panel_screen.dart';

void main() async {
// ... (Walang pagbabago sa main function)
}

class StationeryApp extends StatelessWidget {
  const StationeryApp({super.key});

  Future<Widget> _getRoleBasedScreen(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // FIX DITO: Palitan ang AdminAddProductScreen() ng AdminHomeScreen()
      if (doc.exists && doc.data()?['role'] == 'admin') {
        return const AdminHomeScreen();
      }

      // Para sa normal na user
      return const ProductsScreen(); // ProductsScreen ang dapat na home ng user
      // Kung ginagamit mo pa rin ang 'HomeScreen', palitan mo ito.

    } catch (e) {
      print('Error fetching user role for routing: $e');
      return const ProductsScreen(); // Fallback to ProductsScreen/HomeScreen
    }
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
      ],
      child: MaterialApp(
          title: 'Office Stationery Store',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.blue),

          // AUTH WRAPPER
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                final user = snapshot.data!;
                return FutureBuilder<Widget>(
                  future: _getRoleBasedScreen(user),
                  builder: (context, roleSnapshot) {
                    if (roleSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (roleSnapshot.hasError || !roleSnapshot.hasData) {
                      print('Role fetch error: ${roleSnapshot.error}');
                    }
                    return roleSnapshot.data!;
                  },
                );
              }
              return const WelcomeScreen();
            },
          ),

          routes: {
            '/products': (context) => const ProductsScreen(),
            '/cart': (context) => const CartScreen(),
            '/checkout': (context) => const CheckoutScreen(),
          }
      ),
    );
  }
}