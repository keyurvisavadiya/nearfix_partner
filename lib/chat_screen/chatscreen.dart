import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nearfix_partner/market/models/app_colors.dart';

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
    this.peerImageUrl,
  });

  @override
  State<ProviderChatMessageScreen> createState() =>
      _ProviderChatMessageScreenState();
}

class _ProviderChatMessageScreenState
    extends State<ProviderChatMessageScreen> {
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
        Uri.parse(
            "https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/chat_handler.php?action=fetch&user1=${widget.currentUserId}&user2=${widget.peerId}"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true &&
          _messages.length != data['data'].length) {
        setState(() => _messages = data['data']);
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    String msg = _messageController.text.trim();
    _messageController.clear();
    await http.post(
      Uri.parse(
          "https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/chat_handler.php?action=send"),
      body: {
        "sender_id": widget.currentUserId.toString(),
        "receiver_id": widget.peerId.toString(),
        "message": msg,
      },
    );
    _fetchMessages();
  }

  String _formatChatTime(String rawDate) {
    if (rawDate.isEmpty) return "";
    try {
      DateTime dt = DateTime.parse(rawDate);
      String hour = dt.hour > 12
          ? (dt.hour - 12).toString()
          : (dt.hour == 0 ? "12" : dt.hour.toString());
      String minute = dt.minute.toString().padLeft(2, '0');
      String ampm = dt.hour >= 12 ? "PM" : "AM";
      return "$hour:$minute $ampm";
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 15, color: AppColors.dark),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: (widget.peerImageUrl != null &&
                      widget.peerImageUrl!.contains('uploads/'))
                  ? NetworkImage(widget.peerImageUrl!)
                  : null,
              child: (widget.peerImageUrl == null)
                  ? Text(widget.peerName[0],
                      style: TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w800))
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.peerName,
                    style: TextStyle(
                        color: AppColors.dark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                Text('Active now',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                bool isMe = m['sender_id'].toString() ==
                    widget.currentUserId.toString();
                return _buildMessageBubble(m, isMe);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic m, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMe
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: isMe
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
              ),
              border: isMe
                  ? null
                  : Border.all(color: AppColors.borderGrey),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04), blurRadius: 6)
              ],
            ),
            child: Text(m['message'],
                style: TextStyle(
                    color: isMe ? Colors.white : AppColors.dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
            child: Text(
              _formatChatTime(m['created_at'] ?? ""),
              style: TextStyle(fontSize: 10, color: AppColors.labelGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.borderGrey)),
                child: TextField(
                  controller: _messageController,
                  cursorColor: AppColors.primary,
                  style: TextStyle(color: AppColors.dark, fontSize: 14),
                  decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(color: AppColors.labelGrey),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
