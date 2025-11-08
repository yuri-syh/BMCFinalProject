import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'my_addresses_screen.dart';
import '../providers/address_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Order Placed!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your order has been placed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF464c56),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Continue Shopping', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  static const Color _appBarColor = Color(0xFF75a2b9);
  static const Color _darkColor = Color(0xFF464c56);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late String _selectedAddress;
  String? _selectedPaymentMethod = 'Cash on Delivery';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);

    if (addressProvider.addresses.isNotEmpty) {
      _selectedAddress = addressProvider.addresses.first.fullAddress;
    } else {
      _selectedAddress = 'Address not yet selected. Tap "Change/Add Address" to proceed.';
    }
  }

  Future<void> _saveOrder(CartProvider cart) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User is not logged in. Cannot place order.");
    }

    final orderItems = cart.items.map((cartItem) => {
      'id': cartItem.id,
      'name': cartItem.name,
      'price': cartItem.price,
      'quantity': cartItem.quantity,
    }).toList();

    await FirebaseFirestore.instance.collection('orders').add({
      'uid': user.uid,
      'email': user.email,
      'timestamp': FieldValue.serverTimestamp(),
      'grandTotal': cart.grandTotal,
      'subTotal': cart.totalPrice,
      'shippingFee': CartProvider.deliveryFee,
      'address': _selectedAddress,
      'paymentMethod': _selectedPaymentMethod,
      'status': 'Pending', // Initial status
      'items': orderItems,
    });
  }
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Checkout"),
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [CheckoutScreen._appBarColor, CheckoutScreen._darkColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: CheckoutScreen._appBarColor,
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delivery To:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyAddressesScreen(isSelectionMode: true),
                      ),
                    );

                    if (result != null && result is String) {
                      setState(() {
                        _selectedAddress = result;
                      });
                    }
                  },
                  child: const Text('Change/Add Address', style: TextStyle(color: CheckoutScreen._darkColor)),
                ),
              ],
            ),
            const Divider(),
            Text(_selectedAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOptions() {
    final List<String> methods = [
      'Cash on Delivery',
      'Credit/Debit Card (Not available)',
      'PayPal (Not available)',
      'GCash (Not available)',
    ];

    return Card(
      elevation: 2,
      child: Column(
        children: methods.map((method) {
          final isAvailable = !method.contains('(Not available)');

          return RadioListTile<String>(
            title: Text(method),
            value: method.split(' ').first,
            groupValue: _selectedPaymentMethod,
            onChanged: isAvailable
                ? (String? value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            }
                : (String? value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${method.split(' ').first} payment is not yet available.")),
              );
            },
            dense: true,
            activeColor: CheckoutScreen._appBarColor,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, Color color, {bool isTotal = false, double? totalFontSize}) {
    final double finalFontSize = isTotal ? (totalFontSize ?? 20) : 16;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: finalFontSize,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: finalFontSize,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(BuildContext context, CartProvider cart) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPriceRow('Subtotal (${cart.totalItemCount} items)', '₱${cart.totalPrice.toStringAsFixed(2)}', Colors.black),
            const Divider(),
            _buildPriceRow('Shipping Fee', '₱${CartProvider.deliveryFee.toStringAsFixed(2)}', Colors.green[700]!),
            const Divider(thickness: 1.5),
            _buildPriceRow('TOTAL', '₱${cart.grandTotal.toStringAsFixed(2)}', Colors.red[700]!, isTotal: true, totalFontSize: 16),
          ],
        ),
      ),
    );
  }

  void _placeOrder(BuildContext context, CartProvider cart) async {
    if (_isLoading) return;

    if (_selectedAddress.startsWith('Address not yet selected') || _selectedAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a shipping address first.")),
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a payment method first.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _saveOrder(cart);
      await Future.delayed(const Duration(seconds: 2));

      // 3. I-clear ang Cart
      cart.clearCart();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OrderSuccessScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error placing order: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    if (cart.items.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: Text('Your cart is empty. Nothing to checkout.')),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shipping Address
              _buildSectionTitle(context, 'Shipping Address'),
              _buildAddressCard(context),
              const SizedBox(height: 20),

              // Payment Method
              _buildSectionTitle(context, 'Payment Method'),
              _buildPaymentMethodOptions(),
              const SizedBox(height: 20),

              // Order Summary
              _buildSectionTitle(context, 'Order Summary'),
              _buildPriceBreakdown(context, cart),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    _placeOrder(context, cart);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CheckoutScreen._darkColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                  // 4. Ipakita ang loading spinner
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                  // Normal button text
                      : Text('Place Order (₱${cart.grandTotal.toStringAsFixed(2)})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}