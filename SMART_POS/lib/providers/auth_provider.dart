import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _checkCurrentSession();
  }

  Future<void> _checkCurrentSession() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      bool isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await _authService.getCurrentUser();
      }
    } catch (e) {
      print('Error checking session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool success = await _authService.login(username, password);
      if (success) {
        _currentUser = await _authService.getCurrentUser();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String email, String password, {String? name, String? phone}) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool success = await _authService.register(username, email, password, name: name, phone: phone);
      if (success) {
        _currentUser = await _authService.getCurrentUser();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateCurrentUser(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool success = await _authService.updateCurrentUser(user);
      if (success) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Update user error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool success = await _authService.changePassword(oldPassword, newPassword);
      notifyListeners();
      return success;
    } catch (e) {
      print('Change password error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}