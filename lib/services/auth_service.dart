import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SIGN UP
  Future<String?> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      await _firestore.collection('users').doc(user!.uid).set({
        'name': name,
        'email': email,
        'uid': user.uid,
        'createdAt': Timestamp.now(),
      });

      await user.sendEmailVerification();
      await _auth.signOut();

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'An account with this email already exists.';
      }
      return e.message ?? 'Something went wrong.';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  // LOGIN
  Future<String?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!result.user!.emailVerified) {
        await _auth.signOut();
        return 'Please verify your email before logging in.';
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed.';
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  // FORGOT PASSWORD
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to send reset link.';
    }
  }

  // RESEND VERIFICATION
  Future<void> resendEmailVerification() async {
    if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
      await _auth.currentUser!.sendEmailVerification();
    }
  }

  // CURRENT USER
  User? get currentUser => _auth.currentUser;

  // CHECK EMAIL VERIFIED
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }
}
