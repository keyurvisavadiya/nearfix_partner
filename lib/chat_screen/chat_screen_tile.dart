import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix_partner/chat_screen/chatscreen.dart';
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> _chatList = [];
  bool _isLoading = true;
  int? _myProviderId;

  final String _baseUrl = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/get_chat_list.php";

  @override
  void initState() {
    super.initState();
    _loadProviderAndChats();
  }

  Future<void> _loadProviderAndChats() async {
    final prefs = await SharedPreferences.getInstance();
    _myProviderId = prefs.getInt('provider_id');
    if (_myProviderId != null) {
      _fetchChatList();
    }
  }

  Future<void> _fetchChatList() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl?user_id=$_myProviderId"),
        headers: {"ngrok-skip-browser-warning": "true"},
      );
      final decoded = jsonDecode(response.body);
      if (decoded['success']) {
        setState(() {
          _chatList = decoded['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text("Messages", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
          : RefreshIndicator(
        onRefresh: _fetchChatList,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _chatList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final chat = _chatList[index];
            return ChatCard(
              name: chat['contact_name'] ?? "User",
              message: chat['message'] ?? "",
              imageUrl: chat['contact_image'],
              currentUserId: _myProviderId!,
              peerId: int.parse(chat['contact_id'].toString()),
              time: chat['created_at'] ?? "",
            );
          },
        ),
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  final String name;
  final String message;
  final String? imageUrl;
  final int currentUserId;
  final int peerId;
  final String time;

  const ChatCard({
    super.key,
    required this.name,
    required this.message,
    this.imageUrl,
    required this.currentUserId,
    required this.peerId,
    required this.time,
  });

  String _formatTime(String rawDate) {
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
    String fullPath = "https://nonregimented-ably-amare.ngrok-free.dev/nearfix/$imageUrl";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderChatMessageScreen(
              currentUserId: currentUserId,
              peerId: peerId,
              peerName: name,
              peerImageUrl: fullPath,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
              backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty) ? NetworkImage(fullPath) : null,
              child: (imageUrl == null || imageUrl!.isEmpty)
                  ? Text(name[0], style: const TextStyle(color: Color(0xFF8B5CF6)))
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(_formatTime(time), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(message, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}