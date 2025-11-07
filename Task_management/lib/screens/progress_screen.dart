import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: Text('Progress Tracking'),
      ),
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
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overall Progress',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: stats.overallProgress,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgressColor(stats.overallProgress),
                              ),
                              minHeight: 10,
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${(stats.overallProgress * 100).toStringAsFixed(1)}% Complete',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Task Statistics
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Task Statistics',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: 16),
                            _buildStatRow('Total Tasks', stats.totalTasks.toString()),
                            _buildStatRow('Completed Tasks', stats.completedTasks.toString()),
                            _buildStatRow('Pending Tasks', stats.pendingTasks.toString()),
                            _buildStatRow('Repeated Tasks', stats.repeatedTasks.toString()),
                            _buildStatRow('Tasks with Subtasks', stats.tasksWithSubtasks.toString()),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Priority Distribution
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Priority Distribution',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: 16),
                            _buildPriorityBar(
                              'High Priority', 
                              stats.highPriorityTasks, 
                              stats.totalTasks, 
                              Colors.red
                            ),
                            _buildPriorityBar(
                              'Medium Priority', 
                              stats.mediumPriorityTasks, 
                              stats.totalTasks, 
                              Colors.orange
                            ),
                            _buildPriorityBar(
                              'Low Priority', 
                              stats.lowPriorityTasks, 
                              stats.totalTasks, 
                              Colors.green
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Completion Chart
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Completion by Priority',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: 16),
                            _buildCompletionBar(
                              'High Priority', 
                              stats.completedHighPriority, 
                              stats.highPriorityTasks, 
                              Colors.red
                            ),
                            _buildCompletionBar(
                              'Medium Priority', 
                              stats.completedMediumPriority, 
                              stats.mediumPriorityTasks, 
                              Colors.orange
                            ),
                            _buildCompletionBar(
                              'Low Priority', 
                              stats.completedLowPriority, 
                              stats.lowPriorityTasks, 
                              Colors.green
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
    final repeatedTasks = tasks.where((task) => task.repeatType != RepeatType.none).length;
    final tasksWithSubtasks = tasks.where((task) => task.subTasks.isNotEmpty).length;
    
    // Priority counts
    final highPriorityTasks = tasks.where((task) => task.priority == Priority.high).length;
    final mediumPriorityTasks = tasks.where((task) => task.priority == Priority.medium).length;
    final lowPriorityTasks = tasks.where((task) => task.priority == Priority.low).length;
    
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildPriorityBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('${count} (${(percentage * 100).toStringAsFixed(1)}%)'),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBar(String label, int completed, int total, Color color) {
    final percentage = total > 0 ? completed / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('$completed/$total (${(percentage * 100).toStringAsFixed(1)}%)'),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
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