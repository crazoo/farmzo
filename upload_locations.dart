import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

Future<void> uploadLocationDetails() async {
  await Firebase.initializeApp(); // Initialize Firebase

  const String apiUrl = "https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070?api-key=579b464db66ec23bdd000001efafcb95abb149a258d2697c3c5fc058&format=json&limit=1000";

  try {
    // Fetch data from API
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['records'] != null) {
        Map<String, Map<String, List<String>>> locationData = {};

        for (var record in data['records']) {
          String state = record['state'] ?? "Unknown";
          String district = record['district'] ?? "Unknown";
          String market = record['market'] ?? "Unknown";

          // Initialize state if not exists
          if (!locationData.containsKey(state)) {
            locationData[state] = {};
          }

          // Initialize district if not exists
          if (!locationData[state]!.containsKey(district)) {
            locationData[state]![district] = [];
          }

          // Add market to the district
          if (!locationData[state]![district]!.contains(market)) {
            locationData[state]![district]!.add(market);
          }
        }

        // Upload to Firestore
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        for (var state in locationData.keys) {
          for (var district in locationData[state]!.keys) {
            await firestore.collection("locations").doc(state).set({
              district: locationData[state]![district]
            }, SetOptions(merge: true));
          }
        }

        print("✅ Location details uploaded successfully!");
      }
    } else {
      print("❌ Failed to fetch data: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error fetching or uploading data: $e");
  }
}

void main() async {
  await uploadLocationDetails();
}
