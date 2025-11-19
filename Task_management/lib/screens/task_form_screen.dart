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
  TimeOfDay? _dueTime;
  RepeatType _repeatType = RepeatType.none;
  Priority _priority = Priority.medium;
  List<SubTask> _subTasks = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _dueDate = widget.task?.dueDate;
    _dueTime = widget.task?.dueTime;
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
        dueTime: _dueTime,
        isCompleted: widget.task?.isCompleted ?? false,
        repeatType: _repeatType,
        completionDate: widget.task?.completionDate,
        priority: _priority,
        subTasks: _subTasks,
      );

      print('Saving task: ${task.title}, due date: ${task.dueDate}');

      if (widget.task == null) {
        // New task
        final id = await DatabaseService.instance.insertTask(task);
        print('New task inserted with ID: $id');
        // Schedule notification for new task
        if (task.dueDate != null) {
          print('Scheduling notification for new task');
          await NotificationService().scheduleNotification(
            task.copyWith(id: id),
          );
        } else {
          print('No due date for task, skipping notification');
        }
      } else {
        // Update existing task
        print('Updating existing task with ID: ${task.id}');
        await DatabaseService.instance.updateTask(task);
        // Reschedule notification for updated task
        if (task.dueDate != null) {
          print('Cancelling old notification and scheduling new one');
          await NotificationService().cancelNotification(task.id ?? 0);
          await NotificationService().scheduleNotification(task);
        } else {
          print('No due date for updated task, cancelling notification');
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

  Future<void> _selectDueTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _dueTime = picked;
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
            dueTime: _dueTime,
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
        final updatedTask = await DatabaseService.instance.getTaskById(
          widget.task!.id!,
        );
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
    final completedSubTasks = _subTasks
        .where((subTask) => subTask.isCompleted)
        .length;
    final progress = _subTasks.isEmpty
        ? 0.0
        : completedSubTasks / _subTasks.length;

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field with improved styling
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black26
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16),

                // Description field with improved styling
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black26
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    maxLines: 4,
                  ),
                ),
                SizedBox(height: 16),

                // Due date section with improved styling
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black26
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _dueDate == null
                                          ? 'No due date'
                                          : Jiffy.parseFromDateTime(
                                              _dueDate!,
                                            ).format(pattern: 'MM/dd/yyyy'),
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white70
                                            : Colors.grey[700],
                                      ),
                                    ),
                                    if (_dueDate != null) ...[
                                      SizedBox(height: 4),
                                      Text(
                                        _dueTime == null
                                            ? 'No time set'
                                            : '${_dueTime!.hour}:${_dueTime!.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white70
                                              : Colors.grey[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            IconButton(
                              icon: Icon(
                                Icons.calendar_today,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: _selectDueDate,
                              tooltip: 'Select date',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.access_time,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: _dueDate != null ? _selectDueTime : null,
                              tooltip: 'Select time',
                            ),
                            IconButton(
                              icon: Icon(Icons.clear, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _dueDate = null;
                                  _dueTime = null;
                                });
                              },
                              tooltip: 'Clear date and time',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Repeat type dropdown with improved styling
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black26
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Repeat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<RepeatType>(
                            value: _repeatType,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Priority dropdown with improved styling
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black26
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Priority',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<Priority>(
                            value: _priority,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            items: Priority.values.map((Priority value) {
                              return DropdownMenuItem<Priority>(
                                value: value,
                                child: Text(
                                  _priorityToString(value),
                                  style: TextStyle(
                                    color: _getPriorityColor(value),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Subtasks section with improved styling
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black26
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: _manageSubTasks,
                              tooltip: 'Manage Subtasks',
                            ),
                          ],
                        ),
                        if (_subTasks.isNotEmpty) ...[
                          SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getPriorityColor(_priority),
                              ),
                              minHeight: 8,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '$completedSubTasks of ${_subTasks.length} completed',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.all(8),
                              itemCount: _subTasks.length,
                              itemBuilder: (context, index) {
                                final subTask = _subTasks[index];
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[700]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    leading: Icon(
                                      subTask.isCompleted
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: subTask.isCompleted
                                          ? Colors.green
                                          : _getPriorityColor(_priority),
                                      size: 20,
                                    ),
                                    title: Text(
                                      subTask.title,
                                      style: TextStyle(
                                        decoration: subTask.isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'No subtasks added',
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24), // Add some space at the bottom
              ],
            ),
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
