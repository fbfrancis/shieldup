import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String loginEmail;

  const ChangePasswordScreen({super.key, required this.loginEmail});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  InputDecoration _inputDecoration(String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      filled: true,
      fillColor: isDark ? Colors.black : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade600),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade600),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'No user is signed in';

      final credential = EmailAuthProvider.credential(
        email: widget.loginEmail,
        password: _oldPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_newPasswordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscureText,
    VoidCallback toggle,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: _inputDecoration(label).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          onPressed: toggle,
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Theme(
      data: themeProvider.themeData,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Change Password"),
          backgroundColor: Colors.teal.shade600,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildPasswordField(
                  'Old Password',
                  _oldPasswordController,
                  _obscureOld,
                  () => setState(() => _obscureOld = !_obscureOld),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  'New Password',
                  _newPasswordController,
                  _obscureNew,
                  () => setState(() => _obscureNew = !_obscureNew),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  'Confirm New Password',
                  _confirmPasswordController,
                  _obscureConfirm,
                  () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _changePassword,
                        child: const Text(
                          'Change Password',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
