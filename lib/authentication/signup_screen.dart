import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nearfix_partner/market/models/app_colors.dart';

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
  final _aboutController = TextEditingController();
  final _visitingChargeController = TextEditingController();
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

  final List<String> _identityTypes = [
    'Aadhar Card', 'PAN Card', 'Passport', 'Driving License'
  ];
  final List<String> _cities = [
    'Ahmedabad', 'Mumbai', 'Bangalore', 'Delhi', 'Pune'
  ];
  final ImagePicker _picker = ImagePicker();

  Future<void> _submitEnrollment() async {
    if (_profilePhoto == null || _nameController.text.isEmpty || _visitingChargeController.text.isEmpty) {
      _showSnackBar("Please fill required fields and upload a profile photo", isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      var uri = Uri.parse('https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/register.php');
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({'ngrok-skip-browser-warning': 'true', 'Accept': 'application/json'});
      request.fields['full_name'] = _nameController.text;
      request.fields['mobile'] = _phoneController.text;
      request.fields['email'] = _emailController.text;
      request.fields['passcode'] = _passcodeController.text;
      request.fields['job_title'] = _jobController.text;
      request.fields['about_me'] = _aboutController.text;
      request.fields['experience'] = _expController.text;
      request.fields['visiting_charges'] = _visitingChargeController.text;
      request.fields['city'] = _selectedCity ?? "";
      request.fields['id_type'] = _selectedIdentity ?? "";
      request.fields['id_num'] = _idNumController.text;
      request.fields['bank'] = _bankController.text;
      request.fields['account'] = _accController.text;
      request.fields['ifsc'] = _ifscController.text;
      if (_idFront != null)
        request.files.add(await http.MultipartFile.fromPath('id_front', _idFront!.path));
      if (_idBack != null)
        request.files.add(await http.MultipartFile.fromPath('id_back', _idBack!.path));
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
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.dark),
          ),
        ),
        title: Text(
          'Partner Enrollment',
          style: TextStyle(
            color: AppColors.dark,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Join NearFix',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.dark,
                    letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text('Create your professional profile',
                style: TextStyle(fontSize: 14, color: AppColors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 28),

            _buildSectionCard('PERSONAL DETAILS', Icons.person_outline_rounded, [
              _buildTextField('Full Legal Name', _nameController),
              _buildTextField('Mobile Number', _phoneController, type: TextInputType.phone),
              _buildTextField('Email Address', _emailController, type: TextInputType.emailAddress),
              _buildTextField('Set Passcode', _passcodeController, isPass: true),
            ]),

            _buildSectionCard('EXPERTISE & PRICING', Icons.work_outline_rounded, [
              _buildTextField('Job Title (e.g. Electrician)', _jobController),
              _buildTextField('Years of Experience', _expController, type: TextInputType.number),
              _buildTextField('Visiting Charges (₹)', _visitingChargeController,
                  type: TextInputType.number, prefixIcon: Icons.currency_rupee_rounded),
              _buildTextField('About Your Work / Skills', _aboutController,
                  maxLines: 3, type: TextInputType.multiline),
              _buildDropdown('Service City', _selectedCity, _cities,
                  (val) => setState(() => _selectedCity = val)),
            ]),

            _buildSectionCard('IDENTITY VERIFICATION', Icons.verified_user_outlined, [
              _buildDropdown('Identity Type', _selectedIdentity, _identityTypes,
                  (val) => setState(() => _selectedIdentity = val)),
              _buildTextField('Identity Number', _idNumController),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: _buildUploadBox('ID FRONT', _idFront, () => _pickImage('front'))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildUploadBox('ID BACK', _idBack, () => _pickImage('back'))),
                ],
              ),
            ]),

            _buildSectionCard('BANKING DETAILS', Icons.account_balance_outlined, [
              _buildTextField('Bank Name', _bankController),
              _buildTextField('Account Number', _accController, type: TextInputType.number),
              _buildTextField('IFSC Code', _ifscController),
            ]),

            _buildSectionCard('PROFILE PICTURE', Icons.camera_alt_outlined, [
              _buildPhotoTile(_profilePhoto, () => _pickImage('profile')),
            ]),

            const SizedBox(height: 32),
            SliverButton(
                isLoading: _isLoading,
                onPressed: _submitEnrollment,
                text: 'SUBMIT APPLICATION'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 14, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: 1.2)),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {TextInputType type = TextInputType.text,
      bool isPass = false,
      int maxLines = 1,
      IconData? prefixIcon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: type,
        obscureText: isPass,
        maxLines: maxLines,
        cursorColor: AppColors.primary,
        style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.w500, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.labelGrey, fontSize: 14),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 18, color: AppColors.labelGrey)
              : null,
          filled: true,
          fillColor: AppColors.surfaceAlt,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderGrey, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String hint, String? value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: Colors.white,
        style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.w500, fontSize: 14),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.labelGrey, fontSize: 14),
          filled: true,
          fillColor: AppColors.surfaceAlt,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderGrey, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadBox(String label, File? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 100,
        decoration: BoxDecoration(
          color: file != null ? Colors.transparent : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: file != null ? AppColors.primary : AppColors.borderGrey,
              width: file != null ? 2 : 1.5),
          image: file != null
              ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
              : null,
        ),
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 26, color: AppColors.primary.withOpacity(0.6)),
                  const SizedBox(height: 6),
                  Text(label,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppColors.grey,
                          letterSpacing: 0.8)),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildPhotoTile(File? file, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey, width: 1.5),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: file != null
                ? Image.file(file, width: 52, height: 52, fit: BoxFit.cover)
                : Container(
                    width: 52,
                    height: 52,
                    color: AppColors.primaryLight,
                    child: Icon(Icons.person_rounded, color: AppColors.primary, size: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PROFESSIONAL PHOTO',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark,
                        letterSpacing: 0.5)),
                const SizedBox(height: 3),
                Text(file == null ? 'Tap to upload' : 'Photo selected ✓',
                    style: TextStyle(
                        fontSize: 12,
                        color: file == null ? AppColors.grey : AppColors.primary,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(file == null ? 'Upload' : 'Change',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: isError ? Colors.red.shade600 : AppColors.primary,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, color: AppColors.primary, size: 36),
              ),
              const SizedBox(height: 20),
              Text("Application Sent!",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dark)),
              const SizedBox(height: 10),
              Text(
                "Thank you for joining NearFix! Our team will review your documents and verify your profile within 24-48 hours.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(c);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("GOT IT",
                      style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(String type) async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      setState(() {
        if (type == 'front') _idFront = File(image.path);
        if (type == 'back') _idBack = File(image.path);
        if (type == 'profile') _profilePhoto = File(image.path);
      });
    }
  }
}

class SliverButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String text;

  const SliverButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(text,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0)),
      ),
    );
  }
}
