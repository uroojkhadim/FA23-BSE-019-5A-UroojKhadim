import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreferences();
  }

  Future<void> _loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveThemePreferences(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.deepPurpleAccent),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MyHomePage(
        isDarkMode: _isDarkMode,
        onThemeChanged: _saveThemePreferences,
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
}

class MyHomePage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const MyHomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _showWelcomeScreen = false;

  @override
  void initState() {
    super.initState();
    _checkIfFirstTimeUser();
  }

  Future<void> _checkIfFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

    setState(() {
      _showWelcomeScreen = !onboardingCompleted;
    });

    if (!onboardingCompleted) {
      // Initialize notification service after a delay to ensure UI is ready
      Future.delayed(Duration(seconds: 1), () {
        _initNotifications();
      });
    } else {
      // Initialize notification service immediately for returning users
      _initNotifications();
    }
  }

  Future<void> _initNotifications() async {
    try {
      print('Initializing notifications');
      await NotificationService().requestPermissions();

      // Check if notifications are enabled
      final areEnabled = await NotificationService().areNotificationsEnabled();
      print('Notifications enabled: $areEnabled');

      if (!areEnabled && mounted) {
        print('Notifications are not enabled. Please check app settings.');
        // Show a dialog to the user to enable notifications
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showNotificationPermissionDialog();
        });
      }
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _showNotificationPermissionDialog() async {
    if (!mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification Permission Required'),
          content: Text(
            'This app needs notification permission to remind you about your tasks. Please enable notifications in your device settings.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showWelcomeScreen) {
      return WelcomeScreen(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      );
    } else {
      return MainScreen(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      );
    }
  }
}
