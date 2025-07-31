import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import 'profile_screen.dart';
import 'package:lottie/lottie.dart';

class NewUserDashboardScreen extends StatefulWidget {
  static const routeName = '/new-user-dashboard';
  final String loginEmail;

  const NewUserDashboardScreen({super.key, required this.loginEmail});

  @override
  State<NewUserDashboardScreen> createState() => _NewUserDashboardScreenState();
}

class _NewUserDashboardScreenState extends State<NewUserDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure user data is loaded when dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProfileProvider>(
        context,
        listen: false,
      );
      if (userProvider.userName == 'Guest') {
        userProvider.loadUserDataFromFirestore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfileProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: _buildDashboard(context, userProfile, isDarkMode),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    UserProfileProvider userProfile,
    bool isDarkMode,
  ) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar with avatar, welcome, and notifications
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile avatar
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      ProfileScreen.routeName,
                      arguments: widget.loginEmail,
                    );
                  },
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        isDarkMode ? Colors.tealAccent[700] : Colors.teal,
                    // Only show image if it actually exists
                    backgroundImage:
                        (userProfile.profileImageUrl != null &&
                                File(userProfile.profileImageUrl!).existsSync())
                            ? FileImage(File(userProfile.profileImageUrl!))
                            : null,
                    child:
                        (userProfile.profileImageUrl == null ||
                                !File(
                                  userProfile.profileImageUrl!,
                                ).existsSync())
                            ? Icon(
                              Icons.person,
                              color: isDarkMode ? Colors.black : Colors.white,
                            )
                            : null,
                  ),
                ),
                // Welcome text
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi,',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          userProfile.isLoading
                              ? 'Loading...'
                              : (userProfile.userName.isEmpty ||
                                  userProfile.userName == 'Guest')
                              ? 'Welcome!'
                              : userProfile.userName,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Notifications icon
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isDarkMode
                                  ? Colors.grey[800]
                                  : Colors.grey.shade300,
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 28,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Main empty state content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    child: Lottie.asset(
                      isDarkMode
                          ? 'assets/images/learn2.json'
                          : 'assets/images/learn1.json',
                      repeat: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ready to start learning?',
                    style: TextStyle(
                      fontSize: 20,
                      color:
                          isDarkMode
                              ? Colors.white.withOpacity(0.9)
                              : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Explore our cybersecurity courses\nand start your learning journey!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkMode ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // FIXED: Add back the Explore Courses button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/home',
                        arguments: {'selectedIndex': 1},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDarkMode
                              ? Colors.tealAccent[700]
                              : Colors.teal.shade600,
                      foregroundColor: isDarkMode ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                      shadowColor: Colors.teal.withOpacity(0.3),
                    ),
                    icon: const Icon(Icons.explore),
                    label: const Text(
                      "Explore Courses",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
