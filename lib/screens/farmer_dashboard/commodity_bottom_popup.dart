import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CommodityBottomPopup extends StatefulWidget {
  final Map<String, dynamic> item;

  const CommodityBottomPopup({super.key, required this.item});

  @override
  _CommodityBottomPopupState createState() => _CommodityBottomPopupState();
}

class _CommodityBottomPopupState extends State<CommodityBottomPopup> {
  Map<String, double> pastPrices = {};
  String latestDate = "";
  bool isLoading = true;
  String priceTrend = "No previous data";
  Color trendColor = Colors.grey; // Default color

  @override
  void initState() {
    super.initState();
    _fetchOldPrices();
  }

  Future<void> _fetchOldPrices() async {
    DateTime now = DateTime.now();
    List<String> dates = List.generate(
      7, // Fetch past 7 days
      (index) => DateFormat('yyyy-MM-dd')
          .format(now.subtract(Duration(days: index + 1))),
    );

    String state = widget.item['state'];
    String district = widget.item['district'];
    String market = widget.item['market'];
    String commodity = widget.item['commodity'];

    Map<String, double> fetchedPrices = {}; // Store multiple prices

    for (String date in dates) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('market_prices')
            .doc(date)
            .collection(state)
            .doc(district)
            .collection(market)
            .doc(commodity)
            .get();

        if (snapshot.exists) {
          var priceData = snapshot.data()?['modal_price'];
          double price = priceData is num
              ? priceData.toDouble()
              : (double.tryParse(priceData.toString()) ?? 0.0);

          fetchedPrices[date] = price;
        }
      } catch (e) {
        print("Error fetching prices for $date: $e");
      }
    }

    setState(() {
      pastPrices = fetchedPrices;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double minPricePerKg =
        (double.tryParse(widget.item['min_price'] ?? "0") ?? 0) / 100;
    double maxPricePerKg =
        (double.tryParse(widget.item['max_price'] ?? "0") ?? 0) / 100;
    double modalPricePerKg =
        (double.tryParse(widget.item['modal_price'] ?? "0") ?? 0) / 100;

    double? oldPrice = pastPrices[latestDate];

    String priceTrend = "No previous data";

// Sort past prices by date in descending order (newest first)
    List<String> sortedDates = pastPrices.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Sorts in descending order

    double? lastAvailablePrice;
    for (String date in sortedDates) {
      if (pastPrices[date] != null) {
        lastAvailablePrice = pastPrices[date];
        break; // Stop at the latest available price
      }
    }

    if (lastAvailablePrice != null) {
      if (modalPricePerKg > lastAvailablePrice) {
        priceTrend =
            "🔼 Increased from ₹${lastAvailablePrice.toStringAsFixed(2)}/kg to ₹${modalPricePerKg.toStringAsFixed(2)}/kg";
        trendColor = Colors.grey; // Price increased 📈
      } else if (modalPricePerKg < lastAvailablePrice) {
        priceTrend =
            "🔽 Decreased from ₹${lastAvailablePrice.toStringAsFixed(2)}/kg to ₹${modalPricePerKg.toStringAsFixed(2)}/kg";
        trendColor = Colors.grey; // Price decreased 📉
      } else {
        priceTrend =
            "➡ No change from ₹${lastAvailablePrice.toStringAsFixed(2)}/kg";
        trendColor = Colors.grey; // No change ➡
      }
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  "${widget.item['commodity']} (${widget.item['variety']})",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Price: ₹${modalPricePerKg.toStringAsFixed(2)}/kg",
                  style: const TextStyle(
                      fontSize: 21,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Text(
                  "Arrival Date: ${widget.item['arrival_date']}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "Market: ${widget.item['market']}, ${widget.item['district']}, ${widget.item['state']}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Price Trend:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  priceTrend,
                  style: TextStyle(
                    fontSize: 17,
                    color: trendColor,
                    fontWeight: FontWeight.w500, // Apply dynamic color
                  ),
                ),
                const SizedBox(height: 20),

                // New Section: Past 7 Days' Prices
                const Text(
                  "Past 3 Days Prices:",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                pastPrices.isEmpty
                    ? const Text("No past data available",
                        style: TextStyle(color: Colors.grey))
                    : Column(
                        children: pastPrices.entries.map((entry) {
                          return Text(
                            "${entry.key}: ₹${entry.value.toStringAsFixed(2)}/kg",
                            style: const TextStyle(fontSize: 16),
                          );
                        }).toList(),
                      ),

                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black26, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Adjust curve radius
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5), // Adjust size
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
