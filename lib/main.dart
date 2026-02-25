import 'package:flutter/material.dart';
import 'package:nearfix_partner/authentication/login_screen.dart';
import 'dart:io';
import 'package:nearfix_partner/chat_screen/chat_screen_tile.dart';
import 'package:nearfix_partner/home_screen/home_screen.dart';
import 'package:nearfix_partner/market/screen/market_screen.dart';
import 'package:nearfix_partner/profile/profile_screen.dart';

// --- 1. THE SSL BYPASS ---
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginScreen(),
  ));
}

// --- 2. MAIN NAVIGATION WRAPPER ---
class MyApp extends StatefulWidget {
  // Define variables to receive data from LoginScreen
  final String userName;
  final String specialty;

  // Add them to the constructor
  const MyApp({
    super.key,
    required this.userName,
    required this.specialty
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 3. Define screens inside build to access 'widget.userName'
    final List<Widget> screens = [
      HomeScreen(
        userName: widget.userName,
        job_title: widget.specialty, // Matching your HomeScreen parameter
      ),
      const MarketScreen(),
      const ChatScreen(),
      const ProviderProfileScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF9333EA),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'MARKET'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'CHAT'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'PROFILE'),
        ],
      ),
    );
  }
}