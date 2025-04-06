import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> schemes = [];

  @override
  void initState() {
    super.initState();
    _fetchSchemes();
  }

  // Fetch farm loan waiver schemes from API
  Future<void> _fetchSchemes() async {
    const String apiUrl =
        'https://api.data.gov.in/resource/d7215e89-edc3-41ca-83bb-ce6fcc2be65a?api-key=579b464db66ec23bdd000001efafcb95abb149a258d2697c3c5fc058&format=json&limit=100';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final records = data['records'] as List<dynamic>;

        if (mounted) {
          setState(() {
            schemes = records.map((record) {
              return {
                'state': record['state_ut'] ?? 'Unknown State',
                'scheme': record['name_of_the_debt_waiver_scheme_since_2014'] ??
                    'No Scheme Name',
                'amount': record['actual_amount_waived__rs__crore_'] ?? 'N/A',
                'source': data['source'] ?? '',
              };
            }).toList();
            isLoading = false;
          });
        }
      } else {
        throw 'Failed to load schemes';
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching schemes.')),
      );
    }
  }

  // Open Source Link in Browser
  void _launchURL(String url) async {
    if (url.isNotEmpty) {
      try {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Farm Loan Waiver Schemes"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : schemes.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: schemes.length,
                  itemBuilder: (context, index) {
                    final scheme = schemes[index];
                    return _buildSchemeCard(scheme);
                  },
                ),
    );
  }

  // Empty State UI (Lottie Animation)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/empty.json', height: 200),
          const SizedBox(height: 16),
          const Text(
            'No schemes available.',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Scheme Card Widget
  Widget _buildSchemeCard(Map<String, dynamic> scheme) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with Icon
            Row(
              children: [
                Icon(Icons.monetization_on,
                    color: Colors.green.shade700, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    scheme['state'] ?? 'No State',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Scheme Name
            Text(
              scheme['scheme'] ?? 'No Scheme Name',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),

            // Amount Waived
            Text(
              'Amount Waived: ₹${scheme['amount']} Crore',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),

            // Action Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text("Source"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: scheme['source'].isNotEmpty
                    ? () => _launchURL(scheme['source'])
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
