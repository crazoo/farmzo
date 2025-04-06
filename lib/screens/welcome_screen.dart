import 'package:farmzo/screens/farmer_dashboard/farmer_screens_main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmzo/screens/authentication/farmer_phone_auth_screen.dart';
import 'package:farmzo/screens/authentication/buyer_phone_auth_screen.dart';
import 'package:farmzo/screens/buyer_dashboard/buyer_screens_main.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Check login status and navigate accordingly
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String userRole = prefs.getString('userRole') ?? '';

    if (isLoggedIn) {
      if (userRole == 'farmer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FarmerHomeScreen()),
        );
      } else if (userRole == 'buyer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BuyerHomeScreen()),
        );
      }
    }
  }

  // Save user role and navigate
  Future<void> _saveUserRole(String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', role);
    await prefs.setBool('isLoggedIn', true);

    // Navigate to the respective authentication screen
    if (role == 'farmer') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FarmerPhoneAuthScreen()),
      );
    } else if (role == 'buyer') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BuyerPhoneAuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Farmzo🍃",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[500],
        elevation: 5,
      ),
      body: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to Farmzo..!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                color: Colors.green[900],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Connecting farmers and buyers for a sustainable future.",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Roboto',
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Hero Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/farm_illustration.png', // Replace with an agriculture-themed illustration
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),

                  // Farmer Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _saveUserRole('farmer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "I am a Farmer 🚜",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Buyer Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _saveUserRole('buyer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "I am a Buyer 🛒",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Let's grow together 🌱",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                      color: Colors.grey[700],
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
