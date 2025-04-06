import 'package:farmzo/screens/farmer_dashboard/farmer_profile_screen.dart';
import 'package:flutter/material.dart';

import 'analytics_screen.dart';
import 'farmer_home_screen.dart';
import 'market_prices_screen.dart';
import 'offers_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  _FarmerHomeScreenState createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MarketPricesScreen(),
    const AnalyticsScreen(),
    const OffersScreen(),
    const FarmerProfileScreen(),
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
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 0 ? Icons.home : Icons.home_outlined,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 1
                  ? Icons.trending_up_outlined
                  : Icons.trending_up_rounded,
            ),
            label: 'Market live',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 2 ? Icons.history : Icons.history,
            ),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 3
                  ? Icons.local_offer_rounded
                  : Icons.local_offer_outlined,
            ),
            label: 'Schemes',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 4 ? Icons.person : Icons.person_outline,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// A simple details screen to show fruit/vegetable details
class DetailScreen extends StatelessWidget {
  final Map<String, String> item;

  const DetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(item['name']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(item['image']!, height: 200),
            const SizedBox(height: 20),
            Text(
              item['name']!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Detailed information about ${item['name']} can go here.',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
