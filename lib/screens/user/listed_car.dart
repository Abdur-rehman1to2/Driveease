import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ListedCar extends StatefulWidget {
  const ListedCar({super.key});

  @override
  State<ListedCar> createState() => _ListedCarState();
}

class _ListedCarState extends State<ListedCar> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("My Listed Cars"),
        ),
        body: const Center(child: Text("Please login to see your listed cars")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("My Listed Cars"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cars')
            .where('ownerId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading listed cars"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("You haven't listed any cars yet."));
          }

          final cars = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: cars.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, 
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.55, // Taller cards to accommodate full images and details
            ),
            itemBuilder: (context, index) {
              var car = cars[index].data() as Map<String, dynamic>;
              String carId = cars[index].id;
              String imageUrl = car['imageUrl'] ?? "";
              bool isBooked = car['isBooked'] ?? false;

              return Card(
                elevation: isBooked ? 0 : 4,
                color: isBooked ? Colors.grey[200] : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IMAGE SECTION
                    Expanded(
                      flex: 4,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isBooked ? Colors.grey[300] : Colors.grey[100],
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (imageUrl.isNotEmpty)
                              Opacity(
                                opacity: isBooked ? 0.5 : 1.0,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.contain, // Shows full image without cutting
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(child: Icon(Icons.broken_image, size: 24)),
                                ),
                              )
                            else
                              const Center(child: Icon(Icons.directions_car, size: 24, color: Colors.grey)),
                            if (isBooked)
                              Center(
                                child: RotationTransition(
                                  turns: const AlwaysStoppedAnimation(-15 / 360),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "BOOKED",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // DETAILS SECTION
                    Expanded(
                      flex: 5,
                      child: Opacity(
                        opacity: isBooked ? 0.6 : 1.0,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                car['name'] ?? "Unknown Car",
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                "Model: ${car['model']}",
                                style: TextStyle(color: Colors.grey[600], fontSize: 9),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                "PKR ${car['price']}/day",
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                              const Spacer(),
                              if (!isBooked)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.edit, color: Colors.blue, size: 16),
                                      onPressed: () => _showEditDialog(carId, car),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                                      onPressed: () => _showDeleteDialog(carId),
                                    ),
                                  ],
                                )
                              else
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "Locked",
                                    style: TextStyle(color: Colors.grey, fontSize: 8, fontStyle: FontStyle.italic),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(String carId, Map<String, dynamic> carData) {
    final nameController = TextEditingController(text: carData['name']);
    final modelController = TextEditingController(text: carData['model']);
    final priceController = TextEditingController(text: carData['price'].toString());
    final locationController = TextEditingController(text: carData['location']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Car Details"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Car Name")),
              TextField(controller: modelController, decoration: const InputDecoration(labelText: "Model")),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Price per Day"),
                keyboardType: TextInputType.number,
              ),
              TextField(controller: locationController, decoration: const InputDecoration(labelText: "Location")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('cars').doc(carId).update({
                'name': nameController.text.trim(),
                'model': modelController.text.trim(),
                'price': double.tryParse(priceController.text.trim()) ?? 0.0,
                'location': locationController.text.trim(),
              });
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String carId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Listing?"),
        content: const Text("Are you sure you want to remove this car from your listings?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('cars').doc(carId).delete();
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
