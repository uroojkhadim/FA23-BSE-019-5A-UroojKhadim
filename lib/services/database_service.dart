import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _db;

  DatabaseService._init();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        createdDate INTEGER NOT NULL,
        dueDate INTEGER,
        isCompleted INTEGER NOT NULL,
        repeatType INTEGER NOT NULL,
        completionDate INTEGER,
        priority INTEGER NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add subtasks table
      await db.execute('''
        CREATE TABLE subtasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          taskId INTEGER NOT NULL,
          title TEXT NOT NULL,
          isCompleted INTEGER NOT NULL,
          FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<int> insertTask(Task task) async {
    final db = await instance.database;
    final taskId = await db.insert('tasks', task.toMap());
    
    // Insert subtasks
    for (final subTask in task.subTasks) {
      final subTaskWithId = subTask.copyWith(taskId: taskId);
      await insertSubTask(subTaskWithId);
    }
    
    return taskId;
  }

  Future<int> insertSubTask(SubTask subTask) async {
    final db = await instance.database;
    return await db.insert('subtasks', subTask.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks', orderBy: 'createdDate DESC');
    final tasks = <Task>[];
    
    for (final taskMap in result) {
      final task = Task.fromMap(taskMap);
      final subTasks = await getSubTasksForTask(task.id!);
      tasks.add(task.copyWith(subTasks: subTasks));
    }
    
    return tasks;
  }

  Future<List<Task>> getPendingTasks() async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'isCompleted = ?',
      whereArgs: [0],
      orderBy: 'createdDate DESC',
    );
    
    final tasks = <Task>[];
    for (final taskMap in result) {
      final task = Task.fromMap(taskMap);
      final subTasks = await getSubTasksForTask(task.id!);
      tasks.add(task.copyWith(subTasks: subTasks));
    }
    
    return tasks;
  }

  Future<List<Task>> getCompletedTasks() async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'isCompleted = ?',
      whereArgs: [1],
      orderBy: 'completionDate DESC',
    );
    
    final tasks = <Task>[];
    for (final taskMap in result) {
      final task = Task.fromMap(taskMap);
      final subTasks = await getSubTasksForTask(task.id!);
      tasks.add(task.copyWith(subTasks: subTasks));
    }
    
    return tasks;
  }

  Future<List<Task>> getTodaysTasks() async {
    final db = await instance.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).millisecondsSinceEpoch;
    
    final result = await db.query(
      'tasks',
      where: 'dueDate >= ? AND dueDate <= ? AND isCompleted = ?',
      whereArgs: [startOfDay, endOfDay, 0],
      orderBy: 'dueDate ASC',
    );
    
    final tasks = <Task>[];
    for (final taskMap in result) {
      final task = Task.fromMap(taskMap);
      final subTasks = await getSubTasksForTask(task.id!);
      tasks.add(task.copyWith(subTasks: subTasks));
    }
    
    return tasks;
  }

  Future<List<Task>> getRepeatedTasks() async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'repeatType != ?',
      whereArgs: [RepeatType.none.index],
      orderBy: 'createdDate DESC',
    );
    
    final tasks = <Task>[];
    for (final taskMap in result) {
      final task = Task.fromMap(taskMap);
      final subTasks = await getSubTasksForTask(task.id!);
      tasks.add(task.copyWith(subTasks: subTasks));
    }
    
    return tasks;
  }

  Future<Task?> getTaskById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isEmpty) return null;
    
    final task = Task.fromMap(result.first);
    final subTasks = await getSubTasksForTask(task.id!);
    return task.copyWith(subTasks: subTasks);
  }

  Future<List<SubTask>> getSubTasksForTask(int taskId) async {
    final db = await instance.database;
    final result = await db.query(
      'subtasks',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );
    return result.map((json) => SubTask.fromMap(json)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    
    // Update task
    final result = await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    
    // Update subtasks
    // First delete existing subtasks
    await db.delete(
      'subtasks',
      where: 'taskId = ?',
      whereArgs: [task.id],
    );
    
    // Then insert new subtasks
    for (final subTask in task.subTasks) {
      await insertSubTask(subTask.copyWith(taskId: task.id!));
    }
    
    return result;
  }

  Future<int> updateSubTask(SubTask subTask) async {
    final db = await instance.database;
    return await db.update(
      'subtasks',
      subTask.toMap(),
      where: 'id = ?',
      whereArgs: [subTask.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSubTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'subtasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllTasks() async {
    final db = await instance.database;
    return await db.delete('tasks');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}