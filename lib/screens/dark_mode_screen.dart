import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class DarkModeSettingsScreen extends StatefulWidget {
  const DarkModeSettingsScreen({super.key});

  @override
  State<DarkModeSettingsScreen> createState() => _DarkModeSettingsScreenState();
}

class _DarkModeSettingsScreenState extends State<DarkModeSettingsScreen> {
  Future<void> _selectTime(BuildContext context, bool isLightMode) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final picked = await showTimePicker(
      context: context,
      initialTime:
          isLightMode
              ? themeProvider.lightModeStart
              : themeProvider.lightModeEnd,
    );
    if (picked != null) {
      themeProvider.updateSchedule(
        isLightMode ? picked : themeProvider.lightModeStart,
        isLightMode ? themeProvider.lightModeEnd : picked,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Theme schedule updated',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Colors.teal.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to ProfileScreen
                  },
                ),
                title: Text(
                  'Dark Mode Settings',
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
                          'Theme Settings',
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: SwitchListTile(
                            title: Text(
                              'Dark Mode',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            secondary: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              color: Colors.teal.shade700,
                            ),
                            value: themeProvider.isDarkMode,
                            onChanged:
                                (value) => themeProvider.toggleDarkMode(),
                            activeColor: Colors.teal.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeInUp(
                        duration: const Duration(milliseconds: 700),
                        child: Text(
                          'Theme Schedule',
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  'Light Mode',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  themeProvider.lightModeStart.format(context),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.access_time,
                                  color: Colors.teal,
                                  size: 24,
                                ),
                                onTap: () => _selectTime(context, true),
                              ),
                              ListTile(
                                title: Text(
                                  'Dark Mode',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  themeProvider.lightModeEnd.format(context),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.access_time,
                                  color: Colors.teal,
                                  size: 24,
                                ),
                                onTap: () => _selectTime(context, false),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                            onPressed: () {
                              themeProvider.updateSchedule(
                                themeProvider.lightModeStart,
                                themeProvider.lightModeEnd,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Settings saved successfully',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.teal.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () {
                                  Navigator.pop(
                                    context,
                                  ); // Navigate back to ProfileScreen
                                },
                              );
                            },
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
            ],
          ),
        ),
      ),
    );
  }
}
