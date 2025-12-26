import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  
  final DatabaseService _databaseService = DatabaseService();

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString(_currentUserKey);
    
    if (userData != null) {
      Map<String, dynamic> userMap = json.decode(userData);
      return User.fromMap(userMap);
    }
    return null;
  }

  // Login user
  Future<bool> login(String username, String password) async {
    try {
      // For now, we'll check if user exists in local database
      // In a real app, you would call an API endpoint here
      User? user = await _databaseService.getUserByUsername(username);
      
      if (user != null) {
        // Simulate password validation
        // In a real app, you would hash and compare passwords
        if (_validatePassword(password)) {
          await _saveUser(user);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Validate password (dummy validation for now)
  bool _validatePassword(String password) {
    // In a real app, you would implement proper password validation
    return password.isNotEmpty && password.length >= 6;
  }

  // Register user
  Future<bool> register(String username, String email, String password, {String? name, String? phone}) async {
    try {
      // Check if user already exists
      User? existingUser = await _databaseService.getUserByUsername(username);
      if (existingUser != null) {
        return false; // User already exists
      }

      // Create new user
      User newUser = User(
        username: username,
        email: email,
        name: name,
        phone: phone,
        role: 'cashier',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user to database
      int result = await _databaseService.insertUser(newUser);
      
      if (result != 0) {
        await _saveUser(newUser);
        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  // Save user to shared preferences
  Future<void> _saveUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, json.encode(user.toMap()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Logout user
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Update current user
  Future<bool> updateCurrentUser(User user) async {
    try {
      int result = await _databaseService.updateUser(user);
      if (result > 0) {
        await _saveUser(user);
        return true;
      }
      return false;
    } catch (e) {
      print('Update user error: $e');
      return false;
    }
  }

  // Change password (placeholder)
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    // In a real app, you would implement password change logic
    // This would involve validating the old password and updating the new one
    return true;
  }
}