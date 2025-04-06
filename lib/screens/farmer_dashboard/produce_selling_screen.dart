import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProduceSellingScreen extends StatefulWidget {
  final String state;
  final String district;
  final String market;

  const ProduceSellingScreen({
    Key? key,
    required this.state,
    required this.district,
    required this.market,
    required List selectedItems,
  }) : super(key: key);

  @override
  _ProduceSellingScreenState createState() => _ProduceSellingScreenState();
}

class _ProduceSellingScreenState extends State<ProduceSellingScreen> {
  Map<String, TextEditingController> quantityControllers = {};
  List<Map<String, dynamic>> sellingItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSellingItems();
  }

  /// Fetches today's selling items from Firestore based on state, district, and market
  Future<void> _fetchSellingItems() async {
    String userId = FirebaseAuth.instance.currentUser?.phoneNumber ?? "";
    String todayDate = DateTime.now().toIso8601String().split('T')[0];

    try {
      final docRef = FirebaseFirestore.instance
          .collection('sells')
          .doc(todayDate)
          .collection(widget.state)
          .doc(widget.district)
          .collection(widget.market)
          .doc(userId);

      final snapshot = await docRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> items = [];

        data.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            items.add(value);
            quantityControllers[key] = TextEditingController(
              text: value['quantity']?.toString() ?? "1", // Default to "1"
            );
          }
        });

        setState(() {
          sellingItems = items;
          isLoading = false;
        });
      } else {
        setState(() {
          sellingItems = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching selling items: $e");
      setState(() => isLoading = false);
    }
  }

  void _removeItem(String produceName) async {
    String userId = FirebaseAuth.instance.currentUser?.phoneNumber ?? "";
    String todayDate = DateTime.now().toIso8601String().split('T')[0];

    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('sells')
        .doc(todayDate)
        .collection(widget.state)
        .doc(widget.district)
        .collection(widget.market)
        .doc(userId);

    await userDocRef.update({produceName: FieldValue.delete()});

    DocumentSnapshot updatedDoc = await userDocRef.get();
    if (!updatedDoc.exists ||
        (updatedDoc.data() as Map<String, dynamic>).isEmpty) {
      await userDocRef.delete();
    }

    setState(() {
      sellingItems.removeWhere((item) => item['name'] == produceName);
      quantityControllers.remove(produceName);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produce removed successfully!")),
    );
  }

  void _showAddProduceDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController quantityController = TextEditingController(text: "1");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add Produce Manually",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Produce Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price per kg"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Quantity (kg)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _addProduceManually(
                    nameController.text.trim(),
                    double.tryParse(priceController.text) ?? 0.0,
                    double.tryParse(quantityController.text) ?? 1.0,
                  );
                  Navigator.pop(context);
                },
                child: const Text("Add Produce"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _addProduceManually(String name, double price, double quantity) {
    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid produce details")),
      );
      return;
    }

    String userId = FirebaseAuth.instance.currentUser?.phoneNumber ?? "";
    String todayDate = DateTime.now().toIso8601String().split('T')[0];

    Map<String, dynamic> newProduce = {
      "name": name,
      "price": price,
      "quantity": quantity,
    };

    FirebaseFirestore.instance
        .collection('sells')
        .doc(todayDate)
        .collection(widget.state)
        .doc(widget.district)
        .collection(widget.market)
        .doc(userId)
        .set({name: newProduce}, SetOptions(merge: true));

    setState(() {
      sellingItems.add(newProduce);
      quantityControllers[name] =
          TextEditingController(text: quantity.toString());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produce added successfully!")),
    );
  }

  /// Updates Firestore with the entered quantity
  Future<void> _updateSellingQuantity(
      String produceName, String quantity) async {
    String userId = FirebaseAuth.instance.currentUser?.phoneNumber ?? "";
    String todayDate = DateTime.now().toIso8601String().split('T')[0];

    await FirebaseFirestore.instance
        .collection('sells')
        .doc(todayDate)
        .collection(widget.state)
        .doc(widget.district)
        .collection(widget.market)
        .doc(userId)
        .set({
      produceName: {"quantity": quantity}
    }, SetOptions(merge: true)); // ✅ Merging to avoid data overwriting
  }

  /// Calculates the total amount for all items
  double _calculateTotalAmount() {
    double total = 0.0;
    for (var item in sellingItems) {
      double pricePerKg = item['price'] ?? 0.0;
      double quantity =
          double.tryParse(quantityControllers[item['name']]?.text ?? "0") ??
              0.0;
      total += pricePerKg * quantity;
    }
    return total;
  }

  /// Uploads all selling items to Firestore
  Future<void> _uploadSellingList() async {
    if (sellingItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No produce to sell! Add items first.")),
      );
      return;
    }

    String userId = FirebaseAuth.instance.currentUser?.phoneNumber ?? "";
    String todayDate = DateTime.now().toIso8601String().split('T')[0];

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch farmer profile
      DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('farmers')
          .doc(userId)
          .get();

      Map<String, dynamic> profileData =
          profileSnapshot.data() as Map<String, dynamic>? ?? {};

      String farmerName = profileData["name"] ?? "Unknown Farmer";
      String addressLine1 = profileData["addressLine1"] ?? "";
      String addressLine2 = profileData["addressLine2"] ?? "";
      String fullAddress = "$addressLine1, $addressLine2".trim();
      if (fullAddress.endsWith(",")) {
        fullAddress = fullAddress.substring(0, fullAddress.length - 1);
      }
      if (fullAddress.isEmpty) fullAddress = "Unknown Address";

      // Prepare data for Firestore
      Map<String, dynamic> itemsData = {};
      double totalPrice = 0.0;

      for (var item in sellingItems) {
        String produceName = item['name'] ?? "Unknown";
        double price = item['price'] ?? 0.0;
        int quantity =
            int.tryParse(quantityControllers[produceName]?.text ?? "1") ?? 1;

        itemsData[produceName] = {
          "quantity": quantity,
          "price": price,
        };

        totalPrice += price * quantity;
      }

      // Upload to Firestore under `sells → date → state → district → market → phoneNumber`
      await FirebaseFirestore.instance
          .collection('sells')
          .doc(todayDate)
          .collection(widget.state)
          .doc(widget.district)
          .collection(widget.market)
          .doc(userId) // Use userId as document ID
          .set({
        "phoneNumber": userId,
        "name": farmerName,
        "address": fullAddress,
        "state": widget.state,
        "district": widget.district,
        "market": widget.market,
        "date": todayDate,
        "items": itemsData,
        "totalPrice": totalPrice,
      }, SetOptions(merge: true)); // Merge data to prevent overwriting

      // Close loading indicator
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Your produce is ready to sell! Our pickup person will contact you shortly.",
            style: TextStyle(color: Colors.green),
          ),
        ),
      );

      // Close the screen and prevent sold items from showing again
      Navigator.pop(context);
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload selling list: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Selling List")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : sellingItems.isEmpty
              ? const Center(child: Text("No produce added yet for today"))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: sellingItems.length,
                        itemBuilder: (context, index) {
                          final item = sellingItems[index];
                          final controller =
                              quantityControllers[item['name']] ??
                                  TextEditingController(
                                      text:
                                          "1"); // ✅ Provide default controller

                          double pricePerKg = item['price'] ?? 0.0;
                          double quantity = double.tryParse(controller.text) ??
                              1.0; // ✅ Default 1 kg
                          double totalAmount = pricePerKg * quantity;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: (item['image'] != null &&
                                      item['image'].isNotEmpty)
                                  ? Image.asset(item['image'],
                                      width: 50, height: 50)
                                  : const Icon(Icons.image, size: 50),
                              title: Text(item['name'] ??
                                  "Unknown Item"), // ✅ Handle null name
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("₹${pricePerKg.toStringAsFixed(2)}/kg"),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Text("Quantity (kg):"),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: controller,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 5,
                                                    horizontal: 10),
                                          ),
                                          onChanged: (value) {
                                            setState(
                                                () {}); // ✅ Update UI when quantity changes
                                            if (value.isNotEmpty) {
                                              _updateSellingQuantity(
                                                  item['name'] ?? "", value);
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Total: ₹${totalAmount.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red, size: 18),
                                onPressed: () =>
                                    _removeItem(item['name'] ?? ""),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "Total Amount: ₹${_calculateTotalAmount().toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            onPressed: _uploadSellingList,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Text("Ready to Sell",
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          _showAddProduceDialog();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
