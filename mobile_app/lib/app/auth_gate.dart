import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/pages/login_page.dart';
import 'package:mobile_app/features/dashboard/pages/dashboard_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // App is checking whether user already logged in or not
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user already logged in, directly go dashboard
        if (snapshot.hasData) {
          return const DashboardPage();
        }

        // If user not logged in, show login page
        return const LoginPage();
      },
    );
  }
}