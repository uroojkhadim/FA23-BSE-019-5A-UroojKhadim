import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const WelcomeScreen({
    Key? key,
    required this.onThemeChanged,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> _onboardingPages = [
    {
      'title': 'Welcome to TaskFlow',
      'description':
          'Your personal task management app that helps you stay organized and productive with a clean, modern interface.',
      'image': 'assets/welcome_1.png',
    },
    {
      'title': 'Create & Organize Tasks',
      'description':
          'Easily add tasks with titles, descriptions, due dates, priorities, and recurring options. Keep everything in one place.',
      'image': 'assets/welcome_2.png',
    },
    {
      'title': 'Stay Notified',
      'description':
          'Get timely reminders for your tasks with customizable notifications. Never miss an important deadline.',
      'image': 'assets/welcome_3.png',
    },
    {
      'title': 'Track Your Progress',
      'description':
          'Monitor your completed tasks and track your productivity over time with beautiful visualizations.',
      'image': 'assets/welcome_4.png',
    },
    {
      'title': 'Get Started Now',
      'description':
          'Start organizing your life today. Create your first task and experience the power of effective task management.',
      'image': 'assets/welcome_5.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainScreen(
            isDarkMode: widget.isDarkMode,
            onThemeChanged: widget.onThemeChanged,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: widget.isDarkMode
                    ? [Colors.grey[900]!, Colors.grey[800]!]
                    : [Colors.deepPurple.shade50, Colors.deepPurple.shade100],
              ),
            ),
          ),
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingPages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _animationController.reset();
                _animationController.forward();
              });
            },
            itemBuilder: (context, index) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: _buildOnboardingPage(
                  _onboardingPages[index]['title']!,
                  _onboardingPages[index]['description']!,
                  index,
                ),
              );
            },
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _buildPageIndicator(),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage != 0)
                        TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(
                                color: widget.isDarkMode
                                    ? Colors.white70
                                    : Colors.deepPurple,
                              ),
                            ),
                          ),
                          child: Text(
                            'BACK',
                            style: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 60),
                      if (_currentPage == _onboardingPages.length - 1)
                        ElevatedButton(
                          onPressed: _finishOnboarding,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'GET STARTED',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            'NEXT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(String title, String description, int index) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration or icon
          Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? Colors.deepPurple.withOpacity(0.3)
                  : Colors.deepPurple.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : Colors.deepPurple.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _getIconForPage(index),
                size: 120,
                color: widget.isDarkMode
                    ? Colors.deepPurpleAccent
                    : Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(height: 50),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.white : Colors.deepPurple,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: widget.isDarkMode ? Colors.white70 : Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIconForPage(int index) {
    switch (index) {
      case 0:
        return Icons.check_circle_outline;
      case 1:
        return Icons.add_task;
      case 2:
        return Icons.notifications_active;
      case 3:
        return Icons.bar_chart;
      case 4:
        return Icons.rocket_launch;
      default:
        return Icons.check_circle_outline;
    }
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_onboardingPages.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: _currentPage == index ? 14 : 10,
          height: _currentPage == index ? 14 : 10,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.deepPurple
                : widget.isDarkMode
                ? Colors.white38
                : Colors.grey.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
