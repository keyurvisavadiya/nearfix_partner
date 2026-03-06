import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix_partner/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_idController.text.isEmpty || _passController.text.isEmpty) {
      _showSnackBar("Credentials required");
      return;
    }
    setState(() => _isLoading = true);
    try {
      var response = await http.post(
        Uri.parse('https://nonregimented-ably-amare.ngrok-free.dev/nearfix/partner_login.php'),
        headers: {'ngrok-skip-browser-warning': 'true'},
        body: {'mobile': _idController.text, 'passcode': _passController.text},
      );
      final result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('provider_id', int.parse(result['id'].toString()));
        await prefs.setString('provider_name', result['user_name'] ?? "Partner");
        await prefs.setString('category', result['specialty'] ?? "Professional");
        await prefs.setString('profile_pic', result['profile_photo_path'] ?? ""); // Matches PHP Key

        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()));
      } else {
        _showSnackBar(result['message'] ?? "Login failed");
      }
    } catch (e) {
      _showSnackBar("Connection failed");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF8B5CF6), size: 40),
              ),
              const SizedBox(height: 32),
              const Text('GATEWAY', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const Text('PARTNER AUTHENTICATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black38)),
              const SizedBox(height: 48),
              _buildField('Partner ID', Icons.person_outline, _idController),
              const SizedBox(height: 16),
              _buildField('Passcode', Icons.key_outlined, _passController, isPass: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('CONNECT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String hint, IconData icon, TextEditingController ctrl, {bool isPass = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black26),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFF3F4F6))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF8B5CF6))),
      ),
    );
  }
}