import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/user_profile_provider.dart';
import 'profile_screen.dart';

class MainUserDashboardScreen extends StatefulWidget {
  static const routeName = '/main-user-dashboard';
  final String loginEmail;

  const MainUserDashboardScreen({super.key, required this.loginEmail});

  @override
  State<MainUserDashboardScreen> createState() =>
      _MainUserDashboardScreenState();
}

class _MainUserDashboardScreenState extends State<MainUserDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProfileProvider>(
      context,
      listen: false,
    );
    await userProvider.init();

    // Ensure user data is loaded from Firestore
    if (userProvider.userName == 'Guest' || userProvider.userName.isEmpty) {
      await userProvider.loadUserDataFromFirestore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor =
        isDarkMode ? Colors.tealAccent[700]! : Colors.teal;
    final enrolledCourses = userProfile.getDashboardCourses();

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      body: SafeArea(
        child:
            userProfile.isLoading
                ? const Center(child: CircularProgressIndicator())
                : enrolledCourses.isEmpty
                ? _buildEmptyState(context, primaryColor, isDarkMode)
                : _buildDashboardContent(
                  context,
                  userProfile,
                  enrolledCourses,
                  primaryColor,
                  isDarkMode,
                ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Color primaryColor,
    bool isDarkMode,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No courses enrolled yet!',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          // FIXED: Don't navigate, just suggest using the tab
          Text(
            '👇 Use the "Courses" tab below to browse courses',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    UserProfileProvider userProfile,
    List<Map<String, dynamic>> enrolledCourses,
    Color primaryColor,
    bool isDarkMode,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(userProfile, primaryColor, isDarkMode),
          const SizedBox(height: 24),
          _buildMotivationCard(primaryColor, isDarkMode),
          const SizedBox(height: 24),
          _buildCourseSection(enrolledCourses, primaryColor, isDarkMode),
          const SizedBox(height: 24),
          _buildActivitySection(primaryColor, isDarkMode),
          const SizedBox(height: 24),
          _buildContinueLearning(
            enrolledCourses,
            primaryColor,
            isDarkMode,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    UserProfileProvider userProfile,
    Color primaryColor,
    bool isDarkMode,
  ) {
    // Better name display logic
    String displayName;
    if (userProfile.isLoading) {
      displayName = 'Loading...';
    } else if (userProfile.userName.isEmpty ||
        userProfile.userName == 'Guest') {
      displayName = 'there';
    } else {
      displayName = userProfile.userName;
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $displayName!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Text(
                'Let\'s continue learning',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap:
              () => Navigator.pushNamed(
                context,
                ProfileScreen.routeName,
                arguments: widget.loginEmail,
              ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: primaryColor,
            backgroundImage:
                userProfile.profileImageUrl != null
                    ? FileImage(File(userProfile.profileImageUrl!))
                    : null,
            child:
                userProfile.profileImageUrl == null
                    ? Icon(
                      Icons.person,
                      color: isDarkMode ? Colors.black : Colors.white,
                    )
                    : null,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationCard(Color primaryColor, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep up the good work!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re making great progress in your courses!',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: Lottie.asset(
              'assets/images/motivation.json',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseSection(
    List<Map<String, dynamic>> courses,
    Color primaryColor,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Courses',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            itemBuilder:
                (context, index) =>
                    _buildCourseCard(courses[index], primaryColor, isDarkMode),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(
    Map<String, dynamic> course,
    Color primaryColor,
    bool isDarkMode,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              course['image'] ?? 'assets/images/default_course.png',
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title'] ?? 'Unknown Course',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (course['progress'] ?? 0.0).toDouble(),
                  backgroundColor:
                      isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  color: primaryColor,
                ),
                const SizedBox(height: 4),
                Text(
                  '${((course['progress'] ?? 0.0) * 100).toInt()}% completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(Color primaryColor, bool isDarkMode) {
    final activities = [
      {
        'course': 'Cybersecurity Basics',
        'activity': 'Completed Lesson 3',
        'time': '2h ago',
        'icon': Icons.check_circle,
      },
      {
        'course': 'Network Security',
        'activity': 'Started new module',
        'time': '1d ago',
        'icon': Icons.assignment,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children:
              activities
                  .map(
                    (activity) =>
                        _buildActivityItem(activity, primaryColor, isDarkMode),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    Map<String, dynamic> activity,
    Color primaryColor,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(activity['icon'], color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['course'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  activity['activity'],
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['time'],
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.black38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearning(
    List<Map<String, dynamic>> courses,
    Color primaryColor,
    bool isDarkMode,
    BuildContext context,
  ) {
    if (courses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Continue Learning',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap:
              () => Navigator.pushNamed(
                context,
                '/course-detail',
                arguments: courses[0]['title'],
              ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courses[0]['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (courses[0]['progress'] ?? 0.0).toDouble(),
                  backgroundColor:
                      isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  color: primaryColor,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${((courses[0]['progress'] ?? 0.0) * 100).toInt()}% completed',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          () => Navigator.pushNamed(
                            context,
                            '/course-detail',
                            arguments: courses[0]['title'],
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor:
                            isDarkMode ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
