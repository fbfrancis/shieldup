import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchEmail(BuildContext context) async {
    const supportEmail = 'shieldup.official@gmail.com';
    final emailUri = Uri.parse(
      'mailto:$supportEmail?subject=Support%20Request&body=Please%20describe%20your%20issue%20or%20question%20here.',
    );

    try {
      await launchUrl(emailUri, mode: LaunchMode.platformDefault);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to open email app. Please send to $supportEmail.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final faqs = [
      {
        'question': 'How do I reset my password?',
        'answer':
            'Navigate to the "Change Password" option in the Profile section to reset your password.',
      },
      {
        'question': 'How do I contact support?',
        'answer':
            'Use the "Contact Support" button below to send an email to our support team.',
      },
      {
        'question': 'Where can I find my saved courses?',
        'answer':
            'Navigate to the "Saved Courses" section in your Profile to view all saved courses.',
      },
      {
        'question': 'How do I update my profile information?',
        'answer':
            'Go to the Profile section, click the edit icon, and update your name or profile picture.',
      },
      {
        'question': 'What should I do if I encounter a technical issue?',
        'answer':
            'Report the issue via the "Report A Concern" option in the Profile section or contact support directly.',
      },
      {
        'question': 'How can I track my learning progress?',
        'answer':
            'Check the "Learning Progress" section in your Profile to view completed courses, badges, and learning hours.',
      },
    ];

    return Theme(
      data: themeProvider.themeData,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  themeProvider.isDarkMode
                      ? [Colors.grey.shade900, Colors.black87]
                      : [Colors.teal.shade50, Colors.white],
            ),
          ),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(
                  'Help & Support',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                pinned: true,
                backgroundColor:
                    themeProvider.isDarkMode
                        ? Colors.black87
                        : Colors.teal.shade800,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          'Frequently Asked Questions',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (faqs.isEmpty)
                        Center(
                          child: Text(
                            'No FAQs available',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color:
                                  themeProvider.isDarkMode
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade800,
                            ),
                          ),
                        )
                      else
                        ...faqs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final faq = entry.value;
                          return FadeInUp(
                            duration: Duration(
                              milliseconds: 600 + (index * 50),
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ExpansionTile(
                                title: Text(
                                  faq['question'] ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: Text(
                                      faq['answer'] ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 20),
                      FadeInUp(
                        duration: const Duration(milliseconds: 900),
                        child: Container(
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
                            onPressed: () => _launchEmail(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.support_agent,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Contact Support',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
