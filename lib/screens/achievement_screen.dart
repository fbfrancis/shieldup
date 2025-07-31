import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      {'title': 'Fast Learner', 'completed': true, 'icon': Icons.flash_on},
      {'title': 'Perfect Score', 'completed': true, 'icon': Icons.star},
      {'title': 'Marathoner', 'completed': false, 'icon': Icons.directions_run},
      {'title': 'Early Bird', 'completed': true, 'icon': Icons.wb_sunny},
      {'title': 'Bookworm', 'completed': false, 'icon': Icons.menu_book},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Achievements',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return FadeInUp(
              delay: Duration(milliseconds: 100 * index),
              child: Card(
                child: ListTile(
                  leading: Icon(
                    achievement['icon'] as IconData,
                    color:
                        achievement['completed'] as bool
                            ? Colors.amber
                            : Colors.grey,
                  ),
                  title: Text(
                    achievement['title'] as String,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  trailing:
                      achievement['completed'] as bool
                          ? const Icon(Icons.check_circle, color: Colors.teal)
                          : const Icon(Icons.lock, color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
