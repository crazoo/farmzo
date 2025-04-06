import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  _BuyerHomeScreenState createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const OrdersScreen(),
    const OffersScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Offers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Home Screen for Buyers (Fetches products from Firestore)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String district = "";
  String state = "";
  List<Map<String, dynamic>> recentSells = [];

  @override
  void initState() {
    super.initState();
    _fetchUserLocation().then((_) => _fetchRecentSells());
  }

  /// Fetch buyer's district and state from Firestore
  Future<void> _fetchUserLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('buyers')
          .doc(user.phoneNumber)
          .get();

      if (doc.exists) {
        setState(() {
          district = doc['district'] ?? "";
          state = doc['state'] ?? "";
        });
      }
    }
  }

  /// Fetch recent sells from Firestore
  Future<void> _fetchRecentSells() async {
    if (state.isEmpty || district.isEmpty) {
      print("⚠️ State or District is empty, cannot fetch sells.");
      return;
    }

    String todayDate = DateTime.now().toIso8601String().split('T')[0];

    try {
      final docRef = FirebaseFirestore.instance
          .collection('sells')
          .doc(todayDate)
          .collection(state)
          .doc(district);

      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        print("🔥 No sells found for date: $todayDate");
        return;
      }

      Map<String, dynamic> districtData =
          docSnapshot.data() as Map<String, dynamic>;

      if (districtData.isEmpty) {
        print("🔥 No data for district: $district");
        return;
      }

      // Fetch available markets
      List<String> marketKeys = districtData.keys.toList();
      if (marketKeys.isEmpty) {
        print("🔥 No markets found in district: $district");
        return;
      }

      // Select a random or first market
      String selectedMarket = marketKeys[Random().nextInt(marketKeys.length)];

      final marketSnapshot = await docRef.collection(selectedMarket).get();

      if (marketSnapshot.docs.isEmpty) {
        print("🔥 No farmers found in market: $selectedMarket");
        return;
      }

      List<Map<String, dynamic>> tempSells = [];

      for (var farmerDoc in marketSnapshot.docs) {
        String farmerId = farmerDoc.id;
        Map<String, dynamic> farmerProducts = farmerDoc.data();

        for (var productName in farmerProducts.keys) {
          var productDetails = farmerProducts[productName];

          tempSells.add({
            "farmer": farmerId,
            "product": productDetails['name'],
            "image": productDetails['image'],
            "price": productDetails['price'],
            "quantity": productDetails['quantity'],
            "market": selectedMarket,
          });
        }
      }

      setState(() {
        recentSells = tempSells;
      });

      print("✅ Successfully fetched ${recentSells.length} sells.");
    } catch (e) {
      print("🚨 Error fetching sells: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Recent Sells in $district, $state"),
      ),
      body: recentSells.isEmpty
          ? const Center(child: Text("No recent sells available."))
          : ListView.builder(
              itemCount: recentSells.length,
              itemBuilder: (context, index) {
                final sell = recentSells[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading:
                        Image.network(sell['image'], width: 50, height: 50),
                    title: Text(sell['product'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Price: ₹${sell['price']} per kg"),
                        Text("Quantity: ${sell['quantity']} kg"),
                        Text("Market: ${sell['market']}"),
                        Text("Farmer: ${sell['farmer']}"),
                      ],
                    ),
                    trailing:
                        const Icon(Icons.agriculture, color: Colors.green),
                  ),
                );
              },
            ),
    );
  }
}

/// Product Detail Screen
class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(product['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(product['image'], height: 200),
            const SizedBox(height: 20),
            Text(product['name'],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Price: ₹${product['price']} per kg",
                style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement the buying process
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Buy Now"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Orders Screen
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Your Orders'));
  }
}

/// Offers Screen
class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Exclusive Offers'));
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic> buyerData = {};
  bool isLoading = true;
  bool isEditingStateDistrict = false;
  bool isEditingTotal = false;
  TextEditingController stateController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController totalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBuyerData();
  }

  Future<void> _fetchBuyerData() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('buyers').doc(user.phoneNumber).get();
      setState(() {
        buyerData = doc.exists ? doc.data() as Map<String, dynamic> : {};
        isLoading = false;

        // Initialize controllers with existing data
        stateController.text = buyerData['state'] ?? '';
        districtController.text = buyerData['district'] ?? '';
        totalController.text = buyerData['total']?.toString() ?? '0';
      });
    }
  }

  Future<void> _updateBuyerData(String field, String value) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('buyers').doc(user.phoneNumber).update({
        field: value,
      });
      setState(() {
        buyerData[field] = value;
      });
    }
  }

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear stored preferences
    await _auth.signOut(); // Sign out from Firebase Auth

    if (mounted) {
      Navigator.pushReplacementNamed(
          context, '/welcome'); // Adjust route as needed
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
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileField("Full Name", buyerData['name']),
                      _buildProfileField("Phone", buyerData['phone']),
                      _buildProfileField("Email", buyerData['email']),
                      _buildEditableField("State", stateController, "state"),
                      _buildEditableField(
                          "District", districtController, "district"),
                      _buildProfileField(
                          "Address Line 1", buyerData['addressLine1']),
                      _buildProfileField(
                          "Address Line 2", buyerData['addressLine2']),
                      _buildProfileField("Pincode", buyerData['pincode']),
                      _buildProfileField(
                          "Business Type", buyerData['businessType']),
                      _buildProfileField(
                          "Buying Items", buyerData['buyingItems']),
                      _buildProfileField(
                          "GST Number", buyerData['gstNumber'] ?? "N/A"),
                      _buildToggleEditableField("Total", totalController),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey)),
          const SizedBox(height: 5),
          Text(value ?? 'N/A',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const Divider(thickness: 1),
        ],
      ),
    );
  }

  Widget _buildEditableField(
      String label, TextEditingController controller, String field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey)),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.save, color: Colors.green),
                onPressed: () {
                  _updateBuyerData(field, controller.text);
                },
              ),
            ],
          ),
          const Divider(thickness: 1),
        ],
      ),
    );
  }

  Widget _buildToggleEditableField(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey)),
              Switch(
                value: isEditingTotal,
                onChanged: (value) {
                  setState(() {
                    isEditingTotal = value;
                  });
                  if (!value) {
                    _updateBuyerData("total", controller.text);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 5),
          isEditingTotal
              ? TextField(
                  controller: controller,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                )
              : Text(
                  controller.text,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
          const Divider(thickness: 1),
        ],
      ),
    );
  }
}
