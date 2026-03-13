import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProviderChatMessageScreen extends StatefulWidget {
  final int currentUserId;
  final int peerId;
  final String peerName;
  final String? peerImageUrl;

  const ProviderChatMessageScreen({
    super.key,
    required this.currentUserId,
    required this.peerId,
    required this.peerName,
    this.peerImageUrl
  });

  @override
  State<ProviderChatMessageScreen> createState() => _ProviderChatMessageScreenState();
}

class _ProviderChatMessageScreenState extends State<ProviderChatMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _timer = Timer.periodic(const Duration(seconds: 2), (t) => _fetchMessages());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(
        Uri.parse("https://sal-unstunted-guadalupe.ngrok-free.dev/nearfix/chat_handler.php?action=fetch&user1=${widget.currentUserId}&user2=${widget.peerId}"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true && _messages.length != data['data'].length) {
        setState(() => _messages = data['data']);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) { debugPrint(e.toString()); }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    String msg = _messageController.text.trim();
    _messageController.clear();
    await http.post(
      Uri.parse("https://sal-unstunted-guadalupe.ngrok-free.dev/nearfix/chat_handler.php?action=send"),
      body: {
        "sender_id": widget.currentUserId.toString(),
        "receiver_id": widget.peerId.toString(),
        "message": msg
      },
    );
    _fetchMessages();
  }

  String _formatChatTime(String rawDate) {
    if (rawDate.isEmpty) return "";
    try {
      DateTime dt = DateTime.parse(rawDate);
      String hour = dt.hour > 12 ? (dt.hour - 12).toString() : (dt.hour == 0 ? "12" : dt.hour.toString());
      String minute = dt.minute.toString().padLeft(2, '0');
      String ampm = dt.hour >= 12 ? "PM" : "AM";
      return "$hour:$minute $ampm";
    } catch (e) { return ""; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: (widget.peerImageUrl != null && widget.peerImageUrl!.contains('uploads/'))
                  ? NetworkImage(widget.peerImageUrl!)
                  : null,
              child: (widget.peerImageUrl == null) ? Text(widget.peerName[0]) : null,
            ),
            const SizedBox(width: 10),
            Text(widget.peerName, style: const TextStyle(color: Colors.black, fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                bool isMe = m['sender_id'].toString() == widget.currentUserId.toString();

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF8B5CF6) : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                          ),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                        ),
                        child: Text(
                            m['message'],
                            style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15)
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                        child: Text(
                          _formatChatTime(m['created_at'] ?? ""),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(hintText: "Type message...", border: InputBorder.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF8B5CF6),
              child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _sendMessage
              ),
            ),
          ],
        ),
      ),
    );
  }
}