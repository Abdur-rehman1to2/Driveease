import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:semester_project/screens/user/listed_car.dart';
import 'package:semester_project/screens/user/list_car.dart';
import 'package:semester_project/screens/auth/login_screen.dart';
import 'package:semester_project/screens/user/profile_screen.dart';
import 'package:semester_project/screens/user/rent_car.dart';
import 'package:semester_project/services/booking.dart';
import 'package:semester_project/screens/auth/signup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  Widget _featureItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.teal),
        const SizedBox(height: 5),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.black,
        title: const Center(
          child: Text(
            "Drive Ease",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.lightBlue,
              fontSize: 35,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: const Row(
              children: [
                Icon(Icons.location_on, size: 20),
                SizedBox(width: 4),
                Text("Lahore"),
                SizedBox(width: 8),
              ],
            ),
          )
        ],
      ),
      body: ListView(children: [
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search Cars",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ready For Your Next Ride?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Turn Your Unused Car \n--------into a \nSource Of Income",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                )),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              if (user == null) ...[
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpView()));
                    },
                    child: const Text(
                      'GET STARTED',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    child: const Text(
                      "Already have an account? LOGIN",
                      style: TextStyle(color: Colors.lightBlue),
                    )),
              ],
              const SizedBox(height: 10),
              const Divider(thickness: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _featureItem(Icons.directions_car, "Wide Range"),
                  _featureItem(Icons.vpn_key, "Easy Book"),
                  _featureItem(Icons.gps_fixed_outlined, "GPS Track"),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _featureItem(Icons.star_border, "Top rated"),
                  _featureItem(Icons.security, "Insured"),
                  _featureItem(Icons.attach_money, "Best Price"),
                ],
              ),
              const SizedBox(height: 10),
              _buildInfoBox(),
            ],
          ),
        ),
      ]),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream: user != null
                        ? FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots()
                        : const Stream.empty(),
                    builder: (context, snapshot) {
                      String name = "Guest User";
                      String email = "Please login";
                      String? photoUrl;

                      if (snapshot.hasData && snapshot.data!.exists) {
                        var data = snapshot.data!.data() as Map<String, dynamic>;
                        name = data['name'] ?? "No Name";
                        email = data['email'] ?? "";
                        photoUrl = data['photoUrl'];
                      } else if (user != null) {
                        name = user!.displayName ?? "User";
                        email = user!.email ?? "";
                        photoUrl = user!.photoURL;
                      }

                      return UserAccountsDrawerHeader(
                        accountName: Text(name),
                        accountEmail: Text(email),
                        currentAccountPicture: CircleAvatar(
                          backgroundColor: Colors.lightBlue,
                          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                          child: (photoUrl == null || photoUrl.isEmpty) ? const Icon(Icons.person, color: Colors.white) : null,
                        ),
                        decoration: const BoxDecoration(color: Colors.black),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text("Home"),
                    leading: const Icon(Icons.home, color: Colors.black),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text("Profile"),
                    leading: const Icon(Icons.person, color: Colors.black),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                    },
                  ),
                  ListTile(
                    title: const Text("Rent A Car"),
                    leading: const Icon(Icons.car_rental, color: Colors.black),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RentCar()));
                    },
                  ),
                  ListTile(
                    title: const Text("List your own Car"),
                    leading: const Icon(Icons.sell, color: Colors.black),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCar()));
                    },
                  ),
                  ListTile(
                    title: const Text("My Bookings"),
                    leading: const Icon(Icons.book_online, color: Colors.black),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Booking()));
                    },
                  ),
                  ListTile(
                    title: const Text("My Listed Cars"),
                    leading: const Icon(Icons.garage, color: Colors.black),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ListedCar()));
                    },
                  ),
                ],
              ),
            ),
            if (user != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: ListTile(
                  title: const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  leading: const Icon(Icons.logout, color: Colors.red),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Why Drive Ease?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Reliable Vehicles. Simple booking. Every time.', style: TextStyle(fontSize: 12, color: Colors.lightBlue.shade600)),
          const Divider(height: 20),
          _infoRow('Verified vehicles', '100% background checked'),
          _infoRow('Driver rating', '4.8 / 5 average'),
          _infoRow('GPS Tracking', 'Insured '),
          _infoRow('Support', '24/7 in-app help'),
          _infoRow('Booking', 'Book in under 1 minute'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
