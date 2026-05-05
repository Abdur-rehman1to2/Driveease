import 'dart:async';
import 'package:flutter/material.dart';
import 'package:semester_project/screens/user/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Adds some breathing room
          child: Image.asset(
            "assets/img/Finalsp.png",
            fit: BoxFit.contain, // Ensures the image is fully visible and fits the screen
          ),
        ),
      ),
    );
  }
}
