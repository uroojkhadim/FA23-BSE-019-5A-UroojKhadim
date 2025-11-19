import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;
import '../models/task.dart';
import 'database_service.dart';

class ImportService {
  static final ImportService _instance = ImportService._internal();
  factory ImportService() => _instance;
  ImportService._internal();

  /// Import tasks from a CSV file
  Future<List<Task>> importTasksFromCSV(String filePath) async {
    final file = File(filePath);
    final input = await file.readAsString();
    
    final List<List<dynamic>> csvData = const CsvToListConverter().convert(input);
    
    // Skip header row if present
    final headerRow = csvData[0];
    bool hasHeader = _hasHeaderRow(headerRow);
    
    final List<Task> tasks = [];
    final startIndex = hasHeader ? 1 : 0;
    
    for (int i = startIndex; i < csvData.length; i++) {
      final row = csvData[i];
      if (row.length >= 4) {
        try {
          final task = _parseTaskFromRow(row);
          tasks.add(task);
        } catch (e) {
          // Skip rows that can't be parsed
          continue;
        }
      }
    }
    
    return tasks;
  }
  
  /// Import tasks and save them to the database
  Future<int> importAndSaveTasks(List<Task> tasks) async {
    int importedCount = 0;
    
    for (final task in tasks) {
      try {
        await DatabaseService.instance.insertTask(task);
        importedCount++;
      } catch (e) {
        // Skip tasks that can't be saved
        continue;
      }
    }
    
    return importedCount;
  }

  bool _hasHeaderRow(List<dynamic> row) {
    // Simple heuristic: check if first few cells look like headers
    if (row.length < 4) return false;
    
    final String firstCell = row[0].toString().toLowerCase();
    final String secondCell = row[1].toString().toLowerCase();
    
    return (firstCell.contains('title') || firstCell.contains('task') || firstCell.contains('name')) &&
           (secondCell.contains('description') || secondCell.contains('desc'));
  }

  Task _parseTaskFromRow(List<dynamic> row) {
    // Parse basic fields
    final title = row[0].toString();
    final description = row.length > 1 ? row[1].toString() : null;
    
    // Parse dates
    DateTime? createdDate;
    DateTime? dueDate;
    
    if (row.length > 2) {
      try {
        createdDate = _parseDate(row[2].toString());
      } catch (e) {
        createdDate = DateTime.now();
      }
    } else {
      createdDate = DateTime.now();
    }
    
    if (row.length > 3) {
      try {
        dueDate = _parseDate(row[3].toString());
      } catch (e) {
        dueDate = null;
      }
    }
    
    // Parse completion status
    bool isCompleted = false;
    if (row.length > 4) {
      final status = row[4].toString().toLowerCase();
      isCompleted = status == 'true' || status == 'completed' || status == 'yes' || status == '1';
    }
    
    // Parse priority
    Priority priority = Priority.medium;
    if (row.length > 5) {
      priority = _parsePriority(row[5].toString());
    }
    
    // Parse repeat type
    RepeatType repeatType = RepeatType.none;
    if (row.length > 6) {
      repeatType = _parseRepeatType(row[6].toString());
    }
    
    return Task(
      title: title,
      description: description,
      createdDate: createdDate,
      dueDate: dueDate,
      isCompleted: isCompleted,
      priority: priority,
      repeatType: repeatType,
    );
  }

  DateTime _parseDate(String dateStr) {
    // Try multiple date formats
    try {
      // Try ISO format
      return DateTime.parse(dateStr);
    } catch (e) {
      try {
        // Try MM/dd/yyyy format
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          final month = int.parse(parts[0]);
          final day = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      } catch (e) {
        // Try yyyy-MM-dd format
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      }
    }
    
    // If all parsing fails, return current date
    return DateTime.now();
  }

  Priority _parsePriority(String priorityStr) {
    final lowerPriority = priorityStr.toLowerCase();
    
    if (lowerPriority.contains('high')) return Priority.high;
    if (lowerPriority.contains('low')) return Priority.low;
    return Priority.medium; // default
  }

  RepeatType _parseRepeatType(String repeatStr) {
    final lowerRepeat = repeatStr.toLowerCase();
    
    if (lowerRepeat.contains('daily') || lowerRepeat.contains('day')) return RepeatType.daily;
    if (lowerRepeat.contains('weekly') || lowerRepeat.contains('week')) return RepeatType.weekly;
    if (lowerRepeat.contains('monthly') || lowerRepeat.contains('month')) return RepeatType.monthly;
    if (lowerRepeat.contains('yearly') || lowerRepeat.contains('year')) return RepeatType.yearly;
    return RepeatType.none; // default
  }
}