import 'package:flutter/material.dart';
import '../services/timer_service.dart';
import '../flip_digit.dart';

class ClockCustomizerSheet extends StatelessWidget {
  const ClockCustomizerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final timerService = TimerService();

    return ListenableBuilder(
      listenable: timerService,
      builder: (context, _) {
        final style = timerService.clockStyle;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Customize Clock',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Live Preview
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FlipDigit(value: 1, size: 40 * style.digitSize, style: style),
                        SizedBox(width: style.digitSpacing * 0.4),
                        FlipDigit(value: 2, size: 40 * style.digitSize, style: style),
                        
                        if (style.showSeconds) ...[
                          SizedBox(width: style.digitSpacing),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _dot(style.textColor),
                              SizedBox(height: style.digitSpacing * 0.8),
                              _dot(style.textColor),
                            ],
                          ),
                          SizedBox(width: style.digitSpacing),
                          FlipDigit(value: 0, size: 40 * style.digitSize, style: style),
                          SizedBox(width: style.digitSpacing * 0.4),
                          FlipDigit(value: 0, size: 40 * style.digitSize, style: style),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Settings List
              Expanded(
                child: ListView(
                  children: [
                    // Presets / Colors
                    const Text('Presets & Colors', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildPresetButton(
                            timerService,
                            'Classic',
                            const Color(0xFF2C2C2C),
                            Colors.white,
                          ),
                          _buildPresetButton(
                            timerService,
                            'Light',
                            Colors.white,
                            Colors.black,
                          ),
                          _buildPresetButton(
                            timerService,
                            'Neon',
                            const Color(0xFF121212),
                            Colors.greenAccent,
                          ),
                          _buildPresetButton(
                            timerService,
                            'Orange',
                            const Color(0xFF121212),
                            Colors.orangeAccent,
                          ),
                           _buildPresetButton(
                            timerService,
                            'Blue',
                            const Color(0xFF0D1B2A),
                            Colors.lightBlueAccent,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Card Color Picker (Custom)
                    // Simplified to just presets for now as per "Color Pickers" requirement being rows of circles.
                    // But I implemented Presets which set both. 
                    // Let's add specific rows for Card and Text color as requested.
                    
                    const Text('Card Color', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    _buildColorRow(
                      [
                        const Color(0xFF2C2C2C),
                        Colors.white,
                        const Color(0xFF121212),
                        const Color(0xFF0D1B2A),
                        Colors.redAccent.shade700,
                      ],
                      style.cardColor,
                      (color) => timerService.updateClockStyle(style.copyWith(cardColor: color)),
                    ),

                    const SizedBox(height: 16),

                    const Text('Text Color', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    _buildColorRow(
                      [
                        Colors.white,
                        Colors.black,
                        Colors.greenAccent,
                        Colors.orangeAccent,
                        Colors.lightBlueAccent,
                        Colors.pinkAccent,
                      ],
                      style.textColor,
                      (color) => timerService.updateClockStyle(style.copyWith(textColor: color)),
                    ),

                    const SizedBox(height: 24),

                    // Corner Radius
                    Text('Corner Radius: ${style.borderRadius.toInt()}', style: const TextStyle(color: Colors.white70)),
                    Slider(
                      value: style.borderRadius,
                      min: 0,
                      max: 20,
                      activeColor: Colors.tealAccent,
                      inactiveColor: Colors.grey[800],
                      onChanged: (value) {
                        timerService.updateClockStyle(style.copyWith(borderRadius: value));
                      },
                    ),

                    // Digit Size
                    const SizedBox(height: 8),
                    Text('Digit Size: ${(style.digitSize * 100).toInt()}%', style: const TextStyle(color: Colors.white70)),
                    Slider(
                      value: style.digitSize,
                      min: 0.5,
                      max: 2.0,
                      activeColor: Colors.tealAccent,
                      inactiveColor: Colors.grey[800],
                      onChanged: (value) {
                        timerService.updateClockStyle(style.copyWith(digitSize: value));
                      },
                    ),

                    // Digit Spacing
                    const SizedBox(height: 8),
                    Text('Digit Spacing: ${style.digitSpacing.toInt()}', style: const TextStyle(color: Colors.white70)),
                    Slider(
                      value: style.digitSpacing,
                      min: 2,
                      max: 40,
                      activeColor: Colors.tealAccent,
                      inactiveColor: Colors.grey[800],
                      onChanged: (value) {
                        timerService.updateClockStyle(style.copyWith(digitSpacing: value));
                      },
                    ),

                    // Show Seconds
                    SwitchListTile(
                      title: const Text('Show Seconds', style: TextStyle(color: Colors.white)),
                      value: style.showSeconds,
                      activeColor: Colors.tealAccent,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        timerService.updateClockStyle(style.copyWith(showSeconds: value));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildPresetButton(
      TimerService service, String label, Color card, Color text) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          service.updateClockStyle(service.clockStyle.copyWith(
            cardColor: card,
            textColor: text,
          ));
        },
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: card,
                border: Border.all(color: Colors.grey[800]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text('Aa', style: TextStyle(color: text, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildColorRow(List<Color> colors, Color selectedColor, Function(Color) onSelect) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: colors.map((color) {
          final isSelected = color.value == selectedColor.value;
          return GestureDetector(
            onTap: () => onSelect(color),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.tealAccent : Colors.grey[800]!,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 20,
                      color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}
