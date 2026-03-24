import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix_partner/authentication/signup_screen.dart';
import 'package:nearfix_partner/main.dart';
import 'package:nearfix_partner/market/models/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePass = true;

  Future<void> _handleLogin() async {
    if (_idController.text.isEmpty || _passController.text.isEmpty) {
      _showSnackBar("Partner ID and Passcode are required");
      return;
    }
    setState(() => _isLoading = true);
    try {
      var uri = Uri.parse(
          'https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/partner_login.php');
      var response = await http.post(
        uri,
        headers: {'ngrok-skip-browser-warning': 'true'},
        body: {'mobile': _idController.text, 'passcode': _passController.text},
      );
      final result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        if (result['id'] != null) {
          await prefs.setInt('provider_id', int.parse(result['id'].toString()));
          await prefs.setString('provider_name', result['user_name'] ?? "Partner");
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
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
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 2),

                    // Brand mark
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 28),

                    Text(
                      'Welcome\nback.',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your partner account',
                      style: TextStyle(fontSize: 15, color: AppColors.grey, fontWeight: FontWeight.w500),
                    ),

                    const SizedBox(height: 40),

                    _buildLabel('PARTNER ID (MOBILE)'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hint: 'Enter mobile number',
                      icon: Icons.phone_android_rounded,
                      controller: _idController,
                      type: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('PASSCODE'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hint: 'Enter your passcode',
                      icon: Icons.lock_outline_rounded,
                      controller: _passController,
                      isPassword: true,
                    ),

                    const SizedBox(height: 32),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Text(
                                'CONNECT',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2),
                              ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Register link
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "New partner? ",
                            style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpScreen()),
                            ),
                            child: Text(
                              "Register now →",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppColors.labelGrey,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePass,
      keyboardType: type,
      cursorColor: AppColors.primary,
      style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.w600, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.labelGrey, fontWeight: FontWeight.w400),
        prefixIcon: Icon(icon, color: AppColors.labelGrey, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.labelGrey,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.borderGrey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
