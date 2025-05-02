import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const JanSarrthiApp());
}

class JanSarrthiApp extends StatelessWidget {
  const JanSarrthiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jan Sarrthi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Inter',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
          bodySmall: TextStyle(fontSize: 14.0, color: Colors.grey),
          titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
      home: const ContactMePage(),
    );
  }
}

class ContactMePage extends StatefulWidget {
  const ContactMePage({super.key});

  @override
  State<ContactMePage> createState() => _ContactMePageState();
}

class _ContactMePageState extends State<ContactMePage> {
  String _selectedReason = 'Select a reason';
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final List<String> _reasons = [
    'Select a reason',
    'Suggestion',
    'Complaint',
    'Feedback',
    'Volunteer Interest',
    'Other',
  ];
  String? _otherReason;
  final String _recipientEmail = 'prashantkumar.official957@gmail.com';
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      await FirebaseFirestore.instance.collection('contactMessages').add({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'reason': _selectedReason == 'Other' ? _otherReason?.trim() : _selectedReason,
        'message': _messageController.text.trim(),
        'timestamp': Timestamp.now(),
      });

      _showCustomSnackBar(context, 'Message sent successfully!', isSuccess: true);

      _formKey.currentState!.reset();
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
      _selectedReason = 'Select a reason';
      _otherReason = null;
      setState(() {});
    } catch (e) {
      _showCustomSnackBar(context, 'Error uploading message: ${e.toString()}', isSuccess: false);
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showCustomSnackBar(BuildContext context, String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0EAFC), Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 20),
                  const Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.support_agent, size: 60, color: Color(0xFF6A11CB)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'How can we help you?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2575FC)),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6A11CB)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6A11CB), width: 2),
                      ),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6A11CB)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6A11CB), width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedReason,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedReason = newValue!;
                        if (_selectedReason != 'Other') _otherReason = null;
                      });
                    },
                    items: _reasons.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.black87)),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Reason for Contact',
                      prefixIcon: const Icon(Icons.subject_outlined, color: Color(0xFF6A11CB)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6A11CB), width: 2),
                      ),
                    ),
                    validator: (value) =>
                    value == 'Select a reason' ? 'Please select a reason' : null,
                  ),
                  if (_selectedReason == 'Other') ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      onChanged: (value) => _otherReason = value,
                      decoration: InputDecoration(
                        labelText: 'Specify Reason',
                        prefixIcon: const Icon(Icons.edit_outlined, color: Color(0xFF6A11CB)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6A11CB), width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (_selectedReason == 'Other' && value!.isEmpty) {
                          return 'Please specify your reason';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Your Message',
                      alignLabelWithHint: true,
                      prefixIcon: const Icon(Icons.message_outlined, color: Color(0xFF6A11CB)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6A11CB), width: 2),
                      ),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your message' : null,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isSending ? null : _sendEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A11CB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: const Color(0xFF6A11CB).withOpacity(0.3),
                    ),
                    child: _isSending
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, color: Colors.white),
                        SizedBox(width: 10),
                        Text('Send Message', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text(
                    'Prefer to contact us directly?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => launchUrl(Uri.parse('mailto:$_recipientEmail')),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6A11CB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Open Email App Directly',
                      style: TextStyle(color: Color(0xFF6A11CB)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}