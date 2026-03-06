import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix_partner/authentication/signup_screen.dart';
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
      _showSnackBar("Partner ID and Passcode are required");
      return;
    }

    setState(() => _isLoading = true);

    try {
      var uri = Uri.parse('https://nonregimented-ably-amare.ngrok-free.dev/nearfix/partner_login.php');
      var response = await http.post(
        uri,
        headers: {'ngrok-skip-browser-warning': 'true'},
        body: {
          'mobile': _idController.text,
          'passcode': _passController.text,
        },
      );

      final result = jsonDecode(response.body);

      if (result['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();

        if (result['id'] != null) {
          await prefs.setInt('provider_id', int.parse(result['id'].toString()));
          await prefs.setString('provider_name', result['user_name'] ?? "Partner");

          // CRITICAL FIX: Save the path coming from your PHP
          // Since DB has "uploads/filename.jpg", we save it as is.
          await prefs.setString('profile_pic', result['profile_photo_path'] ?? "");

          await prefs.setString('category', result['specialty'] ?? "");
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      } else {
        _showSnackBar(result['message'] ?? "Login failed");
      }
    } catch (e) {
      _showSnackBar("Connection failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'GATEWAY',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const Text(
                      'PARTNER AUTHENTICATION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black38,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    _buildTextField(
                      hint: 'Partner ID (Mobile)',
                      icon: Icons.person_outline,
                      controller: _idController,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      hint: 'Passcode',
                      icon: Icons.key_outlined,
                      isPassword: true,
                      controller: _passController,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                            : const Text(
                          'CONNECT',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Spacer(flex: 3),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "NEW PARTNER? ",
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUpScreen()),
                              );
                            },
                            child: const Text(
                              "REGISTER NOW",
                              style: TextStyle(
                                color: Color(0xFF8B5CF6),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      cursorColor: const Color(0xFF8B5CF6),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black26),
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
        ),
      ),
    );
  }
}