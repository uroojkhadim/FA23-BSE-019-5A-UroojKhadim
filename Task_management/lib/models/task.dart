import 'package:flutter/material.dart';

class Task {
  final int? id;
  final String title;
  final String? description;
  final DateTime createdDate;
  final DateTime? dueDate;
  final TimeOfDay? dueTime;
  final bool isCompleted;
  final RepeatType repeatType;
  final DateTime? completionDate;
  final Priority priority;
  final List<SubTask> subTasks;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.createdDate,
    this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    this.repeatType = RepeatType.none,
    this.completionDate,
    this.priority = Priority.medium,
    this.subTasks = const [],
  });

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdDate,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    bool? isCompleted,
    RepeatType? repeatType,
    DateTime? completionDate,
    Priority? priority,
    List<SubTask>? subTasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatType: repeatType ?? this.repeatType,
      completionDate: completionDate ?? this.completionDate,
      priority: priority ?? this.priority,
      subTasks: subTasks ?? this.subTasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'dueTimeHour': dueTime?.hour,
      'dueTimeMinute': dueTime?.minute,
      'isCompleted': isCompleted ? 1 : 0,
      'repeatType': repeatType.index,
      'completionDate': completionDate?.millisecondsSinceEpoch,
      'priority': priority.index,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['createdDate']),
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      dueTime: map['dueTimeHour'] != null && map['dueTimeMinute'] != null
          ? TimeOfDay(hour: map['dueTimeHour'], minute: map['dueTimeMinute'])
          : null,
      isCompleted: map['isCompleted'] == 1,
      repeatType: RepeatType.values[map['repeatType']],
      completionDate: map['completionDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completionDate'])
          : null,
      priority: Priority.values[map['priority']],
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, description: $description, createdDate: $createdDate, dueDate: $dueDate, isCompleted: $isCompleted, repeatType: $repeatType, completionDate: $completionDate, priority: $priority, subTasks: $subTasks)';
  }
}

enum RepeatType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
}

enum Priority {
  low,
  medium,
  high,
}

class SubTask {
  final int? id;
  final int taskId;
  final String title;
  final bool isCompleted;

  SubTask({
    this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
  });

  SubTask copyWith({
    int? id,
    int? taskId,
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'],
      taskId: map['taskId'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
    );
  }

  @override
  String toString() {
    return 'SubTask(id: $id, taskId: $taskId, title: $title, isCompleted: $isCompleted)';
  }
}