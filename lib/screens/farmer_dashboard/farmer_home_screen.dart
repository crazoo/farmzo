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
    "Apple": "https://farmzoassets.crazoo.me/fruits/apple.png",
    "Banana": "https://farmzoassets.crazoo.me/fruits/banana.png",
    "Banana - Green": "https://farmzoassets.crazoo.me/fruits/banana.png",
    "Mango": "https://farmzoassets.crazoo.me/fruits/mango.png",
    "Tomato": "https://farmzoassets.crazoo.me/vegetables/tomato.png",
    "Potato": "https://farmzoassets.crazoo.me/vegetables/potato.png",
    "Black Grapes": "https://farmzoassets.crazoo.me/fruits/blackgrapes.png",
    "Green Grapes": "https://farmzoassets.crazoo.me/fruits/greengrapes.png",
    "Guava": "https://farmzoassets.crazoo.me/fruits/guava.png",
    "Orange": "https://farmzoassets.crazoo.me/fruits/orange.png",
    "Papaya": "https://farmzoassets.crazoo.me/fruits/papaya.jpg",
    "Pineapple": "https://farmzoassets.crazoo.me/fruits/pineapple.jpg",
    "Pomegranate": "https://farmzoassets.crazoo.me/fruits/pomegranate.jpg",
    "Water Melon": "https://farmzoassets.crazoo.me/fruits/watermelon.jpg",
    "Muskmelon": "https://farmzoassets.crazoo.me/fruits/muskmelon.jpg",
    "Coconut": "https://farmzoassets.crazoo.me/fruits/coconut.jpg",
    "Jackfruit": "https://farmzoassets.crazoo.me/fruits/jackfruit.jpg",
    "Chikoo": "https://farmzoassets.crazoo.me/fruits/chikoo.jpg",
    "Litchi": "https://farmzoassets.crazoo.me/fruits/litchi.jpg",
    "Custard Apple": "https://farmzoassets.crazoo.me/fruits/custardapple.jpg",
    "Tamarind": "https://farmzoassets.crazoo.me/fruits/tamarind.jpg",
    "Amla": "https://farmzoassets.crazoo.me/fruits/amla.png",
    "Amla(Nelli Kai)": "https://farmzoassets.crazoo.me/fruits/amla.png",
    "Fig": "https://farmzoassets.crazoo.me/fruits/fig.jpg",
    "Starfruit": "https://farmzoassets.crazoo.me/fruits/starfruit.jpg",
    "Jamun": "https://farmzoassets.crazoo.me/fruits/jamun.jpg",
    "Ber": "https://farmzoassets.crazoo.me/fruits/ber.jpg",
    "Strawberry": "https://farmzoassets.crazoo.me/fruits/strawberry.jpg",
    "Kiwi": "https://farmzoassets.crazoo.me/fruits/kiwi.jpg",
    "Bael": "https://farmzoassets.crazoo.me/fruits/bael.jpg",
    "Carrot": "https://farmzoassets.crazoo.me/vegetables/carrot.png",
    "Spinach": "https://farmzoassets.crazoo.me/vegetables/spinach.png",
    "Green Chilli":
        "https://farmzoassets.crazoo.me/vegetables/green_chilli.png",
    "Cabbage": "https://farmzoassets.crazoo.me/vegetables/cabbage.png",
    "Cluster beans":
        "https://farmzoassets.crazoo.me/vegetables/cluster_beans.png",
    "Brinjal": "https://farmzoassets.crazoo.me/vegetables/brinjal.png",
    "Cauliflower": "https://farmzoassets.crazoo.me/vegetables/cauliflower.png",
    "Onion": "https://farmzoassets.crazoo.me/vegetables/onion.png",
    "Amaranthus": "https://farmzoassets.crazoo.me/vegetables/amaranthus.png",
    "Beans": "https://farmzoassets.crazoo.me/vegetables/beans.png",
    "Beetroot": "https://farmzoassets.crazoo.me/vegetables/beetroot.png",
    "Betal Leaves":
        "https://farmzoassets.crazoo.me/vegetables/betal_leaves.png",
  };

// https://farmzoassets.crazoo.me/fruits/amla.png
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

        if (mounted) {
          setState(() {
            state = farmerData['state'] ?? "";
            district = farmerData['district'] ?? "";
            market = farmerData['market'] ?? "";
          });
        }

        if (state.isNotEmpty && district.isNotEmpty && market.isNotEmpty) {
          _fetchLivePrices();
        } else {
          if (mounted) {
            setState(() => isLoading = false);
          }
        }
      } else {
        print("Farmer document does not exist.");
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      print("Error fetching farmer profile: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
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

    if (mounted) {
      setState(() {
        selectedItems.add(item);
      });
    }

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

// Inside your build method:
                  Column(
                    children: [
                      SizedBox(
                        height: 160,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: adImages.length,
                          physics: const BouncingScrollPhysics(),
                          pageSnapping: true,
                          onPageChanged: (index) {
                            if (mounted) {
                              setState(() {
                                _currentPage = index;
                              });
                            }
                          },
                          itemBuilder: (context, index) {
                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 13),
                                  child: GestureDetector(
                                    onTap: () => _launchURL(adImages[index]),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        adImages[index],
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
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(adImages.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 16 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.green
                                  : Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ],
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
                                      : "https://farmzoassets.crazoo.me/default.png",
                                  price),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    produceImages[produce] ??
                                        'https://farmzoassets.crazoo.me/default.png',
                                    fit: BoxFit.contain,
                                    height: 90,
                                  )),
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
                                      : "https://farmzoassets.crazoo.me/default.png",
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

    // Wait until the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer.periodic(const Duration(seconds: 5), (Timer timer) {
        if (!mounted) return;
        if (!_pageController.hasClients) return;

        final nextPage =
            (_pageController.page?.toInt() ?? 0 + 1) % adImages.length;

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      });
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
    "https://farmzoassets.crazoo.me/ad1.png",
    "https://farmzoassets.crazoo.me/ad2.png",
    "https://farmzoassets.crazoo.me/ad3.png",
    "https://farmzoassets.crazoo.me/ad4.png",
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
                            child: Image.network(
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
