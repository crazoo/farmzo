import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class FarmerDetailsScreen extends StatefulWidget {
  const FarmerDetailsScreen({super.key});

  @override
  _FarmerDetailsScreenState createState() => _FarmerDetailsScreenState();
}

class _FarmerDetailsScreenState extends State<FarmerDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _farmSizeController = TextEditingController();
  final TextEditingController _cropTypeController = TextEditingController();
  final TextEditingController _irrigationController = TextEditingController();
  final TextEditingController _machineryController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedMarket;

  // Indian States and Districts (Add your actual list here)
  final Map<String, List<String>> _indiaStatesAndDistricts = {
    'Andhra Pradesh': [
      'Anantapur',
      'Chittoor',
      'East Godavari',
      'Guntur',
      'Krishna',
      'Kurnool',
      'Nellore',
      'Prakasam',
      'Srikakulam',
      'Visakhapatnam',
      'Vizianagaram',
      'West Godavari',
      'YSR Kadapa'
    ],
    'Arunachal Pradesh': [
      'Anjaw',
      'Changlang',
      'Dibang Valley',
      'East Kameng',
      'East Siang',
      'Kamle',
      'Kra Daadi',
      'Kurung Kumey',
      'Lepa Rada',
      'Lohit',
      'Longding',
      'Lower Dibang Valley',
      'Lower Siang',
      'Lower Subansiri',
      'Namsai',
      'Pakke Kessang',
      'Papum Pare',
      'Shi Yomi',
      'Siang',
      'Tawang',
      'Tirap',
      'Upper Siang',
      'Upper Subansiri',
      'West Kameng',
      'West Siang'
    ],
    'Assam': [
      'Baksa',
      'Barpeta',
      'Biswanath',
      'Bongaigaon',
      'Cachar',
      'Charaideo',
      'Chirang',
      'Darrang',
      'Dhemaji',
      'Dhubri',
      'Dibrugarh',
      'Dima Hasao',
      'Goalpara',
      'Golaghat',
      'Hailakandi',
      'Hojai',
      'Jorhat',
      'Kamrup',
      'Kamrup Metropolitan',
      'Karbi Anglong',
      'Karimganj',
      'Kokrajhar',
      'Lakhimpur',
      'Majuli',
      'Morigaon',
      'Nagaon',
      'Nalbari',
      'Sivasagar',
      'Sonitpur',
      'South Salmara-Mankachar',
      'Tinsukia',
      'Udalguri',
      'West Karbi Anglong'
    ],
    'Bihar': [
      'Araria',
      'Arwal',
      'Aurangabad',
      'Banka',
      'Begusarai',
      'Bhagalpur',
      'Bhojpur',
      'Buxar',
      'Darbhanga',
      'East Champaran',
      'Gaya',
      'Gopalganj',
      'Jamui',
      'Jehanabad',
      'Kaimur',
      'Katihar',
      'Khagaria',
      'Kishanganj',
      'Lakhisarai',
      'Madhepura',
      'Madhubani',
      'Munger',
      'Muzaffarpur',
      'Nalanda',
      'Nawada',
      'Patna',
      'Purnia',
      'Rohtas',
      'Saharsa',
      'Samastipur',
      'Saran',
      'Sheikhpura',
      'Sheohar',
      'Sitamarhi',
      'Siwan',
      'Supaul',
      'Vaishali',
      'West Champaran'
    ],
    'Chhattisgarh': [
      'Balod',
      'Baloda Bazar',
      'Balrampur',
      'Bastar',
      'Bemetara',
      'Bijapur',
      'Bilaspur',
      'Dantewada',
      'Dhamtari',
      'Durg',
      'Gariaband',
      'Janjgir-Champa',
      'Jashpur',
      'Kabirdham',
      'Kanker',
      'Kondagaon',
      'Korba',
      'Koriya',
      'Mahasamund',
      'Mungeli',
      'Narayanpur',
      'Raigarh',
      'Raipur',
      'Rajnandgaon',
      'Sukma',
      'Surajpur',
      'Surguja'
    ],
    'Goa': ['North Goa', 'South Goa'],
    'Gujarat': [
      'Ahmedabad',
      'Amreli',
      'Anand',
      'Aravalli',
      'Banaskantha',
      'Bharuch',
      'Bhavnagar',
      'Botad',
      'Chhota Udaipur',
      'Dahod',
      'Dang',
      'Devbhoomi Dwarka',
      'Gandhinagar',
      'Gir Somnath',
      'Jamnagar',
      'Junagadh',
      'Kheda',
      'Kutch',
      'Mahisagar',
      'Mehsana',
      'Morbi',
      'Narmada',
      'Navsari',
      'Panchmahal',
      'Patan',
      'Porbandar',
      'Rajkot',
      'Sabarkantha',
      'Surat',
      'Surendranagar',
      'Tapi',
      'Vadodara',
      'Valsad'
    ],
    'Haryana': [
      'Ambala',
      'Bhiwani',
      'Charkhi Dadri',
      'Faridabad',
      'Fatehabad',
      'Gurugram',
      'Hisar',
      'Jhajjar',
      'Jind',
      'Kaithal',
      'Karnal',
      'Kurukshetra',
      'Mahendragarh',
      'Nuh',
      'Palwal',
      'Panchkula',
      'Panipat',
      'Rewari',
      'Rohtak',
      'Sirsa',
      'Sonipat',
      'Yamunanagar'
    ],
    'Himachal Pradesh': [
      'Bilaspur',
      'Chamba',
      'Hamirpur',
      'Kangra',
      'Kinnaur',
      'Kullu',
      'Lahaul and Spiti',
      'Mandi',
      'Shimla',
      'Sirmaur',
      'Solan',
      'Una'
    ],
    'Jharkhand': [
      'Bokaro',
      'Chatra',
      'Deoghar',
      'Dhanbad',
      'Dumka',
      'East Singhbhum',
      'Garhwa',
      'Giridih',
      'Godda',
      'Gumla',
      'Hazaribagh',
      'Jamtara',
      'Khunti',
      'Koderma',
      'Latehar',
      'Lohardaga',
      'Pakur',
      'Palamu',
      'Ramgarh',
      'Ranchi',
      'Sahebganj',
      'Seraikela-Kharsawan',
      'Simdega',
      'West Singhbhum'
    ],
    'Karnataka': [
      'Bagalkot',
      'Ballari',
      'Belagavi',
      'Bengaluru Rural',
      'Bengaluru Urban',
      'Bidar',
      'Chamarajanagar',
      'Chikballapur',
      'Chikkamagaluru',
      'Chitradurga',
      'Dakshina Kannada',
      'Davanagere',
      'Dharwad',
      'Gadag',
      'Hassan',
      'Haveri',
      'Kalaburagi',
      'Kodagu',
      'Kolar',
      'Koppal',
      'Mandya',
      'Mysuru',
      'Raichur',
      'Ramanagara',
      'Shivamogga',
      'Tumakuru',
      'Udupi',
      'Uttara Kannada',
      'Vijayapura',
      'Yadgir'
    ],
    'Kerala': [
      'Alappuzha',
      'Ernakulam',
      'Idukki',
      'Kannur',
      'Kasaragod',
      'Kollam',
      'Kottayam',
      'Kozhikode',
      'Malappuram',
      'Palakkad',
      'Pathanamthitta',
      'Thiruvananthapuram',
      'Thrissur',
      'Wayanad'
    ],
    'Madhya Pradesh': [
      'Agar Malwa',
      'Alirajpur',
      'Anuppur',
      'Ashoknagar',
      'Balaghat',
      'Barwani',
      'Betul',
      'Bhind',
      'Bhopal',
      'Burhanpur',
      'Chhatarpur',
      'Chhindwara',
      'Damoh',
      'Datia',
      'Dewas',
      'Dhar',
      'Dindori',
      'Guna',
      'Gwalior',
      'Harda',
      'Hoshangabad',
      'Indore',
      'Jabalpur',
      'Jhabua',
      'Katni',
      'Khandwa',
      'Khargone',
      'Mandla',
      'Mandsaur',
      'Morena',
      'Narsinghpur',
      'Neemuch',
      'Panna',
      'Raisen',
      'Rajgarh',
      'Ratlam',
      'Rewa',
      'Sagar',
      'Satna',
      'Sehore',
      'Seoni',
      'Shahdol',
      'Shajapur',
      'Sheopur',
      'Shivpuri',
      'Sidhi',
      'Singrauli',
      'Tikamgarh',
      'Ujjain',
      'Umaria',
      'Vidisha'
    ],
    'Maharashtra': [
      'Ahmednagar',
      'Akola',
      'Amravati',
      'Aurangabad',
      'Beed',
      'Bhandara',
      'Buldhana',
      'Chandrapur',
      'Dhule',
      'Gadchiroli',
      'Gondia',
      'Hingoli',
      'Jalgaon',
      'Jalna',
      'Kolhapur',
      'Latur',
      'Mumbai City',
      'Mumbai Suburban',
      'Nagpur',
      'Nanded',
      'Nandurbar',
      'Nashik',
      'Osmanabad',
      'Palghar',
      'Parbhani',
      'Pune',
      'Raigad',
      'Ratnagiri',
      'Sangli',
      'Satara',
      'Sindhudurg',
      'Solapur',
      'Thane',
      'Wardha',
      'Washim',
      'Yavatmal'
    ],
    'Manipur': [
      'Bishnupur',
      'Chandel',
      'Churachandpur',
      'Imphal East',
      'Imphal West',
      'Jiribam',
      'Kakching',
      'Kamjong',
      'Kangpokpi',
      'Noney',
      'Pherzawl',
      'Senapati',
      'Tamenglong',
      'Tengnoupal',
      'Thoubal',
      'Ukhrul'
    ],
    'Meghalaya': [
      'East Garo Hills',
      'East Jaintia Hills',
      'East Khasi Hills',
      'North Garo Hills',
      'Ri Bhoi',
      'South Garo Hills',
      'South West Garo Hills',
      'South West Khasi Hills',
      'West Garo Hills',
      'West Jaintia Hills',
      'West Khasi Hills'
    ],
    'Mizoram': [
      'Aizawl',
      'Champhai',
      'Hnahthial',
      'Khawzawl',
      'Kolasib',
      'Lawngtlai',
      'Lunglei',
      'Mamit',
      'Saiha',
      'Saitual',
      'Serchhip'
    ],
    'Nagaland': [
      'Chümoukedima',
      'Dimapur',
      'Kiphire',
      'Kohima',
      'Longleng',
      'Mokokchung',
      'Mon',
      'Niuland',
      'Noklak',
      'Peren',
      'Phek',
      'Shamator',
      'Tseminyü',
      'Tuensang',
      'Wokha',
      'Zünheboto'
    ],
    'Odisha': [
      'Angul',
      'Balangir',
      'Balasore',
      'Bargarh',
      'Bhadrak',
      'Boudh',
      'Cuttack',
      'Deogarh',
      'Dhenkanal',
      'Gajapati',
      'Ganjam',
      'Jagatsinghpur',
      'Jajpur',
      'Jharsuguda',
      'Kalahandi',
      'Kandhamal',
      'Kendrapara',
      'Kendujhar',
      'Khordha',
      'Koraput',
      'Malkangiri',
      'Mayurbhanj',
      'Nabarangpur',
      'Nayagarh',
      'Nuapada',
      'Puri',
      'Rayagada',
      'Sambalpur',
      'Subarnapur',
      'Sundargarh'
    ],
    'Punjab': [
      'Amritsar',
      'Barnala',
      'Bathinda',
      'Faridkot',
      'Fatehgarh Sahib',
      'Fazilka',
      'Ferozepur',
      'Gurdaspur',
      'Hoshiarpur',
      'Jalandhar',
      'Kapurthala',
      'Ludhiana',
      'Malerkotla',
      'Mansa',
      'Moga',
      'Muktsar',
      'Nawanshahr',
      'Pathankot',
      'Patiala',
      'Rupnagar',
      'Sangrur',
      'SAS Nagar',
      'Tarn Taran'
    ],
    'Rajasthan': [
      'Ajmer',
      'Alwar',
      'Banswara',
      'Baran',
      'Barmer',
      'Bharatpur',
      'Bhilwara',
      'Bikaner',
      'Bundi',
      'Chittorgarh',
      'Churu',
      'Dausa',
      'Dholpur',
      'Dungarpur',
      'Hanumangarh',
      'Jaipur',
      'Jaisalmer',
      'Jalore',
      'Jhalawar',
      'Jhunjhunu',
      'Jodhpur',
      'Karauli',
      'Kota',
      'Nagaur',
      'Pali',
      'Pratapgarh',
      'Rajsamand',
      'Sawai Madhopur',
      'Sikar',
      'Sirohi',
      'Sri Ganganagar',
      'Tonk',
      'Udaipur'
    ],
    'Sikkim': ['East Sikkim', 'North Sikkim', 'South Sikkim', 'West Sikkim'],
    'Tamil Nadu': [
      'Ariyalur',
      'Chengalpattu',
      'Chennai',
      'Coimbatore',
      'Cuddalore',
      'Dharmapuri',
      'Dindigul',
      'Erode',
      'Kallakurichi',
      'Kancheepuram',
      'Karur',
      'Krishnagiri',
      'Madurai',
      'Mayiladuthurai',
      'Nagapattinam',
      'Kanyakumari',
      'Namakkal',
      'Perambalur',
      'Pudukkottai',
      'Ramanathapuram',
      'Ranipet',
      'Salem',
      'Sivaganga',
      'Tenkasi',
      'Thanjavur',
      'Theni',
      'Thoothukudi',
      'Tiruchirappalli',
      'Tirunelveli',
      'Tirupattur',
      'Tiruppur',
      'Tiruvallur',
      'Tiruvannamalai',
      'Tiruvarur',
      'Vellore',
      'Viluppuram',
      'Virudhunagar'
    ],
    'Telangana': [
      'Adilabad',
      'Bhadradri Kothagudem',
      'Hyderabad',
      'Jagtial',
      'Jangaon',
      'Jayashankar Bhupalpally',
      'Jogulamba Gadwal',
      'Kamareddy',
      'Karimnagar',
      'Khammam',
      'Komaram Bheem Asifabad',
      'Mahabubabad',
      'Mahabubnagar',
      'Mancherial',
      'Medak',
      'Medchal-Malkajgiri',
      'Mulugu',
      'Nagarkurnool',
      'Nalgonda',
      'Narayanpet',
      'Nirmal',
      'Nizamabad',
      'Peddapalli',
      'Rajanna Sircilla',
      'Rangareddy',
      'Sangareddy',
      'Siddipet',
      'Suryapet',
      'Vikarabad',
      'Wanaparthy',
      'Warangal',
      'Yadadri Bhuvanagiri'
    ],
    'Tripura': [
      'Dhalai',
      'Gomati',
      'Khowai',
      'North Tripura',
      'Sepahijala',
      'South Tripura',
      'Unakoti',
      'West Tripura'
    ],
    'Uttar Pradesh': [
      'Agra',
      'Aligarh',
      'Ambedkar Nagar',
      'Amethi',
      'Amroha',
      'Auraiya',
      'Ayodhya',
      'Azamgarh',
      'Baghpat',
      'Bahraich',
      'Ballia',
      'Balrampur',
      'Banda',
      'Barabanki',
      'Bareilly',
      'Basti',
      'Bhadohi',
      'Bijnor',
      'Budaun',
      'Bulandshahr',
      'Chandauli',
      'Chitrakoot',
      'Deoria',
      'Etah',
      'Etawah',
      'Farrukhabad',
      'Fatehpur',
      'Firozabad',
      'Gautam Buddha Nagar',
      'Ghaziabad',
      'Ghazipur',
      'Gonda',
      'Gorakhpur',
      'Hamirpur',
      'Hapur',
      'Hardoi',
      'Hathras',
      'Jalaun',
      'Jaunpur',
      'Jhansi',
      'Kannauj',
      'Kanpur Dehat',
      'Kanpur Nagar',
      'Kasganj',
      'Kaushambi',
      'Kushinagar',
      'Lakhimpur Kheri',
      'Lalitpur',
      'Lucknow',
      'Maharajganj',
      'Mahoba',
      'Mainpuri',
      'Mathura',
      'Mau',
      'Meerut',
      'Mirzapur',
      'Moradabad',
      'Muzaffarnagar',
      'Pilibhit',
      'Pratapgarh',
      'Prayagraj',
      'Raebareli',
      'Rampur',
      'Saharanpur',
      'Sambhal',
      'Sant Kabir Nagar',
      'Shahjahanpur',
      'Shamli',
      'Shravasti',
      'Siddharthnagar',
      'Sitapur',
      'Sonbhadra',
      'Sultanpur',
      'Unnao',
      'Varanasi'
    ],
    'Uttarakhand': [
      'Almora',
      'Bageshwar',
      'Chamoli',
      'Champawat',
      'Dehradun',
      'Haridwar',
      'Nainital',
      'Pauri Garhwal',
      'Pithoragarh',
      'Rudraprayag',
      'Tehri Garhwal',
      'Udham Singh Nagar',
      'Uttarkashi'
    ],
    'West Bengal': [
      'Alipurduar',
      'Bankura',
      'Birbhum',
      'Cooch Behar',
      'Dakshin Dinajpur',
      'Darjeeling',
      'Hooghly',
      'Howrah',
      'Jalpaiguri',
      'Jhargram',
      'Kalimpong',
      'Kolkata',
      'Malda',
      'Murshidabad',
      'Nadia',
      'North 24 Parganas',
      'Paschim Bardhaman',
      'Paschim Medinipur',
      'Purba Bardhaman',
      'Purba Medinipur',
      'Purulia',
      'South 24 Parganas',
      'Uttar Dinajpur'
    ],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _pincodeController.dispose();
    _aadharController.dispose();
    _farmSizeController.dispose();
    _cropTypeController.dispose();
    _irrigationController.dispose();
    _machineryController.dispose();
    super.dispose();
  }

  // Fetch markets from API
  Future<List<String>> _fetchMarkets() async {
    if (_selectedState == null || _selectedDistrict == null) return [];

    const String apiKey =
        "579b464db66ec23bdd000001efafcb95abb149a258d2697c3c5fc058"; // Add your API key
    const String resourceId = "9ef84268-d588-465a-a308-a864a43d0070";
    const String url =
        "https://api.data.gov.in/resource/$resourceId?api-key=$apiKey&format=json&limit=10000";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('records') && data['records'] is List) {
          return data['records']
              .where((record) =>
                  record['state'] == _selectedState &&
                  record['district'] == _selectedDistrict)
              .map<String>((record) => record['market'].toString())
              .toSet()
              .toList();
        }
      }
    } catch (error) {
      print("Error fetching markets: $error");
    }
    return [];
  }

  // Save farmer details to Firestore
  Future<void> _saveFarmerDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('farmers').doc(user.phoneNumber).set({
          'uid': user.uid,
          'name': _nameController.text.trim(),
          'addressLine1': _addressLine1Controller.text.trim(),
          'addressLine2': _addressLine2Controller.text.trim(),
          'state': _selectedState,
          'district': _selectedDistrict,
          'market': _selectedMarket,
          'pincode': _pincodeController.text.trim(),
          'aadharNumber': _aadharController.text.trim(),
          'farmSize': _farmSizeController.text.trim(),
          'cropType': _cropTypeController.text.trim(),
          'irrigationMethod': _irrigationController.text.trim(),
          'machineryDetails': _machineryController.text.trim(),
          'phone': user.phoneNumber ?? 'N/A',
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details saved successfully!')),
        );

        Navigator.pushReplacementNamed(context, '/farmer');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving details: $e')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Registration')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_nameController, 'Full Name'),
                    _buildTextField(_addressLine1Controller, 'Address Line 1'),
                    _buildTextField(_addressLine2Controller, 'Address Line 2'),
                    _buildTextField(_pincodeController, 'Pincode'),
                    _buildTextField(_aadharController, 'Aadhar Number'),
                    _buildDropdownField(
                      label: 'State',
                      items: _indiaStatesAndDistricts.keys.toList(),
                      selectedValue: _selectedState,
                      onChanged: (newState) {
                        setState(() {
                          _selectedState = newState;
                          _selectedDistrict = null;
                        });
                      },
                    ),
                    if (_selectedState != null)
                      _buildDropdownField(
                        label: 'District',
                        items: _indiaStatesAndDistricts[_selectedState] ?? [],
                        selectedValue: _selectedDistrict,
                        onChanged: (newDistrict) {
                          setState(() {
                            _selectedDistrict = newDistrict;
                          });
                        },
                      ),
                    if (_selectedState != null && _selectedDistrict != null)
                      FutureBuilder<List<String>>(
                        future: _fetchMarkets(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          List<String> markets = snapshot.data ?? [];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (markets.isNotEmpty)
                                _buildDropdownField(
                                  label: 'Market',
                                  items: markets,
                                  selectedValue: _selectedMarket,
                                  onChanged: (newMarket) {
                                    setState(() {
                                      _selectedMarket = newMarket;
                                    });
                                  },
                                )
                              else ...[
                                const Text(
                                  "No markets found. Add one manually:",
                                  style: TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: "Enter Market Name",
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedMarket = value;
                                    });
                                  },
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    _buildTextField(_farmSizeController, 'Farm Size'),
                    _buildTextField(_cropTypeController, 'Crop Type'),
                    _buildTextField(_irrigationController, 'Irrigation Method'),
                    _buildTextField(_machineryController, 'Machinery Details'),
                    ElevatedButton(
                      onPressed: _saveFarmerDetails,
                      child: const Text('Save & Continue'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration:
            InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) => value!.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? selectedValue,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }
}
