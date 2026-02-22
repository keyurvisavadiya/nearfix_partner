import 'package:flutter/material.dart';

import 'login_screen.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: LoginScreen(), // You can toggle this to SignUpScreen()
));

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Selection States
  String? _selectedIdentity;
  String? _selectedCity;

  // Data Lists
  final List<String> _identityTypes = [
    'Aadhar Card',
    'PAN Card',
    'Election Card',
    'Passport',
    'Driving License'
  ];

  final List<String> _cities = [
    'Ahmedabad',
    'Mumbai',
    'Bangalore',
    'Delhi',
    'Hyderabad',
    'Chennai',
    'Pune'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Join ServicePro',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 8),
            const Text(
              'COMPLETE YOUR PROFESSIONAL\nPROFILE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 32),

            _buildSectionLabel('PERSONAL CREDENTIALS'),
            _buildTextField('Full Legal Name'),
            _buildTextField('Mobile Number', keyboardType: TextInputType.phone),
            _buildTextField('Email Address', keyboardType: TextInputType.emailAddress),

            // EXPERTISE SECTION
            _buildSectionLabel('EXPERTISE & REACH'),
            _buildTextField('Job Title / Role'),
            _buildTextField('Years of Experience', keyboardType: TextInputType.number),
            _buildCustomDropdown(
              hint: 'Select Operational City',
              value: _selectedCity,
              items: _cities,
              onChanged: (val) => setState(() => _selectedCity = val),
            ),

            //  IDENTITY SECTION
            _buildSectionLabel('GOVERNMENT IDENTITY'),
            _buildCustomDropdown(
              hint: 'Select Identity Document',
              value: _selectedIdentity,
              items: _identityTypes,
              onChanged: (val) => setState(() => _selectedIdentity = val),
            ),
            _buildTextField('Enter ID Document Number'),

            Row(
              children: [
                Expanded(child: _buildUploadBox('UPLOAD FRONT')),
                const SizedBox(width: 12),
                Expanded(child: _buildUploadBox('UPLOAD BACK')),
              ],
            ),

            //  PAYOUT SECTION
            _buildSectionLabel('PAYOUT NODE CONFIGURATION'),
            _buildTextField('Bank Name'),
            _buildTextField('Account Number'),
            _buildTextField('IFSC Code'),

            // VISIBILITY SECTION
            _buildSectionLabel('PROFILE VISIBILITY'),
            _buildPhotoTile(),

            const SizedBox(height: 40),

            // SUBMIT
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'SUBMIT ENROLLMENT',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // REUSABLE COMPONENTS

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildTextField(String hint, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF9333EA), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9333EA)),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF9333EA), width: 1.5),
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildUploadBox(String label) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_a_photo_outlined, size: 24, color: Colors.black26),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black38)),
        ],
      ),
    );
  }

  Widget _buildPhotoTile() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_box_outlined, color: Colors.black26, size: 28),
          const SizedBox(width: 12),
          const Text('PASSPORT SIZE PHOTO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black45)),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: const Text('UPLOAD', style: TextStyle(color: Color(0xFF9333EA), fontWeight: FontWeight.w900, fontSize: 11)),
          )
        ],
      ),
    );
  }
}