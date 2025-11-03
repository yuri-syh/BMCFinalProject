import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.stock,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'stock': stock,
  };

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>?;
    if (map == null) {
      throw Exception("Document data is null for ID: ${doc.id}");
    }

    final rawPrice = map['price'];

    double finalPrice;
    if (rawPrice is num) {
      finalPrice = rawPrice.toDouble();
    } else {
      finalPrice = 0.0;
    }

    return Product(
      id: doc.id,
      name: map['name'] is String ? map['name'] : 'No Name',
      price: finalPrice,
      imageUrl: map['imageUrl'] is String ? map['imageUrl'] : '',
      stock: map['stock'] is int ? map['stock'] : 0,
    );
  }
}