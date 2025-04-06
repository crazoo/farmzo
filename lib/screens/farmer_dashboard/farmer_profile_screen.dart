import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  _FarmerProfileScreenState createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? farmerData;
  bool isLoading = true;
  bool isEditing = false; // Toggle edit mode

  TextEditingController districtController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController marketController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFarmerData();
  }

  Future<void> _fetchFarmerData() async {
    final user = _auth.currentUser;

    if (user != null && user.phoneNumber != null) {
      try {
        DocumentSnapshot doc =
            await _firestore.collection('farmers').doc(user.phoneNumber).get();

        if (doc.exists) {
          if (mounted) {
            setState(() {
              farmerData = doc.data() as Map<String, dynamic>;
              isLoading = false;

              // Initialize controllers with existing data
              districtController.text = farmerData!['district'] ?? '';
              stateController.text = farmerData!['state'] ?? '';
              marketController.text = farmerData!['market'] ?? '';
            });
          }
        } else {
          if (mounted) {
            setState(() => isLoading = false);
            Future.delayed(Duration.zero, () {
              _showSnackBar('No farmer details found.');
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
          Future.delayed(Duration.zero, () {
            _showSnackBar('Error fetching farmer details.');
          });
        }
      }
    } else {
      if (mounted) {
        setState(() => isLoading = false);
        Future.delayed(Duration.zero, () {
          _showSnackBar('User is not authenticated.');
        });
      }
    }
  }

  /// Updates Firestore with new district, state, and market
  Future<void> _updateFarmerData() async {
    String userId = _auth.currentUser?.phoneNumber ?? "";
    try {
      await _firestore.collection('farmers').doc(userId).update({
        "district": districtController.text,
        "state": stateController.text,
        "market": marketController.text,
      });

      if (mounted) {
        setState(() {
          farmerData!['district'] = districtController.text;
          farmerData!['state'] = stateController.text;
          farmerData!['market'] = marketController.text;
          isEditing = false; // Exit edit mode
        });
      }

      _showSnackBar("Profile updated successfully!");
    } catch (e) {
      _showSnackBar("Failed to update profile.");
    }
  }

  /// Toggles edit mode
  void _toggleEditMode() {
    if (mounted) {
      setState(() => isEditing = !isEditing);
    }
  }

  Future<void> _logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear locally stored user data
      await _auth.signOut(); // Sign out from Firebase Auth

      if (mounted) {
        Navigator.of(context)
            .pushReplacementNamed('/welcome'); // Redirect to Welcome screen
      }
    } catch (e) {
      _showSnackBar('Failed to log out.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon:
                Icon(isEditing ? Icons.check : Icons.edit, color: Colors.white),
            onPressed: isEditing ? _updateFarmerData : _toggleEditMode,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.blue,
                ))
              : farmerData != null
                  ? _buildProfileContent()
                  : _buildNoDataContent(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF1B5E20)], // Green gradient
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 100), // Space for AppBar
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26, blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: Colors.green),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmerData!['name'] ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    farmerData!['phone'] ?? 'No Phone',
                    style: const TextStyle(fontSize: 15, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildNoDataContent() {
    return const Center(
      child: Text(
        'No details available for this farmer. Please login again',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            _buildInfoTile(Icons.credit_card, 'Aadhar Number',
                farmerData!['aadharNumber'] ?? 'N/A'),
            _buildEditableInfoTile(
                Icons.store_outlined, 'Nearby Market', marketController),
            _buildInfoTile(Icons.location_on, 'Address',
                "${farmerData!['addressLine1'] ?? 'N/A'}, ${farmerData!['addressLine2'] ?? ''}"),
            _buildEditableInfoTile(
                Icons.location_city, 'District', districtController),
            _buildEditableInfoTile(
                Icons.location_city, 'State', stateController),
            _buildInfoTile(
                Icons.pin_drop, 'Pincode', farmerData!['pincode'] ?? 'N/A'),
            _buildInfoTile(Icons.landscape, 'Farm Size',
                "${farmerData!['farmSize'] ?? 'N/A'} acres"),
            _buildInfoTile(Icons.agriculture, 'Crop Type',
                farmerData!['cropType'] ?? 'N/A'),
            _buildInfoTile(Icons.water, 'Irrigation Method',
                farmerData!['irrigationMethod'] ?? 'N/A'),
            _buildInfoTile(Icons.build, 'Machinery Details',
                farmerData!['machineryDetails'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  /// Non-editable information tile
  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green.shade700, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    )),
                Text(value,
                    style:
                        const TextStyle(fontSize: 16, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Editable text field for district, state, and market
  Widget _buildEditableInfoTile(
      IconData icon, String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green.shade700, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    )),
                isEditing
                    ? TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        ),
                      )
                    : Text(controller.text,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
