import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  static const routeName = '/notification-settings'; // For named navigation

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _courseReminders = true;
  bool _achievementAlerts = true;
  String _notificationFrequency = 'Daily';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _requestNotificationPermissions();
  }

  Future<void> _requestNotificationPermissions() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Notification permission status: ${settings.authorizationStatus}');
  }

  Future<void> _loadNotificationSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user signed in');
      return;
    }

    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Map<String, dynamic>? notifications = data['notifications'];
        if (notifications != null) {
          setState(() {
            _pushNotifications = notifications['pushNotifications'] ?? true;
            _emailNotifications = notifications['emailNotifications'] ?? false;
            _courseReminders = notifications['courseReminders'] ?? true;
            _achievementAlerts = notifications['achievementAlerts'] ?? true;
            _notificationFrequency =
                notifications['notificationFrequency'] ?? 'Daily';
          });
        }
      }
      print('Loaded notification settings for user ${user.uid}');
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  Future<void> _saveNotificationSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user signed in');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please sign in to save settings.',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'notifications': {
          'pushNotifications': _pushNotifications,
          'emailNotifications': _emailNotifications,
          'courseReminders': _courseReminders,
          'achievementAlerts': _achievementAlerts,
          'notificationFrequency': _notificationFrequency,
        },
      }, SetOptions(merge: true));
      print('Saved notification settings for user ${user.uid}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Settings saved successfully',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.teal.shade700,
        ),
      );
    } catch (e) {
      print('Error saving notification settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save settings: $e',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Theme(
      data: themeProvider.themeData,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Notification Settings',
            style: GoogleFonts.poppins(fontSize: 20),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  themeProvider.isDarkMode
                      ? [Colors.grey.shade900, Colors.black87]
                      : [Colors.grey.shade100, Colors.white],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      'Notification Preferences',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Card(
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: Text(
                              'Push Notifications',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                            secondary: const Icon(
                              Icons.notifications_active,
                              color: Colors.teal,
                            ),
                            value: _pushNotifications,
                            onChanged:
                                (value) =>
                                    setState(() => _pushNotifications = value),
                            activeColor: Colors.teal.shade700,
                          ),
                          SwitchListTile(
                            title: Text(
                              'Email Notifications',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                            secondary: const Icon(
                              Icons.email,
                              color: Colors.teal,
                            ),
                            value: _emailNotifications,
                            onChanged:
                                (value) =>
                                    setState(() => _emailNotifications = value),
                            activeColor: Colors.teal.shade700,
                          ),
                          SwitchListTile(
                            title: Text(
                              'Course Reminders',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                            secondary: const Icon(
                              Icons.book,
                              color: Colors.teal,
                            ),
                            value: _courseReminders,
                            onChanged:
                                (value) =>
                                    setState(() => _courseReminders = value),
                            activeColor: Colors.teal.shade700,
                          ),
                          SwitchListTile(
                            title: Text(
                              'Achievement Alerts',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                            secondary: const Icon(
                              Icons.star,
                              color: Colors.teal,
                            ),
                            value: _achievementAlerts,
                            onChanged:
                                (value) =>
                                    setState(() => _achievementAlerts = value),
                            activeColor: Colors.teal.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: Text(
                      'Notification Frequency',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: Card(
                      child: DropdownButtonFormField<String>(
                        value: _notificationFrequency,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items:
                            ['Daily', 'Weekly', 'Monthly']
                                .map(
                                  (frequency) => DropdownMenuItem<String>(
                                    value: frequency,
                                    child: Text(
                                      frequency,
                                      style: GoogleFonts.poppins(fontSize: 16),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) =>
                                setState(() => _notificationFrequency = value!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    duration: const Duration(milliseconds: 900),
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors:
                                      themeProvider.isDarkMode
                                          ? [
                                            Colors.teal.shade700,
                                            Colors.teal.shade400,
                                          ]
                                          : [
                                            Colors.teal.shade800,
                                            Colors.teal.shade600,
                                          ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _saveNotificationSettings,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Save Settings',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
