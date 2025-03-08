import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SelectUserDialog extends StatefulWidget {
  const SelectUserDialog({super.key});

  @override
  _SelectUserDialogState createState() => _SelectUserDialogState();
}

class _SelectUserDialogState extends State<SelectUserDialog> {
  // final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await Dio().get(
        'http://10.0.2.2:8000/api/users',
      ); // Adjust endpoint
      setState(() {
        _users = List<Map<String, dynamic>>.from(response.data['users']);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select a user to chat'),
      content:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user['avatar_url'] ?? ''),
                      ),
                      title: Text(user['name']),
                      onTap:
                          () =>
                              Navigator.of(context).pop(user['id'].toString()),
                    );
                  },
                ),
              ),
    );
  }
}
