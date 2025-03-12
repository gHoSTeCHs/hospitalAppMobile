import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutterapplication/services/auth_service.dart';
import 'package:flutterapplication/services/message_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../models/message.dart';
import '../../utils/formatters.dart';
import '../../config/app_config.dart';

class ChatDScreen extends StatefulWidget {
  final int chatId;
  final String name;
  final String avatarUrl;
  final bool isOnline;

  const ChatDScreen({
    super.key,
    required this.chatId,
    required this.name,
    required this.avatarUrl,
    required this.isOnline,
  });

  @override
  State<ChatDScreen> createState() => _ChatDScreenState();
}

class _ChatDScreenState extends State<ChatDScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageService _messageService = MessageService();

  List<Message> _messages = [];
  bool _isLoading = true;
  bool _showEmojiPicker = false;
  final int _limit = AppConfig.defaultPageSize;
  int _offset = 0;
  bool _hasMoreMessages = true;
  Timer? _refreshTimer;
  int? _currentUserId;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _fetchMessages();

    _scrollController.addListener(_scrollListener);

    if (AppConfig.enablePushNotifications) {
      _refreshTimer = Timer.periodic(
        Duration(milliseconds: AppConfig.messageRefreshInterval),
        (_) => _refreshMessages(),
      );
    }
  }

  // Get current user ID (for determining message ownership)
  Future<void> _getCurrentUserId() async {
    // final prefs = await SharedPreferences.getInstance();
    final user = await AuthService().getCurrentUser();
    _currentUserId = user!.id;
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _hasMoreMessages) {
      _loadMoreMessages();
    }
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await _messageService.gM(
        widget.chatId,
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        _messages = messages;
        _isLoading = false;
        _hasMoreMessages = messages.length == _limit;
      });

      // Mark messages as read if we have any messages
      if (messages.isNotEmpty) {
        _markMessagesAsRead(messages.first.id);
      }
    } catch (e) {
      print('Error fetching messages: $e');
      setState(() {
        _isLoading = false;
      });

      _showErrorSnackbar('Failed to load messages');
    }
  }

  // Refresh only new messages
  Future<void> _refreshMessages() async {
    if (_messages.isEmpty) return;

    try {
      // Get messages newer than our newest message
      final latestMessages = await _messageService.gM(
        widget.chatId,
        limit: 10,
        offset: 0,
      );

      // Filter out messages we already have
      final newMessages =
          latestMessages
              .where((msg) => !_messages.any((m) => m.id == msg.id))
              .toList();

      if (newMessages.isNotEmpty) {
        setState(() {
          _messages = [...newMessages, ..._messages];
        });

        // Mark as read
        if (newMessages.isNotEmpty) {
          _markMessagesAsRead(newMessages.first.id);
        }
      }
    } catch (e) {
      print('Error refreshing messages: $e');
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoading) return;

    setState(() {
      _offset += _limit;
      _isLoading = true;
    });

    try {
      final messages = await _messageService.gM(
        widget.chatId,
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        _messages = [..._messages, ...messages];
        _isLoading = false;
        _hasMoreMessages = messages.length == _limit;
      });
    } catch (e) {
      print('Error loading more messages: $e');
      setState(() {
        _isLoading = false;
      });

      _showErrorSnackbar('Failed to load more messages');
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _markMessagesAsRead(int messageId) async {
    if (!AppConfig.enableReadReceipts) return;

    // try {
    //   await _messageService.markAsRead(widget.chatId, messageId);
    // } catch (e) {
    //   print('Error marking messages as read: $e');
    // }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text;
    _messageController.clear();

    // Optimistically add message to UI
    final optimisticMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
      conversationId: widget.chatId,
      senderId: _currentUserId ?? 0,
      content: messageText,
      createdAt: DateTime.now(),
      readAt: null,
      files: [],
      messageType: 'text',
      isAlert: false,
      isEmergency: false,
      updatedAt: DateTime.now(),
      status: [],
    );

    setState(() {
      _messages.insert(0, optimisticMessage);
    });

    try {
      final sentMessage = await _messageService.pasteMessages(
        widget.chatId,
        'text',
        false,
        false,
        messageText,
      );

      if (sentMessage != null) {
        // Replace optimistic message with the actual one
        setState(() {
          final index = _messages.indexWhere(
            (m) =>
                m.id == optimisticMessage.id ||
                (m.content == optimisticMessage.content &&
                    m.createdAt
                            .difference(optimisticMessage.createdAt)
                            .inSeconds <
                        5),
          );

          if (index != -1) {
            _messages[index] = sentMessage;
          } else {
            // If we couldn't find the optimistic message, just add the new one
            _messages.insert(0, sentMessage);
          }
        });
      } else {
        // Handle error - remove optimistic message
        setState(() {
          _messages.removeWhere((m) => m.id == optimisticMessage.id);
        });
        _showErrorSnackbar('Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
      // Handle error - remove optimistic message
      setState(() {
        _messages.removeWhere((m) => m.id == optimisticMessage.id);
      });
      _showErrorSnackbar('Network error. Please try again.');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onEmojiSelected(Emoji emoji) {
    _messageController.text = _messageController.text + emoji.emoji;
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/men/32.jpg',
                  ),
                ),
                if (widget.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Text(
              widget.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.indigo),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child:
                _isLoading && _messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          _messages.length +
                          (_isLoading && _messages.isNotEmpty ? 1 : 0),
                      reverse: true,
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final message = _messages[index];
                        return _buildMessageItem(message);
                      },
                    ),
          ),

          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  spreadRadius: 1,
                  blurRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: _toggleEmojiPicker,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Write a message...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                  onPressed: _pickFile,
                ),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),

          // Emoji picker
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) => _onEmojiSelected(emoji),
                config: Config(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message message) {
    final bool isMe = message.senderId == _currentUserId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 16,
          left: isMe ? 80 : 0,
          right: isMe ? 0 : 80,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/men/32.jpg',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "you",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  if (message.files.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildImageGrid(
                      message.files.map((file) => file.filePath).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormatter.formatTime(message.createdAt),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                if (isMe && AppConfig.enableReadReceipts) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.readAt != null ? Icons.done_all : Icons.done,
                    size: 14,
                    color:
                        message.readAt != null
                            ? Colors.blue
                            : Colors.grey.shade400,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<String> images) {
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          images[0],
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        ),
      );
    } else {
      return SizedBox(
        height: 150,
        child: GridView.count(
          crossAxisCount: images.length > 3 ? 2 : images.length,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children:
              images.map((url) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
        ),
      );
    }
  }
}
