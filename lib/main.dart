import 'package:flutter/material.dart';
import 'package:nearfix_partner/chat_screen/chat_screen_tile.dart';
import 'package:nearfix_partner/home_screen/home_screen.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(), // Your Dashboard UI
    const Center(child: Text("Market Screen")),
    const ChatScreen(),
    const Center(child: Text("Profile Screen")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
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