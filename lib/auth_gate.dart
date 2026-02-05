import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/emergency_dashboard_screen.dart'; // Replace with your main app home screen

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF1B9B8E),
                ),
              ),
            ),
          );
        }

        // Check if user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in - navigate to home screen
          return const EmergencyDashboardScreen();
        } else {
          // User is not logged in - navigate to login screen
          return const LoginScreen();
        }
      },
    );
  }
}