import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutterapplication/models/message.dart';
import 'package:flutterapplication/models/message_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageService {
  final String baseUrl = 'http://10.0.2.2:8000/api';
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Fetch the auth token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Add the token dynamically to each request
  Future<void> _setAuthHeaders() async {
    String? token = await _getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<bool> isLoggedIn() async {
    return (await _getToken()) != null;
  }

  Future<Response> getMessages(int conversationId) async {
    await _setAuthHeaders();

    try {
      Response response = await _dio.get('messages/$conversationId');
      return response;
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  Future<List<Message>> gM(
    int conversationId, {
    int limit = 50,
    int offset = 0,
  }) async {
    await _setAuthHeaders();

    try {
      final response = await _dio.get(
        '/messages/$conversationId?limit=$limit&offset=$offset',
      );

      if (response.statusCode == 200) {
        // Use the MessagesResponse model to parse the response
        final messagesResponse = MessagesResponse.fromJson(response.data);
        return messagesResponse.messages;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  Future<Message?> sendMessage(
    int conversationId,
    String content, {
    List<String>? filePaths,
  }) async {
    try {
      Map<String, dynamic> body = {'content': content};

      final response = await _dio.post('/messages/$conversationId', data: body);

      if (response.statusCode == 201) {
        final data = json.decode(response.data);
        return Message.fromJson(data['message']);
      }
      return null;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }
}
