import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/timer_service.dart';
import '../models/task.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

enum StatPeriod { day, week, month }

class _StatsPageState extends State<StatsPage> {
  StatPeriod _selectedPeriod = StatPeriod.day;
  final DateTime _currentDate = DateTime.now();

  String _formatDuration(int totalSeconds) {
    if (totalSeconds == 0) return '0m';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Helper to get start of the week (Monday)
  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Map<int, int> _getChartData(List<Task> tasks) {
    final Map<int, int> data = {};
    
    if (_selectedPeriod == StatPeriod.day) {
      // Buckets for hours 0-23
      for (var i = 0; i < 24; i++) {
        data[i] = 0;
      }
      
      final todayStart = DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      for (var task in tasks) {
        for (var session in task.sessions) {
          if (session.startTime.isAfter(todayStart) && session.startTime.isBefore(todayEnd)) {
             final hour = session.startTime.hour;
             data[hour] = (data[hour] ?? 0) + session.durationSeconds;
          }
        }
      }
    } else if (_selectedPeriod == StatPeriod.week) {
      // Buckets for Weekday 1-7 (Mon-Sun)
      for (var i = 1; i <= 7; i++) {
        data[i] = 0;
      }

      final startOfWeek = _getStartOfWeek(_currentDate);
      final endOfWeek = startOfWeek.add(const Duration(days: 7));
      
      final startFilter = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final endFilter = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day);

      for (var task in tasks) {
        for (var session in task.sessions) {
          if (session.startTime.isAfter(startFilter) && session.startTime.isBefore(endFilter)) {
             final weekday = session.startTime.weekday; // 1=Mon, 7=Sun
             data[weekday] = (data[weekday] ?? 0) + session.durationSeconds;
          }
        }
      }
    } else if (_selectedPeriod == StatPeriod.month) {
      // Buckets for days 1-31
      final daysInMonth = DateUtils.getDaysInMonth(_currentDate.year, _currentDate.month);
      for (var i = 1; i <= daysInMonth; i++) {
        data[i] = 0;
      }
      
      final startMonth = DateTime(_currentDate.year, _currentDate.month, 1);
      final endMonth = DateTime(_currentDate.year, _currentDate.month + 1, 1);

      for (var task in tasks) {
        for (var session in task.sessions) {
          if (session.startTime.isAfter(startMonth) && session.startTime.isBefore(endMonth)) {
             final day = session.startTime.day;
             data[day] = (data[day] ?? 0) + session.durationSeconds;
          }
        }
      }
    }

    return data;
  }

  int _getTotalTimeForPeriod(List<Task> tasks) {
    int total = 0;
    // Logic similar to above, just summing
    // To avoid duplication, let's just sum the chart data values
    final chartData = _getChartData(tasks);
    for (var val in chartData.values) {
      total += val;
    }
    return total;
  }
  
  // Calculate specific task time for the period to show in the list
  int _getTaskTimeForPeriod(Task task) {
     int total = 0;
     DateTime start, end;

     if (_selectedPeriod == StatPeriod.day) {
        start = DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
        end = start.add(const Duration(days: 1));
     } else if (_selectedPeriod == StatPeriod.week) {
        final sow = _getStartOfWeek(_currentDate);
        start = DateTime(sow.year, sow.month, sow.day);
        end = start.add(const Duration(days: 7));
     } else {
        start = DateTime(_currentDate.year, _currentDate.month, 1);
        end = DateTime(_currentDate.year, _currentDate.month + 1, 1);
     }

     for (var session in task.sessions) {
       if (session.startTime.isAfter(start) && session.startTime.isBefore(end)) {
         total += session.durationSeconds;
       }
     }
     return total;
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodBtn(StatPeriod.day, "Day"),
          _buildPeriodBtn(StatPeriod.week, "Week"),
          _buildPeriodBtn(StatPeriod.month, "Month"),
        ],
      ),
    );
  }

  Widget _buildPeriodBtn(StatPeriod period, String label) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.redAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChart(Map<int, int> data) {
    List<BarChartGroupData> barGroups = [];
    int maxVal = 1;
    
    // Sort keys to ensure order
    final sortedKeys = data.keys.toList()..sort();
    
    for (var key in sortedKeys) {
      if (data[key]! > maxVal) maxVal = data[key]!;
    }
    
    // Normalize logic or let fl_chart handle it? 
    // Let's just create BarChartGroupData
    for (var key in sortedKeys) {
       barGroups.add(
         BarChartGroupData(
           x: key,
           barRods: [
             BarChartRodData(
               toY: data[key]!.toDouble(),
               color: Colors.redAccent,
               width: _selectedPeriod == StatPeriod.month ? 4 : 12, // Thinner bars for month
               borderRadius: BorderRadius.circular(4),
               backDrawRodData: BackgroundBarChartRodData(
                 show: true,
                 toY: maxVal.toDouble(),
                 color: const Color(0xFF2C2C2C),
               )
             )
           ],
         )
       );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal.toDouble() * 1.1, // little buffer
          barTouchData: BarTouchData(
             touchTooltipData: BarTouchTooltipData(
               getTooltipColor: (_) => Colors.grey[800]!,
               getTooltipItem: (group, groupIndex, rod, rodIndex) {
                 return BarTooltipItem(
                   _formatDuration(rod.toY.toInt()),
                   const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                 );
               },
             ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final intVal = value.toInt();
                  String text = '';
                  if (_selectedPeriod == StatPeriod.day) {
                    if (intVal % 4 == 0) text = '$intVal:00';
                  } else if (_selectedPeriod == StatPeriod.week) {
                     const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                     if (intVal >= 1 && intVal <= 7) text = days[intVal-1];
                  } else {
                     if (intVal % 5 == 0 || intVal == 1) text = '$intVal';
                  }
                  
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerService = TimerService();
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: timerService,
          builder: (context, child) {
            final chartData = _getChartData(timerService.tasks);
            final totalTime = _getTotalTimeForPeriod(timerService.tasks);
            
            // Sort tasks by time spent in this period
            final activeTasks = timerService.tasks
                .where((t) => _getTaskTimeForPeriod(t) > 0)
                .toList();
            activeTasks.sort((a, b) => _getTaskTimeForPeriod(b).compareTo(_getTaskTimeForPeriod(a)));

            return Column(
              children: [
                const SizedBox(height: 10),
                // Header
                const Text(
                   'Statistics',
                   style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                
                _buildPeriodSelector(),
                
                // Total Time Display
                Text(
                  _formatDuration(totalTime),
                  style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Total Focus Time (${_selectedPeriod.name})",
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                
                const SizedBox(height: 30),
                
                // Chart
                _buildChart(chartData),
                
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                
                // Task List Breakdown
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: activeTasks.length,
                    itemBuilder: (context, index) {
                      final task = activeTasks[index];
                      final taskTime = _getTaskTimeForPeriod(task);
                      
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.circle, color: Colors.redAccent, size: 12),
                        title: Text(task.title, style: const TextStyle(color: Colors.white)),
                        trailing: Text(
                          _formatDuration(taskTime),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}