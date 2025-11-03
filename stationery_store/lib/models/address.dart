import 'package:uuid/uuid.dart';

class Address {
  final String id;
  final String label;
  final String details;

  Address({
    String? id,
    required this.label,
    required this.details,
  }) : id = id ?? const Uuid().v4();

  // Ginagamit ito para sa display
  String get fullAddress => '$details ($label)';
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'details': details,
    };
  }
  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as String,
      label: map['label'] as String,
      details: map['details'] as String,
    );
  }
}