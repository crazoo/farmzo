import 'package:farmzo/screens/farmer_dashboard/farmer_screens_main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:farmzo/screens/farmer_dashboard/farmer_details_screen.dart';


class FarmerPhoneAuthScreen extends StatefulWidget {
  const FarmerPhoneAuthScreen({super.key});

  @override
  _FarmerPhoneAuthScreenState createState() => _FarmerPhoneAuthScreenState();
}

class _FarmerPhoneAuthScreenState extends State<FarmerPhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String _verificationId = "";
  bool _isOtpSent = false;
  final String _countryCode = "+91";
  bool _isLoading = false;

  Future<void> _sendOtp() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid phone number.")),
      );
      return;
    }

    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Phone Number"),
        content: Text(
            "Is this your correct phone number?\n$_countryCode $phoneNumber"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Edit"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (isConfirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "$_countryCode$phoneNumber",
        verificationCompleted: (PhoneAuthCredential credential) async {
          setState(() {
            _isLoading = false;
          });
          await FirebaseAuth.instance.signInWithCredential(credential);
          await _navigateWithLoadingIndicator();
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${e.message}")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP sent to your phone number.")),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send OTP: $e")),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the OTP.")),
      );
      return;
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Show loading indicator before navigating
      await _navigateWithLoadingIndicator();
    } catch (e) {
      // If authentication fails, clear shared preferences
      await _clearLoginState();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP. Please try again.")),
      );
    }
  }

  Future<void> _clearLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userRole');
  }

  Future<void> _navigateWithLoadingIndicator() async {
    setState(() {
      _isLoading = true;
    });

    await _navigateBasedOnFirstLogin();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _navigateBasedOnFirstLogin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseFirestore.instance
          .collection('farmers')
          .doc(user.phoneNumber);
      final docSnapshot = await userRef.get();

      if (docSnapshot.exists) {
        // Phone number found in database, navigate to FarmerHomeScreen
        await _saveLoginState('farmer'); // Save login state
        _navigateToHomePage();
      } else {
        // First time login, navigate to FarmerDetailsScreen
        await _saveFarmerData();
        await _saveLoginState('farmer'); // Save login state
        _navigateToDetailsScreen();
      }
    }
  }

  Future<void> _saveFarmerData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseFirestore.instance
          .collection('farmers')
          .doc(user.phoneNumber);
      await userRef.set({
        'phoneNumber': user.phoneNumber,
        'isVerified': true, // Mark the user as verified
      });
    }
  }

  Future<void> _saveLoginState(String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true); // Save login state
    await prefs.setString('userRole', role); // Save user role
  }

  void _navigateToHomePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const FarmerHomeScreen()),
    );
  }

  void _navigateToDetailsScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const FarmerDetailsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Farmer Phone Authentication",
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: const Color.fromARGB(255, 80, 163, 163),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back icon
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Title Section
                const SizedBox(height: 50),
                Center(
                  child: Text(
                    "Phone Authentication",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 79, 163, 163),
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Enter your phone number to receive an OTP.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Phone Number Input Section
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              "$_countryCode ",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: "Phone Number",
                            hintText: "Enter your phone number",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 12),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        if (_isOtpSent)
                          TextField(
                            controller: _otpController,
                            decoration: InputDecoration(
                              labelText: "Enter OTP",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 12),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Button Section
                ElevatedButton(
                  onPressed:
                      _isLoading ? null : (_isOtpSent ? _verifyOtp : _sendOtp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 25),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: Text(_isOtpSent ? "Verify OTP" : "Send OTP"),
                ),
              ],
            ),
          ),
          // Loading Indicator
          if (_isLoading)
            Center(
              child: Container(
                color: Colors.transparent,
                child: const CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
