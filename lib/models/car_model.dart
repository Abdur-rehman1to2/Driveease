import 'package:cloud_firestore/cloud_firestore.dart';

class CarModel {
  final String? id;
  final String name;
  final String model;
  final double price;
  final String location;
  final String availability;
  final String ownerId;
  final bool isBooked;
  final String imageUrl;
  final DateTime? createdAt;

  CarModel({
    this.id,
    required this.name,
    required this.model,
    required this.price,
    required this.location,
    required this.availability,
    required this.ownerId,
    required this.isBooked,
    required this.imageUrl,
    this.createdAt,
  });

  factory CarModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CarModel(
      id: documentId,
      name: map['name'] ?? '',
      model: map['model'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      location: map['location'] ?? '',
      availability: map['availability'] ?? '',
      ownerId: map['ownerId'] ?? '',
      isBooked: map['isBooked'] ?? false,
      imageUrl: map['imageUrl'] ?? '',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'model': model,
      'price': price,
      'location': location,
      'availability': availability,
      'ownerId': ownerId,
      'isBooked': isBooked,
      'imageUrl': imageUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
