import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({super.key});

  @override
  _BuyerProfileScreenState createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> buyerData = {};
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController marketController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBuyerData();
  }

  /// Fetch Buyer Profile Data from Firestore
  Future<void> _fetchBuyerData() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('buyers').doc(user.phoneNumber).get();
      if (doc.exists) {
        if (mounted) {
          setState(() {
            buyerData = doc.data() as Map<String, dynamic>;
            isLoading = false;

            nameController.text = buyerData['name'] ?? '';
            phoneController.text = buyerData['phone'] ?? '';
            emailController.text = buyerData['email'] ?? '';
            addressController.text = buyerData['address'] ?? '';
            pincodeController.text = buyerData['pincode'] ?? '';
            stateController.text = buyerData['state'] ?? '';
            districtController.text = buyerData['district'] ?? '';
            marketController.text = buyerData['market'] ?? '';
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  /// Update Buyer Data in Firestore
  Future<void> _updateBuyerData(String field, String value) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('buyers').doc(user.phoneNumber).update({
        field: value,
      });
      if (mounted) {
        setState(() {
          buyerData[field] = value;
        });
      }
    }
  }

  /// Sign out user
  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _signOut,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditableField("Full Name", nameController, "name"),
                  _buildReadOnlyField("Phone", phoneController.text),
                  _buildEditableField("Email", emailController, "email"),
                  _buildEditableField("Address", addressController, "address"),
                  _buildEditableField("Pincode", pincodeController, "pincode"),
                  _buildEditableField("State", stateController, "state"),
                  _buildEditableField(
                      "District", districtController, "district"),
                  _buildEditableField("Market", marketController, "market"),
                  const SizedBox(height: 20),
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  /// Read-Only Field (Non-Editable)
  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const Divider(thickness: 1),
        ],
      ),
    );
  }

  /// Editable Text Field
  Widget _buildEditableField(
      String label, TextEditingController controller, String field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.save, color: Colors.green),
            onPressed: () {
              _updateBuyerData(field, controller.text);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$label updated successfully!")),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Save Button for All Edits
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save),
        label: const Text("Save Changes"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 18),
        ),
        onPressed: () {
          _updateBuyerData("name", nameController.text);
          _updateBuyerData("email", emailController.text);
          _updateBuyerData("address", addressController.text);
          _updateBuyerData("pincode", pincodeController.text);
          _updateBuyerData("state", stateController.text);
          _updateBuyerData("district", districtController.text);
          _updateBuyerData("market", marketController.text);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully!")),
          );
        },
      ),
    );
  }
}
