import 'package:flutter/material.dart';
import 'package:nearfix_partner/profile/ledger_screen.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Light gray background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // --- Profile Header ---
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFFE0E0E0),
                backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150'), // Replace with actual avatar
              ),
              const SizedBox(height: 16),
              const Text(
                'Rahul Sharma',
                style: TextStyle(fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBadge('PLUMBING PRO', const Color(0xFFF3E5F5),
                      const Color(0xFF9C27B0)),
                  const SizedBox(width: 8),
                  _buildBadge('IDENTITY VERIFIED', const Color(0xFFE8F5E9),
                      const Color(0xFF4CAF50)),
                ],
              ),
              const SizedBox(height: 30),

              // --- Revenue Card ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SETTLED REVENUE', style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text('₹12,450', style: TextStyle(fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1A1A))),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(
                              0xFFE8F5E9), borderRadius: BorderRadius.circular(
                              12)),
                          child: const Icon(Icons.trending_up, color: Color(
                              0xFF4CAF50)),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MISSIONS FINISHED', style: TextStyle(
                                color: Colors.grey, fontSize: 12)),
                            Text('24 Total', style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>LedgerScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1C1E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          child: const Text('VIEW LEDGER', style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Account Center Tile ---
              _buildActionTile(Icons.settings_outlined, 'Account Center'),

              const SizedBox(height: 40),

              // --- Terminate Session Button ---
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFEDF2F7),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(color: Color(0xFF718096),
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for Badges
  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(
          color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  // Helper for Settings Tiles
  Widget _buildActionTile(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 22),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 16)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }

}