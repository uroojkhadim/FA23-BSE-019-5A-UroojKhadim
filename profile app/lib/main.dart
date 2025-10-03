import 'package:flutter/material.dart';

void main() => runApp(ProfileApp());

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProfilePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String name = 'uROOJ KHADIM';
  final String email = 'UROOJKHADIM505@gmail.com';
  final String phone = '+923046983794';
  final String tagline = 'Full-Stack Developer & AI Enthusiast';

  int selectedTheme = 0; // 0: default, 1: gradient, 2: color scheme

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Professional CV'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: _getBackgroundDecoration(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Theme Selection Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGradientButton('Classic', [
                      Colors.black87,
                      Colors.purple,
                    ], 0),
                    _buildGradientButton('Modern', [
                      Colors.orange,
                      Colors.red,
                    ], 1),
                    _buildGradientButton('Creative', [
                      Colors.green,
                      Colors.teal,
                    ], 2),
                    _buildGradientButton('Creative', [
                      Colors.green,
                      Colors.teal,
                    ], 2),
                  ],
                ),
                SizedBox(height: 20),

                // Profile Header Card
                _buildProfileCard(),
                SizedBox(height: 20),

                // About Section Card
                _buildAboutCard(),
                SizedBox(height: 20),

                // Skills Section Card
                _buildSkillsCard(),
                SizedBox(height: 20),

                // Experience Section Card
                _buildExperienceCard(),
                SizedBox(height: 20),

                // Contact Section Card
                _buildContactCard(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Stack Widget - Profile Image with Badge
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('images/UROOJ.jpg'),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            name,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          SizedBox(height: 5),
          Text(
            tagline,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.indigo, size: 24),
              SizedBox(width: 10),
              Text(
                'About Me',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            'Passionate Full-Stack Developer with 10+ years of experience in creating innovative digital solutions. Specialized in AI Development, Flutter App Development, WordPress, and Python Development. I love turning complex problems into simple, beautiful, and intuitive solutions.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard() {
    List<Map<String, dynamic>> skills = [
      {
        'name': 'AI Development',
        'icon': Icons.psychology,
        'color': Colors.purple,
      },
      {
        'name': 'Flutter App Development',
        'icon': Icons.phone_android,
        'color': Colors.blue,
      },
      {'name': 'WordPress', 'icon': Icons.web, 'color': Colors.green},
      {
        'name': 'Python Development',
        'icon': Icons.code,
        'color': Colors.orange,
      },
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.indigo, size: 24),
              SizedBox(width: 10),
              Text(
                'Core Skills',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          // ListView Widget - Skills List
          Container(
            height: 200,
            child: ListView.builder(
              itemCount: skills.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: skills[index]['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: skills[index]['color'].withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: skills[index]['color'],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          skills[index]['icon'],
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        skills[index]['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work, color: Colors.indigo, size: 24),
              SizedBox(width: 10),
              Text(
                'Experience',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          _buildExperienceItem(
            'Senior Flutter Developer',
            'Tech Solutions Inc.',
            '2022 - Present',
          ),
          _buildExperienceItem(
            'AI Development Specialist',
            'Innovation Labs',
            '2021 - 2022',
          ),
          _buildExperienceItem(
            'WordPress Developer',
            'Digital Agency',
            '2020 - 2021',
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(String title, String company, String period) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          Text(
            company,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            period,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_mail, color: Colors.indigo, size: 24),
              SizedBox(width: 10),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          // Row Widget - Contact Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactItem(Icons.email, email, 'Email'),
              _buildContactItem(Icons.phone, phone, 'Phone'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, String label) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.indigo, size: 24),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String text, List<Color> colors, int themeIndex) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTheme = themeIndex;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  BoxDecoration _getBackgroundDecoration() {
    switch (selectedTheme) {
      case 1: // Modern theme
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.blue, Colors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
      case 2: // Creative theme
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.pink, Colors.red],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );
      default: // Classic theme
        return BoxDecoration(color: Colors.grey[100]);
    }
  }
}