import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
                icon: Icons.music_note,
                title: 'Focus Sound',
                subtitle: 'Change completion sound',
                onTap: () => _showSoundPicker(context, timerService),
              ),

              _buildSwitchTile(
                icon: Icons.coffee,
                title: 'Auto-start Break',
                subtitle: 'Automatically start break timer',
                value: timerService.autoStartBreak,
                onChanged: (val) => timerService.setAutoStartBreak(val),
              ),

              _buildSwitchTile(
                icon: Icons.play_arrow,
                title: 'Auto-start Focus',
                subtitle: 'Automatically start focus timer',
                value: timerService.autoStartFocus,
                onChanged: (val) => timerService.setAutoStartFocus(val),
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

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.tealAccent,
      ),
    );
  }

  void _showSoundPicker(BuildContext context, TimerService timerService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final List<Map<String, String>> sounds = [
          {'name': 'Clock Tick', 'path': 'music/clock-tick.mp3'},
          {'name': 'Vine Boom', 'path': 'music/vine-boom.mp3'},
        ];
        sounds.addAll(timerService.customSounds);

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Sound',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.audio,
                        );

                        if (result != null) {
                          String? filePath = result.files.single.path;
                          String fileName = result.files.single.name;
                          if (filePath != null) {
                            await timerService.addCustomSound(fileName, filePath);
                            if (context.mounted) {
                              Navigator.pop(context); // Close to refresh or just setState
                              _showSoundPicker(context, timerService); // Re-open to show new item
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.add, color: Colors.tealAccent),
                      label: const Text('Add', style: TextStyle(color: Colors.tealAccent)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sounds.length,
                  itemBuilder: (context, index) {
                    final soundItem = sounds[index];
                    final isSelected = timerService.selectedSound == soundItem['path'];
                    return ListTile(
                      leading: Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.tealAccent : Colors.grey,
                      ),
                      title: Text(
                        soundItem['name']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        timerService.setSound(soundItem['path']!);
                        Navigator.pop(context);
                      },
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

  void _showBackgroundPicker(BuildContext context, TimerService timerService) {
    final List<Map<String, String>> options = [
      {'type': 'color', 'value': 'color_black', 'label': 'Black'},
      {'type': 'color', 'value': 'color_white', 'label': 'White'},
      {'type': 'image', 'value': 'assets/images/bg_universe.jpg'},
      {'type': 'image', 'value': 'assets/images/hinh-nen-oppo-1.jpg'},
      {'type': 'image', 'value': 'assets/images/images.jpg'},
    ];

    // Add custom images
    for (var path in timerService.customBackgrounds) {
       options.add({'type': 'file', 'value': path});
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Background',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate, color: Colors.tealAccent),
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.image,
                      );

                      if (result != null) {
                        String? filePath = result.files.single.path;
                        if (filePath != null) {
                          await timerService.addCustomBackground(filePath);
                          if (context.mounted) {
                            Navigator.pop(context);
                            _showBackgroundPicker(context, timerService);
                          }
                        }
                      }
                    },
                  )
                ],
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

                    ImageProvider? imgProvider;
                    if (option['type'] == 'image') {
                      imgProvider = AssetImage(option['value']!);
                    } else if (option['type'] == 'file') {
                      imgProvider = FileImage(File(option['value']!));
                    }

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
                          image: imgProvider != null
                              ? DecorationImage(
                                  image: imgProvider,
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