import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:permission_handler/permission_handler.dart'; // Assuming this exists or will be added

class SettingsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updatePrivacySetting(String key, bool value) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Update Local (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('privacy_$key', value);

    // 2. Sync to Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'privacy.$key': value,
    });
  }

  Future<void> updateTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('theme_dark', isDark);
    
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'settings.themeMode': isDark,
      });
    }
  }

  // Placeholder for Permission checking if package not available
  // Real implementation requires 'permission_handler' package
  Future<Map<String, String>> checkPermissions() async {
    // Mock result for now to avoid compilation errors if package missing
    return {
      'Location': 'Granted',
      'Start Contacts': 'Denied', // Native contacts
      'Bluetooth': 'Granted',
      'Notifications': 'Granted',
    };
  }
}
