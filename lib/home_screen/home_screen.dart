import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nearfix_partner/market/screen/market_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- 1. DYNAMIC VARIABLES ---
  String _userName = "Loading...";
  String _jobTitle = "PROFESSIONAL";
  int _totalCompletedJobs = 0; // The true total counter
  List<dynamic> _recentMissions = [];
  Map<String, dynamic>? _priorityMission;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileAndData();
  }

  // --- 2. DATA LOADING LOGIC ---
  Future<void> _loadProfileAndData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load local profile data
    setState(() {
      _userName = prefs.getString('provider_name') ?? "Partner";
      _jobTitle = prefs.getString('category') ?? "Professional";
    });

    // Fetch remote job data
    await _fetchDashboardData(prefs.getInt('provider_id') ?? 0);
  }

  Future<void> _fetchDashboardData(int providerId) async {
    try {
      final response = await http.get(
        Uri.parse("https://nonregimented-ably-amare.ngrok-free.dev/nearfix/get_jobs.php?provider_id=$providerId"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success']) {
          List<dynamic> allJobs = decoded['data'];

          setState(() {
            // --- THE FIX: Calculate total COMPLETED from the full dataset ---
            _totalCompletedJobs = allJobs.where((job) {
              String status = job['status']?.toString().toLowerCase() ?? "";
              return status == 'completed' || status == 'finish';
            }).length;

            // Find Priority Mission (First one that is Active or Confirmed)
            _priorityMission = allJobs.firstWhere(
                  (j) {
                String s = j['status']?.toString().toLowerCase() ?? "";
                return s == 'confirmed' || s == 'active';
              },
              orElse: () => null,
            );

            // Recent Activity: Just show the 3 most recent items for UI neatness
            _recentMissions = allJobs.take(3).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Home Data Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfileAndData,
          color: const Color(0xFF9333EA),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // --- PROFILE HEADER ---
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFFF3F4F6),
                      child: Icon(Icons.person, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_userName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        Text(
                          _jobTitle.toUpperCase(),
                          style: TextStyle(
                              color: Colors.purple.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 1
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.notifications_none_rounded, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 32),

                // --- STATS CARDS ---
                Row(
                  children: [
                    // --- DYNAMIC TOTAL COMPLETED ---
                    _buildStatCard("COMPLETED", "$_totalCompletedJobs", Colors.white),
                    const SizedBox(width: 16),
                    _buildStatCard("RATING", "4.9", Colors.white),
                  ],
                ),
                const SizedBox(height: 40),

                // --- PRIORITY MISSION ---
                const Text("PRIORITY MISSION",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: Colors.black87)
                ),
                const SizedBox(height: 16),

                if (_priorityMission != null)
                  _buildPriorityCard(_priorityMission!)
                else if (!_isLoading)
                  _buildEmptyState("No active missions at the moment"),

                const SizedBox(height: 40),

                // --- RECENT ACTIVITY ---
                InkWell(
                  // Use () => or () {} to define the callback function
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MarketScreen()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0), // Added padding for better touch target
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                            "RECENT ACTIVITY",
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)
                        ),
                        Text(
                            "VIEW ALL",
                            style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold, fontSize: 10)
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (_recentMissions.isEmpty && !_isLoading)
                  _buildEmptyState("No recent activity found"),

                // List the recent missions dynamically
                ..._recentMissions.map((job) => _buildActivityTile(
                    job['service_name'] ?? "Job",
                    job['status'] ?? "Pending"
                )).toList(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildPriorityCard(Map<String, dynamic> job) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple.shade100),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_filled, color: Color(0xFF9333EA), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job['service_name'] ?? "Maintenance", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(
                    job['address'] ?? "Location Hidden",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text("₹${job['amount']}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(String title, String status) {
    bool isDone = status.toLowerCase() == 'completed' || status.toLowerCase() == 'finish';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
              isDone ? Icons.check_circle : Icons.pending_actions_rounded,
              color: isDone ? const Color(0xFF10B981) : Colors.orange,
              size: 20
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(status.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}