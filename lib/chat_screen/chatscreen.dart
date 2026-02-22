import 'package:flutter/material.dart';

const Color primaryColor = Color.fromARGB(255, 51, 54, 93);
const Color bgColor = Color(0xFFF6F7FB);

class ProviderChatMessageScreen extends StatelessWidget {
  const ProviderChatMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _chatAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: 12),
              child: Column(
                children: [
                  const _TimeLabel("Today, 2:30 PM"),
                  const SizedBox(height: 16),

                  _receivedMessage("Hi Alex! I'm on my way to your place."),
                  const SizedBox(height: 12),

                  _sentMessage("Great! Gate code is 4455."),
                  const SizedBox(height: 12),

                  _receivedMessage(
                    "Got it, thanks! I'm arriving in about 10 minutes, see you soon!",
                  ),
                ],
              ),
            ),
          ),

          _chatInputBar(),
        ],
      ),
    );
  }

  // ================= APP BAR =================
  AppBar _chatAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          const CircleAvatar(radius: 20, child: Icon(Icons.person)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Sarah Jenkins",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
            ],
          ),
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.call, color: primaryColor),
        ),
      ],
    );
  }

  // ================= RECEIVED MESSAGE =================
  Widget _receivedMessage(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(text),
          ),
        ],
      ),
    );
  }

  // ================= SENT MESSAGE =================
  Widget _sentMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // ================= INPUT BAR =================
  Widget _chatInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(color: bgColor),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.grey),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 22,
            backgroundColor: primaryColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= TIME LABEL =================
class _TimeLabel extends StatelessWidget {
  final String text;
  const _TimeLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Colors.grey, fontSize: 12));
  }
}
