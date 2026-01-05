import 'package:flutter/material.dart';
import 'focus_page.dart';
import 'task_page.dart';
import 'stats_page.dart';
import 'timeline_page.dart';
import 'profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    FocusPage(),
    TaskPage(),
    StatsPage(),
    TimelinePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Needed for 4+ items
        backgroundColor: Colors.black, // Dark theme background
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.timer), // Focus - Image 1 (Home/Timer)
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list), // Tasks - Image 4
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), // Stats - Image 5
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history), // Timeline
            label: 'Timeline',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Profile
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
