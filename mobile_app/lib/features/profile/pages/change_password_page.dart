import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hideOldPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password must be at least 6 characters'),
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null || currentUser.email == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'No logged in user found',
        );
      }

      final credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: oldPassword,
      );

      await currentUser.reauthenticateWithCredential(credential);
      await currentUser.updatePassword(newPassword);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to change password';

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Old password is incorrect';
      } else if (e.code == 'weak-password') {
        message = 'New password is too weak';
      } else if (e.code == 'requires-recent-login') {
        message = 'Please logout and login again before changing password';
      } else if (e.code == 'no-user') {
        message = 'No logged in user found';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5EDE4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF62C49D),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_reset_outlined,
                    color: Color(0xFF51BA90),
                    size: 42,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Update Your Password',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Enter your old password first, then set a new password for your account.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _buildPasswordField(
              controller: _oldPasswordController,
              label: 'Old Password',
              obscureText: _hideOldPassword,
              onToggle: () {
                setState(() {
                  _hideOldPassword = !_hideOldPassword;
                });
              },
            ),
            const SizedBox(height: 14),
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'New Password',
              obscureText: _hideNewPassword,
              onToggle: () {
                setState(() {
                  _hideNewPassword = !_hideNewPassword;
                });
              },
            ),
            const SizedBox(height: 14),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              obscureText: _hideConfirmPassword,
              onToggle: () {
                setState(() {
                  _hideConfirmPassword = !_hideConfirmPassword;
                });
              },
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF51BA90),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
