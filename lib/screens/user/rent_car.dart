import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:semester_project/screens/auth/login_screen.dart';

class RentCar extends StatefulWidget {
  const RentCar({super.key});

  @override
  State<RentCar> createState() => _RentCarState();
}

class _RentCarState extends State<RentCar> {
  final user = FirebaseAuth.instance.currentUser;

  void handleBooking(Map<String, dynamic> carData, String carId) {
    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingFinalizeScreen(carData: carData, carId: carId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Rent A Car"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cars').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No cars available for rent"));
          }

          final cars = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: cars.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              var car = cars[index].data() as Map<String, dynamic>;
              String carId = cars[index].id;
              return carCard(car, carId);
            },
          );
        },
      ),
    );
  }

  Widget carCard(Map<String, dynamic> car, String carId) {
    bool isMyCar = user != null && car['ownerId'] == user!.uid;
    bool isBooked = car['isBooked'] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  car['imageUrl'] != null && car['imageUrl'].startsWith('http')
                      ? Image.network(car['imageUrl'], fit: BoxFit.cover, width: double.infinity)
                      : Image.asset("assets/img/img.png", fit: BoxFit.cover, width: double.infinity),
                  if (isBooked)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Text(
                          "NOT AVAILABLE",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car['name'] ?? 'Unknown Car',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  car['model'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  "PKR ${car['price']}/day",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (isBooked || isMyCar) ? Colors.grey : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 2),
                    ),
                    onPressed: (isBooked || isMyCar)
                        ? () {
                            String msg = isBooked ? "This car is already booked" : "You cannot book your own car";
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                          }
                        : () => handleBooking(car, carId),
                    child: Text(isMyCar ? "My Car" : "Book"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingFinalizeScreen extends StatefulWidget {
  final Map<String, dynamic> carData;
  final String carId;
  const BookingFinalizeScreen({super.key, required this.carData, required this.carId});

  @override
  State<BookingFinalizeScreen> createState() => _BookingFinalizeScreenState();
}

class _BookingFinalizeScreenState extends State<BookingFinalizeScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void finalizeBooking() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date and time")),
      );
      return;
    }

    setState(() => isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    try {
      // 1. Create the booking record
      await FirebaseFirestore.instance.collection('bookings').add({
        'carId': widget.carId,
        'carName': widget.carData['name'],
        'carModel': widget.carData['model'],
        'price': widget.carData['price'],
        'userId': user!.uid,
        'bookingDate': Timestamp.fromDate(selectedDate!),
        'bookingTime': "${selectedTime!.hour}:${selectedTime!.minute}",
        'status': 'Booked',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Update the car's availability status
      await FirebaseFirestore.instance.collection('cars').doc(widget.carId).update({
        'isBooked': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking Successful!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finalize Booking"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Booking for: ${widget.carData['name']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Model: ${widget.carData['model']}"),
            Text("Price: PKR ${widget.carData['price']}/day"),
            const SizedBox(height: 30),
            ListTile(
              title: Text(selectedDate == null
                  ? "Select Date"
                  : "Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
              shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
            ),
            const SizedBox(height: 15),
            ListTile(
              title: Text(selectedTime == null
                  ? "Select Time"
                  : "Time: ${selectedTime!.format(context)}"),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
              shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : finalizeBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.all(15),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Confirm Booking"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
