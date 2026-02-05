import 'package:flutter/material.dart';
import '../screens/Entry_screen.dart';
import '../screens/Login_screen.dart';
import '../screens/Signup_screen.dart';
import '../screens/Forget_Password_screen.dart';
import '../screens/OTP_screen.dart';
import '../screens/Reset_Password_screen.dart';
import '../screens/Permissions_screen.dart';
import '../screens/Success_screen.dart';
import '../screens/emergency_dashboard_screen.dart';
import '../screens/emergency_profile_screen.dart';
import '../screens/sos_trigger_screen.dart';
import '../screens/accident_detected_screen.dart';
import '../screens/Alerts_Centre_screen.dart';
import '../screens/safety_map_screen.dart';
import '../screens/CPR_guide.dart';
import '../screens/First_Aid_screen.dart';
import '../screens/Safety_Tutorial_screen.dart';
import '../screens/emergency_beacon_screen.dart';
import '../screens/event_history_screen.dart';
import '../screens/Responder_Directory_screen.dart';
import '../screens/Community_Alert.dart';
import '../screens/Advanced_Sensors_screen.dart';
import '../screens/connectivity_status_screen.dart';
import '../screens/safety_settings_screen.dart';
import '../screens/preventive_safety_alerts_screen.dart';

class AppRoutes {
  // Auth Routes
  static const String entry = '/entry';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgetPassword = '/forget-password';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';
  static const String permissions = '/permissions';
  static const String success = '/success';

  // Dashboard & Main Routes
  static const String dashboard = '/dashboard';
  static const String emergencyProfile = '/emergency-profile';

  // Emergency & SOS Routes
  static const String sosTriggered = '/sos-triggered';
  static const String accidentDetected = '/accident-detected';
  static const String emergencyBeacon = '/emergency-beacon';

  // Alerts & Safety Routes
  static const String alertsCenter = '/alerts-center';
  static const String safetyMap = '/safety-map';
  static const String communityAlert = '/community-alert';
  static const String preventiveSafetyAlerts = '/preventive-safety-alerts';

  // Educational Routes
  static const String cprGuide = '/cpr-guide';
  static const String firstAid = '/first-aid';
  static const String safetyTutorial = '/safety-tutorial';

  // Directory & History Routes
  static const String responderDirectory = '/responder-directory';
  static const String eventHistory = '/event-history';

  // Settings & Advanced Routes
  static const String advancedSensors = '/advanced-sensors';
  static const String connectivityStatus = '/connectivity-status';
  static const String safetySettings = '/safety-settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      entry: (context) => const GuardianScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      forgetPassword: (context) => const RecoverAccessScreen(),
      otp: (context) => const OTPVerificationScreen(),
      resetPassword: (context) => const ResetPasswordScreen(),
      permissions: (context) => const SafetyPermissionsScreen(),
      success: (context) => const AccountCreatedScreen(),
      dashboard: (context) => const EmergencyDashboardScreen(),
      emergencyProfile: (context) => const EmergencyProfileScreen(),
      sosTriggered: (context) => const SOSTriggeredScreen(),
      accidentDetected: (context) => const AccidentDetectedScreen(),
      emergencyBeacon: (context) => const EmergencyBeaconScreen(),
      alertsCenter: (context) => const AlertsCenterPage(),
      safetyMap: (context) => const SafetyMapScreen(),
      communityAlert: (context) => const CommunityAlertsScreen(),
      preventiveSafetyAlerts: (context) => const PreventiveSafetyAlertsScreen(),
      cprGuide: (context) => const CPRGuideScreen(),
      firstAid: (context) => const FirstAidGuideScreen(),
      safetyTutorial: (context) => const SafetyTutorialsPage(),
      responderDirectory: (context) => const ResponderDirectoryPage(),
      eventHistory: (context) => const EventHistoryScreen(),
      advancedSensors: (context) => const AdvancedSensorsPage(),
      connectivityStatus: (context) => const ConnectivityStatusScreen(),
      safetySettings: (context) => const SafetySettingsScreen(),
    };
  }
}
