class ChatModel {
  final String id;
  final String name;
  final String message;
  final String time;
  final String avatarUrl;
  final int unreadCount;
  final bool isOnline;

  ChatModel({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    required this.avatarUrl,
    required this.unreadCount,
    required this.isOnline,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      message: json['last_message'] ?? '',
      time: json['last_message_time'] ?? 'Unknown',
      avatarUrl: json['avatar_url'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
      isOnline: json['is_online'] ?? false,
    );
  }
}
