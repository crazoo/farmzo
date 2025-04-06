import 'package:flutter/material.dart';
import '../../services/perenual_api.dart';
import 'crop_detail_screen.dart';

class CropListScreen extends StatefulWidget {
  const CropListScreen({super.key});

  @override
  _CropListScreenState createState() => _CropListScreenState();
}

class _CropListScreenState extends State<CropListScreen> {
  List<dynamic> crops = [];
  List<dynamic> filteredCrops = [];
  bool isLoading = true;
  int page = 1;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCrops();
  }

  Future<void> loadCrops() async {
    try {
      List<dynamic> fetchedCrops = await PerenualAPI.fetchCrops(page: page);

      // Filter only Indian crops (Modify list as needed)
      List<String> indianCrops = [
        "Rice",
        "Wheat",
        "Sugarcane",
        "Maize",
        "Barley",
        "Soybean",
        "Cotton"
      ];
      fetchedCrops = fetchedCrops
          .where((crop) => indianCrops.contains(crop['common_name'] ?? ''))
          .toList();

      setState(() {
        crops.addAll(fetchedCrops);
        filteredCrops = crops;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading crops: $e");
    }
  }

  void searchCrop(String query) {
    setState(() {
      filteredCrops = crops.where((crop) {
        final name = crop['common_name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Indian Crop Growth & Practices")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Search Crops",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: searchCrop,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show loader while fetching
                : crops.isEmpty
                    ? const Center(
                        child: Text("No crops found!")) // Show message if empty
                    : GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filteredCrops.length,
                        itemBuilder: (context, index) {
                          final crop = filteredCrops[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        CropDetailScreen(crop['id'])),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (crop['image_url'] != null &&
                                      crop['image_url'].isNotEmpty)
                                    Image.network(
                                      crop['image_url'],
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.image),
                                    )
                                  else
                                    const Icon(Icons.image,
                                        size: 100), // Show placeholder image
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      crop['common_name'] ?? 'Unknown Crop',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
