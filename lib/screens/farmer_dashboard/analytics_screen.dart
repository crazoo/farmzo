import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String userPhoneNumber = FirebaseAuth.instance.currentUser?.phoneNumber ?? "";
  DateTime selectedDate = DateTime.now();

  // Defaults that will be updated after fetching
  String state = "";
  String district = "";
  String market = "";

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  /// Fetches the user's saved state, district, and market from Firestore
  Future<void> _fetchUserLocation() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection("farmers")
          .doc(userPhoneNumber)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data();
        setState(() {
          state = userData?["state"] ?? "Tamil Nadu"; // Fallback if empty
          district =
              userData?["district"] ?? "Krishnagiri"; // Fallback if empty
          market = userData?["market"] ??
              "Hosur(Uzhavar Sandhai )"; // Fallback if empty
        });
      } else {
        if (mounted) {
          setState(() {
            state = "Tamil Nadu"; // Default fallback
            district = "Krishnagiri";
            market = "Hosur(Uzhavar Sandhai )";
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching user location: $e");
      if (mounted) {
        setState(() {
          state = "Karnataka"; // Fallback in case of error
          district = "Bangalore";
          market = "KR Market";
        });
      }
    }
  }

  /// Fetches sales data for the selected date
  Future<List<Map<String, dynamic>>> _fetchFarmerSales(String date) async {
    if (state.isEmpty || district.isEmpty || market.isEmpty) {
      return []; // Avoid fetching if data is missing
    }

    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await FirebaseFirestore.instance
              .collection("sells")
              .doc(date)
              .collection(state)
              .doc(district)
              .collection(market)
              .doc(userPhoneNumber)
              .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        Map<String, dynamic> salesData = docSnapshot.data()!;
        List<Map<String, dynamic>> salesList = [];
        int grandTotal = 0;

        if (salesData.containsKey("items")) {
          Map<String, dynamic> itemsData = salesData["items"];
          itemsData.forEach((produceName, details) {
            if (details is Map<String, dynamic>) {
              int quantity = (details["quantity"] as num).toInt();
              int price = (details["price"] as num).toInt();
              int totalPrice = quantity * price;

              grandTotal += totalPrice;

              salesList.add({
                "name": produceName,
                "quantity": quantity,
                "price": price,
                "totalPrice": totalPrice,
              });
            }
          });
        }

        salesList.add({
          "isTotalRow": true,
          "totalPrice": grandTotal,
          "address": salesData["address"] ?? "Unknown Address",
        });

        return salesList;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("❌ Firestore Error: $e");
      return [];
    }
  }

  /// Opens Date Picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      if (mounted) {
        setState(() {
          selectedDate = picked;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Analytics",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.black),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: state.isEmpty || district.isEmpty || market.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchFarmerSales(formattedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text("❌ Error: ${snapshot.error}",
                          style: const TextStyle(color: Colors.red)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "📉 No sales data available for today.",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                List<Map<String, dynamic>> sales = snapshot.data!;

                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    // 📍 Address Section
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      color: Colors.blue.shade50,
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "📍 Address Details",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text("🌍 State: $state",
                                style: const TextStyle(fontSize: 16)),
                            Text("🏛️ District: $district",
                                style: const TextStyle(fontSize: 16)),
                            Text("🏪 Market: $market",
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),

                    // 📊 Sales Data List
                    ...sales.map((sale) {
                      if (sale.containsKey("isTotalRow")) {
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: Colors.green.shade200,
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                "💰 Total Sales: ₹${sale["totalPrice"]}",
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                              ),
                            ),
                          ),
                        );
                      }

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "🛒 ${sale["name"]}",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Text("📦 Quantity: ${sale["quantity"]} kg",
                                  style: const TextStyle(fontSize: 16)),
                              Text("💸 Price: ₹${sale["price"]}/kg",
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 10),
                              Text(
                                "💰 Total: ₹${sale["totalPrice"]}",
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
    );
  }
}
