import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../chat_screen/chatscreen.dart';
import '../models/job.dart';
import '../models/app_colors.dart';
import '../widgets/section_label.dart';

class JobDetailScreen extends StatelessWidget {
  final Job job;
  final VoidCallback onAccept;
  final VoidCallback onFinish;

  const JobDetailScreen({
    super.key,
    required this.job,
    required this.onAccept,
    required this.onFinish,
  });

  // --- GOOGLE MAPS DIRECTIONS LOGIC ---
  Future<void> _openMapDirections(BuildContext context) async {
    final double lat = job.latitude;
    final double lng = job.longitude;

    if (lat == 0.0 || lng == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No GPS coordinates saved for this booking")),
      );
      return;
    }

    final Uri googleMapsUri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    final Uri appleMapsUri = Uri.parse("http://maps.apple.com/?daddr=$lat,$lng");

    try {
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri);
      } else if (await canLaunchUrl(appleMapsUri)) {
        await launchUrl(appleMapsUri);
      } else {
        // Fallback to browser if app intent fails
        final String webUrl = "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng";
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error launching maps: $e");
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 10),
                  Text(job.type.toUpperCase(),
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.dark, height: 1.1)),
                  const SizedBox(height: 24),
                  _buildCustomerCard(context),
                  const SizedBox(height: 24),

                  // --- DESTINATION SECTION WITH MAP ICON ---
                  SectionLabel(icon: Icons.location_on_outlined, label: 'DESTINATION'),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 22),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            job.location,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _openMapDirections(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.directions_rounded, color: AppColors.purple, size: 18),
                                SizedBox(width: 4),
                                Text("GO", style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.w900, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                  SectionLabel(icon: Icons.article_outlined, label: 'PROBLEM STATEMENT'),
                  const SizedBox(height: 10),
                  _buildProblemStatement(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
            child: _buildCTA(),
          ),
        ],
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: AppColors.grey),
                ),
              ),
              const Expanded(
                child: Text('JOB DETAIL', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.dark, letterSpacing: 1.2)),
              ),
              const SizedBox(width: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: AppColors.purpleBg, borderRadius: BorderRadius.circular(6)),
          child: Text(job.category.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.purple, letterSpacing: 0.5)),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('PRE-PAID PAYOUT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.labelGrey)),
            Text(job.rate, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.dark)),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 56, height: 56,
              child: (job.customerImage != null && job.customerImage!.isNotEmpty)
                  ? Image.network(job.customerImage!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildProfessionalFallback())
                  : _buildProfessionalFallback(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.customer, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.dark)),
                const Text('VERIFIED USER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.grey)),
              ],
            ),
          ),
          _iconButton(Icons.phone_rounded, Colors.white, AppColors.green, () => _makePhoneCall(job.customerPhone)),
        ],
      ),
    );
  }

  Widget _buildProblemStatement() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderGrey)),
      child: Text('"${job.detailedDescription.toUpperCase()}"',
          style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, color: AppColors.cardText, height: 1.6)),
    );
  }

  Widget _buildProfessionalFallback() {
    return Container(
      color: AppColors.purple,
      child: Center(
        child: Text(job.customer.isNotEmpty ? job.customer[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _iconButton(IconData icon, Color iconColor, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _buildCTA() {
    switch (job.status) {
      case JobStatus.available:
      case JobStatus.pending:
        return _ctaButton(label: 'ACCEPT JOB', color: AppColors.dark, onTap: onAccept);
      case JobStatus.active:
      case JobStatus.Confirmed:
        return _ctaButton(label: 'FINISH JOB', color: AppColors.green, onTap: onFinish);
      case JobStatus.completed:
        return const Center(child: Text('MISSION ACCOMPLISHED', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.green)));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _ctaButton({required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Center(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2))),
      ),
    );
  }
}