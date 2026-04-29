import 'package:flutter/material.dart';
import 'package:semester_project/screens/auth/login_screen.dart';
import 'package:semester_project/screens/auth/signup_screen.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 30),
            Image.asset(
              "assets/img/Rent a car.png",
              width: 100,
              height: 50,
            ),
            // 🔹 Top Section (Heading + Image)
            Column(
              children: [
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(
                    "Experiencing  Good Feelings From Our \nLuxury Cars At Low Prices ",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Image.asset(
                  "assets/img/home1.png",
                  width: 1030,
                  height: 580,
                ),
              ],
            ),

            // 🔹 Bottom Section (Text + Buttons)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  Text(
                    "Do you already have an account?",
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 15),

                  // 🔹 Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                       Navigator.push(context,
                           MaterialPageRoute(
                               builder: (context) =>LoginScreen()));
                      },
                      child: Text("Already have an Account"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔹 Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                       Navigator.push(context,
                           MaterialPageRoute(
                               builder: (context)=> SignUpView()));
                      },
                      child: Text("Create new account ",selectionColor: Colors.grey,),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}