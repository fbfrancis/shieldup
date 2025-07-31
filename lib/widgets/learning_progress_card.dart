import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class LearningProgressCard extends StatelessWidget {
  final Map<String, int> learningProgress;

  const LearningProgressCard({super.key, required this.learningProgress});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDarkMode
                    ? [Colors.grey.shade800, Colors.grey.shade700]
                    : [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header with title and View All
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Learning Progress',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey.shade800,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/full-progress');
                  },
                  child: Text(
                    'View All',
                    style: GoogleFonts.poppins(
                      color: Colors.teal.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// Progress indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPercentIndicator(
                  context,
                  title: 'Courses\nCompleted',
                  value: learningProgress['courses_completed']! / 20,
                  count: learningProgress['courses_completed']!,
                  color: Colors.teal.shade600,
                ),
                _buildPercentIndicator(
                  context,
                  title: 'Badges\nEarned',
                  value: learningProgress['badges_earned']! / 10,
                  count: learningProgress['badges_earned']!,
                  color: Colors.amber.shade600,
                ),
                _buildPercentIndicator(
                  context,
                  title: 'Hours\nLearned',
                  value: learningProgress['hours_learned']! / 100,
                  count: learningProgress['hours_learned']!,
                  color: Colors.purple.shade600,
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// Learning Streak section with Lottie
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? Colors.grey.shade900.withOpacity(0.6)
                        : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Learning Streak',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 36,
                        width: 36,
                        child: Lottie.asset(
                          'assets/lottie_fire.json',
                          repeat: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${learningProgress['streak_days']} Days',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isDarkMode ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentIndicator(
    BuildContext context, {
    required String title,
    required double value,
    required int count,
    required Color color,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor:
                    isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                color: color,
              ),
            ),
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
