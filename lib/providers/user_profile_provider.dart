import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfileProvider extends ChangeNotifier {
  String _userName = 'Guest';
  String? _email;
  String? _profileImageUrl; // Changed to store Firebase Storage URL
  final Map<String, double> _courseProgress = {};
  final Map<String, DateTime> _lastAccessed = {};
  final Map<String, bool> _courseCompletion = {};
  bool _isLoading = false;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getters
  String get userName => _userName;
  String? get email => _email ?? _auth.currentUser?.email;
  String? get profileImageUrl => _profileImageUrl; // Updated getter
  bool get isLoading => _isLoading;
  bool get hasCourses => _courseProgress.isNotEmpty;
  Map<String, double> get courseProgress => Map.from(_courseProgress);

  // Check if user has accessed courses
  bool hasAccessedCourses() {
    return _courseProgress.isNotEmpty ||
        _courseCompletion.values.any((completed) => completed);
  }

  // Course completion methods
  bool isCourseCompleted(String courseId) {
    return (_courseCompletion[courseId] ?? false) ||
        (_courseProgress[courseId] ?? 0.0) >= 1.0;
  }

  Future<void> markCourseCompleted(String courseId) async {
    _courseCompletion[courseId] = true;
    _courseProgress[courseId] = 1.0;
    await _updateCourseInFirestore(courseId);
    notifyListeners();
  }

  Future<void> updateCourseProgress(
    String courseId,
    double progress, {
    bool setCompleted = false,
    required bool isCorrect,
  }) async {
    _courseProgress[courseId] = progress.clamp(0.0, 1.0);
    if (setCompleted || progress >= 1.0) {
      _courseCompletion[courseId] = true;
    }
    await _updateCourseInFirestore(courseId);
    notifyListeners();
  }

  Future<void> enrollInCourse(String courseId) async {
    debugPrint('📚 Enrolling in course: $courseId');

    if (_courseProgress.containsKey(courseId)) {
      debugPrint('⚠️ Already enrolled in $courseId');
      return;
    }

    _courseProgress[courseId] = 0.0;
    _lastAccessed[courseId] = DateTime.now();
    _courseCompletion[courseId] = false;

    await _updateCourseInFirestore(courseId);
    debugPrint('✅ Successfully enrolled in $courseId');
    notifyListeners();
  }

  List<Map<String, dynamic>> getDashboardCourses() {
    return _courseProgress.entries.map((entry) {
      return {
        'title': entry.key,
        'progress': entry.value,
        'lastAccessed': _formatDate(_lastAccessed[entry.key]),
        'image': _getCourseImage(entry.key),
        'completed': isCourseCompleted(entry.key),
      };
    }).toList();
  }

  // Core methods
  Future<void> init() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _loadPersistedData();

      if (_auth.currentUser != null) {
        _email = _auth.currentUser!.email;
        await loadUserDataFromFirestore();
        await _loadCourseData();
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserDataFromFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        debugPrint('🔍 Loading user data for UID: ${user.uid}');

        final doc =
            await _firestore
                .collection('verified_users') // Changed to verified_users
                .doc(user.uid)
                .get();

        if (doc.exists) {
          final data = doc.data()!;
          debugPrint('📄 Firestore data: $data');

          // Handle name
          final firestoreName = data['name'] as String?;
          if (firestoreName != null && firestoreName.isNotEmpty) {
            _userName = firestoreName;
          } else {
            debugPrint(
              '⚠️ No name found in Firestore, keeping current: $_userName',
            );
          }

          // Handle email
          _email = data['email'] ?? user.email;

          // Handle profile image URL
          final profileImageUrl = data['profileImageUrl'] as String?;
          if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
            _profileImageUrl = profileImageUrl;
          }

          // Save to SharedPreferences for offline access
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userName', _userName);
          if (_email != null) {
            await prefs.setString('email', _email!);
          }
          if (_profileImageUrl != null) {
            await prefs.setString('profileImageUrl', _profileImageUrl!);
          }

          debugPrint(
            '✅ Loaded user data: Name=$_userName, Email=$_email, ProfileImageUrl=$_profileImageUrl',
          );
          notifyListeners();
        } else {
          debugPrint(
            '❌ User document does not exist in Firestore for UID: ${user.uid}',
          );
          await _createUserDocument(user);
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading user data from Firestore: $e');
    }
  }

  // Create user document if it doesn't exist
  Future<void> _createUserDocument(User user) async {
    try {
      await _firestore.collection('verified_users').doc(user.uid).set({
        'email': user.email,
        'name': user.displayName ?? _userName,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('✅ Created user document for ${user.email}');

      // Reload after creating
      await loadUserDataFromFirestore();
    } catch (e) {
      debugPrint('❌ Error creating user document: $e');
    }
  }

  Future<void> updateProfile({
    String? name,
    String? imagePath,
    String? email,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final prefs = await SharedPreferences.getInstance();
      final updates = <String, dynamic>{};

      // Update name if provided
      if (name != null && name.trim().isNotEmpty) {
        _userName = name;
        updates['name'] = name;
        await prefs.setString('userName', name);
        debugPrint('✅ Updated name: $name');
      }

      // Upload image to Firebase Storage and update profileImageUrl if provided
      if (imagePath != null) {
        final ref = _storage
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');
        await ref.putFile(File(imagePath));
        _profileImageUrl = await ref.getDownloadURL();
        updates['profileImageUrl'] = _profileImageUrl;
        await prefs.setString('profileImageUrl', _profileImageUrl!);
        debugPrint('✅ Updated profile image URL: $_profileImageUrl');
      }

      // Update Firestore document
      if (updates.isNotEmpty) {
        await _firestore
            .collection('verified_users')
            .doc(user.uid)
            .set(updates, SetOptions(merge: true));
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      rethrow; // Rethrow to handle errors in the UI
    }
  }

  // Private methods
  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? 'Guest';
    _email = prefs.getString('email');
    _profileImageUrl = prefs.getString('profileImageUrl');
    debugPrint(
      '📱 Loaded from SharedPreferences: Name=$_userName, Email=$_email, ProfileImageUrl=$_profileImageUrl',
    );
  }

  Future<void> _loadCourseData() async {
    try {
      final snapshot =
          await _firestore
              .collection('user_courses')
              .where('userId', isEqualTo: _auth.currentUser!.uid)
              .get();

      _courseProgress.clear();
      _lastAccessed.clear();
      _courseCompletion.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final courseId = data['courseId'] as String;
        _courseProgress[courseId] = (data['progress'] ?? 0).toDouble();
        _courseCompletion[courseId] = data['completed'] ?? false;
        _lastAccessed[courseId] =
            (data['lastAccessed'] as Timestamp?)?.toDate() ?? DateTime.now();
      }
    } catch (e) {
      debugPrint('Course load error: $e');
      rethrow;
    }
  }

  Future<void> _updateCourseInFirestore(String courseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('user_courses')
          .doc('${user.uid}_$courseId')
          .set({
            'userId': user.uid,
            'courseId': courseId,
            'progress': _courseProgress[courseId],
            'completed': _courseCompletion[courseId] ?? false,
            'lastAccessed': Timestamp.fromDate(
              _lastAccessed[courseId] ?? DateTime.now(),
            ),
          }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore update error: $e');
      rethrow;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Never accessed';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getCourseImage(String courseId) {
    switch (courseId.toLowerCase()) {
      case 'flutter':
        return 'assets/images/flutter.png';
      case 'ui_design':
        return 'assets/images/ui_design.png';
      default:
        return 'assets/images/default_course.png';
    }
  }
}
