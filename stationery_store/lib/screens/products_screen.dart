import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'account_details_screen.dart';
import 'my_addresses_screen.dart';
import 'favorites_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  static const Color _appBarColor = Color(0xFF75a2b9);
  static const Color _darkColor = Color(0xFF464c56);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
    });
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = _currentUser?.displayName ?? 'User';
    final String email = _currentUser?.email ?? 'No Email';
    const String userRole = 'User';

    return Scaffold(
      drawer: Drawer(
        // Ginagamit ang Column upang ihiwalay ang DrawerHeader at ang 'Logout' sa dulo
        child: Column(
          children: <Widget>[
            // User Account (DrawerHeader)
            DrawerHeader(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Container(
                // ITO ANG NAGPA-FULL WIDTH NG GRADIENT
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ProductsScreen._appBarColor, ProductsScreen._darkColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                // Inayos na padding para sa content
                padding: const EdgeInsets.only(top: 20.0, left: 16.0, bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: ProductsScreen._darkColor, size: 30),
                    ),
                    const SizedBox(height: 10),
                    Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                    Text('$email | $userRole', style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
            ),


            // Expanded area para sa mga main menu items
            // Ito ay gumagamit ng ListView para maging scrollable
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero, // Alisin ang default padding ng ListView
                children: [
                  // My Account
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('My Account'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AccountDetailsScreen()),
                      );
                    },
                  ),

                  // Favorites
                  ListTile(
                    leading: const Icon(Icons.favorite_border),
                    title: const Text('Favorites'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FavoritesScreen()),
                      );
                    },
                  ),

                  // My Addresses
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('My Addresses'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyAddressesScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Logout area - inilagay sa labas ng Expanded para manatili sa ilalim
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),

            // Maliit na espasyo sa ilalim (para sa safety area ng device)
            SizedBox(height: MediaQuery.of(context).padding.bottom > 0 ? 8.0 : 0.0),
          ],
        ),
      ),

      appBar: AppBar(
        title: const Text("Office Stationery Store"),
        foregroundColor: Colors.white,

        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF75a2b9),
                Color(0xFF464c56),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        actions: [
          // Shopping Cart
          Consumer<CartProvider>(
            builder: (context, cart, child) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
                if (cart.totalItemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        cart.totalItemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                fillColor: ProductsScreen._appBarColor.withOpacity(0.1),
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(
                    color: ProductsScreen._appBarColor,
                  ));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No products available."));
                }

                final allProducts = snapshot.data!.docs
                    .map((doc) => Product.fromFirestore(doc))
                    .toList();

                final filteredProducts = allProducts.where((product) {
                  return product.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (_searchQuery.length >= 3 && filteredProducts.isEmpty) {
                  return const Center(
                    child: Text(
                      "No products found matching your search.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final displayProducts = _searchQuery.length < 3 ? allProducts : filteredProducts;

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 310,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: displayProducts.length,
                  itemBuilder: (context, i) => ProductCard(product: displayProducts[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}