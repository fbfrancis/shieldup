import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/user_profile_provider.dart';
import 'main_dashboard_screen.dart';
import 'new_user_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final result = await authService.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result == 'Please verify your email first.') {
        _showVerifyDialog();
        return;
      }

      if (result != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
        return;
      }

      final user = authService.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Authentication failed.")));
        return;
      }

      final doc =
          await FirebaseFirestore.instance
              .collection('verified_users')
              .doc(user.uid)
              .get();

      if (!doc.exists) {
        await authService.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Your account is not yet verified by admin."),
          ),
        );
        return;
      }

      final email = user.email ?? '';
      final name = user.displayName ?? '';
      final userProvider = Provider.of<UserProfileProvider>(
        context,
        listen: false,
      );

      await userProvider.updateProfile(name: name, email: email);
      await userProvider.init();

      Navigator.pushReplacementNamed(
        context,
        userProvider.hasCourses
            ? MainUserDashboardScreen.routeName
            : NewUserDashboardScreen.routeName,
        arguments: email,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login error: ${e.toString()}")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showVerifyDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Email not verified"),
            content: const Text(
              "Please verify your email before logging in. Would you like to resend the verification email?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final authService = AuthService();
                  await authService.resendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Verification email resent.")),
                  );
                },
                child: const Text("Resend"),
              ),
            ],
          ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white38),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.tealAccent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(41, 53, 45, 1),
                  Color.fromRGBO(0, 77, 64, 1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                'Login Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Lottie.asset(
                                'assets/signup.json',
                                height: 250,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _inputDecoration('Email'),
                                    validator:
                                        (value) =>
                                            (value == null ||
                                                    !value.contains('@'))
                                                ? 'Enter a valid email'
                                                : null,
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _inputDecoration(
                                      'Password',
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.white70,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                    validator:
                                        (value) =>
                                            (value == null || value.length < 6)
                                                ? 'Password must be at least 6 characters'
                                                : null,
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: Colors.tealAccent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.tealAccent,
                                      )
                                      : SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _loginUser,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.teal.shade600,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            elevation: 4,
                                            shadowColor: Colors.teal
                                                .withOpacity(0.4),
                                          ),
                                          child: const Text(
                                            'Login',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
