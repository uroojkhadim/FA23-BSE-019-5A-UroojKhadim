import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class GoogleDriveService {
  static final GoogleDriveService _instance = GoogleDriveService._internal();
  factory GoogleDriveService() => _instance;
  
  late GoogleSignIn _googleSignIn;
  drive.DriveApi? _driveApi;
  
  static const _scopes = [drive.DriveApi.driveFileScope];
  
  GoogleDriveService._internal() {
    _googleSignIn = GoogleSignIn(
      scopes: _scopes,
    );
  }
  
  Future<bool> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return false;
      
      final GoogleSignInAuthentication auth = await account.authentication;
      final credentials = AccessCredentials(
        AccessToken('Bearer', auth.accessToken!, DateTime.now().add(Duration(hours: 1))),
        null,
        _scopes,
      );
      
      final client = authenticatedClient(http.Client(), credentials);
      _driveApi = drive.DriveApi(client);
      
      return true;
    } catch (e) {
      print('Error signing in to Google Drive: $e');
      return false;
    }
  }
  
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _driveApi = null;
  }
  
  Future<bool> isSignedIn() async {
    return _googleSignIn.currentUser != null;
  }
  
  Future<String?> backupTasks(List<Task> tasks) async {
    if (_driveApi == null) return null;
    
    try {
      // Convert tasks to JSON
      final tasksJson = tasks.map((task) => task.toMap()).toList();
      final jsonString = jsonEncode(tasksJson);
      
      // Create file content
      final fileContent = utf8.encode(jsonString);
      
      // Create file metadata
      final fileMetadata = drive.File()
        ..name = 'task_backup_${DateTime.now().millisecondsSinceEpoch}.json'
        ..mimeType = 'application/json';
      
      // Upload file
      final media = drive.Media(
        Stream.value(fileContent),
        fileContent.length,
      );
      
      final uploadedFile = await _driveApi!.files.create(
        fileMetadata,
        uploadMedia: media,
      );
      
      return uploadedFile.id;
    } catch (e) {
      print('Error backing up tasks to Google Drive: $e');
      return null;
    }
  }
  
  Future<List<Task>?> restoreTasks(String fileId) async {
    if (_driveApi == null) return null;
    
    try {
      // Download file content
      final drive.Media media = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;
      
      // Read file content
      final bytes = await media.stream.toList();
      final jsonString = utf8.decode(bytes.expand((element) => element).toList());
      
      // Parse JSON
      final List<dynamic> tasksJson = jsonDecode(jsonString);
      final List<Task> tasks = tasksJson
          .map((json) => Task.fromMap(json as Map<String, dynamic>))
          .toList();
      
      return tasks;
    } catch (e) {
      print('Error restoring tasks from Google Drive: $e');
      return null;
    }
  }
  
  Future<List<drive.File>?> listBackupFiles() async {
    if (_driveApi == null) return null;
    
    try {
      final result = await _driveApi!.files.list(
        q: "name contains 'task_backup_' and mimeType = 'application/json'",
        spaces: 'drive',
        $fields: 'files(id, name, createdTime)',
      );
      
      return result.files;
    } catch (e) {
      print('Error listing backup files from Google Drive: $e');
      return null;
    }
  }
}