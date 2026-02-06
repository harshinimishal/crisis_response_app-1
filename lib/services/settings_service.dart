import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Update a privacy setting both locally and in Firestore
  Future<void> updatePrivacySetting(String key, bool value) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // 1. Update Local (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('privacy_$key', value);

      // 2. Sync to Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'privacy.$key': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating privacy setting: $e');
      rethrow;
    }
  }

  /// Get a privacy setting value
  Future<bool> getPrivacySetting(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('privacy_$key') ?? false;
    } catch (e) {
      print('Error getting privacy setting: $e');
      return false;
    }
  }

  /// Update theme preference
  Future<void> updateTheme(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('theme_dark', isDark);
      
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'settings.themeMode': isDark,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating theme: $e');
      rethrow;
    }
  }

  /// Get theme preference
  Future<bool> getTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('theme_dark') ?? false;
    } catch (e) {
      print('Error getting theme: $e');
      return false;
    }
  }

  /// Update notification setting
  Future<void> updateNotificationSetting(bool enabled) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);
      
      await _firestore.collection('users').doc(user.uid).update({
        'settings.enableNotifications': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating notification setting: $e');
      rethrow;
    }
  }

  /// Check all permissions status
  /// This is a placeholder - implement with permission_handler package
  Future<Map<String, String>> checkPermissions() async {

    final locationStatus = await Permission.location.status;
    final contactsStatus = await Permission.contacts.status;
    final bluetoothStatus = await Permission.bluetooth.status;
    final notificationStatus = await Permission.notification.status;
    final microphoneStatus = await Permission.microphone.status;
    
    return {
      'Location': locationStatus.isGranted ? 'Granted' : 'Denied',
      'Contacts': contactsStatus.isGranted ? 'Granted' : 'Denied',
      'Bluetooth': bluetoothStatus.isGranted ? 'Granted' : 'Denied',
      'Notifications': notificationStatus.isGranted ? 'Granted' : 'Denied',
      'Microphone': microphoneStatus.isGranted ? 'Granted' : 'Denied',
    };
    
    return {
      'Location': 'Granted',
      'Start Contacts': 'Denied',
      'Bluetooth': 'Granted',
      'Notifications': 'Granted',
      'Microphone': 'Denied',
    };
  }

  /// Request specific permission
  Future<bool> requestPermission(String permissionName) async {

    Permission permission;
    
    switch (permissionName.toLowerCase()) {
      case 'location':
        permission = Permission.location;
        break;
      case 'contacts':
        permission = Permission.contacts;
        break;
      case 'bluetooth':
        permission = Permission.bluetooth;
        break;
      case 'notification':
        permission = Permission.notification;
        break;
      case 'microphone':
        permission = Permission.microphone;
        break;
      default:
        return false;
    }
    
    final status = await permission.request();
    return status.isGranted;
    
    return false;
  }

  /// Update safety setting
  Future<void> updateSafetySetting(String key, dynamic value) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'safetySettings.$key': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating safety setting: $e');
      rethrow;
    }
  }

  /// Get all settings for a user
  Future<Map<String, dynamic>> getAllSettings() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        return {
          'settings': data?['settings'] ?? {},
          'privacy': data?['privacy'] ?? {},
          'safetySettings': data?['safetySettings'] ?? {},
        };
      }
      return {};
    } catch (e) {
      print('Error getting settings: $e');
      return {};
    }
  }

  /// Reset all settings to defaults
  Future<void> resetAllSettings() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'settings': {
          'themeMode': false,
          'enableNotifications': true,
        },
        'privacy': {
          'shareLocation': true,
          'shareBluetooth': true,
          'shareNotifications': true,
        },
        'safetySettings': {
          'emergencyAlerts': true,
          'locationTracking': true,
          'autoCallEmergency': false,
          'shareHealthData': true,
          'biometricLock': false,
          'crashDetection': true,
          'fallDetection': true,
          'sosCountdown': 5,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Also clear local preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error resetting settings: $e');
      rethrow;
    }
  }
}