import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nearfix_partner/profile/ledger_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix_partner/authentication/login_screen.dart';
import 'package:nearfix_partner/market/models/app_colors.dart';

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
        Uri.parse(
            "https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/get_jobs.php?provider_id=$providerId"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['success']) {
          double revenue = 0;
          int finished = 0;
          for (var job in decoded['data']) {
            if (job['status'].toString().toLowerCase() == 'completed') {
              revenue += double.tryParse(job['amount'].toString()) ?? 0;
              finished++;
            }
          }
          setState(() {
            _totalRevenue = revenue.toStringAsFixed(0);
            _totalMissions = finished;
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl =
        "https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/$_profilePic";

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          Text('Profile',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.dark,
                                  letterSpacing: -0.3)),
                          const Spacer(),
                          GestureDetector(
                            onTap: _loadProfileData,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.bg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.borderGrey),
                              ),
                              child: Icon(Icons.refresh_rounded,
                                  color: AppColors.grey, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Avatar
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primary, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: _profilePic.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : null,
                        child: _profilePic.isEmpty
                            ? Icon(Icons.person_rounded,
                                size: 48, color: AppColors.primary)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(_userName,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.dark,
                            letterSpacing: -0.3)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _badge(_category.toUpperCase(),
                            AppColors.primaryLight, AppColors.primary),
                        const SizedBox(width: 8),
                        _badge('VERIFIED ✓',
                            const Color(0xFFDCFCE7), const Color(0xFF16A34A)),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Revenue card
                  _revenueCard(),
                  const SizedBox(height: 16),

                  // Menu items
                  _menuCard([
                    _menuItem(Icons.account_balance_wallet_outlined,
                        'Account Center', () {}),
                    _divider(),
                    _menuItem(Icons.receipt_long_outlined, 'View Ledger', () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LedgerScreen()));
                    }),
                    _divider(),
                    _menuItem(
                        Icons.help_outline_rounded, 'Help & Support', () {}),
                  ]),

                  const SizedBox(height: 16),

                  // Logout
                  GestureDetector(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (r) => false);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded,
                              color: Color(0xFFEF4444), size: 18),
                          SizedBox(width: 8),
                          Text('Log Out',
                              style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _revenueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('SETTLED REVENUE',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('THIS MONTH',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('₹$_totalRevenue',
              style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          const SizedBox(height: 18),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _revenueStatItem('$_totalMissions', 'Missions Finished'),
              Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withOpacity(0.15)),
              _revenueStatItem('4.9 ★', 'Avg Rating'),
              Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withOpacity(0.15)),
              _revenueStatItem('Gold', 'Partner Level'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _revenueStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _menuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(children: children),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Text(title,
                style: TextStyle(
                    color: AppColors.dark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.labelGrey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, indent: 18, endIndent: 18, color: AppColors.divider);

  Widget _badge(String text, Color bg, Color txt) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                color: txt, fontSize: 11, fontWeight: FontWeight.w800)),
      );
}
