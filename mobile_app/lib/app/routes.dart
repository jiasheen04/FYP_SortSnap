import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/pages/login_page.dart';
import 'package:mobile_app/features/auth/pages/register_page.dart';
import 'package:mobile_app/features/chatbot/pages/chatbot_page.dart';
import 'package:mobile_app/features/dashboard/pages/dashboard_page.dart';
import 'package:mobile_app/features/community/pages/community_page.dart';
import 'package:mobile_app/features/map/pages/map_page.dart';
import 'package:mobile_app/features/pickup/pages/pickup_page.dart';
import 'package:mobile_app/features/profile/pages/profile_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String community = '/community';
  static const String map = '/map';
  static const String chatbot = '/chatbot';
  static const String pickup = '/pickup';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    dashboard: (context) => const DashboardPage(),
    community: (context) => const CommunityPage(),
    map: (context) => const MapPage(),
    chatbot: (context) => const ChatbotPage(),
    pickup: (context) => const PickupPage(),
    profile: (context) => const ProfilePage(),
  };
}
