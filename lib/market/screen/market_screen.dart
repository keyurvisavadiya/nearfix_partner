import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/job_list.dart';
import '../screen/job_detailed.dart';
import '../models/job.dart';
import '../models/app_colors.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});
  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Job> _jobs = [];
  bool _isLoading = true;

  final String _baseUrl =
      "https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _fetchJobs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchJobs() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      int myId = prefs.getInt('provider_id') ?? 1;
      String myCategory = prefs.getString('category') ?? '';
      final response = await http
          .get(
            Uri.parse(
              "${_baseUrl}get_jobs.php?provider_id=$myId&category=$myCategory",
            ),
            headers: {"ngrok-skip-browser-warning": "true"},
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          final List<dynamic> data = decoded['data'];
          if (mounted) {
            setState(() {
              _jobs = data.map((item) => Job.fromJson(item)).toList();
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatusInDb(Job job, String newStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int myId = prefs.getInt('provider_id') ?? 1;
      final response = await http.post(
        Uri.parse("${_baseUrl}update_job_status.php"),
        body: {
          "job_id": job.id.toString(),
          "status": newStatus,
          "provider_id": myId.toString(),
        },
      );
      final result = json.decode(response.body);
      if (result['success'] == true) {
        await _fetchJobs();
        _toast(newStatus == 'Confirmed' ? 'Lead Accepted ✓' : 'Job Complete ✓');
        if (newStatus == 'Confirmed') _tabController.animateTo(1);
        if (newStatus == 'completed') _tabController.animateTo(2);
      }
    } catch (e) {
      _toast('Error updating status');
    }
  }

  List<Job> _getJobs(JobStatus status) {
    if (status == JobStatus.available) {
      return _jobs
          .where(
            (j) =>
                j.status == JobStatus.available ||
                j.status == JobStatus.pending,
          )
          .toList();
    } else if (status == JobStatus.active) {
      return _jobs
          .where(
            (j) =>
                j.status == JobStatus.active || j.status == JobStatus.Confirmed,
          )
          .toList();
    } else {
      return _jobs.where((j) => j.status == JobStatus.completed).toList();
    }
  }

  void _acceptJob(Job job) => _updateStatusInDb(job, 'Confirmed');
  void _finishJob(Job job) => _updateStatusInDb(job, 'completed');

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColors.dark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(40, 0, 40, 32),
        elevation: 0,
      ),
    );
  }

  void _openDetail(Job job) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JobDetailScreen(
          job: job,
          onAccept: () {
            _acceptJob(job);
            Navigator.pop(context);
          },
          onFinish: () {
            _finishJob(job);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _isLoading
          ? _buildLoadingState()
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildTabList(JobStatus.available),
                      _buildTabList(JobStatus.active),
                      _buildTabList(JobStatus.completed),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ─── Loading State ────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Finding jobs near you…',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 0),
              child: Row(
                children: [
                  // Title section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marketplace',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_jobs.length} jobs available',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Refresh button
                  _buildIconButton(
                    icon: Icons.refresh_rounded,
                    onTap: _fetchJobs,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTabBar(),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderGrey, width: 1),
        ),
        child: Icon(icon, color: AppColors.grey, size: 18),
      ),
    );
  }

  Widget _buildTabBar() {
    const tabLabels = ['Available', 'Active', 'Done'];
    final statuses = [
      JobStatus.available,
      JobStatus.active,
      JobStatus.completed,
    ];

    return Row(
      children: List.generate(3, (i) {
        final isSelected = _tabController.index == i;
        final count = _getJobs(statuses[i]).length;
        return Expanded(
          child: GestureDetector(
            onTap: () => _tabController.animateTo(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderGrey,
                  width: isSelected ? 0 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tabLabels[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.grey,
                      letterSpacing: 0.1,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    _buildBadge(count, isSelected: isSelected),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBadge(int count, {required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withOpacity(0.25)
            : AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isSelected ? Colors.white : AppColors.primary,
        ),
      ),
    );
  }

  // ─── Tab Content ──────────────────────────────────────────────────────────

  Widget _buildTabList(JobStatus status) {
    final list = _getJobs(status);
    return RefreshIndicator(
      onRefresh: _fetchJobs,
      color: AppColors.primary,
      displacement: 20,
      strokeWidth: 2,
      child: list.isEmpty
          ? _buildEmptyState(status)
          : JobList(
              jobs: list,
              onAccept: _acceptJob,
              onFinish: _finishJob,
              onTap: _openDetail,
            ),
    );
  }

  Widget _buildEmptyState(JobStatus status) {
    final config = _emptyStateConfig(status);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  config['icon'] as IconData,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                config['title'] as String,
                style: TextStyle(
                  color: AppColors.dark,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                config['subtitle'] as String,
                style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _emptyStateConfig(JobStatus status) {
    switch (status) {
      case JobStatus.available:
        return {
          'icon': Icons.search_off_rounded,
          'title': 'No jobs right now',
          'subtitle': 'Pull down to refresh',
        };
      case JobStatus.active:
        return {
          'icon': Icons.work_outline_rounded,
          'title': 'No active jobs',
          'subtitle': 'Accept a lead to get started',
        };
      default:
        return {
          'icon': Icons.check_circle_outline_rounded,
          'title': 'No completed jobs yet',
          'subtitle': 'Finished jobs will appear here',
        };
    }
  }
}
