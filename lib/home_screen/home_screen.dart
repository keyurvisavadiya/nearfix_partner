import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix_partner/services/location_service.dart';
import 'package:nearfix_partner/market/models/job.dart';
import 'package:nearfix_partner/market/screen/market_screen.dart';
import '../market/models/app_colors.dart';
import '../market/screen/job_detailed.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final ProviderLocationService _locationService = ProviderLocationService();
  bool _isOnline = false;
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
    const String imageBaseUrl =
        "https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/uploads/";
    setState(() {
      _userName = prefs.getString('provider_name') ?? "Partner";
      String? rawImage = prefs.getString('profile_pic');
      if (rawImage != null && rawImage.isNotEmpty && rawImage != "null") {
        _profileImageUrl = "$imageBaseUrl${rawImage.replaceAll('uploads/', '')}";
      }
    });
    try {
      final response = await http.get(
        Uri.parse(
            "https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/get_jobs.php?provider_id=$providerId"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success']) {
          List<dynamic> allJobs = decoded['data'];
          setState(() {
            _totalCompletedJobs = allJobs
                .where((j) => ['completed', 'finish']
                    .contains(j['status']?.toString().toLowerCase()))
                .length;
            _priorityMission = allJobs.firstWhere(
              (j) => ['active', 'confirmed']
                  .contains(j['status']?.toString().toLowerCase()),
              orElse: () => null,
            );
            _recentMissions = allJobs
                .where((j) =>
                    _priorityMission == null ||
                    j['id'].toString() != _priorityMission!['id'].toString())
                .take(5)
                .toList();
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
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        color: AppColors.primary,
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
                    _buildStatsRow(),
                    const SizedBox(height: 28),
                    _buildSectionHeader("Active Mission"),
                    const SizedBox(height: 12),
                    _buildPriorityCard(),
                    const SizedBox(height: 28),
                    _buildSectionHeader("Recent Activity"),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Center(
                          child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(
                                  color: AppColors.primary)))
                    else if (_recentMissions.isEmpty)
                      _buildEmptyState()
                    else
                      ..._recentMissions
                          .map((job) => _buildActivityTile(job))
                          .toList(),
                    const SizedBox(height: 32),
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
      expandedHeight: 130,
      floating: false,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileAvatar(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome back,",
                            style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        Text(_userName,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.dark,
                                letterSpacing: -0.5),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  _buildStatusToggle(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: _isOnline ? AppColors.primary : AppColors.borderGrey,
            width: 2.5),
      ),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.primaryLight,
        backgroundImage:
            _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
        child: _profileImageUrl == null
            ? Icon(Icons.person_rounded, color: AppColors.primary, size: 26)
            : null,
      ),
    );
  }

  Widget _buildStatusToggle() {
    return GestureDetector(
      onTap: () => _toggleStatus(!_isOnline),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isOnline ? AppColors.primaryLight : AppColors.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: _isOnline ? AppColors.primary : AppColors.borderGrey,
              width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _isOnline ? AppColors.primary : AppColors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _isOnline ? "ONLINE" : "OFFLINE",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: _isOnline ? AppColors.primary : AppColors.grey,
                  letterSpacing: 0.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard("Missions", "$_totalCompletedJobs",
            Icons.bolt_rounded, AppColors.primary, AppColors.primaryLight),
        const SizedBox(width: 12),
        _statCard("Rating", "4.9",
            Icons.star_rounded, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
        const SizedBox(width: 12),
        _statCard("Level", "Gold",
            Icons.workspace_premium_rounded, AppColors.primaryDark, AppColors.primaryLight),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.dark)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w600)),
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Column(
          children: [
            Icon(Icons.radar_rounded, color: AppColors.borderGrey, size: 40),
            const SizedBox(height: 12),
            Text("No Active Missions",
                style: TextStyle(
                    color: AppColors.dark,
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
            const SizedBox(height: 4),
            Text("Switch online to receive new jobs",
                style: TextStyle(color: AppColors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _onJobTap(_priorityMission!),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.electric_bolt_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("IN PROGRESS",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8)),
                ),
                const Spacer(),
                Text("₹${_priorityMission!['amount']}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 24)),
              ],
            ),
            const SizedBox(height: 16),
            Text(_priorityMission!['service_name'] ?? "Job",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -0.3)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_rounded,
                    color: Colors.white.withOpacity(0.7), size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(_priorityMission!['address'] ?? "",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.75), fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14)),
              child: Center(
                child: Text("Continue Mission →",
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> job) {
    bool isDone =
        ['completed', 'finish'].contains(job['status']?.toString().toLowerCase());
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: ListTile(
        onTap: () => _onJobTap(job),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
              color: isDone
                  ? AppColors.primaryLight
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(13)),
          child: Icon(
              isDone ? Icons.check_rounded : Icons.timer_outlined,
              color: isDone ? AppColors.primary : const Color(0xFFF59E0B),
              size: 22),
        ),
        title: Text(job['service_name'] ?? "Job",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
                fontSize: 14)),
        subtitle: Text(job['status'].toString().toUpperCase(),
            style: TextStyle(
                color: isDone ? AppColors.primary : const Color(0xFFF59E0B),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("₹${job['amount']}",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.dark,
                    fontSize: 16)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title,
        style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: AppColors.dark,
            letterSpacing: -0.3));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: AppColors.borderGrey),
            const SizedBox(height: 12),
            Text("No recent history",
                style: TextStyle(
                    color: AppColors.grey, fontWeight: FontWeight.w600)),
          ],
        ),
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
      _showStatusSnack("Ready for missions", AppColors.primary);
    } else {
      _locationService.stopTracking(providerId: providerId.toString());
      _showStatusSnack("Offline mode active", AppColors.grey);
    }
  }

  void _showStatusSnack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
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
        Uri.parse(
            "https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/update_job_status.php"),
        body: {
          'job_id': jobId.toString(),
          'status': newStatus,
          'provider_id': providerId.toString()
        },
      );
      if (response.statusCode == 200) _loadDashboardData();
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }
}
