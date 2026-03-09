import 'package:flutter/material.dart';
import 'package:nearfix_partner/authentication/login_screen.dart';
import 'dart:io';
import 'package:nearfix_partner/chat_screen/chat_screen_tile.dart';
import 'package:nearfix_partner/home_screen/home_screen.dart';
import 'package:nearfix_partner/market/screen/market_screen.dart';
import 'package:nearfix_partner/profile/profile_screen.dart' hide HomeScreen;
import 'package:shared_preferences/shared_preferences.dart';

// --- 1. THE SSL BYPASS ---
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  final prefs = await SharedPreferences.getInstance();

  // Retrieve saved ID to check if user is logged in
  final int? providerId = prefs.getInt('provider_id');

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true), // Enable modern Material 3 styling
    // If providerId exists, go to the Navigation Wrapper, else Login
    home: providerId != null ? const MyApp() : const LoginScreen(),
  ));
}

// --- 2. MAIN NAVIGATION WRAPPER ---
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  // Define screens here. Notice HomeScreen no longer needs parameters passed from here.
  final List<Widget> _screens = [
    const HomeScreen(), // Now fully dynamic inside its own state
    const MarketScreen(),
    const ChatScreen(),
    const ProviderProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // Using IndexedStack preserves the scroll state of your screens
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF9333EA),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
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