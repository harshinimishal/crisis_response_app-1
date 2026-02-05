import 'package:flutter/material.dart';

/// App-wide route names for type-safe navigation
class AppRoutes {
  static const String roleSelection = '/';
  static const String citizenHome = '/citizen-home';
  static const String emergencyReport = '/emergency-report';
  static const String incidentStatus = '/incident-status';
  static const String authorityDashboard = '/authority-dashboard';
  static const String incidentDetail = '/incident-detail';
  static const String volunteerTasks = '/volunteer-tasks';
}

/// Navigation helper methods
class NavigationHelper {
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }
  
  static void replaceTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }
  
  static void navigateBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
  
  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.roleSelection,
      (route) => false,
    );
  }
}
