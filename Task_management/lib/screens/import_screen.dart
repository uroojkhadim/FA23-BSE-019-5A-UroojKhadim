import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../services/import_service.dart';
import '../services/database_service.dart';
import '../models/task.dart';

class ImportScreen extends StatefulWidget {
  @override
  _ImportScreenState createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  String? _selectedFilePath;
  List<Task> _previewTasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _importedCount = 0;

  Future<void> _pickCSVFile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        setState(() {
          _selectedFilePath = filePath;
        });

        // Preview the tasks
        await _previewTasksFromFile(filePath);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error selecting file: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _previewTasksFromFile(String filePath) async {
    try {
      final tasks = await ImportService().importTasksFromCSV(filePath);
      setState(() {
        _previewTasks = tasks;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error reading file: $e';
        _previewTasks = [];
      });
    }
  }

  Future<void> _importTasks() async {
    if (_selectedFilePath == null || _previewTasks.isEmpty) {
      setState(() {
        _errorMessage = 'Please select a file first';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final importedCount = await ImportService().importAndSaveTasks(_previewTasks);
      
      setState(() {
        _importedCount = importedCount;
        _previewTasks = [];
        _selectedFilePath = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported $importedCount tasks'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error importing tasks: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Tasks'),
      ),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView to fix overflow
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import from CSV',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Select a CSV file containing your tasks to import them into the app.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedFilePath ?? 'No file selected',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _pickCSVFile,
                            icon: Icon(Icons.file_upload),
                            label: Text('Select File'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              if (_errorMessage != null) ...[
                SizedBox(height: 16),
                Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
              
              if (_previewTasks.isNotEmpty) ...[
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview (${_previewTasks.length} tasks)',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 16),
                        Container(
                          height: 200,
                          child: ListView.builder(
                            itemCount: _previewTasks.length > 5 ? 5 : _previewTasks.length,
                            itemBuilder: (context, index) {
                              final task = _previewTasks[index];
                              return ListTile(
                                title: Text(task.title),
                                subtitle: Text(
                                  task.description ?? 'No description',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Icon(
                                  task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: task.isCompleted ? Colors.green : Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        if (_previewTasks.length > 5) ...[
                          Divider(),
                          Text(
                            'And ${_previewTasks.length - 5} more tasks...',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _importTasks,
                          child: _isLoading
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Importing...'),
                                  ],
                                )
                              : Text('Import ${_previewTasks.length} Tasks'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              if (_importedCount > 0) ...[
                SizedBox(height: 16),
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Successfully imported $_importedCount tasks!',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CSV Format Guide',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your CSV file should have the following columns:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      _buildFormatRow('Title', 'Task title (required)'),
                      _buildFormatRow('Description', 'Task description (optional)'),
                      _buildFormatRow('Created Date', 'Creation date (optional)'),
                      _buildFormatRow('Due Date', 'Due date (optional)'),
                      _buildFormatRow('Completed', 'true/false (optional)'),
                      _buildFormatRow('Priority', 'low/medium/high (optional)'),
                      _buildFormatRow('Repeat', 'none/daily/weekly/monthly/yearly (optional)'),
                      SizedBox(height: 8),
                      Text(
                        'Example:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Title,Description,Created Date,Due Date,Completed,Priority,Repeat',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                      Text(
                        'Buy groceries,Get milk and bread,2023-01-01,2023-01-05,false,medium,none',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
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

  Widget _buildFormatRow(String column, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            '• $column: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }
}