import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/timer_service.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> with SingleTickerProviderStateMixin {
  late TimerService _timerService;
  late TabController _tabController;
  String _selectedPeriod = 'Week';

  @override
  void initState() {
    super.initState();
    _timerService = TimerService();
    _timerService.addListener(_update);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _timerService.removeListener(_update);
    _tabController.dispose();
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  // Get all sessions with task info
  List<TimelineItem> _getAllSessions() {
    List<TimelineItem> items = [];
    for (var task in _timerService.tasks) {
      for (var session in task.sessions) {
        items.add(TimelineItem(session, task.title, task.id));
      }
    }
    items.sort((a, b) => b.session.startTime.compareTo(a.session.startTime));
    return items;
  }

  // Calculate total focus time for a period
  int _getTotalSeconds(List<TimelineItem> items, {DateTime? from, DateTime? to}) {
    return items.where((item) {
      if (from != null && item.session.startTime.isBefore(from)) return false;
      if (to != null && item.session.startTime.isAfter(to)) return false;
      return true;
    }).fold(0, (sum, item) => sum + item.session.durationSeconds);
  }

  // Get sessions for today
  List<TimelineItem> _getTodaySessions(List<TimelineItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return items.where((item) {
      final sessionDate = DateTime(
        item.session.startTime.year,
        item.session.startTime.month,
        item.session.startTime.day,
      );
      return sessionDate == today;
    }).toList();
  }

  // Get sessions for this week
  List<TimelineItem> _getWeekSessions(List<TimelineItem> items) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return items.where((item) => item.session.startTime.isAfter(start)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = _getAllSessions();
    final todayItems = _getTodaySessions(allItems);
    final weekItems = _getWeekSessions(allItems);
    
    final todayTotal = _getTotalSeconds(todayItems);
    final weekTotal = _getTotalSeconds(weekItems);
    final allTimeTotal = _getTotalSeconds(allItems);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Stats
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1A2E), Color(0xFF0D0D0D)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Timeline',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Period Selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedPeriod,
                            dropdownColor: const Color(0xFF2C2C2C),
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            items: ['Today', 'Week', 'All Time'].map((period) {
                              return DropdownMenuItem(value: period, child: Text(period));
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedPeriod = value!);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Today',
                          _formatDurationLong(todayTotal),
                          '${todayItems.length} sessions',
                          Colors.tealAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'This Week',
                          _formatDurationLong(weekTotal),
                          '${weekItems.length} sessions',
                          Colors.purpleAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Total Focus Time Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepOrange.withOpacity(0.3),
                          Colors.redAccent.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.deepOrange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Focus Time',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              _formatDurationLong(allTimeTotal),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          '${allItems.length}',
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'sessions',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                tabs: const [
                  Tab(text: 'History'),
                  Tab(text: 'By Task'),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Content based on tab and period
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryView(_getFilteredItems(allItems)),
                _buildByTaskView(_getFilteredItems(allItems)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<TimelineItem> _getFilteredItems(List<TimelineItem> items) {
    switch (_selectedPeriod) {
      case 'Today':
        return _getTodaySessions(items);
      case 'Week':
        return _getWeekSessions(items);
      default:
        return items;
    }
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView(List<TimelineItem> items) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    // Group by date
    Map<String, List<TimelineItem>> groupedItems = {};
    for (var item in items) {
      String dateKey = _getDateKey(item.session.startTime);
      groupedItems.putIfAbsent(dateKey, () => []).add(item);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: groupedItems.keys.length,
      itemBuilder: (context, index) {
        String dateKey = groupedItems.keys.elementAt(index);
        List<TimelineItem> dayItems = groupedItems[dateKey]!;
        int dayTotal = dayItems.fold(0, (sum, item) => sum + item.session.durationSeconds);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateKey,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDurationShort(dayTotal),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            // Sessions
            ...dayItems.map((item) => _buildSessionCard(item)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildByTaskView(List<TimelineItem> items) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    // Group by task
    Map<String, List<TimelineItem>> byTask = {};
    for (var item in items) {
      byTask.putIfAbsent(item.taskTitle, () => []).add(item);
    }

    // Sort by total time
    var sortedTasks = byTask.entries.toList()
      ..sort((a, b) {
        int totalA = a.value.fold(0, (sum, item) => sum + item.session.durationSeconds);
        int totalB = b.value.fold(0, (sum, item) => sum + item.session.durationSeconds);
        return totalB.compareTo(totalA);
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: sortedTasks.length,
      itemBuilder: (context, index) {
        final entry = sortedTasks[index];
        final taskName = entry.key;
        final sessions = entry.value;
        final totalSeconds = sessions.fold(0, (sum, item) => sum + item.session.durationSeconds);
        
        // Calculate percentage of total
        final allTotal = items.fold(0, (sum, item) => sum + item.session.durationSeconds);
        final percentage = allTotal > 0 ? (totalSeconds / allTotal * 100) : 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            collapsedShape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            iconColor: Colors.white54,
            collapsedIconColor: Colors.white54,
            title: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getTaskColor(index),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        taskName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _formatDurationLong(totalSeconds),
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${sessions.length} sessions',
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTaskColor(index).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: _getTaskColor(index),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            children: [
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(_getTaskColor(index)),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),
              // Recent sessions
              ...sessions.take(3).map((item) => _buildMiniSessionCard(item)),
              if (sessions.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+ ${sessions.length - 3} more sessions',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionCard(TimelineItem item) {
    final startTime = DateFormat('HH:mm').format(item.session.startTime);
    final endTime = DateFormat('HH:mm').format(
      item.session.startTime.add(Duration(seconds: item.session.durationSeconds)),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          // Time indicator
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.tealAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.timer_outlined, color: Colors.tealAccent, size: 20),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.taskTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white38, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '$startTime - $endTime',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Duration badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatDurationShort(item.session.durationSeconds),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSessionCard(TimelineItem item) {
    final date = DateFormat('MMM d, HH:mm').format(item.session.startTime);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white38,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            date,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const Spacer(),
          Text(
            _formatDurationShort(item.session.durationSeconds),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_empty_rounded,
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No focus sessions yet',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a focus timer to track your productivity',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTaskColor(int index) {
    final colors = [
      Colors.tealAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.lightBlueAccent,
      Colors.greenAccent,
      Colors.amberAccent,
      Colors.cyanAccent,
    ];
    return colors[index % colors.length];
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return 'Today';
    if (checkDate == yesterday) return 'Yesterday';
    
    // Check if same week
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    if (checkDate.isAfter(weekStart.subtract(const Duration(days: 1)))) {
      return DateFormat('EEEE').format(date); // Day name
    }
    
    return DateFormat('MMM d').format(date);
  }

  String _formatDurationLong(int seconds) {
    if (seconds < 60) return '${seconds}s';
    
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatDurationShort(int seconds) {
    if (seconds < 60) return '${seconds}s';
    
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h${minutes > 0 ? ' ${minutes}m' : ''}';
    }
    return '${minutes}m';
  }
}

class TimelineItem {
  final FocusSession session;
  final String taskTitle;
  final String taskId;
  TimelineItem(this.session, this.taskTitle, this.taskId);
}
