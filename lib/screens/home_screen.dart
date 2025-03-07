import 'package:flutter/material.dart';
import 'package:flutterapplication/screens/call_screen.dart';
import 'package:flutterapplication/screens/chat/chat_list_screen.dart';
import 'package:flutterapplication/screens/profile.dart';
import 'package:flutterapplication/screens/recent_screen.dart';
// import 'package:flutterapplication/widgets/chat_tile.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';
// import '../models/chat.dart';

// Screens for different tabs

// Reusable UI components

// Main home screen with navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  // List of all screens for the tabs
  final List<Widget> _screens = [
    const ChatsScreen(),
    const RecentScreen(),
    const CallsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Recent Chats',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A3C),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1A1A3C)),
            onPressed: () {},
          ),
        ],
      ),
      body: _screens[_selectedTab],
      floatingActionButton:
          _selectedTab == 0
              ? FloatingActionButton(
                onPressed: () {
                  // Show dialog or navigate to new conversation screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Create new conversation')),
                  );
                },
                child: const Icon(Icons.add_comment),
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Chats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Recent',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Calls'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
