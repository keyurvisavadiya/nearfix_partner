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
      case JobStatus.available:
      case JobStatus.pending:
        return _pill('ACCEPT', AppColors.primary, () => onAccept(job));
      case JobStatus.active:
      case JobStatus.Confirmed:
        return _pill('DONE', AppColors.primaryDark, () => onFinish(job));
      case JobStatus.completed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('FINISHED',
              style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 10)),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _pill(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5)),
      ),
    );
  }
}
