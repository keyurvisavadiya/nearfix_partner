import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix_partner/services/location_service.dart';
import 'package:nearfix_partner/market/models/job.dart';
import 'package:nearfix_partner/market/screen/market_screen.dart';
import '../market/screen/job_detailed.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final ProviderLocationService _locationService = ProviderLocationService();
  bool _isOnline = false;

  // --- DESIGN SYSTEM ---
  final Color primaryColor = const Color(0xFF6366F1); // Indigo
  final Color secondaryColor = const Color(0xFF4F46E5);
  final Color slate900 = const Color(0xFF0F172A);
  final Color slate800 = const Color(0xFF1E293B);
  final Color slate500 = const Color(0xFF64748B);
  final Color slate100 = const Color(0xFFF8FAFC);
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
    WidgetsBinding.instance.addObserver(this);
    _initializeStatusAndData();
  }

  Future<void> _initializeStatusAndData() async {
    final prefs = await SharedPreferences.getInstance();
    bool savedStatus = prefs.getBool('is_online_status') ?? false;
    int providerId = prefs.getInt('provider_id') ?? 0;

    setState(() => _isOnline = savedStatus);
    if (_isOnline && providerId != 0) {
      _locationService.startTracking(providerId.toString());
    }
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    int providerId = prefs.getInt('provider_id') ?? 0;
    const String imageBaseUrl = "https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/uploads/";

    setState(() {
      _userName = prefs.getString('provider_name') ?? "Partner";
      String? rawImage = prefs.getString('profile_pic');
      if (rawImage != null && rawImage.isNotEmpty && rawImage != "null") {
        _profileImageUrl = "$imageBaseUrl${rawImage.replaceAll('uploads/', '')}";
      }
    });

    try {
      final response = await http.get(
        Uri.parse("https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/get_jobs.php?provider_id=$providerId"),
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
        color: primaryColor,
        onRefresh: _loadDashboardData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildStatsGrid(),
                    const SizedBox(height: 32),
                    _buildSectionHeader("Active Mission"),
                    const SizedBox(height: 12),
                    _buildPriorityCard(),
                    const SizedBox(height: 32),
                    _buildSectionHeader("Recent Activity"),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                    else if (_recentMissions.isEmpty)
                      _buildEmptyState()
                    else
                      ..._recentMissions.map((job) => _buildActivityTile(job)).toList(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      elevation: 0,
      surfaceTintColor: Colors.green,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, slate100],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome back,", style: TextStyle(color: slate500, fontSize: 14)),
                      Text(_userName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: slate900, letterSpacing: -0.5)),
                    ],
                  ),
                ),
                _buildStatusToggle(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _isOnline ? emerald : Colors.transparent, width: 2),
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
        child: _profileImageUrl == null ? Icon(Icons.person_rounded, color: primaryColor, size: 30) : null,
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _isOnline ? emerald.withOpacity(0.1) : slate500.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(_isOnline ? "ON" : "OFF", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _isOnline ? emerald : slate500)),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _isOnline,
              onChanged: _toggleStatus,
              activeColor: emerald,
              activeTrackColor: emerald.withOpacity(0.3),
              inactiveThumbColor: slate500,
              inactiveTrackColor: slate500.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _statCard("Missions", "$_totalCompletedJobs", Icons.bolt_rounded, primaryColor),
        const SizedBox(width: 16),
        _statCard("Rating", "4.9", Icons.star_rounded, amber),
        const SizedBox(width: 16),
        _statCard("Level", "Gold", Icons.workspace_premium_rounded, emerald),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: slate900)),
            Text(label, style: TextStyle(fontSize: 11, color: slate500, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityCard() {
    if (_priorityMission == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          children: [
            Icon(Icons.radar_rounded, color: slate500.withOpacity(0.3), size: 32),
            const SizedBox(height: 12),
            Text("No Active Missions", style: TextStyle(color: slate900, fontWeight: FontWeight.bold)),
            Text("Switch online to receive new jobs", style: TextStyle(color: slate500, fontSize: 12)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _onJobTap(_priorityMission!),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [slate900, slate800]),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildIconBadge(Icons.electric_bolt_rounded, emerald),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("IN PROGRESS", style: TextStyle(color: emerald, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      Text(_priorityMission!['service_name'] ?? "Job", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                Text("₹${_priorityMission!['amount']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.location_on_rounded, color: slate500, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(_priorityMission!['address'] ?? "", style: TextStyle(color: slate500, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text("Continue Mission", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> job) {
    bool isDone = ['completed', 'finish'].contains(job['status']?.toString().toLowerCase());
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      child: ListTile(
        onTap: () => _onJobTap(job),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          height: 48, width: 48,
          decoration: BoxDecoration(color: (isDone ? emerald : amber).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
          child: Icon(isDone ? Icons.check_circle_rounded : Icons.timer_rounded, color: isDone ? emerald : amber),
        ),
        title: Text(job['service_name'] ?? "Job", style: TextStyle(fontWeight: FontWeight.bold, color: slate900)),
        subtitle: Text(job['status'].toString().toUpperCase(), style: TextStyle(color: isDone ? emerald : amber, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("₹${job['amount']}", style: TextStyle(fontWeight: FontWeight.w900, color: slate900, fontSize: 16)),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- HELPER UI ---

  Widget _buildIconBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: slate900,
            letterSpacing: -0.5,
          )
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.inbox_rounded, size: 64, color: slate500.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text("No recent history", style: TextStyle(color: slate500, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _toggleStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    int providerId = prefs.getInt('provider_id') ?? 0;
    await prefs.setBool('is_online_status', value);
    setState(() => _isOnline = value);
    if (_isOnline && providerId != 0) {
      _locationService.startTracking(providerId.toString());
      _showStatusSnack("Ready for missions", emerald);
    } else {
      _locationService.stopTracking(providerId: providerId.toString());
      _showStatusSnack("Offline mode active", slate500);
    }
  }

  void _showStatusSnack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: bg,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(20),
        )
    );
  }

  void _onJobTap(Map<String, dynamic> jobData) {
    final jobModel = Job.fromJson(jobData);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailScreen(
          job: jobModel,
          onAccept: () => _handleStatusUpdate(jobModel.id, 'Confirmed'),
          onFinish: () => _handleStatusUpdate(jobModel.id, 'completed'),
        ),
      ),
    ).then((_) => _loadDashboardData());
  }

  Future<void> _handleStatusUpdate(int jobId, String newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int providerId = prefs.getInt('provider_id') ?? 0;
      final response = await http.post(
        Uri.parse("https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/update_job_status.php"),
        body: {'job_id': jobId.toString(), 'status': newStatus, 'provider_id': providerId.toString()},
      );
      if (response.statusCode == 200) _loadDashboardData();
    } catch (e) { debugPrint("Update Error: $e"); }
  }
}