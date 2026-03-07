import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // --- CONTROLLERS ---
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passcodeController = TextEditingController();
  final _jobController = TextEditingController();
  final _expController = TextEditingController();
  final _aboutController = TextEditingController();
  final _visitingChargeController = TextEditingController(); // NEW
  final _idNumController = TextEditingController();
  final _bankController = TextEditingController();
  final _accController = TextEditingController();
  final _ifscController = TextEditingController();

  String? _selectedIdentity;
  String? _selectedCity;
  File? _idFront;
  File? _idBack;
  File? _profilePhoto;
  bool _isLoading = false;

  final List<String> _identityTypes = ['Aadhar Card', 'PAN Card', 'Passport', 'Driving License'];
  final List<String> _cities = ['Ahmedabad', 'Mumbai', 'Bangalore', 'Delhi', 'Pune'];
  final ImagePicker _picker = ImagePicker();

  Future<void> _submitEnrollment() async {
    // Basic Validation
    if (_profilePhoto == null || _nameController.text.isEmpty || _visitingChargeController.text.isEmpty) {
      _showSnackBar("Please fill required fields and upload a profile photo", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      var uri = Uri.parse('https://nonregimented-ably-amare.ngrok-free.dev/nearfix/register.php');
      var request = http.MultipartRequest('POST', uri);

      // Necessary for ngrok and JSON handling
      request.headers.addAll({
        'ngrok-skip-browser-warning': 'true',
        'Accept': 'application/json',
      });

      // --- TEXT FIELDS (MUST MATCH PHP $_POST KEYS) ---
      request.fields['full_name'] = _nameController.text;
      request.fields['mobile'] = _phoneController.text;
      request.fields['email'] = _emailController.text;
      request.fields['passcode'] = _passcodeController.text;
      request.fields['job_title'] = _jobController.text;
      request.fields['about_me'] = _aboutController.text;
      request.fields['experience'] = _expController.text;
      request.fields['visiting_charges'] = _visitingChargeController.text; // Matches PHP
      request.fields['city'] = _selectedCity ?? "";
      request.fields['id_type'] = _selectedIdentity ?? "";
      request.fields['id_num'] = _idNumController.text;
      request.fields['bank'] = _bankController.text;
      request.fields['account'] = _accController.text;
      request.fields['ifsc'] = _ifscController.text;

      // --- FILE FIELDS (MUST MATCH PHP $_FILES KEYS) ---
      if (_idFront != null) {
        request.files.add(await http.MultipartFile.fromPath('id_front', _idFront!.path));
      }
      if (_idBack != null) {
        request.files.add(await http.MultipartFile.fromPath('id_back', _idBack!.path));
      }
      request.files.add(await http.MultipartFile.fromPath('profile_photo', _profilePhoto!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          _showSuccessDialog();
        } else {
          _showSnackBar(result['message'] ?? "Registration failed", isError: true);
        }
      } else {
        _showSnackBar("Server error: ${response.statusCode}", isError: true);
      }
    } catch (e) {
      _showSnackBar("Connection failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Partner Enrollment', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Join NearFix', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            const Text('CREATE YOUR PROFESSIONAL PROFILE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),

            _buildSectionLabel('PERSONAL DETAILS'),
            _buildTextField('Full Legal Name', _nameController),
            _buildTextField('Mobile Number', _phoneController, type: TextInputType.phone),
            _buildTextField('Email Address', _emailController, type: TextInputType.emailAddress),
            _buildTextField('Set Passcode', _passcodeController, isPass: true),

            _buildSectionLabel('EXPERTISE & PRICING'),
            _buildTextField('Job Title (e.g. Electrician)', _jobController),
            _buildTextField('Years of Experience', _expController, type: TextInputType.number),

            // --- VISITING CHARGE FIELD ---
            _buildTextField(
                'Visiting Charges (₹)',
                _visitingChargeController,
                type: TextInputType.number,
                prefixIcon: Icons.currency_rupee_rounded
            ),

            _buildTextField('About Your Work / Skills', _aboutController, maxLines: 3, type: TextInputType.multiline),
            _buildDropdown('Service City', _selectedCity, _cities, (val) => setState(() => _selectedCity = val)),

            _buildSectionLabel('IDENTITY VERIFICATION'),
            _buildDropdown('Identity Type', _selectedIdentity, _identityTypes, (val) => setState(() => _selectedIdentity = val)),
            _buildTextField('Identity Number', _idNumController),

            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildUploadBox('ID FRONT', _idFront, () => _pickImage('front'))),
                const SizedBox(width: 12),
                Expanded(child: _buildUploadBox('ID BACK', _idBack, () => _pickImage('back'))),
              ],
            ),

            _buildSectionLabel('BANKING DETAILS (FOR PAYOUTS)'),
            _buildTextField('Bank Name', _bankController),
            _buildTextField('Account Number', _accController, type: TextInputType.number),
            _buildTextField('IFSC Code', _ifscController),

            _buildSectionLabel('PROFILE PICTURE'),
            _buildPhotoTile(_profilePhoto, () => _pickImage('profile')),

            const SizedBox(height: 40),
            SliverButton(
              isLoading: _isLoading,
              onPressed: _submitEnrollment,
              text: 'SUBMIT APPLICATION',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 1)),
  );

  Widget _buildTextField(String hint, TextEditingController controller, {TextInputType type = TextInputType.text, bool isPass = false, int maxLines = 1, IconData? prefixIcon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: type,
        obscureText: isPass,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: Colors.black45) : null,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF9333EA))),
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildUploadBox(String label, File? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          image: file != null ? DecorationImage(image: FileImage(file), fit: BoxFit.cover) : null,
        ),
        child: file == null ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_outlined, size: 24, color: Colors.black26),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black38)),
          ],
        ) : null,
      ),
    );
  }

  Widget _buildPhotoTile(File? file, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: file != null
                ? Image.file(file, width: 50, height: 50, fit: BoxFit.cover)
                : Container(width: 50, height: 50, color: Colors.black12, child: const Icon(Icons.person, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          const Text('PROFESSIONAL PHOTO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black45)),
          const Spacer(),
          TextButton(onPressed: onTap, child: Text(file == null ? 'UPLOAD' : 'CHANGE', style: const TextStyle(color: Color(0xFF9333EA), fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.green));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Application Sent"),
        content: const Text("Thank you for joining NearFix! Our team will review your documents and verify your profile within 24-48 hours."),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text("GOT IT", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9333EA)))),
        ],
      ),
    );
  }

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      setState(() {
        if (type == 'front') _idFront = File(image.path);
        if (type == 'back') _idBack = File(image.path);
        if (type == 'profile') _profilePhoto = File(image.path);
      });
    }
  }
}

// Simple Custom Button to match your UI
class SliverButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String text;

  const SliverButton({super.key, required this.isLoading, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9333EA),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}