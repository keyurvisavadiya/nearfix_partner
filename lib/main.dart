import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your internal files
import 'package:nearfix_partner/authentication/login_screen.dart';
import 'package:nearfix_partner/home_screen/home_screen.dart';
import 'package:nearfix_partner/market/screen/market_screen.dart';
import 'package:nearfix_partner/chat_screen/chat_screen_tile.dart';
import 'package:nearfix_partner/profile/profile_screen.dart' hide HomeScreen;

import 'onboarding_screen/onboarding_screen.dart';

// --- 1. SSL BYPASS (For development) ---
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

  // Retrieve states
  final bool onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
  final int? providerId = prefs.getInt('provider_id');

  // Logic to determine the starting screen
  Widget initialScreen;

  if (!onboardingSeen) {
    // Brand new user
    initialScreen = const OnboardingScreen();
  } else if (providerId == null) {
    // Has seen onboarding but is logged out
    initialScreen = const LoginScreen();
  } else {
    // Logged in and seen onboarding
    initialScreen = const MyApp();
  }

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: initialScreen,
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

  final List<Widget> _screens = [
    const HomeScreen(),
    const MarketScreen(),
    const ChatScreen(),
    const ProviderProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF9333EA),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
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