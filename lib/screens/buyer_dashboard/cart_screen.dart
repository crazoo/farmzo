import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  final Map<String, int> cart;
  final Map<String, dynamic> producePrices;

  const CartScreen(
      {super.key, required this.cart, required this.producePrices});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isPlacingOrder = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadCartFromPreferences();
  }

  Future<void> _loadCartFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartJson = prefs.getString("cart");
    if (cartJson != null) {
      Map<String, dynamic> cartMap = jsonDecode(cartJson);
      setState(() {
        widget.cart.clear();
        cartMap.forEach((key, value) {
          widget.cart[key] = (value as num).toInt();
        });
      });
    }
    _initializeControllers();
  }

  void _initializeControllers() {
    for (var entry in widget.cart.entries) {
      _controllers[entry.key] =
          TextEditingController(text: entry.value.toString());
    }
  }

  Future<void> _saveCartToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("cart", jsonEncode(widget.cart));
  }

  void _updateQuantity(String produce, int newQuantity) {
    setState(() {
      widget.cart[produce] = newQuantity;
      _controllers[produce]?.text = newQuantity.toString();
    });
    _saveCartToPreferences();
  }

  Future<void> _placeOrder() async {
    if (widget.cart.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Your cart is empty!")));
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      DocumentSnapshot userDoc =
          await _firestore.collection('buyers').doc(user.phoneNumber).get();
      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User details not found.")));
        return;
      }

      String state = userDoc['state'] ?? "";
      String district = userDoc['district'] ?? "";
      String mobileNumber = user.phoneNumber ?? "";
      String addressLine1 = userDoc['addressLine1'] ?? "";
      String addressLine2 = userDoc['addressLine2'] ?? "";

      if (state.isEmpty || district.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("State and district not found.")));
        return;
      }

      String orderedDate = DateTime.now().toIso8601String().split("T")[0];

      Map<String, dynamic> orderedProduces = {};
      widget.cart.forEach((key, value) {
        orderedProduces[key] = {
          "quantity": value,
          "price_per_kg": widget.producePrices[key]?['max_price'] ?? 0.0
        };
      });

      double totalPrice = widget.cart.entries.fold(0.0, (sum, item) {
        double price = widget.producePrices[item.key]?['max_price'] ?? 0.0;
        return sum + (price * item.value);
      });

      // Storing order with auto-generated ID
      await _firestore
          .collection('orders')
          .doc(orderedDate)
          .collection("allOrders")
          .add({
        "orderedDate": orderedDate,
        "state": state,
        "district": district,
        "mobileNumber": mobileNumber,
        "orderedProduces": orderedProduces,
        "totalPrice": totalPrice,
        "address": {"line1": addressLine1, "line2": addressLine2},
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order placed successfully!")));

      setState(() {
        widget.cart.clear();
        _controllers.clear();
      });

      _saveCartToPreferences();

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error placing order: $e")));
    } finally {
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.cart.entries.fold(0.0, (sum, item) {
      double price = widget.producePrices[item.key]?['max_price'] ?? 0.0;
      return sum + (price * item.value);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Cart"),
      ),
      body: widget.cart.isEmpty
          ? const Center(child: Text("Your cart is empty."))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: widget.cart.entries.map((entry) {
                      double price =
                          widget.producePrices[entry.key]?['max_price'] ?? 0.0;
                      String imagePath = widget.producePrices[entry.key]
                              ?['image'] ??
                          "assets/images/default.png";
                      bool isZero = entry.value == 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        elevation: 5,
                        color: isZero ? Colors.grey.shade300 : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipOval(
                                child: Image.asset(imagePath,
                                    width: 50, height: 50, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.key,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: isZero
                                                ? Colors.grey
                                                : Colors.black)),
                                    const SizedBox(height: 5),
                                    Text("Price: ₹${price.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        "Total: ₹${(price * entry.value).toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () => _updateQuantity(
                                          entry.key, entry.value - 1)),
                                  SizedBox(
                                    width: 40,
                                    child: TextField(
                                      controller: _controllers[entry.key],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      onChanged: (value) {
                                        int newQty = int.tryParse(value) ?? 0;
                                        _updateQuantity(entry.key, newQty);
                                      },
                                    ),
                                  ),
                                  const Text("kg"),
                                  IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () => _updateQuantity(
                                          entry.key, entry.value + 1)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _isPlacingOrder ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50)),
                    child: _isPlacingOrder
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Place Order",
                            style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
    );
  }
}
