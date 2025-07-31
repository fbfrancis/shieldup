import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'new_user_dashboard.dart'; // Ensure this is correct

class TipsScreen extends StatelessWidget {
  static const routeName = '/tips';

  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(
          context,
          NewUserDashboardScreen.routeName,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
        appBar: AppBar(
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.teal.shade700,
          title: Text(
            'Cybersecurity Tips',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                NewUserDashboardScreen.routeName,
              );
            },
          ),
          elevation: 2,
        ),
        body: Scrollbar(
          radius: const Radius.circular(8),
          thickness: 6,
          thumbVisibility: true,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return TipCard(
                tip: tip,
                isDarkMode: isDarkMode,
                key: ValueKey(tip.title),
              );
            },
          ),
        ),
      ),
    );
  }

  static const List<Tip> tips = [
    Tip(
      icon: Icons.lock,
      title: 'Use Strong Passwords',
      description:
          'Create passwords with at least 12-16 characters, mixing uppercase, lowercase, numbers, and symbols. Use a password manager to generate and store unique passwords for each account.',
    ),
    Tip(
      icon: Icons.security,
      title: 'Enable Multi-Factor Authentication',
      description:
          'Activate MFA on all accounts to require two or more verification methods like a password and a one-time code.',
    ),
    Tip(
      icon: Icons.link_off,
      title: 'Avoid Suspicious Links',
      description:
          'Don’t click links or download attachments from unknown emails. Verify the sender’s legitimacy first.',
    ),
    Tip(
      icon: Icons.update,
      title: 'Keep Software Updated',
      description:
          'Enable automatic updates to patch security holes. Remove unused apps to reduce your attack surface.',
    ),
    Tip(
      icon: Icons.wifi_off,
      title: 'Be Cautious on Public Wi-Fi',
      description:
          'Avoid accessing sensitive data on public Wi-Fi. Use a VPN or mobile hotspot for secure browsing.',
    ),
    Tip(
      icon: Icons.phishing,
      title: 'Defend Against AI-Powered Phishing',
      description:
          'Watch for emails using AI to mimic trusted sources. Use email filters and double-check message authenticity.',
    ),
    Tip(
      icon: Icons.lock_clock,
      title: 'Prepare for Ransomware Attacks',
      description:
          'Back up data regularly to encrypted off-site storage. Test recovery. Train users to recognize phishing.',
    ),
    Tip(
      icon: Icons.verified_user,
      title: 'Adopt Zero Trust Architecture',
      description:
          'Verify every user/device before granting access. Apply least-privilege principles.',
    ),
    Tip(
      icon: Icons.devices,
      title: 'Secure IoT Devices',
      description:
          'Change default passwords, update firmware, and isolate IoT devices on a separate network.',
    ),
    Tip(
      icon: Icons.cloud,
      title: 'Strengthen Cloud Security',
      description:
          'Use providers with encryption and MFA. Monitor configs regularly.',
    ),
    Tip(
      icon: Icons.school,
      title: 'Train Employees on Cybersecurity',
      description:
          'Educate staff on phishing, safe data handling, and suspicious activity reporting.',
    ),
    Tip(
      icon: Icons.vpn_key,
      title: 'Use VPNs for Secure Connections',
      description:
          'Encrypt your traffic when remote or on public networks to protect data.',
    ),
    Tip(
      icon: Icons.privacy_tip,
      title: 'Limit App Permissions',
      description:
          'Only grant necessary permissions to mobile apps. Revoke access to camera, mic, or location if unused.',
    ),
    Tip(
      icon: Icons.password,
      title: 'Avoid Password Reuse',
      description:
          'Using the same password on multiple sites increases breach risk. Use unique passwords for every service.',
    ),
    Tip(
      icon: Icons.auto_delete,
      title: 'Regularly Clear Browser Data',
      description:
          'Clear cookies, cache, and saved passwords on shared or public devices to avoid data theft.',
    ),
    Tip(
      icon: Icons.backup,
      title: 'Back Up Data Frequently',
      description:
          'Use both cloud and local backups. Automate it to prevent loss from ransomware or hardware failure.',
    ),
  ];
}

class Tip {
  final IconData icon;
  final String title;
  final String description;

  const Tip({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class TipCard extends StatelessWidget {
  final Tip tip;
  final bool isDarkMode;

  const TipCard({super.key, required this.tip, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            isDarkMode
                ? []
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: ExpansionTileThemeData(
            backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
            collapsedBackgroundColor:
                isDarkMode ? Colors.grey[850] : Colors.white,
            iconColor: isDarkMode ? Colors.tealAccent : Colors.teal.shade700,
            collapsedIconColor:
                isDarkMode ? Colors.tealAccent : Colors.teal.shade700,
            textColor: isDarkMode ? Colors.white : Colors.grey[900],
            collapsedTextColor: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
        child: ExpansionTile(
          leading: Icon(
            tip.icon,
            color: isDarkMode ? Colors.tealAccent : Colors.teal.shade700,
            size: 24,
            semanticLabel: '${tip.title} icon',
          ),
          title: Text(
            tip.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.grey[900],
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
          children: [
            Text(
              tip.description,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
