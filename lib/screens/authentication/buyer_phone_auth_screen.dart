import 'package:farmzo/screens/buyer_dashboard/buyer_details_screen.dart';
import 'package:farmzo/screens/buyer_dashboard/buyer_screens_main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuyerPhoneAuthScreen extends StatefulWidget {
  const BuyerPhoneAuthScreen({super.key});

  @override
  _BuyerPhoneAuthScreenState createState() => _BuyerPhoneAuthScreenState();
}

class _BuyerPhoneAuthScreenState extends State<BuyerPhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _verificationId = "";
  bool _isOtpSent = false;
  bool _isLoading = false;
  final String _countryCode = "+91";

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

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "$_countryCode$phoneNumber",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _handleLoginSuccess();
        },
        verificationFailed: (FirebaseAuthException e) {
          _handleLoginFailure();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Verification failed: ${e.message}")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP sent to your phone number.")),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _handleLoginFailure();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send OTP: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
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

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      _handleLoginSuccess();
    } catch (e) {
      _handleLoginFailure();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLoginSuccess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userRole', 'buyer');

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final buyerDetailsSnapshot = await FirebaseFirestore.instance
          .collection('buyers')
          .doc(user.phoneNumber)
          .get();

      setState(() => _isLoading = true);

      if (buyerDetailsSnapshot.exists) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BuyerHomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BuyerDetailsScreen()),
        );
      }
    }
  }

  Future<void> _handleLoginFailure() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Buyer Phone Authentication",
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
                const SizedBox(height: 50),
                Center(
                  child: Text(
                    "Phone Authentication",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isOtpSent ? "Verify OTP" : "Send OTP"),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
