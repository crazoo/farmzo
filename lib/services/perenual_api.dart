import 'dart:convert';
import 'package:http/http.dart' as http;

class PerenualAPI {
  static const String _baseUrl = "https://perenual.com/api";
  static const String _apiKey =
      "sk-ESZ467d6cf1fdcf989182"; // Replace with actual API key

  static Future<List<dynamic>> fetchCrops({int page = 1}) async {
    final url = Uri.parse("$_baseUrl/species-list?key=$_apiKey&page=$page");
    try {
      final response = await http.get(url);
      print("API Response: ${response.body}"); // 👀 Debugging line
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? []; // Ensure it returns a list
      } else {
        throw Exception("Failed to fetch crops");
      }
    } catch (e) {
      print("Error: $e");
      return []; // Return empty list to prevent app crash
    }
  }

  static Future<Map<String, dynamic>> fetchCropDetails(int id) async {
    final url = Uri.parse("$_baseUrl/species/details/$id?key=$_apiKey");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to fetch details");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
