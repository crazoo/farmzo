import 'package:flutter/material.dart';

import '../../services/perenual_api.dart';

class CropDetailScreen extends StatefulWidget {
  final int cropId;

  const CropDetailScreen(this.cropId, {super.key});

  @override
  _CropDetailScreenState createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  late Future<Map<String, dynamic>> cropDetails;

  @override
  void initState() {
    super.initState();
    cropDetails = PerenualAPI.fetchCropDetails(widget.cropId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crop Details")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: cropDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No details available"));
          }

          final crop = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (crop['image_url'] != null)
                  Image.network(crop['image_url'], width: double.infinity, fit: BoxFit.cover),
                const SizedBox(height: 10),
                Text(
                  crop['common_name'] ?? 'Unknown Crop',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("Sunlight: ${crop['sunlight']?.join(', ') ?? 'Not specified'}"),
                Text("Watering: ${crop['watering'] ?? 'Not specified'}"),
                Text("Growth Period: ${crop['growth_rate'] ?? 'Not specified'}"),
                const SizedBox(height: 20),
                const Text(
                  "Best Practices",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(crop['care_guides'] ?? "No specific care guides available."),
              ],
            ),
          );
        },
      ),
    );
  }
}
