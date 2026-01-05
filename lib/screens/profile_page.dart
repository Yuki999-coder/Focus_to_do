import 'package:flutter/material.dart';
import '../services/timer_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final timerService = TimerService();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: Colors.black,
      ),
      body: ListenableBuilder(
        listenable: timerService,
        builder: (context, child) {
          return ListView(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[800],
                      child: const Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Focus Master',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.grey),

              // Settings Section
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              _buildListTile(
                icon: Icons.image,
                title: 'Background Image',
                subtitle: 'Change the Focus page background',
                onTap: () => _showBackgroundPicker(context, timerService),
              ),

              _buildListTile(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Manage app notifications',
                onTap: () {}, // Placeholder
              ),

              _buildListTile(
                icon: Icons.sync,
                title: 'Sync Data',
                subtitle: 'Backup your progress',
                onTap: () {}, // Placeholder
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.grey))
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showBackgroundPicker(BuildContext context, TimerService timerService) {
    final List<Map<String, String>> options = [
      {'type': 'color', 'value': 'color_black', 'label': 'Black'},
      {'type': 'color', 'value': 'color_white', 'label': 'White'},
      {'type': 'image', 'value': 'assets/images/bg_universe.jpg'},
      {'type': 'image', 'value': 'assets/images/hinh-nen-oppo-1.jpg'},
      {'type': 'image', 'value': 'assets/images/images.jpg'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Background',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0, // Square items
                  ),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = timerService.backgroundImage == option['value'];

                    return GestureDetector(
                      onTap: () {
                        timerService.setBackgroundImage(option['value']!);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(color: Colors.tealAccent, width: 3)
                              : Border.all(color: Colors.grey[800]!),
                          color: option['type'] == 'color' && option['value'] == 'color_black'
                              ? Colors.black
                              : (option['type'] == 'color' && option['value'] == 'color_white'
                                  ? Colors.white
                                  : Colors.grey[900]),
                          image: option['type'] == 'image'
                              ? DecorationImage(
                                  image: AssetImage(option['value']!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: Stack(
                          children: [
                            if (option['type'] == 'color')
                              Center(
                                child: Text(
                                  option['label']!,
                                  style: TextStyle(
                                    color: option['value'] == 'color_white' ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (isSelected)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, color: Colors.white, size: 24),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}