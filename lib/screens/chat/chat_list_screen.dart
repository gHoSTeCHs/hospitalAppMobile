import 'package:flutter/material.dart';
import '../../models/chat.dart';
import 'chat_details_screen.dart';
import '../../widgets/chat_filter_chip.dart';
import '../../widgets/chat_tile.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  String _selectedFilter = "All chats";
  final List<String> _filters = ["All chats", "Personal", "Work", "Groups"];

  // Mock chat data
  final List<ChatModel> _chats = [
    ChatModel(
      id: '2',
      name: 'Lee Williamson',
      message: 'Yes, that\'s gonna work, hopefully.',
      time: '06:12',
      avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
      unreadCount: 0,
      isOnline: true,
    ),
    ChatModel(
      id: '3',
      name: 'Ronald Mccoy',
      message: '✓✓ Thanks dude 😊',
      time: 'Yesterday',
      avatarUrl: 'https://randomuser.me/api/portraits/men/81.jpg',
      unreadCount: 0,
      isOnline: false,
    ),
    ChatModel(
      id: '4',
      name: 'Albert Bell',
      message: 'I\'m happy this anime has such grea...',
      time: 'Yesterday',
      avatarUrl: 'https://randomuser.me/api/portraits/men/17.jpg',
      unreadCount: 0,
      isOnline: false,
    ),
  ];

  void _handleFilterChange(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _navigateToChatDetail(BuildContext context, String chatId) {
    // Find the chat data for this ID
    final chat = _chats.firstWhere((c) => c.id == chatId);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => ChatDetailScreen(
              chatId: chatId,
              name: chat.name,
              avatarUrl: chat.avatarUrl,
              isOnline: chat.isOnline,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter chips
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = filter == _selectedFilter;

              return ChatFilterChip(
                label: filter,
                isSelected: isSelected,
                onSelected: (_) => _handleFilterChange(filter),
              );
            },
          ),
        ),

        // Chat list
        Expanded(
          child:
              _chats.isEmpty
                  ? const Center(child: Text('No chats yet'))
                  : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _chats.length,
                    itemBuilder: (context, index) {
                      final chat = _chats[index];

                      return ChatTile(
                        name: chat.name,
                        message: chat.message,
                        time: chat.time,
                        avatarUrl: chat.avatarUrl,
                        unreadCount: chat.unreadCount,
                        isOnline: chat.isOnline,
                        onTap: () => _navigateToChatDetail(context, chat.id),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}
