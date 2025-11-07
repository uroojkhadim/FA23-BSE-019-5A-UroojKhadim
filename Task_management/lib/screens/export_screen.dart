import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';

class ExportScreen extends StatefulWidget {
  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _includeCompleted = true;
  bool _includePending = true;

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<List<Task>> _getFilteredTasks() async {
    final allTasks = await DatabaseService.instance.getAllTasks();
    
    // Filter by date range
    List<Task> filteredTasks = allTasks;
    if (_startDate != null) {
      filteredTasks = filteredTasks.where((task) {
        final taskDate = task.createdDate;
        return taskDate.isAfter(_startDate!.subtract(Duration(days: 1)));
      }).toList();
    }
    
    if (_endDate != null) {
      filteredTasks = filteredTasks.where((task) {
        final taskDate = task.createdDate;
        return taskDate.isBefore(_endDate!.add(Duration(days: 1)));
      }).toList();
    }
    
    // Filter by completion status
    if (!_includeCompleted && !_includePending) {
      // If both are unchecked, show no tasks
      filteredTasks = [];
    } else if (!_includeCompleted) {
      // Show only pending tasks
      filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
    } else if (!_includePending) {
      // Show only completed tasks
      filteredTasks = filteredTasks.where((task) => task.isCompleted).toList();
    }
    
    return filteredTasks;
  }

  Future<void> _exportToCSV() async {
    try {
      final tasks = await _getFilteredTasks();
      final filePath = await ExportService().exportTasksToCSV(tasks);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tasks exported to: $filePath'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export tasks: $e')),
        );
      }
    }
  }

  Future<void> _exportToPDF() async {
    try {
      final tasks = await _getFilteredTasks();
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text(
                  'Task Management Export',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Exported on: ${DateTime.now().toString()}',
                  style: pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                ...tasks.map((task) {
                  return pw.Container(
                    margin: pw.EdgeInsets.symmetric(vertical: 5),
                    padding: pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          task.title,
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if (task.description != null)
                          pw.SizedBox(height: 5)
                        else
                          pw.SizedBox.shrink(),
                        if (task.description != null)
                          pw.Text(task.description!),
                        pw.SizedBox(height: 5),
                        pw.Text('Created: ${task.createdDate.toString()}'),
                        if (task.dueDate != null)
                          pw.Text('Due: ${task.dueDate.toString()}'),
                        pw.Text('Status: ${task.isCompleted ? 'Completed' : 'Pending'}'),
                        pw.Text('Priority: ${_priorityToString(task.priority)}'),
                        if (task.repeatType != RepeatType.none)
                          pw.Text('Repeat: ${_repeatTypeToString(task.repeatType)}'),
                      ],
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      );
      
      // Save PDF to file
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'tasks_export_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${dir.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tasks exported to: $filePath'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export tasks to PDF: $e')),
        );
      }
    }
  }

  Future<void> _exportToEmail() async {
    try {
      final tasks = await _getFilteredTasks();
      
      // For now, we'll just show a message that this feature would send an email
      // In a real app, you would use a package like 'url_launcher' or 'mailer'
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'In a real app, this would open your email client with the tasks attached.'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to prepare email export: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Export Tasks'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Selection
            Text(
              'Date Range',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text('Start Date'),
                            subtitle: Text(
                                _startDate?.toString().split(' ')[0] ?? 'Not selected'),
                            onTap: _selectStartDate,
                          ),
                        ),
                        Icon(Icons.arrow_forward),
                        Expanded(
                          child: ListTile(
                            title: Text('End Date'),
                            subtitle: Text(
                                _endDate?.toString().split(' ')[0] ?? 'Not selected'),
                            onTap: _selectEndDate,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                            });
                          },
                          child: Text('Clear Dates'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Status Filter
            Text(
              'Task Status',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: Text('Include Completed Tasks'),
                      value: _includeCompleted,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _includeCompleted = value;
                          });
                        }
                      },
                    ),
                    CheckboxListTile(
                      title: Text('Include Pending Tasks'),
                      value: _includePending,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _includePending = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Export Options
            Text(
              'Export Options',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.file_download),
                      title: Text('Export to CSV'),
                      subtitle: Text('Export tasks as a CSV file'),
                      onTap: _exportToCSV,
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.picture_as_pdf),
                      title: Text('Export to PDF'),
                      subtitle: Text('Export tasks as a PDF document'),
                      onTap: _exportToPDF,
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text('Export to Email'),
                      subtitle: Text('Send tasks via email'),
                      onTap: _exportToEmail,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Preview Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final tasks = await _getFilteredTasks();
                  _showPreviewDialog(context, tasks);
                },
                icon: Icon(Icons.visibility),
                label: Text('Preview Export'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreviewDialog(BuildContext context, List<Task> tasks) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Export Preview'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (task.description != null) ...[
                          SizedBox(height: 4),
                          Text(task.description!),
                        ],
                        SizedBox(height: 4),
                        Text(
                          'Status: ${task.isCompleted ? 'Completed' : 'Pending'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
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
}