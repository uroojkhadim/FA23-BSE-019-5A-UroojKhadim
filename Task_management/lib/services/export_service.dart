import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task.dart';

class ExportService {
  static final ExportService _instance = ExportService._();
  factory ExportService() => _instance;
  ExportService._();

  Future<String> exportTasksToCSV(List<Task> tasks) async {
    // Create CSV header
    List<List<dynamic>> rows = [
      [
        'ID',
        'Title',
        'Description',
        'Created Date',
        'Due Date',
        'Completed',
        'Repeat Type',
        'Completion Date',
        'Priority'
      ]
    ];

    // Add task data
    for (var task in tasks) {
      rows.add([
        task.id,
        task.title,
        task.description,
        task.createdDate.toIso8601String(),
        task.dueDate?.toIso8601String() ?? '',
        task.isCompleted,
        _repeatTypeToString(task.repeatType),
        task.completionDate?.toIso8601String() ?? '',
        _priorityToString(task.priority)
      ]);
    }

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(rows);

    // Get directory for saving file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/tasks_export.csv';

    // Write to file
    final file = File(filePath);
    await file.writeAsString(csv);

    return filePath;
  }

  Future<String> exportTasksToExcel(List<Task> tasks) async {
    // Create Excel workbook
    final excel = Excel.createExcel();
    final sheet = excel['Tasks'];

    // Add header row
    sheet.appendRow([
      'ID',
      'Title',
      'Description',
      'Created Date',
      'Due Date',
      'Completed',
      'Repeat Type',
      'Completion Date',
      'Priority'
    ]);

    // Add task data
    for (var task in tasks) {
      sheet.appendRow([
        task.id,
        task.title,
        task.description,
        task.createdDate.toIso8601String(),
        task.dueDate?.toIso8601String() ?? '',
        task.isCompleted,
        _repeatTypeToString(task.repeatType),
        task.completionDate?.toIso8601String() ?? '',
        _priorityToString(task.priority)
      ]);
    }

    // Get directory for saving file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/tasks_export.xlsx';

    // Save Excel file
    final fileBytes = excel.save();
    final file = File(filePath);
    await file.writeAsBytes(fileBytes!);

    return filePath;
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
}