import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Profile Header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Dang Nhap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white70),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month, color: Colors.white70),
                    onPressed: () {},
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.white38),
                    icon: Icon(Icons.search, color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Menu List
              Expanded(
                child: ListView(
                  children: [
                    _buildMenuItem(
                      icon: Icons.wb_sunny,
                      iconColor: Colors.yellow,
                      title: 'Today',
                      time: '1h 25m',
                      count: 4,
                    ),
                     _buildMenuItem(
                      icon: Icons.calendar_today,
                      iconColor: Colors.purpleAccent,
                      title: 'Tomorrow',
                      time: '45m',
                      count: 2,
                    ),
                    _buildMenuItem(
                      icon: Icons.date_range,
                      iconColor: Colors.blueAccent,
                      title: 'This Week',
                      time: '5h 10m',
                      count: 8,
                    ),
                    _buildMenuItem(
                      icon: Icons.event_note,
                      iconColor: Colors.orangeAccent,
                      title: 'Planned',
                      time: '',
                      count: 0,
                    ),
                     _buildMenuItem(
                      icon: Icons.emoji_events,
                      iconColor: Colors.greenAccent,
                      title: 'Events',
                      time: '2h',
                      count: 1,
                    ),
                    _buildMenuItem(
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.redAccent,
                      title: 'Tasks',
                      time: '30m',
                      count: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
    required int count,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.transparent, // Or a slight background if preferred
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (time.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
               color: Colors.grey[800],
               borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}