import 'package:dio/dio.dart';
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
}
