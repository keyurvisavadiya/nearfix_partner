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

class _MarketScreenState extends State<MarketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Job> _jobs = [];
  bool _isLoading = true;

  final String _baseUrl = "https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/";

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

      final response = await http.get(
        Uri.parse(
            "${_baseUrl}get_jobs.php?provider_id=$myId&category=$myCategory"),
        headers: {"ngrok-skip-browser-warning": "true"},
      ).timeout(const Duration(seconds: 10));

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
      // ✅ FIX: Include both 'available' and 'pending' in the first tab
      return _jobs.where((j) =>
      j.status == JobStatus.available ||
          j.status == JobStatus.pending
      ).toList();
    } else if (status == JobStatus.active) {
      // ✅ FIX: Include both 'active' and 'Confirmed' in the second tab
      return _jobs.where((j) =>
      j.status == JobStatus.active ||
          j.status == JobStatus.Confirmed
      ).toList();
    } else {
      // 'completed' tab
      return _jobs.where((j) => j.status == JobStatus.completed).toList();
    }
  }
  void _acceptJob(Job job) => _updateStatusInDb(job, 'Confirmed');

  void _finishJob(Job job) => _updateStatusInDb(job, 'completed');

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
        backgroundColor: AppColors.dark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(40, 0, 40, 30),
      ),
    );
  }

  void _openDetail(Job job) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            JobDetailScreen(
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
          ? const Center(
          child: CircularProgressIndicator(color: AppColors.purple))
          : Column(
        children: [
          _buildHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
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

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 14),
            const Text('Market Place', style: TextStyle(fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.dark)),
            const SizedBox(height: 2),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.purple,
              unselectedLabelColor: AppColors.grey,
              indicatorColor: AppColors.purple,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'AVAILABLE'),
                Tab(text: 'ACTIVE'),
                Tab(text: 'COMPLETED')
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabList(JobStatus status) {
    final list = _getJobs(status);

    return RefreshIndicator(
      onRefresh: _fetchJobs,
      color: AppColors.purple,
      child: list.isEmpty
          ? ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.6,
            child: const Center(
              child: Text(
                  "No jobs found", style: TextStyle(color: AppColors.grey)),
            ),
          ),
        ],
      )
          : JobList(
        jobs: list,
        onAccept: _acceptJob,
        onFinish: _finishJob,
        onTap: _openDetail,
      ),
    );
  }
}