import 'package:flutter/material.dart';
import 'package:my_app/screens/ai_chat/chat_screen.dart'; // Updated import
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import 'course_screen.dart';
import 'tips_screen.dart';
import 'profile_screen.dart';
import 'new_user_dashboard.dart';
import 'main_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  final String loginEmail;
  final int selectedIndex;

  const HomeScreen({
    super.key,
    required this.loginEmail,
    this.selectedIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProfileProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget dashboard =
        userProvider.hasAccessedCourses()
            ? MainUserDashboardScreen(loginEmail: widget.loginEmail)
            : NewUserDashboardScreen(loginEmail: widget.loginEmail);

    final List<Widget> screens = [
      dashboard,
      const CourseScreen(),
      const ChatScreen(),
      const TipsScreen(),
      ProfileScreen(loginEmail: widget.loginEmail),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        selectedItemColor:
            isDarkMode ? Colors.tealAccent : Colors.teal.shade700,
        unselectedItemColor: isDarkMode ? Colors.white70 : Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cast_for_education),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'ShieldAi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Tips'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
