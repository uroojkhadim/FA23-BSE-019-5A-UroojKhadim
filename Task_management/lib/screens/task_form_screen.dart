import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'subtask_screen.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  TaskFormScreen({this.task});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  RepeatType _repeatType = RepeatType.none;
  Priority _priority = Priority.medium;
  List<SubTask> _subTasks = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate;
    _repeatType = widget.task?.repeatType ?? RepeatType.none;
    _priority = widget.task?.priority ?? Priority.medium;
    _subTasks = List.from(widget.task?.subTasks ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.task?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        createdDate: widget.task?.createdDate ?? DateTime.now(),
        dueDate: _dueDate,
        isCompleted: widget.task?.isCompleted ?? false,
        repeatType: _repeatType,
        completionDate: widget.task?.completionDate,
        priority: _priority,
        subTasks: _subTasks,
      );

      if (widget.task == null) {
        // New task
        final id = await DatabaseService.instance.insertTask(task);
        // Schedule notification for new task
        if (task.dueDate != null) {
          await NotificationService().scheduleNotification(task.copyWith(id: id));
        }
      } else {
        // Update existing task
        await DatabaseService.instance.updateTask(task);
        // Reschedule notification for updated task
        if (task.dueDate != null) {
          await NotificationService().cancelNotification(task.id ?? 0);
          await NotificationService().scheduleNotification(task);
        } else {
          await NotificationService().cancelNotification(task.id ?? 0);
        }
      }

      Navigator.pop(context, true);
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _manageSubTasks() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubTaskScreen(
          task: Task(
            id: widget.task?.id,
            title: _titleController.text,
            description: _descriptionController.text,
            createdDate: widget.task?.createdDate ?? DateTime.now(),
            dueDate: _dueDate,
            isCompleted: widget.task?.isCompleted ?? false,
            repeatType: _repeatType,
            completionDate: widget.task?.completionDate,
            priority: _priority,
            subTasks: _subTasks,
          ),
        ),
      ),
    );

    if (result == true) {
      // Refresh subtasks from database
      if (widget.task != null) {
        final updatedTask = await DatabaseService.instance.getTaskById(widget.task!.id!);
        if (updatedTask != null) {
          setState(() {
            _subTasks = List.from(updatedTask.subTasks);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedSubTasks = _subTasks.where((subTask) => subTask.isCompleted).length;
    final progress = _subTasks.isEmpty ? 0.0 : completedSubTasks / _subTasks.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTask,
            tooltip: 'Save Task',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Due Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _dueDate == null
                            ? 'No due date'
                            : Jiffy.parseFromDateTime(_dueDate!).format(pattern: 'MM/dd/yyyy'),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _selectDueDate,
                  ),
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _dueDate = null;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<RepeatType>(
                value: _repeatType,
                decoration: InputDecoration(
                  labelText: 'Repeat',
                  border: OutlineInputBorder(),
                ),
                items: RepeatType.values.map((RepeatType value) {
                  return DropdownMenuItem<RepeatType>(
                    value: value,
                    child: Text(_repeatTypeToString(value)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _repeatType = newValue;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<Priority>(
                value: _priority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: Priority.values.map((Priority value) {
                  return DropdownMenuItem<Priority>(
                    value: value,
                    child: Text(_priorityToString(value)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _priority = newValue;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              // Subtasks section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtasks',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: _manageSubTasks,
                            tooltip: 'Manage Subtasks',
                          ),
                        ],
                      ),
                      if (_subTasks.isNotEmpty) ...[
                        SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getPriorityColor(_priority),
                          ),
                          minHeight: 8,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '$completedSubTasks of ${_subTasks.length} completed',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            itemCount: _subTasks.length,
                            itemBuilder: (context, index) {
                              final subTask = _subTasks[index];
                              return Row(
                                children: [
                                  Checkbox(
                                    value: subTask.isCompleted,
                                    onChanged: null,
                                    activeColor: _getPriorityColor(_priority),
                                  ),
                                  Expanded(
                                    child: Text(
                                      subTask.title,
                                      style: TextStyle(
                                        decoration: subTask.isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        SizedBox(height: 8),
                        Text(
                          'No subtasks added',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _repeatTypeToString(RepeatType repeatType) {
    switch (repeatType) {
      case RepeatType.none:
        return 'None';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weekly:
        return 'Weekly';
      case RepeatType.monthly:
        return 'Monthly';
      case RepeatType.yearly:
        return 'Yearly';
      default:
        return 'None';
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
}