import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart'; // REQUIRED
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

  // --- PHONE DIALER LOGIC ---
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint("Could not launch dialer for $phoneNumber");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          // ── App Bar
          Container(
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
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 15,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'JOB DETAIL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.dark,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.purpleBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          job.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.purple,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'PRE-PAID PAYOUT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.labelGrey,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.rate,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.dark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Text(
                    job.type.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dark,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Customer Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderGrey),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: (job.customerImage != null && job.customerImage!.isNotEmpty)
                                ? Image.network(
                              job.customerImage!,
                              fit: BoxFit.cover,
                              headers: const {"ngrok-skip-browser-warning": "69420"},
                              errorBuilder: (context, error, stackTrace) => _buildProfessionalFallback(),
                            )
                                : _buildProfessionalFallback(),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.customer,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.dark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${job.customerRating} VERIFIED USER',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ACTION BUTTONS
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
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
                              },
                              child: _iconButton(Icons.chat_bubble_rounded, AppColors.purple, AppColors.purple.withOpacity(0.1)),
                            ),
                            const SizedBox(width: 8),
                            // --- UPDATED CALL BUTTON ---
                            GestureDetector(
                              onTap: () => _makePhoneCall(job.customerPhone),
                              child: _iconButton(Icons.phone_rounded, Colors.white, AppColors.green),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  SectionLabel(icon: Icons.location_on_outlined, label: 'DESTINATION'),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 22),
                    child: Text(
                      job.location,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark),
                    ),
                  ),

                  const SizedBox(height: 22),
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
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cardText,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),

          // ── Bottom CTA
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
            child: _buildCTA(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalFallback() {
    return Container(
      decoration: const BoxDecoration(color: AppColors.purple),
      child: Center(
        child: Text(
          job.customer.isNotEmpty ? job.customer.substring(0, 1).toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, Color iconColor, Color bgColor) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: iconColor, size: 20),
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
}