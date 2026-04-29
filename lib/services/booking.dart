import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("My Bookings"),
        ),
        body: const Center(child: Text("Please login to see your bookings")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("My Bookings"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading bookings"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("You have no bookings yet."));
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index].data() as Map<String, dynamic>;
              String bookingId = bookings[index].id;
              String carId = booking['carId'];
              
              DateTime date = (booking['bookingDate'] as Timestamp).toDate();
              String formattedDate = DateFormat('yyyy-MM-dd').format(date);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.lightBlue,
                    child: Icon(Icons.directions_car, color: Colors.white),
                  ),
                  title: Text(
                    booking['carName'] ?? "Unknown Car",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Model: ${booking['carModel']}"),
                      Text("Date: $formattedDate at ${booking['bookingTime']}"),
                      Text("Price: PKR ${booking['price']}"),
                    ],
                  ),
                  trailing: TextButton(
                    onPressed: () => _showCancelDialog(bookingId, carId),
                    child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCancelDialog(String bookingId, String carId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Booking?"),
        content: const Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              // 1. Delete the booking
              await FirebaseFirestore.instance.collection('bookings').doc(bookingId).delete();
              
              // 2. Make the car available again
              await FirebaseFirestore.instance.collection('cars').doc(carId).update({
                'isBooked': false,
              });
              
              if (mounted) Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Booking cancelled successfully")),
              );
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
