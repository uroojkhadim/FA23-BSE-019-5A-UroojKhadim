import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<Task>> _tasksWithNotificationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshTasksWithNotifications();
  }

  Future<void> _refreshTasksWithNotifications() async {
    setState(() {
      _tasksWithNotificationsFuture = _getTasksWithNotifications();
    });
  }

  Future<List<Task>> _getTasksWithNotifications() async {
    final tasks = await DatabaseService.instance.getAllTasks();
    // Filter tasks that have due dates (these are the ones with notifications)
    return tasks.where((task) => task.dueDate != null).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scheduled Notifications'),
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksWithNotificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading notifications'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No scheduled notifications',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tasks with due dates will appear here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
                    leading: Icon(
                      Icons.notifications_active,
                      color: _getPriorityColor(task.priority),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                            Icon(Icons.calendar_today, size: 16),
                            SizedBox(width: 4),
                            Text(
                              _formatDueDate(task.dueDate!),
                              style: TextStyle(fontSize: 12),
                            ),
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
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => _cancelNotification(context, task),
                      tooltip: 'Cancel Notification',
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
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

  Future<void> _cancelNotification(BuildContext context, Task task) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Notification'),
          content: Text(
              'Are you sure you want to cancel the notification for "${task.title}"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                await NotificationService().cancelNotification(task.id ?? 0);
                _refreshTasksWithNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Notification cancelled for "${task.title}"')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}