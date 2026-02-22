import 'package:flutter/material.dart';

import 'chatscreen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),

      /* ---------- HEADER ---------- */
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          "Messages",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),

      /* ---------- BODY ---------- */
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            ChatCard(
              name: "Sarah Jenkins",
              message: "I'm arriving in about 10 minutes, see you soon!",
              time: "2m ago",
              isOnline: true,
            ),
            SizedBox(height: 14),
            ChatCard(
              name: "John Moyer",
              message: "Thanks for the tip!",
              time: "Yesterday",
              isOnline: false,
              faded: true,
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= CHAT CARD ================= */

class ChatCard extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool isOnline;
  final bool faded;

  const ChatCard({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.isOnline,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProviderChatMessageScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /* ----- AVATAR ----- */
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(Icons.person, color: Colors.grey.shade500),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            /* ----- TEXT ----- */
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: faded
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
