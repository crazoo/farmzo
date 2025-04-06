import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'commodity_bottom_popup.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  _MarketPricesScreenState createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  String state = "Loading...";
  String district = "Loading...";
  String market = "Loading...";
  List<dynamic> prices = [];
  List<dynamic> filteredPrices = [];
  bool isLoading = true;
  bool showDropdowns = false;

  String? selectedState;
  String? selectedDistrict;
  String? selectedMarket;
  double minPrice = 0;
  double maxPrice = 100;
  String searchQuery = "";

  Set<String> states = {};
  Set<String> districts = {};
  Set<String> markets = {};

  @override
  void initState() {
    super.initState();
    _fetchFarmerProfile();
  }

  /// Fetches the farmer’s location from Firestore
  Future<void> _fetchFarmerProfile() async {
    String userId = FirebaseAuth.instance.currentUser?.phoneNumber ?? "";
    if (userId.isEmpty) return;

    DocumentSnapshot farmerDoc = await FirebaseFirestore.instance
        .collection('farmers')
        .doc(userId)
        .get();

    if (farmerDoc.exists) {
      Map<String, dynamic> farmerData =
          farmerDoc.data() as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          state = farmerData['state'] ?? "";
          district = farmerData['district'] ?? "";
          market = farmerData['market'] ?? "";

          // ✅ Set the dropdowns to the farmer's location ONLY if they haven't been changed by the user
          selectedState ??= state;
          selectedDistrict ??= district;
          selectedMarket ??= market;
        });
      }

      if (state.isNotEmpty && district.isNotEmpty && market.isNotEmpty) {
        fetchPrices();
      }
    }
  }

  /// Handles dropdown selection updates
  void _updateSelectedState(String? newState) {
    if (mounted) {
      setState(() {
        selectedState = newState;
        selectedDistrict = null; // Reset district
        selectedMarket = null; // Reset market
        filterData();
      });
    }
  }

  void _updateSelectedDistrict(String? newDistrict) {
    if (mounted) {
      setState(() {
        selectedDistrict = newDistrict;
        selectedMarket = null; // Reset market
        filterData();
      });
    }
  }

  void _updateSelectedMarket(String? newMarket) {
    if (mounted) {
      setState(() {
        selectedMarket = newMarket;
        filterData();
      });
    }
  }

  Future<void> fetchPrices() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    const String apiKey =
        "579b464db66ec23bdd000001efafcb95abb149a258d2697c3c5fc058"; // Replace with your API key
    const String resourceId = "9ef84268-d588-465a-a308-a864a43d0070";
    const String url =
        "https://api.data.gov.in/resource/$resourceId?api-key=$apiKey&format=json&limit=10000";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('records') && data['records'] is List) {
          List<dynamic> allPrices = data['records'];

          prices = allPrices.where((item) {
            bool matchesState =
                selectedState == null || item['state'] == selectedState;
            bool matchesDistrict = selectedDistrict == null ||
                item['district'] == selectedDistrict;
            return matchesState && matchesDistrict;
          }).toList();

          if (prices.isNotEmpty) {
            if (mounted) {
              setState(() {
                extractFilterOptions();
                filterData();
                isLoading = false;
              });
            }

            await _storePricesToFirestore();
            return;
          }
        }
      }

      await _fetchPricesFromFirestore();
    } catch (error) {
      print("🚨 Error fetching API data: $error");
      await _fetchPricesFromFirestore();
    }
  }

  /// Fetch prices from Firestore if API has no records
  Future<void> _fetchPricesFromFirestore() async {
    String todayDate = DateTime.now().toIso8601String().split('T')[0];
    String yesterdayDate = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0];

    List<Map<String, dynamic>> firestorePrices = [];

    firestorePrices = await _getFirestorePrices(todayDate);
    if (firestorePrices.isEmpty) {
      print("⚠️ No prices for today. Trying yesterday’s data...");
      firestorePrices = await _getFirestorePrices(yesterdayDate);
    }
    if (firestorePrices.isEmpty) {
      print("⚠️ No prices for yesterday. Fetching last available data...");
      firestorePrices = await _getLastAvailableFirestorePrices();
    }

    if (mounted) {
      setState(() {
        prices = firestorePrices;
        extractFilterOptions();
        filterData();
        isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getFirestorePrices(String date) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('market_prices')
          .doc(date)
          .collection(selectedState ?? "")
          .doc(selectedDistrict ?? "")
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data.entries
            .map((entry) => {"name": entry.key, "modal_price": entry.value})
            .toList();
      }
    } catch (e) {
      print("🚨 Error fetching Firestore data for $date: $e");
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> _getLastAvailableFirestorePrices() async {
    try {
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('market_prices')
          .orderBy(FieldPath.documentId, descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        String lastAvailableDate = query.docs.first.id;
        print("📅 Last available Firestore data found for: $lastAvailableDate");
        return await _getFirestorePrices(lastAvailableDate);
      }
    } catch (e) {
      print("🚨 Error fetching last available Firestore data: $e");
    }
    return [];
  }

  Future<void> _storePricesToFirestore() async {
    // ✅ Format today's date to match API date format
    String todayDate = DateFormat("dd/MM/yyyy").format(DateTime.now());

    for (var item in prices) {
      String marketName = item['market'] ?? "";
      String commodity = item['commodity'] ?? "";
      String arrivalDate = item['arrival_date'] ?? "";

      if (arrivalDate.isEmpty) {
        print("🚨 Skipping $commodity due to missing arrival date");
        continue;
      }

      // ✅ Convert API arrival date from "dd/MM/yyyy" to "yyyy-MM-dd"
      DateTime parsedArrivalDate = DateFormat("dd/MM/yyyy").parse(arrivalDate);
      String formattedArrivalDate =
          DateFormat("yyyy-MM-dd").format(parsedArrivalDate);

      // ✅ Ensure both dates use "yyyy-MM-dd" format
      String expectedTodayDate =
          DateFormat("yyyy-MM-dd").format(DateTime.now());

      if (formattedArrivalDate != expectedTodayDate) {
        print(
            "⚠️ Skipping $commodity (Arrival Date: $formattedArrivalDate ≠ Today: $expectedTodayDate)");
        continue;
      }

      double minPrice = (double.tryParse(item['min_price'] ?? "0") ?? 0) / 100;
      double maxPrice = (double.tryParse(item['max_price'] ?? "0") ?? 0) / 100;
      double modalPrice =
          (double.tryParse(item['modal_price'] ?? "0") ?? 0) / 100;

      DocumentReference docRef = FirebaseFirestore.instance
          .collection('market_prices')
          .doc(expectedTodayDate) // ✅ Now both match
          .collection(state)
          .doc(district)
          .collection(marketName)
          .doc(commodity);

      try {
        DocumentSnapshot existingDoc = await docRef.get();

        if (!existingDoc.exists) {
          await docRef.set({
            'min_price': minPrice,
            'max_price': maxPrice,
            'modal_price': modalPrice,
            'arrival_date': formattedArrivalDate, // ✅ Store consistent format
            'variety': item['variety'] ?? "Unknown",
            'timestamp': FieldValue.serverTimestamp(),
          });

          print("✅ Stored: $commodity in $marketName ($district, $state)");
        } else {
          print(
              "🔄 Already exists: $commodity in $marketName ($district, $state)");
        }
      } catch (e) {
        print("🚨 Firestore Error storing $commodity: $e");
      }
    }
  }

  void extractFilterOptions() {
    states = prices.map((e) => e['state'].toString()).toSet();
    districts = prices
        .where((e) => selectedState == null || e['state'] == selectedState)
        .map((e) => e['district'].toString())
        .toSet();
    markets = prices
        .where((e) =>
            (selectedState == null || e['state'] == selectedState) &&
            (selectedDistrict == null || e['district'] == selectedDistrict))
        .map((e) => e['market'].toString())
        .toSet();

    if (mounted) {
      setState(() {
        selectedState = selectedState ?? state;
        selectedDistrict = selectedDistrict ?? district;
        selectedMarket = selectedMarket ?? market;
      });
    }

    filterData();
  }

  void filterData() {
    if (mounted) {
      setState(() {
        filteredPrices = prices.where((item) {
          double itemMinPrice =
              (double.tryParse(item['min_price'] ?? "0") ?? 0) / 100;
          double itemMaxPrice =
              (double.tryParse(item['max_price'] ?? "0") ?? 0) / 100;

          bool matchesState =
              selectedState == null || item['state'] == selectedState;
          bool matchesDistrict =
              selectedDistrict == null || item['district'] == selectedDistrict;
          bool matchesMarket =
              selectedMarket == null || item['market'] == selectedMarket;
          bool matchesPrice =
              itemMaxPrice >= minPrice && itemMinPrice <= maxPrice;
          bool matchesSearch = searchQuery.isEmpty ||
              item['commodity']
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              item['market'].toLowerCase().contains(searchQuery.toLowerCase());

          return matchesState &&
              matchesDistrict &&
              matchesMarket &&
              matchesPrice &&
              matchesSearch;
        }).toList();
      });
    }
  }

  /// Dropdown builder (farmer’s location is preselected ONLY ONCE)
  Widget buildDropdown(String label, Set<String> items, String? selectedItem,
      ValueChanged<String?> onChanged, String? defaultValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        value: (selectedItem != null && items.contains(selectedItem))
            ? selectedItem
            : (items.isNotEmpty
                ? items.first
                : null), // Choose the first option if invalid
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: (value) {
          if (mounted) {
            setState(() {
              onChanged(value);
            });
          }
          fetchPrices();
        },
      ),
    );
  }

  Widget buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        labelText: "Search Commodity or Market",
        prefixIcon: const Icon(Icons.search, color: Colors.green),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (query) {
        if (mounted) {
          setState(() => searchQuery = query);
        }
        filterData();
      },
    );
  }

  Widget buildList() {
    return filteredPrices.isEmpty
        ? const Center(child: Text("No results found for today"))
        : ListView.builder(
            itemCount: filteredPrices.length,
            itemBuilder: (context, index) {
              final item = filteredPrices[index];
              double minPricePerKg =
                  (double.tryParse(item['min_price'] ?? "0") ?? 0) / 100;
              double maxPricePerKg =
                  (double.tryParse(item['max_price'] ?? "0") ?? 0) / 100;
              double modalPricePerKg =
                  (double.tryParse(item['modal_price'] ?? "0") ?? 0) / 100;

              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // Allows full-height expansion
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context)
                              .viewInsets
                              .bottom, // Prevent overlap with keyboard
                        ),
                        child: Wrap(
                          // Wrap adjusts height automatically
                          children: [
                            CommodityBottomPopup(item: item),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(6.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    textColor: Colors.black,
                    title: Text(
                      "${item['commodity']} (${item['variety']})",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Market: ${item['market']}, ${item['district']}, ${item['state']}\n"
                      "Arrival Date: ${item['arrival_date']}\n"
                      "Min Price: ₹${minPricePerKg.toStringAsFixed(2)}/kg, "
                      "Max Price: ₹${maxPricePerKg.toStringAsFixed(2)}/kg, "
                      "Modal Price: ₹${modalPricePerKg.toStringAsFixed(2)}/kg",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
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
              "Market Prices",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "${selectedMarket ?? market}, ${selectedDistrict ?? district}, ${selectedState ?? state}",
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                buildSearchBar(),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        showDropdowns = !showDropdowns;
                      });
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "See Location",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Icon(
                        showDropdowns
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.green.shade700,
                      ),
                    ],
                  ),
                ),
                if (showDropdowns) ...[
                  const SizedBox(height: 5),
                  buildDropdown("State", states, selectedState, (value) {
                    if (mounted) {
                      setState(() {
                        selectedState = value;
                        selectedDistrict = null; // Reset district
                        selectedMarket = null; // Reset market
                        districts.clear(); // Ensure districts update correctly
                        markets.clear(); // Ensure markets update correctly
                      });
                    }
                  }, state),
                  const SizedBox(height: 5),
                  buildDropdown("District", districts, selectedDistrict,
                      (value) {
                    if (mounted) {
                      setState(() {
                        selectedDistrict = value;
                        selectedMarket = null; // Reset market
                        markets.clear(); // Ensure markets update correctly
                      });
                    }
                  }, district),
                  const SizedBox(height: 5),
                  if (selectedState != null && selectedDistrict != null)
                    buildDropdown("Market", markets, selectedMarket, (value) {
                      if (mounted) {
                        setState(() => selectedMarket = value);
                      }
                      fetchPrices(); // Refresh prices after selecting market
                    }, null),
                ],
                const SizedBox(height: 10),
                Expanded(child: buildList()),
              ],
            ),
          ),
          if (isLoading) buildLoadingOverlay(),
        ],
      ),
    );
  }
}
