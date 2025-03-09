import 'package:flutterapplication/models/message_status.dart';

import 'user.dart';
import 'file_attachment.dart';

class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String messageType;
  final String? content;
  final bool isAlert;
  final bool isEmergency;
  final DateTime? readAt;
  final DateTime createdAt;
  final User? sender;
  final List<FileAttachment>? files;
  final List<MessageStatus>? status;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.messageType,
    this.content,
    this.isAlert = false,
    this.isEmergency = false,
    this.readAt,
    required this.createdAt,
    this.sender,
    this.files,
    this.status,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      messageType: json['message_type'],
      content: json['content'],
      isAlert: json['is_alert'] ?? false,
      isEmergency: json['is_emergency'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      files:
          json['files'] != null
              ? (json['files'] as List)
                  .map((file) => FileAttachment.fromJson(file))
                  .toList()
              : null,
      status:
          json['status'] != null
              ? (json['status'] as List)
                  .map((status) => MessageStatus.fromJson(status))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message_type': messageType,
      'content': content,
      'is_alert': isAlert,
      'is_emergency': isEmergency,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'sender': sender?.toJson(),
      'files': files?.map((file) => file.toJson()).toList(),
      'status': status?.map((status) => status.toJson()).toList(),
    };
  }

  // Check if the message is from the current user
  bool isFromCurrentUser(int currentUserId) {
    return senderId == currentUserId;
  }
}
