import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'task_form_screen.dart';

class TodaysTasksScreen extends StatefulWidget {
  @override
  _TodaysTasksScreenState createState() => _TodaysTasksScreenState();
}

class _TodaysTasksScreenState extends State<TodaysTasksScreen> {
  late Future<List<Task>> _tasksFuture;
  String _sortOrder = 'date';

  @override
  void initState() {
    super.initState();
    _loadSortPreferences();
    _refreshTasks();
  }

  Future<void> _loadSortPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sortOrder = prefs.getString('defaultSortOrder') ?? 'date';
    });
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _tasksFuture = _getSortedTasks(DatabaseService.instance.getTodaysTasks());
    });
  }

  Future<List<Task>> _getSortedTasks(Future<List<Task>> tasksFuture) async {
    final tasks = await tasksFuture;
    if (_sortOrder == 'priority') {
      // Sort by priority (high to low)
      tasks.sort((a, b) {
        if (a.priority.index > b.priority.index) return -1;
        if (a.priority.index < b.priority.index) return 1;
        return 0;
      });
    } else {
      // Sort by date (newest first)
      tasks.sort((a, b) {
        return b.createdDate.compareTo(a.createdDate);
      });
    }
    return tasks;
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completionDate: !task.isCompleted ? DateTime.now() : null,
    );

    await DatabaseService.instance.updateTask(updatedTask);
    
    // Cancel notification if task is completed
    if (updatedTask.isCompleted) {
      await NotificationService().cancelNotification(updatedTask.id ?? 0);
    } else {
      // Schedule notification if task is marked as pending
      if (updatedTask.dueDate != null) {
        await NotificationService().scheduleNotification(updatedTask);
      }
    }

    _refreshTasks();
  }

  Future<void> _editTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: task),
      ),
    );

    if (result == true) {
      _refreshTasks();
    }
  }

  Future<void> _deleteTask(Task task) async {
    await DatabaseService.instance.deleteTask(task.id!);
    await NotificationService().cancelNotification(task.id ?? 0);
    _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Tasks'),
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading tasks'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tasks due today',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          } else {
            final tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) => _toggleTaskCompletion(task),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description != null)
                          Text(
                            task.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            if (task.dueDate != null) ...[
                              Icon(Icons.calendar_today, size: 16),
                              SizedBox(width: 4),
                              Text(
                                _formatTime(task.dueDate!),
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(task.priority),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _priorityToString(task.priority),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (task.repeatType != RepeatType.none) ...[
                              SizedBox(width: 8),
                              Icon(Icons.repeat, size: 16),
                              SizedBox(width: 4),
                              Text(
                                _repeatTypeToString(task.repeatType),
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                        // Show progress if task has subtasks
                        if (task.subTasks.isNotEmpty) ...[
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _calculateProgress(task),
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getPriorityColor(task.priority),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${_getCompletedSubTasks(task)}/${task.subTasks.length} subtasks completed',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editTask(task);
                        } else if (value == 'delete') {
                          _confirmDelete(context, task);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                    onTap: () => _editTask(task),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  double _calculateProgress(Task task) {
    if (task.subTasks.isEmpty) return 0.0;
    final completed = task.subTasks.where((subTask) => subTask.isCompleted).length;
    return completed / task.subTasks.length;
  }

  int _getCompletedSubTasks(Task task) {
    return task.subTasks.where((subTask) => subTask.isCompleted).length;
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _priorityToString(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      default:
        return 'Medium';
    }
  }

  String _repeatTypeToString(RepeatType repeatType) {
    switch (repeatType) {
      case RepeatType.none:
        return '';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.monthly:
        return 'Monthly';
      case RepeatType.yearly:
        return 'Yearly';
      default:
        return '';
    }
  }

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTask(task);
              },
            ),
          ],
        );
      },
    );
  }
}