class ChatMessage {
  final String sender;
  final String text;
  final String time;
  final bool isMe;
  final List<String> images;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.isMe,
    required this.images,
  });
}
