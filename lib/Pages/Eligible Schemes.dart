import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jan_saarthi/Pages/Dashboard.dart';
import 'package:url_launcher/url_launcher.dart';

class EligibleSchemesScreen extends StatefulWidget {
  const EligibleSchemesScreen({super.key});

  @override
  State<EligibleSchemesScreen> createState() => _EligibleSchemesScreenState();
}

class _EligibleSchemesScreenState extends State<EligibleSchemesScreen> {
  List<dynamic> schemes = [];
  bool isLoading = true;
  bool userDataFetched = false;

  int userAge = 0;
  String userGender = '';
  String userState = '';

  @override
  void initState() {
    super.initState();
    fetchUserDataAndSchemes();
    fetchSchemes(); // Fetch schemes independently
  }

  Future<void> fetchUserDataAndSchemes() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final doc = await FirebaseFirestore.instance
            .collection('Posts') // Changed collection name to 'Posts'
            .doc(currentUser.uid)
            .get();

        if (doc.exists) {
          final data = doc.data();
          userAge = data?['age'] ?? 0;
          userGender = _sanitizeValue(data?['sex'] as String?); // Changed key to 'sex'
          userState = _sanitizeValue(data?['state'] as String?);
          userDataFetched = true;
          _showSnackBar(context, 'User data fetched successfully');
          print('Firebase User Data - Age: $userAge, Gender: $userGender, State: $userState');
        } else {
          _showSnackBar(context, 'Error: User data not found in Firebase');
        }
      } else {
        _showSnackBar(context, 'Error: User not logged in');
      }
    } catch (e) {
      _showSnackBar(context, 'Error fetching user data: $e');
    }
  }
  Future<void> fetchSchemes() async {
    try {
      final response = await http
          .get(Uri.parse('https://webadmin-panel-2.onrender.com/api/schemes'));
      if (response.statusCode == 200) {
        final List<dynamic> decodedSchemes = json.decode(response.body);
        setState(() {
          schemes = decodedSchemes;
          isLoading = false;
        });
        print('API Schemes Data: $schemes');
      } else {
        setState(() => isLoading = false);
        _showSnackBar(context,
            'Failed to load schemes. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar(context, 'Error fetching schemes: $e');
    }
  }

  String _sanitizeValue(String? value) {
    if (value == null) {
      return '';
    }
    return value.toLowerCase().trim().replaceAll(RegExp(r'[,\s]+'), '');
  }

  bool isUserEligible(Map<String, dynamic> scheme) {
    int minAge = scheme['minAge'] ?? 0;
    int maxAge = scheme['maxAge'] ?? 100;
    String gender = _sanitizeValue(scheme['gender'] as String?);
    String schemeState = _sanitizeValue(scheme['state'] as String?);

    bool ageMatch = userAge >= minAge && userAge <= maxAge;
    bool genderMatch = gender == 'both' || gender == userGender;
    bool stateMatch = schemeState == 'allstates' || schemeState == userState;

    print('Evaluating Scheme: ${scheme['title']}');
    print('  Scheme Min Age: $minAge, Max Age: $maxAge, Gender: $gender, State: $schemeState');
    print('  User Age: $userAge, Gender: $userGender, State: $userState');
    print('  Age Match: $ageMatch, Gender Match: $genderMatch, State Match: $stateMatch');

    return ageMatch && genderMatch && stateMatch;
  }

  void _showSnackBar(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.deepPurple,
        ),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnackBar(context, 'Could not launch $url');
    }
  }

  Widget _buildImageWidget(String imageLink) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Image.network(
        imageLink,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          color: Colors.grey[300],
          child: const Icon(Icons.image, size: 60, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title:
        const Text("All Schemes", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const Dashboard())),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : schemes.isEmpty
          ? const Center(child: Text("No schemes found"))
          : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: schemes.length,
          itemBuilder: (context, index) {
            final scheme = schemes[index];
            final eligible = isUserEligible(scheme);

            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageWidget(scheme['imageLink'] ?? ''),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                scheme['title'] ?? 'No Title',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2575FC)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: eligible
                                    ? Colors.green
                                    : Colors.redAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    eligible
                                        ? Icons.verified
                                        : Icons.cancel,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    eligible ? 'Eligible' : 'Ineligible',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          scheme['description'] ??
                              'No description available',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.cake_outlined, "Age Range",
                            "${scheme['minAge']} - ${scheme['maxAge']}"),
                        _buildInfoRow(Icons.person_outline, "Gender",
                            scheme['gender'] ?? "All"),
                        _buildInfoRow(Icons.location_on_outlined, "State",
                            scheme['state'] ?? "All India"),
                        const SizedBox(height: 12),
                        if (scheme['pdfLink'] != null)
                          ElevatedButton.icon(
                            onPressed: () =>
                                _launchURL(scheme['pdfLink']),
                            icon: const Icon(Icons.download,color: Colors.white,),
                            label: const Text("Download PDF/ Apply For Scheme",style: TextStyle(color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple),
                          ),
                        if (scheme['applyLink'] != null)
                          OutlinedButton.icon(
                            onPressed: () =>
                                _launchURL(scheme['applyLink']),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text("Apply Now"),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }),
    );
  }
}