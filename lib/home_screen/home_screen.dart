import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // --- PROFILE HEADER ---
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFF3F4F6),
                    child: Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Rahul Sharma",
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                      Text(
                        "PLUMBING SPECIALIST",
                        style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.notifications_none_rounded, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 32),

              // --- STATS CARDS ---
              Row(
                children: [
                  _buildStatCard("COMPLETED", "24", Colors.white),
                  const SizedBox(width: 16),
                  _buildStatCard("RATING", "4.9", Colors.white),
                ],
              ),
              const SizedBox(height: 40),

              // --- PRIORITY MISSION ---
              const Text("PRIORITY MISSION", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, color: Colors.black87)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple.shade100),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_filled, color: Color(0xFF9333EA), size: 28),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Full Kitchen Re-pipe", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text("TODAY - 2:30 PM | JUHU", style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Spacer(),
                    const Text("₹850", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- RECENT ACTIVITY ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("RECENT ACTIVITY", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                  Text("VIEW ALL", style: TextStyle(color: Colors.purple.shade700, fontWeight: FontWeight.bold, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 16),
              _buildActivityTile("Full Bathroom Repair", "Oct 12"),
              _buildActivityTile("Pipe System Install", "Oct 10"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(String title, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        ],
      ),
    );
  }
}