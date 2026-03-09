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

  // Function to trigger the system dialer
  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      debugPrint("Phone number is empty");
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      // LaunchMode.externalApplication is critical for Android 11+
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch dialer for $phoneNumber');
      }
    } catch (e) {
      debugPrint('Error triggering dialer: $e');
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
                  _buildHeaderSection(),
                  const SizedBox(height: 24),
                  _buildCustomerCard(context),
                  const SizedBox(height: 24),
                  _buildLocationSection(),
                  const SizedBox(height: 22),
                  _buildProblemSection(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),

          // Bottom CTA
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                14 + MediaQuery.of(context).padding.bottom
            ),
            child: _buildCTA(),
          ),
        ],
      ),
    );
  }

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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: AppColors.grey),
                ),
              ),
              const Expanded(
                child: Text(
                  'JOB DETAIL',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.dark, letterSpacing: 1.2),
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.purpleBg, borderRadius: BorderRadius.circular(6)),
              child: Text(
                job.category.toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.purple, letterSpacing: 0.5),
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('PRE-PAID PAYOUT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.labelGrey, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(job.rate, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.dark)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          job.type.toUpperCase(),
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.dark, height: 1.1),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: const Color(0xFFE8E0F5), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(_avatarEmoji(job.customer), style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.customer, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.dark)),
                const SizedBox(height: 2),
                Text('${job.customerRating} VERIFIED USER', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.grey, letterSpacing: 0.4)),
              ],
            ),
          ),
          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: () => _handleChatNavigation(context),
                child: _iconButton(Icons.chat_bubble_rounded, AppColors.purple.withOpacity(0.1), AppColors.purple),
              ),
              const SizedBox(width: 8),

              // --- FUNCTIONAL CALL BUTTON ---
              GestureDetector(
                onTap: () => _makePhoneCall(job.customerPhone),
                child: _iconButton(Icons.phone_rounded, AppColors.green, Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, Color bg, Color iconColor) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(icon: Icons.location_on_outlined, label: 'DESTINATION'),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(job.location, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
        ),
      ],
    );
  }

  Widget _buildProblemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(icon: Icons.article_outlined, label: 'PROBLEM STATEMENT'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: Text(
            '"${job.detailedDescription.toUpperCase()}"',
            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, color: AppColors.cardText, height: 1.6),
          ),
        ),
      ],
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
        return const Center(
          child: Text('MISSION ACCOMPLISHED', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.green, letterSpacing: 1)),
        );
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
        child: Center(
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
        ),
      ),
    );
  }

  void _handleChatNavigation(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    int? myId = prefs.getInt('provider_id');
    if (myId != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProviderChatMessageScreen(
            currentUserId: myId,
            peerId: job.customerId,
            peerName: job.customer,
          ),
        ),
      );
    }
  }

  String _avatarEmoji(String name) {
    const emojis = ['🧑', '👩', '👨', '🧔', '👱'];
    return emojis[name.codeUnitAt(0) % emojis.length];
  }
}