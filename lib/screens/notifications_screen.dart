import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  static const routeName = '/notifications';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Theme(
      data: themeProvider.themeData,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: GoogleFonts.poppins(fontSize: 20),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  themeProvider.isDarkMode
                      ? [Colors.black87, Colors.grey.shade900]
                      : [Colors.grey.shade100, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('notifications')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No notifications yet.',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                );
              }

              final notifications = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification =
                      notifications[index].data() as Map<String, dynamic>;
                  final title = notification['title'] ?? 'No title';
                  final body = notification['body'] ?? '';
                  final timestamp =
                      (notification['timestamp'] as Timestamp?)?.toDate();
                  final formattedTime =
                      timestamp != null
                          ? DateFormat.yMMMd().add_jm().format(timestamp)
                          : 'Unknown time';

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        title,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(body, style: GoogleFonts.poppins()),
                          const SizedBox(height: 4),
                          Text(
                            formattedTime,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
