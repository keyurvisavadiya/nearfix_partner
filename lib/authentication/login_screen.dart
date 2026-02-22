import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nearfix_partner/authentication/signup_screen.dart';

void main() {
  // Sets the status bar to transparent for a cleaner look
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const GatewayApp());
}

class GatewayApp extends StatelessWidget {
  const GatewayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gateway Partner',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans-serif', // Uses default system sans-serif
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false, // Allows centering content while keeping it scrollable
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // --- PURPLE ICON BOX ---
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

                    // --- BRANDING ---
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

                    // --- INPUT FIELDS ---
                    _buildTextField(
                      hint: 'Partner ID',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      hint: 'Passcode',
                      icon: Icons.key_outlined,
                      isPassword: true,
                    ),
                    const SizedBox(height: 32),

                    // --- CONNECT BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle Login Logic here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'CONNECT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // --- FOOTER ---
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
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context)=>SignUpScreen()));
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

  // A reusable TextField widget to keep the code DRY (Don't Repeat Yourself)
  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      cursorColor: const Color(0xFF8B5CF6),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        // Subtle border as seen in the image
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