import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmzo/screens/farmer_dashboard/analytics_screen.dart';
import 'package:farmzo/screens/farmer_dashboard/farmer_profile_screen.dart';
import 'package:farmzo/screens/farmer_dashboard/market_prices_screen.dart';
import 'package:farmzo/screens/farmer_dashboard/offers_screen.dart';
import 'package:farmzo/screens/farmer_dashboard/produce_selling_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _name = "";
  String _phone = "";
  String _address = "";

  @override
  void initState() {
    super.initState();
    _fetchFarmerDetails();
  }

  Future<void> _fetchFarmerDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc =
            await _firestore.collection('farmers').doc(user.phoneNumber).get();

        if (doc.exists) {
          setState(() {
            _name = doc['name'] ?? "Not Available";
            _phone = doc['phone'] ?? "Not Available";
            _address =
                "${doc['addressLine1'] ?? ''}, ${doc['addressLine2'] ?? ''}, ${doc['pincode'] ?? ''}";
          });
        }
      } catch (e) {
        print("Error fetching farmer details: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 200, // Increase height as needed
            child: UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              accountName: Transform.translate(
                offset: const Offset(0, 6),
                child: Text(
                  _name,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500), // Increase font size
                ),
              ),
              accountEmail: Text(
                _phone,
                style: const TextStyle(fontSize: 15), // Increase font size
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 40, // Increase profile image size
                child: Icon(Icons.person,
                    size: 50, color: Colors.green), // Larger icon
              ),
            ),
          ),
          _createDrawerItem(
            icon: Icons.home,
            text: "Home",
            onTap: () {
              Navigator.pop(context); // Just closes the drawer
            },
          ),
          _createDrawerItem(
            icon: Icons.store,
            text: "Market Prices",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MarketPricesScreen()),
              );
            },
          ),
          _createDrawerItem(
            icon: Icons.add_shopping_cart,
            text: "Sell Produce",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProduceSellingScreen(
                          state: '',
                          market: '',
                          district: '',
                          selectedItems: [],
                        )),
              );
            },
          ),
          _createDrawerItem(
            icon: Icons.bar_chart,
            text: "View Sales",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
              );
            },
          ),
          _createDrawerItem(
            icon: Icons.card_giftcard,
            text: "Government Schemes",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OffersScreen()),
              );
            },
          ),
          _createDrawerItem(
            icon: Icons.account_circle,
            text: "Profile",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FarmerProfileScreen()),
              );
            },
          ),
          const Divider(),
          _createDrawerItem(
            icon: Icons.exit_to_app,
            text: "Logout",
            iconColor: Colors.red,
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color iconColor = Colors.green,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(text),
      onTap: onTap,
    );
  }

  void _handleLogout(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear locally stored user data
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase Auth

      if (context.mounted) {
        Navigator.of(context)
            .pushReplacementNamed('/welcome'); // Redirect to Welcome screen
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log out.')),
      );
    }
  }
}
