import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix_partner/market/models/job.dart';
import 'package:nearfix_partner/market/screen/market_screen.dart';
import '../market/screen/job_detailed.dart'; // Ensure this path is correct

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- MODERN SLATE PALETTE ---
  final Color primaryColor = const Color(0xFF6366F1);
  final Color slate900 = const Color(0xFF0F172A);
  final Color slate700 = const Color(0xFF334155);
  final Color slate500 = const Color(0xFF64748B);
  final Color slate400 = const Color(0xFF94A3B8);
  final Color slate100 = const Color(0xFFF1F5F9);
  final Color emerald = const Color(0xFF10B981);
  final Color amber = const Color(0xFFF59E0B);

  String? _profileImageUrl;
  String _userName = "Partner";
  int _totalCompletedJobs = 0;
  List<dynamic> _recentMissions = [];
  Map<String, dynamic>? _priorityMission;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // --- API STATUS UPDATE (SYNCHRONIZED WITH PHP) ---
  Future<void> _handleStatusUpdate(int jobId, String newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int providerId = prefs.getInt('provider_id') ?? 0;

      final response = await http.post(
        Uri.parse("https://nonregimented-ably-amare.ngrok-free.dev/nearfix/update_job_status.php"),
        body: {
          'job_id': jobId.toString(),
          'status': newStatus,
          'provider_id': providerId.toString(), // Sent for PHP bind_param
        },
      );

      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        if (res['success']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Job $newStatus successfully!"),
                backgroundColor: newStatus == 'completed' ? emerald : primaryColor,
              ),
            );

            // Navigate back and refresh
            if (Navigator.canPop(context)) Navigator.pop(context);
            _loadDashboardData();
          }
        }
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  // --- NAVIGATION ---
  void _onJobTap(Map<String, dynamic> jobData) {
    final jobModel = Job.fromJson(jobData);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailScreen(
          job: jobModel,
          // 'Confirmed' triggers the provider_id update in your PHP
          onAccept: () => _handleStatusUpdate(jobModel.id, 'Confirmed'),
          onFinish: () => _handleStatusUpdate(jobModel.id, 'completed'),
        ),
      ),
    ).then((_) => _loadDashboardData());
  }

  // --- DATA FETCHING ---
  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    int providerId = prefs.getInt('provider_id') ?? 0;
    const String imageBaseUrl = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/uploads/";

    setState(() {
      _userName = prefs.getString('provider_name') ?? "Partner";
      String? rawImage = prefs.getString('profile_pic');
      if (rawImage != null && rawImage.isNotEmpty && rawImage != "null") {
        _profileImageUrl = "$imageBaseUrl${rawImage.replaceAll('uploads/', '')}";
      }
    });

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
            _totalCompletedJobs = allJobs.where((j) =>
                ['completed', 'finish'].contains(j['status']?.toString().toLowerCase())).length;

            _priorityMission = allJobs.firstWhere(
                  (j) => ['active', 'confirmed'].contains(j['status']?.toString().toLowerCase()),
              orElse: () => null,
            );

            _recentMissions = allJobs.where((j) =>
            _priorityMission == null || j['id'].toString() != _priorityMission!['id'].toString()
            ).take(5).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: slate100,
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeroStats(),
                  const SizedBox(height: 32),
                  _rowHeader("Active Mission", null),
                  const SizedBox(height: 16),
                  _buildPriorityCard(),
                  const SizedBox(height: 32),
                  _rowHeader("Recent Activity", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketScreen()));
                  }),
                  const SizedBox(height: 16),
                  if (_isLoading) const Center(child: LinearProgressIndicator()),
                  ..._recentMissions.map((job) => _buildActivityTile(job)).toList(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI WIDGETS ---

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26, backgroundColor: slate100,
              backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
              child: _profileImageUrl == null ? Icon(Icons.person, color: primaryColor) : null,
            ),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Welcome back,", style: TextStyle(color: slate500, fontSize: 13)),
              Text(_userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: slate900)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: slate900, borderRadius: BorderRadius.circular(32)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statItem("TOTAL JOBS", "$_totalCompletedJobs", Icons.assignment_turned_in_rounded),
          _statItem("RATING", "4.9", Icons.stars_rounded),
          _statItem("LEVEL", "Gold", Icons.workspace_premium_rounded),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) => Column(children: [
    Icon(icon, color: Colors.indigoAccent.shade100, size: 20),
    const SizedBox(height: 8),
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    Text(label, style: TextStyle(color: slate400, fontSize: 10)),
  ]);

  Widget _buildPriorityCard() {
    if (_priorityMission == null) {
      return Container(
          height: 100,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Center(child: Text("Waiting for missions...", style: TextStyle(color: slate400)))
      );
    }
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: () => _onJobTap(_priorityMission!),
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                      child: Icon(Icons.flash_on_rounded, color: primaryColor)
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_priorityMission!['service_name'] ?? "Job", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: slate900)),
                    Text(_priorityMission!['address'] ?? "No Location", style: TextStyle(color: slate500, fontSize: 12), maxLines: 1),
                  ])),
                  Text("₹${_priorityMission!['amount']}", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                  height: 45,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(12)),
                  child: const Text("View Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> job) {
    bool isDone = ['completed', 'finish'].contains(job['status']?.toString().toLowerCase());
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _onJobTap(job),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                    height: 48, width: 48,
                    decoration: BoxDecoration(color: isDone ? emerald.withOpacity(0.1) : amber.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(isDone ? Icons.check_rounded : Icons.schedule_rounded, color: isDone ? emerald : amber)
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(job['service_name'] ?? "Job", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: slate900)),
                  Text(job['status'].toString().toUpperCase(), style: TextStyle(color: isDone ? emerald : slate400, fontSize: 10, fontWeight: FontWeight.w800)),
                ])),
                Text("₹${job['amount']}", style: TextStyle(fontWeight: FontWeight.bold, color: slate700)),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rowHeader(String t, VoidCallback? onTap) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(t, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: slate900)),
      ]
  );
}