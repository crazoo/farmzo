import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String district = "";
  String state = "";
  String market = "";
  String dataDate = "";
  Map<String, dynamic> producePrices = {};
  Map<String, int> cart = {};
  bool isLoading = true;
  List<String> availableMarkets = [];

  final Map<String, String> produceImages = {
    "Apple": "assets/images/fruits/apple.png",
    "Banana": "assets/images/fruits/banana.png",
    "Banana - Green": "assets/images/fruits/banana.png",
    "Mango": "assets/images/fruits/mango.png",
    "Tomato": "assets/images/vegetables/tomato.png",
    "Potato": "assets/images/vegetables/potato.png",
    "name": "Black Grapes",
    "image": "assets/images/fruits/blackgrapes.png",
    "Green Grapes": "assets/images/fruits/greengrapes.png",
    "Guava": "assets/images/fruits/guava.png",
    "Orange": "assets/images/fruits/orange.png",
    "Papaya": "assets/images/fruits/papaya.jpg",
    "Pineapple": "assets/images/fruits/pineapple.jpg",
    "Pomegranate": "assets/images/fruits/pomegranate.jpg",
    "Water Melon": "assets/images/fruits/watermelon.jpg",
    "Muskmelon": "assets/images/fruits/muskmelon.jpg",
    "Coconut": "assets/images/fruits/coconut.jpg",
    "Jackfruit": "assets/images/fruits/jackfruit.jpg",
    "Chikoo": "assets/images/fruits/chikoo.jpg",
    "Litchi": "assets/images/fruits/litchi.jpg",
    "Custard Apple": "assets/images/fruits/custardapple.jpg",
    "Tamarind": "assets/images/fruits/tamarind.jpg",
    "Amla": "assets/images/fruits/amla.jpg",
    "Fig": "assets/images/fruits/fig.jpg",
    "Starfruit": "assets/images/fruits/starfruit.jpg",
    "Jamun": "assets/images/fruits/jamun.jpg",
    "Ber": "assets/images/fruits/ber.jpg",
    "Strawberry": "assets/images/fruits/strawberry.jpg",
    "Kiwi": "assets/images/fruits/kiwi.jpg",
    "Bael": "assets/images/fruits/bael.jpg",
    "Carrot": "assets/images/vegetables/carrot.png",
    "Spinach": "assets/images/vegetables/spinach.png",
    "Green Chilli": "assets/images/vegetables/green_chilli.png",
    "Cabbage": "assets/images/vegetables/cabbage.png",
    "Cluster beans": "assets/images/vegetables/cluster_beans.png",
    "Brinjal": "assets/images/vegetables/brinjal.png",
    "Cauliflower": "assets/images/vegetables/cauliflower.png",
    "Onion": "assets/images/vegetables/onion.png",
  };

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
    _loadCart();
  }

  Future<void> _fetchUserLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('buyers')
          .doc(user.phoneNumber)
          .get();

      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>?;

        setState(() {
          district = data?['district'] ?? "";
          state = data?['state'] ?? "";
          market = data?['market'] ?? "";
        });

        if (state.isNotEmpty && district.isNotEmpty) {
          _fetchMarkets();
        }

        if (market.isNotEmpty) {
          _fetchMarketPrices();
        }
      }
    }
  }

  Future<void> _fetchMarkets() async {
    if (state.isEmpty || district.isEmpty) return;

    DateTime now = DateTime.now();
    String todayDate = DateFormat('yyyy-MM-dd').format(now);

    try {
      var docRef = FirebaseFirestore.instance
          .collection('market_prices')
          .doc(todayDate)
          .collection(state)
          .doc(district);

      var docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data();

        if (data != null && data.containsKey('available_markets')) {
          List<String> fetchedMarkets =
              List<String>.from(data['available_markets']);

          setState(() {
            availableMarkets = fetchedMarkets;
          });

          if (!availableMarkets.contains(market) &&
              availableMarkets.isNotEmpty) {
            String randomMarket =
                availableMarkets[Random().nextInt(availableMarkets.length)];
            _updateMarketSelection(randomMarket);
          }
        }
      }
    } catch (e) {
      print("🚨 Error fetching markets: $e");
    }
  }

  Future<void> _updateMarketSelection(String selectedMarket) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('buyers')
          .doc(user.phoneNumber)
          .update({'market': selectedMarket});

      setState(() {
        market = selectedMarket;
        isLoading = true;
      });

      print("✅ Market updated: $market");

      _fetchMarketPrices();
    }
  }

  Future<void> _fetchMarketPrices() async {
    if (market.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Prepare the dates for today, yesterday, and the day before yesterday
    List<String> datesToCheck = [
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
      DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 1))),
      DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 2))),
      DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 3))),
      DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 4))),
      DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 5))),
      DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 6))),
      DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 7))),
    ];

    bool pricesLoaded = false;

    for (String date in datesToCheck) {
      pricesLoaded = await _fetchPricesForDate(date);
      if (pricesLoaded) break; // Exit the loop if prices are loaded
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<bool> _fetchPricesForDate(String date) async {
    try {
      var marketRef = FirebaseFirestore.instance
          .collection('market_prices')
          .doc(date)
          .collection(state)
          .doc(district)
          .collection(market);

      var snapshot = await marketRef.get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> fetchedPrices = {};

        for (var doc in snapshot.docs) {
          var data = doc.data();
          fetchedPrices[doc.id] = {
            "max_price": data['max_price'] ?? 0.0,
            "variety": data['variety'] ?? "",
          };
        }

        setState(() {
          producePrices = fetchedPrices;
          dataDate = date;
        });

        return true;
      }
    } catch (e) {
      print("🚨 Error fetching market prices for $date: $e");
    }

    return false;
  }

  void _addToCart(String product, int quantity) async {
    setState(() {
      cart[product] = (cart[product] ?? 0) + quantity;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("cart", jsonEncode(cart));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$product added to cart!'),
    ));
  }

  Future<void> _loadCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartData = prefs.getString("cart");

    if (cartData != null) {
      setState(() {
        cart = Map<String, int>.from(jsonDecode(cartData));
      });
    }
  }

  void _goToCartScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 400), // Animation speed
        pageBuilder: (context, animation, secondaryAnimation) =>
            CartScreen(cart: cart, producePrices: producePrices),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Start from right
          const end = Offset.zero; // End at center
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    ).then((_) {
      _loadCart();
    });
  }

  void _showAddProducePopup() {
    String produceName = "";
    String quantity = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add Unlisted Produce",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(labelText: "Produce Name"),
                  onChanged: (value) => produceName = value,
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(labelText: "Quantity (kg)"),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => quantity = value,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (produceName.isNotEmpty && quantity.isNotEmpty) {
                      _addToCart(produceName, int.tryParse(quantity) ?? 1);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add to Cart"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketPriceList() {
    if (producePrices.isEmpty) {
      return const Center(child: Text("No market prices available."));
    }

    return ListView.builder(
      itemCount: producePrices.length,
      itemBuilder: (context, index) {
        String produce = producePrices.keys.elementAt(index);
        var priceData = producePrices[produce];
        String imagePath = produceImages[produce] ??
            "assets/images/default.png"; // Default image

        // Ensure `max_price` is properly handled
        double? price = priceData?['max_price'] != null
            ? (priceData['max_price'] as num)
                .toDouble() // Ensures both int & double work
            : null;

        String priceText =
            price != null ? "₹${price.toStringAsFixed(2)}" : "Determined later";

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: Image.asset(imagePath,
                width: 50, height: 50, fit: BoxFit.cover),
            title: Text(produce,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                "Price: $priceText"), // Display price or "Determined later"
            trailing: ElevatedButton(
              onPressed: () {
                _addToCart(
                    produce, (price ?? 0.0).toInt()); // Convert to int safely
              },
              child: const Text("Add to Cart"),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Farmzo",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "$market, $district, $state",
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _goToCartScreen,
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      cart.length.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Market Prices as of: $dataDate",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMarketPriceList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProducePopup,
        child: const Icon(Icons.add),
      ),
    );
  }
}
