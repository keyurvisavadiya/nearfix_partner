import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nearfix_partner/profile/ledger_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix_partner/authentication/login_screen.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  String _userName = "Loading...";
  String _category = "PROFESSIONAL";
  String _profilePic = "";
  String _totalRevenue = "0";
  int _totalMissions = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('provider_name') ?? "Partner";
      _category = prefs.getString('category') ?? "Professional";
      _profilePic = prefs.getString('profile_pic') ?? "";
    });
    _fetchStats(prefs.getInt('provider_id') ?? 0);
  }

  Future<void> _fetchStats(int providerId) async {
    try {
      final res = await http.get(
        Uri.parse("https://sal-unstunted-guadalupe.ngrok-free.dev/nearfix/get_jobs.php?provider_id=$providerId"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['success']) {
          double revenue = 0; int finished = 0;
          for (var job in decoded['data']) {
            if (job['status'].toString().toLowerCase() == 'completed') {
              revenue += double.tryParse(job['amount'].toString()) ?? 0;
              finished++;
            }
          }
          setState(() { _totalRevenue = revenue.toStringAsFixed(0); _totalMissions = finished; });
        }
      }
    } catch (e) { debugPrint(e.toString()); }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = "https://sal-unstunted-guadalupe.ngrok-free.dev/nearfix/$_profilePic";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFE0E0E0),
                backgroundImage: _profilePic.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: _profilePic.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
              ),
              const SizedBox(height: 16),
              Text(_userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _badge(_category.toUpperCase(), const Color(0xFFF3E5F5), const Color(0xFF9C27B0)),
                  const SizedBox(width: 8),
                  _badge('VERIFIED', const Color(0xFFE8F5E9), const Color(0xFF4CAF50)),
                ],
              ),
              const SizedBox(height: 30),
              _revenueCard(),
              const SizedBox(height: 20),
              _actionTile(Icons.settings_outlined, 'Account Center'),
              const SizedBox(height: 40),
              _logoutButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _revenueCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SETTLED REVENUE', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('₹$_totalRevenue', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('MISSIONS FINISHED', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('$_totalMissions Total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ]),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LedgerScreen()));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1C1E), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('VIEW LEDGER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color bg, Color txt) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: TextStyle(color: txt, fontSize: 10, fontWeight: FontWeight.bold)),
  );

  Widget _actionTile(IconData icon, String title) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
    child: Row(children: [Icon(icon, color: Colors.purple, size: 22), const SizedBox(width: 16), Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), const Spacer(), const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1))]),
  );

  Widget _logoutButton() => SizedBox(
    width: double.infinity,
    child: TextButton(
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
      },
      style: TextButton.styleFrom(backgroundColor: const Color(0xFFEDF2F7), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      child: const Text('Log Out', style: TextStyle(color: Color(0xFF718096), fontWeight: FontWeight.bold)),
    ),
  );
}