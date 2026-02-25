import 'package:flutter/material.dart';
import '../widgets/job_list.dart';
import '../screen/job_detailed.dart';

import '../models/job.dart';
import '../models/app_colors.dart';
import '../data/jobs_data.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Job> _jobs = sampleJobs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Job> _getJobs(JobStatus status) =>
      _jobs.where((j) => j.status == status).toList();

  void _acceptJob(Job job) {
    setState(() => job.status = JobStatus.active);
    _tabController.animateTo(1);
    _toast('Lead Accepted ✓');
  }

  void _finishJob(Job job) {
    setState(() => job.status = JobStatus.completed);
    _tabController.animateTo(2);
    _toast('Job Complete ✓');
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColors.dark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(40, 0, 40, 30),
      ),
    );
  }

  void _openDetail(Job job) {
    Navigator.of(context)
        .push(
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
        )
        .then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          // ── Header + Tabs ─────────────────────────────────────────
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  const Text(
                    'Market Place',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.purple,
                    unselectedLabelColor: AppColors.grey,
                    indicatorColor: AppColors.purple,
                    indicatorWeight: 2,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                    tabs: const [
                      Tab(text: 'AVAILABLE'),
                      Tab(text: 'ACTIVE'),
                      Tab(text: 'COMPLETED'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Tab Views ─────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                JobList(
                  jobs: _getJobs(JobStatus.available),
                  onAccept: _acceptJob,
                  onFinish: _finishJob,
                  onTap: _openDetail,
                ),
                JobList(
                  jobs: _getJobs(JobStatus.active),
                  onAccept: _acceptJob,
                  onFinish: _finishJob,
                  onTap: _openDetail,
                ),
                JobList(
                  jobs: _getJobs(JobStatus.completed),
                  onAccept: _acceptJob,
                  onFinish: _finishJob,
                  onTap: _openDetail,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
