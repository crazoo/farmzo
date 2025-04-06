import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print("❌ User not logged in.");
        return;
      }

      String mobileNumber = user.phoneNumber ?? "";
      print("🔍 Fetching orders for mobile: $mobileNumber");

      List<Map<String, dynamic>> userOrders = [];

      // Fetch all orders for the user on the selected date
      QuerySnapshot orderSnapshots = await _firestore
          .collection('orders')
          .doc(_selectedDate) // Selected date
          .collection('allOrders') // Generic subcollection
          .where('mobileNumber',
              isEqualTo: mobileNumber) // Filter by mobile number
          .get();

      for (var doc in orderSnapshots.docs) {
        Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;

        userOrders.add({
          "id": doc.id,
          "orderedDate": orderData["orderedDate"],
          "state": orderData["state"],
          "district": orderData["district"],
          "market": orderData["market"],
          "mobileNumber": orderData["mobileNumber"],
          "orderedProduces": orderData["orderedProduces"] ?? {},
          "totalPrice": orderData["totalPrice"] ?? 0,
          "address": orderData["address"] ?? {},
        });

        print("✅ Order found: ${doc.id}");
      }

      setState(() {
        _orders = userOrders;
        _isLoading = false;
      });

      if (_orders.isEmpty) {
        print("❌ No orders found for mobile: $mobileNumber.");
      } else {
        print("📦 Fetched Orders: $_orders");
      }
    } catch (e, stackTrace) {
      print("⚠️ Error fetching orders: $e");
      print(stackTrace);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_selectedDate),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked.toLocal() != DateTime.parse(_selectedDate)) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
        _isLoading = true; // Show loading indicator while fetching
      });
      await _fetchOrders(); // Fetch orders for the selected date
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No orders found.'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final orderedProduces =
                        order['orderedProduces'] as Map<String, dynamic>? ?? {};
                    final totalPrice = (order['totalPrice'] ?? 0).toDouble();
                    final address =
                        order['address'] as Map<String, dynamic>? ?? {};
                    final addressLine1 = address['line1'] ?? '';
                    final addressLine2 = address['line2'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '📅 Order Date: ${order['orderedDate']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Divider(color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            const Text(
                              '🏠 Delivery Address:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '📍 $addressLine1, $addressLine2',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '🏙️ District: ${order['district']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              '🏛️ State: ${order['state']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '🍏 Ordered Items:',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            for (var produce in orderedProduces.keys)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, bottom: 2),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        size: 16, color: Colors.green),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$produce: ${orderedProduces[produce]['quantity']} kg',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 8),
                            Divider(color: Colors.grey[300]),
                            const SizedBox(height: 8),
                            Text(
                              '💰 Total Price: ₹${totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
