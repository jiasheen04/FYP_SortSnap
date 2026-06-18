import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/services/id_generator_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController contactNoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String convertUsernameToEmail(String username) {
    return '$username@sortsnap.com';
  }

  Future<void> registerUser() async {
    String username = usernameController.text.trim();
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String contactNo = contactNoController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (username.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty ||
        contactNo.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password and Confirm Password do not match'),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      String email = convertUsernameToEmail(username);

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final userNo = await IdGeneratorService().generateReadableCode(
        counterName: 'users',
        prefix: 'U',
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'userNo': userNo,
            'username': username,
            'firstName': firstName,
            'lastName': lastName,
            'contactNo': contactNo,
            'email': email,
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Register successful')));

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'Register failed';

      if (e.code == 'email-already-in-use') {
        message = 'Username already exists';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid username';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    contactNoController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBEF2DE), Color(0xFFD5EDE4)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF51BA90),
                  ),
                ),
                const SizedBox(height: 35),

                const Text(
                  'Username',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 22),
                const Text(
                  'First Name',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 22),
                const Text(
                  'Last Name',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 22),
                const Text(
                  'Contact No.',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contactNoController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 22),
                const Text(
                  'Password',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 22),
                const Text(
                  'Confirm Password',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: hideConfirmPassword,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hideConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          hideConfirmPassword = !hideConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Color(0xFF51BA90),
                          width: 2,
                        ),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.grey,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Color(0xFF51BA90),
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
