import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class SubTaskScreen extends StatefulWidget {
  final Task task;

  SubTaskScreen({required this.task});

  @override
  _SubTaskScreenState createState() => _SubTaskScreenState();
}

class _SubTaskScreenState extends State<SubTaskScreen> {
  final TextEditingController _subTaskController = TextEditingController();
  late List<SubTask> _subTasks;

  @override
  void initState() {
    super.initState();
    _subTasks = List.from(widget.task.subTasks);
  }

  @override
  void dispose() {
    _subTaskController.dispose();
    super.dispose();
  }

  Future<void> _addSubTask() async {
    if (_subTaskController.text.trim().isNotEmpty) {
      final newSubTask = SubTask(
        taskId: widget.task.id ?? 0,
        title: _subTaskController.text.trim(),
      );
      
      setState(() {
        _subTasks.add(newSubTask);
      });
      
      _subTaskController.clear();
    }
  }

  void _toggleSubTaskCompletion(int index) {
    setState(() {
      _subTasks[index] = _subTasks[index].copyWith(
        isCompleted: !_subTasks[index].isCompleted,
      );
    });
  }

  void _removeSubTask(int index) {
    setState(() {
      _subTasks.removeAt(index);
    });
  }

  Future<void> _saveSubTasks() async {
    try {
      final updatedTask = widget.task.copyWith(subTasks: _subTasks);
      await DatabaseService.instance.updateTask(updatedTask);
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save subtasks: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _subTasks.where((subTask) => subTask.isCompleted).length;
    final progress = _subTasks.isEmpty ? 0.0 : completedCount / _subTasks.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Subtasks: ${widget.task.title}'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSubTasks,
            tooltip: 'Save Subtasks',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          if (_subTasks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress: ${completedCount}/${_subTasks.length} (${(progress * 100).toStringAsFixed(1)}%)',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                  ),
                ],
              ),
            ),
          ],
          
          // Add new subtask
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subTaskController,
                    decoration: InputDecoration(
                      hintText: 'Add a new subtask',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addSubTask(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addSubTask,
                  tooltip: 'Add Subtask',
                ),
              ],
            ),
          ),
          
          // Subtasks list
          Expanded(
            child: _subTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checklist, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No subtasks yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add subtasks to break down your task',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _subTasks.length,
                    itemBuilder: (context, index) {
                      final subTask = _subTasks[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Checkbox(
                            value: subTask.isCompleted,
                            onChanged: (_) => _toggleSubTaskCompletion(index),
                          ),
                          title: Text(
                            subTask.title,
                            style: TextStyle(
                              decoration: subTask.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _removeSubTask(index),
                            tooltip: 'Remove Subtask',
                          ),
                          onTap: () => _toggleSubTaskCompletion(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}