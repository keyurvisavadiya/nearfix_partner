import 'package:flutter/material.dart';
import '../models/job.dart';
import '../models/app_colors.dart';

class ActionPill extends StatelessWidget {
  final Job job;
  final void Function(Job) onAccept;
  final void Function(Job) onFinish;

  const ActionPill({
    super.key,
    required this.job,
    required this.onAccept,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    switch (job.status) {
    // Both will now work because 'pending' is in the enum
      case JobStatus.available:
      case JobStatus.pending:
        return _pill('ACCEPT', AppColors.purple, () => onAccept(job));

      case JobStatus.active:
      case JobStatus.Confirmed:
        return _pill('MARK DONE', AppColors.green, () => onFinish(job));

      case JobStatus.completed:
        return const Text('FINISHED', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold));

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _pill(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
        child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w800)),
      ),
    );
  }
}