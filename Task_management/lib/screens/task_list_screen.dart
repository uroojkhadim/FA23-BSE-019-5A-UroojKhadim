import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with TickerProviderStateMixin {
  late Future<List<Task>> _tasksFuture;
  bool _showCompleted = false;
  String _sortOrder = 'date';
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Priority? _filterPriority;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  Map<int, AnimationController> _animationControllers = {};
  Map<int, Animation<double>> _fadeAnimations = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadSortPreferences();
    _refreshTasks();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    // Dispose all animation controllers
    _animationControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _initializeAnimations(List<Task> tasks) {
    // Dispose of old controllers
    _animationControllers.values.forEach((controller) => controller.dispose());
    _animationControllers.clear();
    _fadeAnimations.clear();

    // Create new controllers for current tasks
    for (int i = 0; i < tasks.length; i++) {
      final taskId = tasks[i].id ?? i;
      _animationControllers[taskId] = AnimationController(
        duration: Duration(milliseconds: 300 + (i * 50)),
        vsync: this,
      );
      _fadeAnimations[taskId] = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationControllers[taskId]!,
          curve: Curves.easeInOut,
        ),
      );
      _animationControllers[taskId]!.forward();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
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
      _tasksFuture = _showCompleted
          ? _getSortedTasks(DatabaseService.instance.getAllTasks())
          : _getSortedTasks(DatabaseService.instance.getPendingTasks());
    });
  }

  Future<List<Task>> _getSortedTasks(Future<List<Task>> tasksFuture) async {
    final tasks = await tasksFuture;

    // Apply search filter
    List<Task> filteredTasks = tasks;
    if (_searchQuery.isNotEmpty) {
      filteredTasks = tasks.where((task) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (task.description != null &&
                task.description!.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ));
      }).toList();
    }

    // Apply priority filter
    if (_filterPriority != null) {
      filteredTasks = filteredTasks
          .where((task) => task.priority == _filterPriority)
          .toList();
    }

    // Apply date range filter
    if (_filterStartDate != null) {
      filteredTasks = filteredTasks
          .where(
            (task) =>
                task.dueDate != null &&
                task.dueDate!.isAfter(_filterStartDate!),
          )
          .toList();
    }

    if (_filterEndDate != null) {
      filteredTasks = filteredTasks
          .where(
            (task) =>
                task.dueDate != null && task.dueDate!.isBefore(_filterEndDate!),
          )
          .toList();
    }

    if (_sortOrder == 'priority') {
      // Sort by priority (high to low)
      filteredTasks.sort((a, b) {
        if (a.priority.index > b.priority.index) return -1;
        if (a.priority.index < b.priority.index) return 1;
        return 0;
      });
    } else {
      // Sort by date (newest first)
      filteredTasks.sort((a, b) {
        return b.createdDate.compareTo(a.createdDate);
      });
    }
    return filteredTasks;
  }

  void _toggleShowCompleted() {
    setState(() {
      _showCompleted = !_showCompleted;
      _refreshTasks();
    });
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _filterStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _filterStartDate = picked;
      });
      _refreshTasks();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _filterEndDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _filterEndDate = picked;
      });
      _refreshTasks();
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _filterPriority = null;
      _filterStartDate = null;
      _filterEndDate = null;
    });
    _refreshTasks();
  }

  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter Tasks'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Priority filter
                    Text(
                      'Priority',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: Text('All'),
                          selected: _filterPriority == null,
                          onSelected: (selected) {
                            setState(() {
                              _filterPriority = null;
                            });
                          },
                        ),
                        FilterChip(
                          label: Text('Low'),
                          selected: _filterPriority == Priority.low,
                          onSelected: (selected) {
                            setState(() {
                              _filterPriority = selected ? Priority.low : null;
                            });
                          },
                        ),
                        FilterChip(
                          label: Text('Medium'),
                          selected: _filterPriority == Priority.medium,
                          onSelected: (selected) {
                            setState(() {
                              _filterPriority = selected
                                  ? Priority.medium
                                  : null;
                            });
                          },
                        ),
                        FilterChip(
                          label: Text('High'),
                          selected: _filterPriority == Priority.high,
                          onSelected: (selected) {
                            setState(() {
                              _filterPriority = selected ? Priority.high : null;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Date range filters
                    Text(
                      'Date Range',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Date'),
                              SizedBox(height: 4),
                              InputDecorator(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  _filterStartDate == null
                                      ? 'Not set'
                                      : '${_filterStartDate!.month}/${_filterStartDate!.day}/${_filterStartDate!.year}',
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: _selectStartDate,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('End Date'),
                              SizedBox(height: 4),
                              InputDecorator(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  _filterEndDate == null
                                      ? 'Not set'
                                      : '${_filterEndDate!.month}/${_filterEndDate!.day}/${_filterEndDate!.year}',
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: _selectEndDate,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: _clearFilters, child: Text('Clear')),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _refreshTasks();
                  },
                  child: Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addNewTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskFormScreen()),
    );

    if (result == true) {
      _refreshTasks();
    }
  }

  Future<void> _editTask(Task task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskFormScreen(task: task)),
    );

    if (result == true) {
      _refreshTasks();
    }
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

  Future<void> _deleteTask(Task task) async {
    await DatabaseService.instance.deleteTask(task.id!);
    await NotificationService().cancelNotification(task.id ?? 0);
    _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Tasks'),
        actions: [
          IconButton(
            icon: Icon(
              _showCompleted ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: _toggleShowCompleted,
            tooltip: _showCompleted
                ? 'Hide Completed Tasks'
                : 'Show Completed Tasks',
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Tasks',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.grey,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            _refreshTasks();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),
          // Active filters indicator
          if (_filterPriority != null ||
              _filterStartDate != null ||
              _filterEndDate != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Row(
                children: [
                  Text(
                    'Filters: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (_filterPriority != null)
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(_filterPriority!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _priorityToString(_filterPriority!),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _filterPriority = null;
                              });
                              _refreshTasks();
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  if (_filterStartDate != null)
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'After ${_formatDate(_filterStartDate!)}',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _filterStartDate = null;
                              });
                              _refreshTasks();
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  if (_filterEndDate != null)
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Before ${_formatDate(_filterEndDate!)}',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _filterEndDate = null;
                              });
                              _refreshTasks();
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text('Clear All'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Task>>(
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
                        Icon(
                          Icons.task_alt,
                          size: 80,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[600]
                              : Colors.grey[400],
                        ),
                        SizedBox(height: 20),
                        Text(
                          _showCompleted
                              ? 'No tasks found'
                              : 'No pending tasks\nAdd a new task to get started',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[500]
                                : Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 20),
                        if (!_showCompleted)
                          ElevatedButton(
                            onPressed: _addNewTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                            child: Text('Create Your First Task'),
                          ),
                      ],
                    ),
                  );
                } else {
                  final tasks = snapshot.data!;
                  _initializeAnimations(tasks);
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final taskId = task.id ?? index;
                      return FadeTransition(
                        opacity:
                            _fadeAnimations[taskId] ??
                            AlwaysStoppedAnimation(1.0),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black26
                                    : Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Dismissible(
                            key: Key(task.id.toString()),
                            direction: DismissDirection.horizontal,
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 20),
                              child: Icon(
                                task.isCompleted ? Icons.undo : Icons.check,
                                color: Colors.white,
                              ),
                            ),
                            secondaryBackground: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                // Swipe right - complete/uncomplete task
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        task.isCompleted
                                            ? 'Mark as Pending'
                                            : 'Mark as Completed',
                                      ),
                                      content: Text(
                                        'Are you sure you want to ${task.isCompleted ? 'mark this task as pending' : 'complete this task'}?',
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                        ),
                                        TextButton(
                                          child: Text('Confirm'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                // Swipe left - delete task
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Delete Task'),
                                      content: Text(
                                        'Are you sure you want to delete "${task.title}"?',
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                        ),
                                        TextButton(
                                          child: Text('Delete'),
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            onDismissed: (direction) {
                              if (direction == DismissDirection.startToEnd) {
                                // Swipe right - complete/uncomplete task
                                _toggleTaskCompletion(task);
                              } else {
                                // Swipe left - delete task
                                _deleteTask(task);
                              }
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: task.isCompleted
                                        ? Colors.green
                                        : Theme.of(context).brightness ==
                                              Brightness.dark
                                        ? Colors.grey[600]!
                                        : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                ),
                                child: task.isCompleted
                                    ? Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.green,
                                      )
                                    : null,
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
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
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  SizedBox(height: 6),
                                  Row(
                                    children: [
                                      if (task.dueDate != null) ...[
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: _isOverdue(task)
                                              ? Colors.red
                                              : Theme.of(context).brightness ==
                                                    Brightness.dark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            _formatDate(task.dueDate!),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: _isOverdue(task)
                                                  ? Colors.red
                                                  : Theme.of(
                                                          context,
                                                        ).brightness ==
                                                        Brightness.dark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getPriorityColor(
                                            task.priority,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          _priorityToString(task.priority),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (task.repeatType !=
                                          RepeatType.none) ...[
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.repeat,
                                          size: 16,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          _repeatTypeToString(task.repeatType),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.grey[400]
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  // Show progress if task has subtasks
                                  if (task.subTasks.isNotEmpty) ...[
                                    SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: _calculateProgress(task),
                                        backgroundColor:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[700]
                                            : Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              _getPriorityColor(task.priority),
                                            ),
                                        minHeight: 6,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${_getCompletedSubTasks(task)}/${task.subTasks.length} subtasks completed',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[500]
                                            : Colors.grey[600],
                                      ),
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
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _addNewTask,
          child: Icon(Icons.add, size: 30),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }

  bool _isOverdue(Task task) {
    if (task.dueDate == null || task.isCompleted) return false;
    return task.dueDate!.isBefore(DateTime.now());
  }

  double _calculateProgress(Task task) {
    if (task.subTasks.isEmpty) return 0.0;
    final completed = task.subTasks
        .where((subTask) => subTask.isCompleted)
        .length;
    return completed / task.subTasks.length;
  }

  int _getCompletedSubTasks(Task task) {
    return task.subTasks.where((subTask) => subTask.isCompleted).length;
  }

  String _formatDate(DateTime date) {
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
