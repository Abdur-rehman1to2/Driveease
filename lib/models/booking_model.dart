import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String? id;
  final String carId;
  final String carName;
  final String carModel;
  final double price;
  final String userId;
  final DateTime bookingDate;
  final String bookingTime;
  final String status;
  final DateTime? createdAt;

  BookingModel({
    this.id,
    required this.carId,
    required this.carName,
    required this.carModel,
    required this.price,
    required this.userId,
    required this.bookingDate,
    required this.bookingTime,
    required this.status,
    this.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BookingModel(
      id: documentId,
      carId: map['carId'] ?? '',
      carName: map['carName'] ?? '',
      carModel: map['carModel'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      userId: map['userId'] ?? '',
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      bookingTime: map['bookingTime'] ?? '',
      status: map['status'] ?? 'Booked',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'carName': carName,
      'carModel': carModel,
      'price': price,
      'userId': userId,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'bookingTime': bookingTime,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
