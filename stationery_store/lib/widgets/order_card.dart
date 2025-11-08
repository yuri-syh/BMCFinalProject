// lib/widgets/order_card.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderCard({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    // Kumuha ng data
    final timestamp = orderData['timestamp'] as Timestamp;
    final DateTime orderDate = timestamp.toDate();
    final double totalPrice = (orderData['totalPrice'] as num).toDouble();
    final String status = orderData['status'] as String;
    final List<dynamic> items = orderData['items'];

    final int totalItems = items.fold(0, (sum, item) {
      final itemQuantity = (item['quantity'] as num?)?.toInt() ?? 0;
      return sum + itemQuantity;
    });

    // Gumamit ng DateFormat
    final dateFormat = DateFormat('MM/dd/yyyy – hh:mm a');
    final formattedDate = dateFormat.format(orderDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Date: $formattedDate',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF464c56)),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: status == 'Pending' ? Colors.orange.shade700 : Colors.green,
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Items: $totalItems',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Total: ₱${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF75a2b9)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}