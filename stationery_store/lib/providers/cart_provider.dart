import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }
}

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  String? _userId;
  StreamSubscription? _authSubscription;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const double deliveryFee = 50.00;

  CartProvider() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        _userId = user.uid;
        _fetchCart();
      } else {
        _userId = null;
        clearCart();
      }
    });
  }

  Future<void> _fetchCart() async {
    if (_userId == null) return;
    try {
      final doc = await _firestore.collection('userCarts').doc(_userId).get();
      if (doc.exists && doc.data()!['cartItems'] != null) {
        final List<dynamic> rawItems = doc.data()!['cartItems'];
        _items = rawItems.map((item) => CartItem.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        _items = [];
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching cart: $e');
    }
  }

  Future<void> _saveCart() async {
    if (_userId == null) return;
    try {
      final cartData = _items.map((item) => item.toJson()).toList();
      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
      });
    } catch (e) {
      print('Error saving cart: $e');
    }
  }
  List<CartItem> get items => [..._items];

  int get totalItemCount {
    return _items.fold(0, (sum, cartItem) => sum + cartItem.quantity);
  }

  double get totalPrice => _items.fold(
      0, (sum, cartItem) => sum + cartItem.price * cartItem.quantity);

  double get grandTotal => totalPrice + deliveryFee;

  // --- ACTIONS ---

  Future<void> placeOrder() async {
    if (_userId == null) {
      throw Exception('User must be logged in to place an order.');
    }

    if (_items.isEmpty) {
      throw Exception('Cannot place an empty order.');
    }

    final orderItems = _items.map((item) => item.toJson()).toList();
    final total = grandTotal;

    try {
      await _firestore.collection('orders').add({
        'userId': _userId,
        'timestamp': FieldValue.serverTimestamp(),
        'items': orderItems,
        'totalPrice': total,
        'status': 'Pending',
      });

      _items = [];
      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': [],
      });

      notifyListeners();
      print('Order placed and cart cleared successfully!');

    } catch (e) {
      print('Error placing order: $e');
      rethrow;
    }
  }

  void addToCart(Product product) {
    var index = _items.indexWhere((item) => item.id == product.id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(
        id: product.id,
        name: product.name,
        price: product.price,
        quantity: 1,
      ));
    }
    _saveCart();
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    var index = _items.indexWhere((item) => item.id == productId);

    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    _saveCart();
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.id == productId);
    _saveCart();
    notifyListeners();
  }

  void clearCart() {
    _items = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}