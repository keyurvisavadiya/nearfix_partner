import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nearfix_partner/chat_screen/chatscreen.dart';
import 'package:nearfix_partner/market/models/app_colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> _chatList = [];
  bool _isLoading = true;
  int? _myProviderId;

  final String _baseUrl =
      "https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/get_chat_list.php";

  @override
  void initState() {
    super.initState();
    _loadProviderAndChats();
  }

  Future<void> _loadProviderAndChats() async {
    final prefs = await SharedPreferences.getInstance();
    _myProviderId = prefs.getInt('provider_id');
    if (_myProviderId != null) _fetchChatList();
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
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.chat_rounded, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Text("Messages",
                style: TextStyle(
                    color: AppColors.dark,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -0.3)),
            const Spacer(),
            if (_chatList.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${_chatList.length}',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12)),
              ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _fetchChatList,
              color: AppColors.primary,
              child: _chatList.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 56, color: AppColors.borderGrey),
                              const SizedBox(height: 12),
                              Text("No conversations yet",
                                  style: TextStyle(
                                      color: AppColors.grey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _chatList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final chat = _chatList[index];
                        return ChatCard(
                          name: chat['contact_name'] ?? "User",
                          message: chat['message'] ?? "",
                          imageUrl: chat['contact_image'],
                          currentUserId: _myProviderId!,
                          peerId:
                              int.parse(chat['contact_id'].toString()),
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
    String fullPath =
        "https://marcella-intonational-tatyana.ngrok-free.dev/nearfix/$imageUrl";
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                      ? NetworkImage(fullPath)
                      : null,
                  child: (imageUrl == null || imageUrl!.isEmpty)
                      ? Text(name[0],
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16))
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.dark)),
                      Text(_formatTime(time),
                          style: TextStyle(
                              color: AppColors.labelGrey, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
