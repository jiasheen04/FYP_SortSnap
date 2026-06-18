import 'package:flutter/material.dart';
import 'package:mobile_app/app/auth_gate.dart';
import 'package:mobile_app/app/routes.dart';
import 'package:mobile_app/app/theme.dart';

class SortSnapApp extends StatelessWidget {
  const SortSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SortSnap',
      theme: AppTheme.lightTheme,

      // Check login status first
      home: const AuthGate(),

      routes: AppRoutes.routes,
    );
  }
}