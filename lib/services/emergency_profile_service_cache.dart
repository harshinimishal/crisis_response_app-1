import 'package:hive/hive.dart';

class EmergencyProfileCacheService {
  static const String boxName = 'emergency_profile_cache';

  /// Save profile locally
  static Future<void> cacheEmergencyProfile(
      Map<String, dynamic> profile) async {
    final box = Hive.box(boxName);
    await box.put('profile', profile);
    await box.put('lastUpdated', DateTime.now().toIso8601String());
  }

  /// Load cached profile
  static Future<Map<String, dynamic>?> loadCachedProfile() async {
    final box = Hive.box(boxName);
    return box.get('profile');
  }

  static String? lastUpdated() {
    final box = Hive.box(boxName);
    return box.get('lastUpdated');
  }
}
