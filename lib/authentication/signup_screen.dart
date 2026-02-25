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
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passcodeController = TextEditingController();
  final _jobController = TextEditingController();
  final _expController = TextEditingController();
  final _aboutController = TextEditingController(); // 1. Added Bio Controller
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

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _passcodeController.clear();
      _jobController.clear();
      _expController.clear();
      _aboutController.clear(); // 2. Reset the bio field
      _idNumController.clear();
      _bankController.clear();
      _accController.clear();
      _ifscController.clear();

      _selectedIdentity = null;
      _selectedCity = null;
      _idFront = null;
      _idBack = null;
      _profilePhoto = null;
    });
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Text("Submitted Successfully"),
        content: const Text("Your profile is under review."),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
              child: const Text("OK")
          )
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

  Future<void> _submitEnrollment() async {
    if (_idFront == null || _profilePhoto == null || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Missing required fields!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      var uri = Uri.parse('https://nonregimented-ably-amare.ngrok-free.dev/nearfix/register.php');
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'ngrok-skip-browser-warning': 'true',
        'Accept': 'application/json',
      });

      request.fields['full_name'] = _nameController.text;
      request.fields['mobile'] = _phoneController.text;
      request.fields['email'] = _emailController.text;
      request.fields['passcode'] = _passcodeController.text;
      request.fields['job_title'] = _jobController.text;
      request.fields['experience'] = _expController.text;
      request.fields['about_me'] = _aboutController.text; // 3. Added to multipart request
      request.fields['city'] = _selectedCity ?? "";
      request.fields['id_type'] = _selectedIdentity ?? "";
      request.fields['id_num'] = _idNumController.text;
      request.fields['bank'] = _bankController.text;
      request.fields['account'] = _accController.text;
      request.fields['ifsc'] = _ifscController.text;

      request.files.add(await http.MultipartFile.fromPath('id_front', _idFront!.path));
      if (_idBack != null) request.files.add(await http.MultipartFile.fromPath('id_back', _idBack!.path));
      request.files.add(await http.MultipartFile.fromPath('profile_photo', _profilePhoto!.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          _showSuccess();
        } else {
          _showError(result['message']);
        }
      } else {
        _showError("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Connection failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
          leading: const BackButton(color: Colors.black)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Join ServicePro', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                const Text('COMPLETE YOUR PROFESSIONAL PROFILE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),

                _buildSectionLabel('PERSONAL CREDENTIALS'),
                _buildTextField('Full Legal Name', _nameController),
                _buildTextField('Mobile Number', _phoneController, type: TextInputType.phone),
                _buildTextField('Email Address', _emailController, type: TextInputType.emailAddress),
                _buildTextField('Set Passcode', _passcodeController, isPass: true),

                _buildSectionLabel('EXPERTISE & REACH'),
                _buildTextField('Job Title', _jobController),
                _buildTextField('Years of Experience', _expController, type: TextInputType.number),
                // 4. Added the "About Me" UI Field here
                _buildTextField(
                    'About Me (Skills, Specialization, etc.)',
                    _aboutController,
                    maxLines: 3, // Multi-line support
                    type: TextInputType.multiline
                ),
                _buildDropdown('Select City', _selectedCity, _cities, (val) => setState(() => _selectedCity = val)),

                _buildSectionLabel('GOVERNMENT IDENTITY'),
                _buildDropdown('Select ID Type', _selectedIdentity, _identityTypes, (val) => setState(() => _selectedIdentity = val)),
                _buildTextField('ID Number', _idNumController),

                Row(
                  children: [
                    Expanded(child: _buildUploadBox('UPLOAD FRONT', _idFront, () => _pickImage('front'))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildUploadBox('UPLOAD BACK', _idBack, () => _pickImage('back'))),
                  ],
                ),

                _buildSectionLabel('PAYOUT CONFIGURATION'),
                _buildTextField('Bank Name', _bankController),
                _buildTextField('Account Number', _accController),
                _buildTextField('IFSC Code', _ifscController),

                _buildSectionLabel('PROFILE PHOTO'),
                _buildPhotoTile(_profilePhoto, () => _pickImage('profile')),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitEnrollment,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9333EA),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('SUBMIT ENROLLMENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPERS ---
  Widget _buildSectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
  );

  // Updated Helper to support maxLines for About Me
  Widget _buildTextField(String hint, TextEditingController controller, {TextInputType type = TextInputType.text, bool isPass = false, int maxLines = 1}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      keyboardType: type,
      obscureText: isPass,
      maxLines: maxLines, // Use the maxLines parameter
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF9333EA))),
      ),
    ),
  );

  Widget _buildUploadBox(String label, File? file, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        image: file != null ? DecorationImage(image: FileImage(file), fit: BoxFit.cover) : null,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: file == null ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.add_a_photo_outlined, size: 24, color: Colors.black26),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black38)),
      ]) : null,
    ),
  );

  Widget _buildPhotoTile(File? file, VoidCallback onTap) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF1F5F9))),
    child: Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: file != null
            ? Image.file(file, width: 40, height: 40, fit: BoxFit.cover)
            : const Icon(Icons.account_box_outlined, color: Colors.black26, size: 40),
      ),
      const SizedBox(width: 12),
      const Text('PASSPORT SIZE PHOTO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black45)),
      const Spacer(),
      TextButton(onPressed: onTap, child: Text(file == null ? 'UPLOAD' : 'CHANGE', style: const TextStyle(color: Color(0xFF9333EA), fontWeight: FontWeight.w900))),
    ]),
  );

  Widget _buildDropdown(String hint, String? value, List<String> items, Function(String?) onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
      ),
    ),
  );
}