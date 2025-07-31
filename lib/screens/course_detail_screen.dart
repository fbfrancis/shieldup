import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../providers/theme_provider.dart';
import '../providers/user_profile_provider.dart';
import 'quiz_screen.dart';
import 'package:my_app/screens/ai_chat/chat_screen.dart'; // Updated import

class CourseDetailScreen extends StatelessWidget {
  static const routeName = '/course-detail';

  final String? courseId;
  final String? courseTitle;
  final String? courseContext;

  const CourseDetailScreen({
    super.key,
    this.courseId,
    this.courseTitle,
    this.courseContext,
  });

  @override
  Widget build(BuildContext context) {
    final course =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProfile = Provider.of<UserProfileProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final primaryColor =
        Colors.teal.shade600; // Using your preferred teal color

    final progress = (course['progress'] as double?) ?? 0.0;
    final isCourseCompleted = progress >= 1.0;
    final isQuizTaken = userProfile.isCourseCompleted(course['title']);
    final videoId = YoutubePlayer.convertUrlToId(course['videoUrl'] ?? '');

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(
            course['title'],
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            // ShieldAi quick access button in app bar
            IconButton(
              onPressed: () => _navigateToShieldAi(context, course),
              icon: const Icon(Icons.security),
              tooltip: 'Ask ShieldAi',
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isDarkMode
                      ? [Colors.black, Colors.grey.shade900]
                      : [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildVideoPlayer(videoId, isDarkMode),
                _buildCourseContent(
                  context,
                  course,
                  isDarkMode,
                  primaryColor,
                  progress,
                  isCourseCompleted,
                  isQuizTaken,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(String? videoId, bool isDarkMode) {
    if (videoId == null) {
      return Image.asset(
        'assets/images/default_course.png',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        ),
        progressIndicatorColor: Colors.teal.shade600,
        progressColors: ProgressBarColors(
          playedColor: Colors.teal.shade600,
          handleColor: Colors.teal.shade600,
        ),
      ),
      builder:
          (_, player) =>
              SizedBox(height: 200, width: double.infinity, child: player),
    );
  }

  Widget _buildCourseContent(
    BuildContext context,
    Map<String, dynamic> course,
    bool isDarkMode,
    Color primaryColor,
    double progress,
    bool isCourseCompleted,
    bool isQuizTaken,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course['title'],
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Instructor: ${course['instructor']}',
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white70 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          _buildProgressIndicator(progress, isDarkMode, primaryColor),
          const SizedBox(height: 16),
          _buildActionButtons(context, course, isQuizTaken, primaryColor),
          const SizedBox(height: 16),
          _buildShieldAiHelp(context, course, isDarkMode, primaryColor),
          const SizedBox(height: 24),
          _buildCourseDetails(course, isDarkMode, primaryColor),
          if (isCourseCompleted)
            _buildCompletionBadge(isDarkMode, primaryColor),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(
    double progress,
    bool isDarkMode,
    Color primaryColor,
  ) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: isDarkMode ? Colors.grey[600] : Colors.grey[300],
          color: primaryColor,
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}% Complete',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Map<String, dynamic> course,
    bool isQuizTaken,
    Color primaryColor,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed:
                isQuizTaken ? null : () => _navigateToQuiz(context, course),
            icon: const Icon(Icons.quiz, size: 20),
            label: Text(isQuizTaken ? 'Quiz Completed' : 'Take Quiz'),
            style: _buttonStyle(isQuizTaken ? Colors.grey : primaryColor),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showShieldAiOptions(context, course),
            icon: const Icon(Icons.security, size: 20),
            label: const Text('ShieldAi Help'),
            style: _buttonStyle(primaryColor),
          ),
        ),
      ],
    );
  }

  // New ShieldAi help card
  Widget _buildShieldAiHelp(
    BuildContext context,
    Map<String, dynamic> course,
    bool isDarkMode,
    Color primaryColor,
  ) {
    return Card(
      elevation: 4,
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Need Help with This Course?',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ask ShieldAi for explanations, examples, or clarifications about ${course['title']}',
              style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToShieldAi(context, course),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Ask Questions'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showQuickPrompts(context, course),
                    icon: const Icon(Icons.lightbulb_outline, size: 18),
                    label: const Text('Quick Help'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(Color backgroundColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildCourseDetails(
    Map<String, dynamic> course,
    bool isDarkMode,
    Color primaryColor,
  ) {
    return ExpansionTile(
      title: Text('Course Overview', style: _titleStyle(isDarkMode)),
      iconColor: primaryColor,
      collapsedIconColor: primaryColor,
      children: [
        Text(course['description'], style: _contentStyle(isDarkMode)),
        const SizedBox(height: 12),
        Text('📌 Summary:', style: _subtitleStyle(primaryColor)),
        Text(
          course['summary'] ?? 'Comprehensive introduction to the topic.',
          style: _contentStyle(isDarkMode),
        ),
        const SizedBox(height: 12),
        Text('⚠️ Watch Out For:', style: _subtitleStyle(Colors.red.shade700)),
        Text(
          course['tips'] ?? 'Important concepts to focus on.',
          style: _contentStyle(isDarkMode),
        ),
      ],
    );
  }

  Widget _buildCompletionBadge(bool isDarkMode, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.teal.shade900 : Colors.teal.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: primaryColor),
          const SizedBox(width: 8),
          Text(
            'Course Completed!',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _titleStyle(bool isDarkMode) {
    return GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      color: isDarkMode ? Colors.white : Colors.grey[900],
    );
  }

  TextStyle _subtitleStyle(Color color) {
    return GoogleFonts.poppins(fontWeight: FontWeight.w600, color: color);
  }

  TextStyle _contentStyle(bool isDarkMode) {
    return GoogleFonts.poppins(
      color: isDarkMode ? Colors.white70 : Colors.grey[600],
    );
  }

  void _navigateToQuiz(BuildContext context, Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(courseTitle: course['title']),
      ),
    );
  }

  // Updated to use new ShieldAi chat screen
  void _navigateToShieldAi(BuildContext context, Map<String, dynamic> course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChatScreen(
              courseContext: course['id'] ?? course['title'],
              courseTitle: course['title'],
            ),
      ),
    );
  }

  // Show ShieldAi options bottom sheet
  void _showShieldAiOptions(BuildContext context, Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.security, color: Colors.teal.shade600, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'ShieldAi Help Options',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.school, color: Colors.teal.shade600),
                  title: const Text('Ask about this course'),
                  subtitle: Text('Get help with ${course['title']}'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToShieldAi(context, course);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.quiz, color: Colors.teal.shade600),
                  title: const Text('Quiz preparation'),
                  subtitle: const Text('Get ready for the course quiz'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToShieldAiWithPrompt(
                      context,
                      course,
                      'Help me prepare for the ${course['title']} quiz. What are the key topics I should focus on?',
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.lightbulb, color: Colors.teal.shade600),
                  title: const Text('Explain concepts'),
                  subtitle: const Text('Get detailed explanations'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToShieldAiWithPrompt(
                      context,
                      course,
                      'Can you explain the main concepts in ${course['title']} in simple terms?',
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.help_outline,
                    color: Colors.teal.shade600,
                  ),
                  title: const Text('General cybersecurity help'),
                  subtitle: const Text('Ask about any security topic'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  // Show quick prompts for the course
  void _showQuickPrompts(BuildContext context, Map<String, dynamic> course) {
    final prompts = [
      'Explain ${course['title']} in simple terms',
      'What are the key points in ${course['title']}?',
      'Give me examples related to ${course['title']}',
      'How does ${course['title']} apply in real life?',
      'What should I remember most about ${course['title']}?',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Quick Questions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ...prompts.map(
                  (prompt) => ListTile(
                    leading: Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.teal.shade600,
                    ),
                    title: Text(prompt),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToShieldAiWithPrompt(context, course, prompt);
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Navigate to ShieldAi with a specific prompt
  void _navigateToShieldAiWithPrompt(
    BuildContext context,
    Map<String, dynamic> course,
    String prompt,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChatScreen(
              courseContext: course['id'] ?? course['title'],
              courseTitle: course['title'],
              initialPrompt: prompt, // Pass the prompt to auto-send
            ),
      ),
    );
  }
}
