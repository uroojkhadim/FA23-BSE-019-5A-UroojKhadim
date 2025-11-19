import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _tasksFuture = DatabaseService.instance.getAllTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Progress Tracking')),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading tasks'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            final tasks = snapshot.data!;
            final stats = _calculateStatistics(tasks);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overall Progress Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overall Progress',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),
                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    height: 150,
                                    child: CircularProgressIndicator(
                                      value: stats.overallProgress,
                                      strokeWidth: 12,
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[700]
                                          : Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getProgressColor(
                                          stats.overallProgress,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${(stats.overallProgress * 100).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: _getProgressColor(
                                            stats.overallProgress,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${stats.completedTasks}/${stats.totalTasks} Tasks',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            _buildStatRow(
                              'Total Tasks',
                              stats.totalTasks.toString(),
                            ),
                            _buildStatRow(
                              'Completed Tasks',
                              stats.completedTasks.toString(),
                            ),
                            _buildStatRow(
                              'Pending Tasks',
                              stats.pendingTasks.toString(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Priority Distribution Chart
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Priority Distribution',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),
                            Container(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  barTouchData: BarTouchData(
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipColor: (group) =>
                                          Colors.grey[800]!,
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                            String priority = '';
                                            switch (groupIndex) {
                                              case 0:
                                                priority = 'High';
                                                break;
                                              case 1:
                                                priority = 'Medium';
                                                break;
                                              case 2:
                                                priority = 'Low';
                                                break;
                                            }
                                            return BarTooltipItem(
                                              '$priority Priority\n',
                                              const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${rod.toY.toInt()} tasks',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          List<String> priorities = [
                                            'High',
                                            'Med',
                                            'Low',
                                          ];
                                          if (value >= 0 &&
                                              value < priorities.length) {
                                            return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              child: Text(
                                                priorities[value.toInt()],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                              ),
                                            );
                                          }
                                          return Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          return SideTitleWidget(
                                            axisSide: meta.axisSide,
                                            child: Text(
                                              value.toInt().toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: [
                                    BarChartGroupData(
                                      x: 0,
                                      barRods: [
                                        BarChartRodData(
                                          toY: stats.highPriorityTasks
                                              .toDouble(),
                                          color: Colors.red,
                                          width: 20,
                                          borderRadius: BorderRadius.zero,
                                        ),
                                      ],
                                    ),
                                    BarChartGroupData(
                                      x: 1,
                                      barRods: [
                                        BarChartRodData(
                                          toY: stats.mediumPriorityTasks
                                              .toDouble(),
                                          color: Colors.orange,
                                          width: 20,
                                          borderRadius: BorderRadius.zero,
                                        ),
                                      ],
                                    ),
                                    BarChartGroupData(
                                      x: 2,
                                      barRods: [
                                        BarChartRodData(
                                          toY: stats.lowPriorityTasks
                                              .toDouble(),
                                          color: Colors.green,
                                          width: 20,
                                          borderRadius: BorderRadius.zero,
                                        ),
                                      ],
                                    ),
                                  ],
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 1,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[700]!
                                            : Colors.grey[300]!,
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Completion by Priority Chart
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Completion by Priority',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),
                            Container(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  barTouchData: BarTouchData(
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipColor: (group) =>
                                          Colors.grey[800]!,
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                            String priority = '';
                                            switch (groupIndex) {
                                              case 0:
                                                priority = 'High';
                                                break;
                                              case 1:
                                                priority = 'Medium';
                                                break;
                                              case 2:
                                                priority = 'Low';
                                                break;
                                            }
                                            return BarTooltipItem(
                                              '$priority Priority\n',
                                              const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      '${rod.toY.toInt()}% completed',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          List<String> priorities = [
                                            'High',
                                            'Med',
                                            'Low',
                                          ];
                                          if (value >= 0 &&
                                              value < priorities.length) {
                                            return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              child: Text(
                                                priorities[value.toInt()],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color:
                                                      Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white70
                                                      : Colors.black54,
                                                ),
                                              ),
                                            );
                                          }
                                          return Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          return SideTitleWidget(
                                            axisSide: meta.axisSide,
                                            child: Text(
                                              '${value.toInt()}%',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: [
                                    BarChartGroupData(
                                      x: 0,
                                      barRods: [
                                        BarChartRodData(
                                          toY: stats.highPriorityTasks > 0
                                              ? (stats.completedHighPriority /
                                                    stats.highPriorityTasks *
                                                    100)
                                              : 0,
                                          color: Colors.red,
                                          width: 20,
                                          borderRadius: BorderRadius.zero,
                                        ),
                                      ],
                                    ),
                                    BarChartGroupData(
                                      x: 1,
                                      barRods: [
                                        BarChartRodData(
                                          toY: stats.mediumPriorityTasks > 0
                                              ? (stats.completedMediumPriority /
                                                    stats.mediumPriorityTasks *
                                                    100)
                                              : 0,
                                          color: Colors.orange,
                                          width: 20,
                                          borderRadius: BorderRadius.zero,
                                        ),
                                      ],
                                    ),
                                    BarChartGroupData(
                                      x: 2,
                                      barRods: [
                                        BarChartRodData(
                                          toY: stats.lowPriorityTasks > 0
                                              ? (stats.completedLowPriority /
                                                    stats.lowPriorityTasks *
                                                    100)
                                              : 0,
                                          color: Colors.green,
                                          width: 20,
                                          borderRadius: BorderRadius.zero,
                                        ),
                                      ],
                                    ),
                                  ],
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 20,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[700]!
                                            : Colors.grey[300]!,
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  maxY: 100,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Additional Statistics
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Additional Statistics',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                            _buildStatRow(
                              'Repeated Tasks',
                              stats.repeatedTasks.toString(),
                            ),
                            _buildStatRow(
                              'Tasks with Subtasks',
                              stats.tasksWithSubtasks.toString(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Statistics _calculateStatistics(List<Task> tasks) {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final pendingTasks = totalTasks - completedTasks;
    final repeatedTasks = tasks
        .where((task) => task.repeatType != RepeatType.none)
        .length;
    final tasksWithSubtasks = tasks
        .where((task) => task.subTasks.isNotEmpty)
        .length;

    // Priority counts
    final highPriorityTasks = tasks
        .where((task) => task.priority == Priority.high)
        .length;
    final mediumPriorityTasks = tasks
        .where((task) => task.priority == Priority.medium)
        .length;
    final lowPriorityTasks = tasks
        .where((task) => task.priority == Priority.low)
        .length;

    // Completed by priority
    final completedHighPriority = tasks
        .where((task) => task.priority == Priority.high && task.isCompleted)
        .length;
    final completedMediumPriority = tasks
        .where((task) => task.priority == Priority.medium && task.isCompleted)
        .length;
    final completedLowPriority = tasks
        .where((task) => task.priority == Priority.low && task.isCompleted)
        .length;

    final overallProgress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Statistics(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      repeatedTasks: repeatedTasks,
      tasksWithSubtasks: tasksWithSubtasks,
      highPriorityTasks: highPriorityTasks,
      mediumPriorityTasks: mediumPriorityTasks,
      lowPriorityTasks: lowPriorityTasks,
      completedHighPriority: completedHighPriority,
      completedMediumPriority: completedMediumPriority,
      completedLowPriority: completedLowPriority,
      overallProgress: overallProgress,
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.75) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.red;
  }
}

class Statistics {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int repeatedTasks;
  final int tasksWithSubtasks;
  final int highPriorityTasks;
  final int mediumPriorityTasks;
  final int lowPriorityTasks;
  final int completedHighPriority;
  final int completedMediumPriority;
  final int completedLowPriority;
  final double overallProgress;

  Statistics({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.repeatedTasks,
    required this.tasksWithSubtasks,
    required this.highPriorityTasks,
    required this.mediumPriorityTasks,
    required this.lowPriorityTasks,
    required this.completedHighPriority,
    required this.completedMediumPriority,
    required this.completedLowPriority,
    required this.overallProgress,
  });
}
