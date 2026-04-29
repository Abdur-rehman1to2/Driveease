import 'dart:async';
import 'package:flutter/material.dart';
import 'package:semester_project/screens/user/home.dart';
import 'package:semester_project/welcome_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (Context) => HomeScreen()
          ));
    });
  }


  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black
        ,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // 🔥 Image Logo
              Image.asset(
                "assets/img/Finalsp.png",
                // width: 200,
                // height: 200,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}