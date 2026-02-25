import 'package:flutter/material.dart';
import '../models/job.dart';
import 'job_card.dart';

class JobList extends StatelessWidget {
  final List<Job> jobs;
  final void Function(Job) onAccept;
  final void Function(Job) onFinish;
  final void Function(Job) onTap;

  const JobList({
    super.key,
    required this.jobs,
    required this.onAccept,
    required this.onFinish,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 52, color: Color(0xFFCBD5E1)),
            SizedBox(height: 12),
            Text(
              'Nothing here yet',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFCBD5E1),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: jobs.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: JobCard(
          job: jobs[i],
          onAccept: onAccept,
          onFinish: onFinish,
          onTap: onTap,
        ),
      ),
    );
  }
}
