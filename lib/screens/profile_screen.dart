import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/user_profile_provider.dart';
import 'achievement_screen.dart';
import 'change_password_screen.dart';
import 'dark_mode_screen.dart';
import 'help_support_screen.dart';
import 'notificationsettings_screen.dart';
import 'report_concern.dart';
import '../widgets/learning_progress_card.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  final String loginEmail;

  const ProfileScreen({super.key, required this.loginEmail});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  final _nameController = TextEditingController();
  bool _isEditing = false;
  String _appVersion = '';
  bool _isImageLoading = false;
  final int _maxNameLength = 30;
  final _nameRegex = RegExp(r'^[a-zA-Z ]+$');
  final ScrollController _scrollController = ScrollController();
  double _avatarSize = 180.0;
  final double _minAvatarSize = 100.0;

  final _learningProgress = {
    'courses_completed': 12,
    'badges_earned': 5,
    'hours_learned': 45,
    'streak_days': 7,
  };

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _scrollController.addListener(_scrollListener);

    // Initialize name controller with current user name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProfile = Provider.of<UserProfileProvider>(
        context,
        listen: false,
      );
      _nameController.text = userProfile.userName;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final double offset = _scrollController.offset;
    final double newSize =
        _avatarSize - offset.clamp(0, _avatarSize - _minAvatarSize);
    if (newSize != _avatarSize) {
      setState(() {
        _avatarSize = newSize > _minAvatarSize ? newSize : _minAvatarSize;
      });
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() => _appVersion = packageInfo.version);
    } catch (e) {
      _showSnackBar(
        context,
        'Failed to load app version',
        Colors.redAccent,
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      setState(() => _isImageLoading = true);
      final pickedFile = await ImagePicker()
          .pickImage(
            source: ImageSource.gallery,
            maxWidth: 500,
            maxHeight: 500,
            imageQuality: 90,
          )
          .timeout(const Duration(seconds: 15));

      if (pickedFile != null) {
        final compressedImage = await _compressImage(File(pickedFile.path));
        setState(() => _imageFile = compressedImage);
        await Provider.of<UserProfileProvider>(
          context,
          listen: false,
        ).updateProfile(imagePath: compressedImage.path);
        _showSnackBar(
          context,
          'Profile picture updated',
          Colors.teal.shade700,
          icon: Icons.check_circle,
        );
      }
    } on TimeoutException {
      _showSnackBarWithAction(
        context,
        'Image selection timed out',
        'Retry',
        Colors.redAccent,
        _pickImage,
      );
    } catch (e) {
      _showSnackBarWithAction(
        context,
        'Failed to update profile picture: ${e.toString()}',
        'Retry',
        Colors.redAccent,
        _pickImage,
      );
    } finally {
      if (mounted) {
        setState(() => _isImageLoading = false);
      }
    }
  }

  Future<File> _compressImage(File image) async {
    return image; // Implement compression logic if needed
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        final userProfile = Provider.of<UserProfileProvider>(
          context,
          listen: false,
        );
        _nameController.text = userProfile.userName;
      }
    });
  }

  void _saveName() {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      _showSnackBar(
        context,
        'Name cannot be empty',
        Colors.redAccent,
        icon: Icons.error_outline,
      );
      return;
    }
    if (newName.length > _maxNameLength) {
      _showSnackBar(
        context,
        'Name cannot exceed $_maxNameLength characters',
        Colors.redAccent,
        icon: Icons.error_outline,
      );
      return;
    }
    if (!_nameRegex.hasMatch(newName)) {
      _showSnackBar(
        context,
        'Name can only contain letters and spaces',
        Colors.redAccent,
        icon: Icons.error_outline,
      );
      return;
    }

    Provider.of<UserProfileProvider>(
      context,
      listen: false,
    ).updateProfile(name: newName);

    setState(() => _isEditing = false);

    _showSnackBar(
      context,
      'Name updated successfully',
      Colors.teal.shade700,
      icon: Icons.check_circle,
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Confirm Logout',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.exit_to_app,
                color: Colors.redAccent.shade400,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Are you sure you want to log out?',
                style: GoogleFonts.poppins(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(fontSize: 14)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar(
                  context,
                  'Logged out successfully',
                  Colors.teal.shade700,
                );
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor, {
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSnackBarWithAction(
    BuildContext context,
    String message,
    String actionLabel,
    Color backgroundColor,
    VoidCallback onAction,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: onAction,
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isEditable = false,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
      child: ListTile(
        leading: Icon(
          icon,
          color: isDarkMode ? Colors.teal.shade400 : Colors.teal.shade700,
          size: 28,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : Colors.grey.shade800,
          ),
        ),
        subtitle:
            isEditable
                ? null
                : Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color:
                        isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                  ),
                ),
        trailing: trailing,
        onTap: isEditable ? null : onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: isLogout ? 6 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient:
                isLogout
                    ? LinearGradient(
                      colors: [Colors.teal.shade700, Colors.teal.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color:
                isLogout
                    ? null
                    : isDarkMode
                    ? Colors.grey.shade800
                    : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            leading: Icon(
              icon,
              color:
                  isLogout
                      ? Colors.white
                      : isDarkMode
                      ? Colors.teal.shade400
                      : Colors.teal.shade700,
              size: 28,
            ),
            title: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color:
                    isLogout
                        ? Colors.white
                        : isDarkMode
                        ? Colors.white
                        : Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color:
                  isLogout
                      ? Colors.white70
                      : isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(UserProfileProvider userProfile) {
    return ClipOval(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white.withOpacity(0.1),
        child:
            _isImageLoading
                ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : _imageFile != null
                ? Image.file(_imageFile!, fit: BoxFit.cover)
                : userProfile.profileImageUrl != null
                ? CachedNetworkImage(
                  imageUrl: userProfile.profileImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    size: _avatarSize * 0.5,
                    color: Colors.white.withOpacity(0.7),
                  ),
                )
                : Icon(
                  Icons.person,
                  size: _avatarSize * 0.5,
                  color: Colors.white.withOpacity(0.7),
                ),
      ),
    );
  }

  Widget _buildEditControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 200,
          child: TextField(
            controller: _nameController,
            style: GoogleFonts.poppins(fontSize: 14, height: 1.2),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter name',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
              ),
              contentPadding: const EdgeInsets.only(bottom: 4),
              isDense: true,
            ),
            maxLength: _maxNameLength,
            onSubmitted: (_) => _saveName(),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.check,
            color:
                _nameController.text.trim().isNotEmpty &&
                        _nameController.text.length <= _maxNameLength &&
                        _nameRegex.hasMatch(_nameController.text)
                    ? Colors.teal.shade600
                    : Colors.grey,
            size: 20,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed:
              _nameController.text.trim().isNotEmpty &&
                      _nameController.text.length <= _maxNameLength &&
                      _nameRegex.hasMatch(_nameController.text)
                  ? _saveName
                  : null,
        ),
        IconButton(
          icon: const Icon(Icons.cancel, size: 20),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: _toggleEditing,
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return IconButton(icon: const Icon(Icons.edit), onPressed: _toggleEditing);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userProfile = Provider.of<UserProfileProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'My Profile',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? Colors.grey.shade900 : Colors.teal.shade800,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: _avatarSize,
                      height: _avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildProfileAvatar(userProfile),
                          if (!_isImageLoading)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade600,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeIn(
                      child: Text(
                        'Personal Info',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color:
                              isDarkMode ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildProfileItem(
                      icon: Icons.person,
                      title: 'Name',
                      subtitle: _isEditing ? '' : userProfile.userName,
                      isEditable: _isEditing,
                      trailing:
                          _isEditing
                              ? _buildEditControls()
                              : _buildEditButton(),
                    ),
                    _buildProfileItem(
                      icon: Icons.email,
                      title: 'Email',
                      subtitle: userProfile.email ?? 'No email',
                    ),
                    const SizedBox(height: 20),
                    LearningProgressCard(learningProgress: _learningProgress),
                    const SizedBox(height: 20),
                    FadeIn(
                      child: Text(
                        'Settings',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color:
                              isDarkMode ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildProfileCard(
                      icon: Icons.lock,
                      title: 'Change Password',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChangePasswordScreen(
                                    loginEmail: widget.loginEmail,
                                  ),
                            ),
                          ),
                    ),
                    _buildProfileCard(
                      icon: Icons.notifications,
                      title: 'Notification Settings',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const NotificationSettingsScreen(),
                            ),
                          ),
                    ),
                    _buildProfileCard(
                      icon: Icons.star,
                      title: 'Achievements',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AchievementsScreen(),
                            ),
                          ),
                    ),
                    _buildProfileCard(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportScreen(),
                            ),
                          ),
                    ),
                    _buildProfileCard(
                      icon: Icons.report_problem_outlined,
                      title: 'Report A Concern',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReportConcernScreen(),
                            ),
                          ),
                    ),
                    _buildProfileCard(
                      icon: Icons.history,
                      title: 'View My Reports',
                      onTap:
                          () => Navigator.pushNamed(context, '/view-reports'),
                    ),
                    _buildProfileCard(
                      icon: Icons.dark_mode,
                      title: 'Dark Mode',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const DarkModeSettingsScreen(),
                            ),
                          ),
                    ),
                    Pulse(
                      duration: const Duration(milliseconds: 1500),
                      child: _buildProfileCard(
                        icon: Icons.logout,
                        title: 'Logout',
                        onTap: _showLogoutConfirmation,
                        isLogout: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'App version: $_appVersion',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color:
                              isDarkMode
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}