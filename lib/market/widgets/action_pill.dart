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
    // Group available and pending to show the ACCEPT button
      case JobStatus.available:
      case JobStatus.pending:
        return _pill('ACCEPT', AppColors.purple, () => onAccept(job));

    // Group active and Confirmed to show the MARK DONE button
      case JobStatus.active:
      case JobStatus.Confirmed:
        return _pill('MARK DONE', AppColors.green, () => onFinish(job));

      case JobStatus.completed:
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'FINISHED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.green,
              letterSpacing: 0.4,
            ),
          ),
        );

    // Added a default return to ensure the switch is always exhaustive
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
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}