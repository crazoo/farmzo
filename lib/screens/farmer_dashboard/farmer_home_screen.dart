import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmzo/screens/farmer_dashboard/app_drawer.dart';
import 'package:farmzo/screens/farmer_dashboard/produce_selling_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, String> produceImages = {
    "Apple": "assets/images/fruits/apple.png",
    "Banana": "assets/images/fruits/banana.png",
    "Banana - Green": "assets/images/fruits/banana.png",
    "Mango": "assets/images/fruits/mango.png",
    "Tomato": "assets/images/vegetables/tomato.png",
    "Potato": "assets/images/vegetables/potato.png",
    "Black Grapes": "assets/images/fruits/blackgrapes.png",
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
    "Amla": "assets/images/fruits/amla.png",
    "Amla(Nelli Kai)": "assets/images/fruits/amla.png",
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
    "Amaranthus": "assets/images/vegetables/amaranthus.png",
    "Beans": "assets/images/vegetables/beans.png",
    "Beetroot": "assets/images/vegetables/beetroot.png",
    "Betal Leaves": "assets/images/vegetables/betal_leaves.png",
  };

  Map<String, double> livePrices = {};
  List<Map<String, dynamic>> selectedItems = [];

  String searchQuery = "";
  bool isLoading = true;
  String state = "", district = "", market = "", dataDate = "";

  Future<void> _fetchFarmerProfile() async {
    print("Fetching farmer profile...");
    String userId = FirebaseAuth.instance.currentUser?.phoneNumber ?? "";
    if (userId.isEmpty) {
      print("User not logged in.");
      return;
    }

    try {
      DocumentSnapshot farmerDoc = await FirebaseFirestore.instance
          .collection('farmers')
          .doc(userId)
          .get();

      if (farmerDoc.exists) {
        Map<String, dynamic> farmerData =
            farmerDoc.data() as Map<String, dynamic>;
        print("Farmer Data: $farmerData");

        setState(() {
          state = farmerData['state'] ?? "";
          district = farmerData['district'] ?? "";
          market = farmerData['market'] ?? "";
        });

        if (state.isNotEmpty && district.isNotEmpty && market.isNotEmpty) {
          _fetchLivePrices();
        } else {
          setState(() => isLoading = false);
        }
      } else {
        print("Farmer document does not exist.");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching farmer profile: $e");
      setState(() => isLoading = false);
    }
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      return formatter.format(parsedDate);
    } catch (e) {
      return date; // Return the original string if parsing fails
    }
  }

  Future<void> _fetchLivePrices() async {
    print("Fetching live prices...");
    DateTime now = DateTime.now();
    List<String> dates = [
      DateFormat('yyyy-MM-dd').format(now),
      DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1))),
      DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 2))),
      DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 3))),
      DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 4))),
      DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 5))),
      DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 6))),
      DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 7))),
    ];

    for (String date in dates) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('market_prices')
            .doc(date)
            .collection(state)
            .doc(district)
            .collection(market)
            .get();

        if (snapshot.docs.isNotEmpty) {
          Map<String, double> prices = {};
          for (var doc in snapshot.docs) {
            var priceData = doc.data()['modal_price'];

            double price = 0.0;
            if (priceData is num) {
              price = priceData.toDouble();
            } else if (priceData is String) {
              price = double.tryParse(priceData) ?? 0.0;
            }

            prices[doc.id] = price;
          }

          print("Fetched Prices from $date: $prices");

          if (mounted) {
            setState(() {
              livePrices = prices;
              dataDate = date;
              isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        print("Error fetching prices for $date: $e");
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addToSell(Map<String, dynamic> item) async {
    String userId = FirebaseAuth.instance.currentUser?.phoneNumber ?? "";
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    item['quantity'] = "1";

    await FirebaseFirestore.instance
        .collection('sells')
        .doc(todayDate)
        .collection(state)
        .doc(district)
        .collection(market)
        .doc(userId)
        .set({
      item['name']: {
        "name": item['name'],
        "image": item['image'],
        "price": item['price'],
        "quantity": item['quantity'],
        "date": todayDate,
        "state": state,
        "district": district,
        "market": market,
      }
    }, SetOptions(merge: true));

    setState(() {
      selectedItems.add(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${item['name']} added for selling")),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProduceSellingScreen(
          state: state,
          district: district,
          market: market,
          selectedItems: const [],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 4,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Farmzo",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              market.isNotEmpty ? "$market, $district, $state" : "Loading...",
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.store_mall_directory_rounded,
                color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration:
                      const Duration(milliseconds: 300), // Adjust the speed
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ProduceSellingScreen(
                    state: state,
                    district: district,
                    market: market,
                    selectedItems: const [],
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // Start from the right
                    const end = Offset.zero; // End at the center
                    const curve = Curves.easeInOut; // Smooth transition

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // 🔹 Auto-Sliding Advertisement Banners
                  SizedBox(
                    height: 160,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: adImages.length,
                      physics:
                          const BouncingScrollPhysics(), // 🔹 Smooth scrolling
                      pageSnapping: true, // 🔹 Ensures proper page snapping
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 13),
                              child: GestureDetector(
                                onTap: () => _launchURL(adImages[
                                    index]), // Call _launchURL function on tap
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    adImages[
                                        index], // Change this to load images from URLs
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔹 Market Date Info
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dataDate.isNotEmpty
                          ? "Market Prices as of: ${_formatDate(dataDate)}"
                          : "No market data found for",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔹 GridView of Market Prices (with shrinkWrap & physics)
                  GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: livePrices.length,
                    shrinkWrap: true, // 🔹 Makes it scroll inside Column
                    physics:
                        const NeverScrollableScrollPhysics(), // 🔹 Prevents separate scrolling
                    itemBuilder: (context, index) {
                      final produce = livePrices.keys.elementAt(index);
                      final price = livePrices[produce] ?? 0.0;

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                        shadowColor: Colors.black26,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 7),

                            // 🔹 Product Image with Full-Screen Blur Popup
                            GestureDetector(
                              onTap: () => _showProduceDetails(
                                  context,
                                  produce,
                                  produceImages.containsKey(produce)
                                      ? produceImages[produce]!
                                      : "assets/images/default.png",
                                  price),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  produceImages.containsKey(produce)
                                      ? produceImages[produce]!
                                      : "assets/images/default.png",
                                  height: 90,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // 🔹 Product Name
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                produce,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // 🔹 Price with Full-Screen Blur Popup
                            GestureDetector(
                              onTap: () => _showProduceDetails(
                                  context,
                                  produce,
                                  produceImages.containsKey(produce)
                                      ? produceImages[produce]!
                                      : "assets/images/default.png",
                                  price),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "₹${price.toStringAsFixed(2)}/kg",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700),
                                ),
                              ),
                            ),

                            const Spacer(),

                            // 🔹 Add to Sell Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  _addToSell({
                                    "name": produce,
                                    "image": produceImages[produce] ?? "",
                                    "price": price
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16)),
                                  ),
                                ),
                                child: const Text("Add to Sell"),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchFarmerProfile();

    _pageController = PageController(initialPage: 0);

    // Auto-slide ads every 5 seconds with a smooth transition
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted) return;

      final nextPage = (_pageController.page!.toInt() + 1) % adImages.length;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600), // 🔹 Smoother transition
        curve: Curves.easeInOutCubic, // 🔹 More fluid effect
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  late PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  List<String> adImages = [
    "https://farmzo.crazoo.me/ad1.png",
    "https://farmzo.crazoo.me/ad2.png",
    "https://farmzo.crazoo.me/ad3.png",
    "https://farmzo.crazoo.me/ad4.png",
  ];
  List<String> adLinks = [
    "https://www.example.com/1", // Link for Image 1
    "https://www.example.com/2", // Link for Image 2
    "https://www.example.com/3", // Link for Image 3
    "https://www.example.com/4", // Link for Image 4
  ];
  void _showProduceDetails(
      BuildContext context, String produce, String image, double price) {
    Map<String, String> descriptions = {
      "Tomato": "A juicy and versatile fruit often used in cooking.",
      "Potato": "A starchy tuber, rich in carbohydrates and nutrients.",
      "Onion": "A pungent vegetable used in many cuisines for flavor.",
      "Carrot": "A crunchy root vegetable, high in beta-carotene.",
      "Apple": "A sweet and crunchy fruit, packed with fiber and vitamins.",
      // Add more commodities as needed...
    };

    String description = descriptions.containsKey(produce)
        ? descriptions[produce]!
        : "Get the fresh and nutritious produce directly from the Farmers.";

    showDialog(
      context: context,
      barrierDismissible: true, // Allows tapping outside to close
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context), // Tap anywhere to close
          child: Stack(
            children: [
              // 🔹 Full-screen Blur Background
              Positioned.fill(
                child: BackdropFilter(
                  filter:
                      ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
                  child: Container(
                      color: Colors.black
                          .withOpacity(0.3)), // Semi-transparent overlay
                ),
              ),

              // 🔹 Centered Popup
              Center(
                child: GestureDetector(
                  onTap:
                      () {}, // Prevents closing when tapping inside the popup
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔹 Product Image
                        SizedBox(
                          height: 300, // Adjust height
                          width: MediaQuery.of(context).size.width *
                              0.8, // Adjust width dynamically
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              image,
                              fit: BoxFit
                                  .contain, // Ensures full image is visible without cropping
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 🔹 Product Name
                        Text(
                          produce,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),

                        // 🔹 Price
                        Text(
                          "₹${price.toStringAsFixed(2)}/kg",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Arrival Date: $dataDate",
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        // 🔹 Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white60),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 🔹 Close Button
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // Button color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  12), // Adjust curve radius
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 3), // Adjust size
                          ),
                          child: const Text(
                            "Close",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
