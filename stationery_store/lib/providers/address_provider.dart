import 'package:flutter/material.dart';
import '../models/address.dart';

class AddressProvider with ChangeNotifier {
  final List<Address> _addresses = [
    Address(
      label: 'Home',
      details: '123 Sampaguita St., Brgy. San Jose, Manila',
    ),
  ];

  List<Address> get addresses => [..._addresses];

  void saveAddress({
    required String label,
    required String details,
    Address? existingAddress,
  }) {
    if (existingAddress != null) {
      final index = _addresses.indexWhere((addr) => addr.id == existingAddress.id);
      if (index != -1) {
        _addresses[index] = Address(
          id: existingAddress.id,
          label: label,
          details: details,
        );
      }
    } else {
      final newAddress = Address(label: label, details: details);
      _addresses.add(newAddress);
    }

    notifyListeners();
  }

  void deleteAddress(String addressId) {
    _addresses.removeWhere((addr) => addr.id == addressId);
    notifyListeners();
  }
}