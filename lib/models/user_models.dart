import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String? profileImageUrl;
  final String gender;
  final DateTime? dob;
  final int? age;
  
  // Medical Information
  final String? bloodType;
  final List<String> allergies;
  final List<String> medications;
  final String? medicalNotes;
  
  // Emergency Contacts (cached locally, managed via subcollection)
  final List<Map<String, dynamic>> emergencyContacts;
  
  // Legal Documents
  final List<String> legalDocuments;
  
  // Settings
  final Map<String, bool> settings;
  final Map<String, bool> privacy;
  final Map<String, bool> permissionsGranted;
  final Map<String, dynamic> safetySettings;
  
  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    this.profileImageUrl,
    this.gender = 'Not Specified',
    this.dob,
    this.age,
    this.bloodType,
    this.allergies = const [],
    this.medications = const [],
    this.medicalNotes,
    this.emergencyContacts = const [],
    this.legalDocuments = const [],
    required this.settings,
    required this.privacy,
    this.permissionsGranted = const {},
    this.safetySettings = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    DateTime? parsedDob;
    if (map['dob'] != null) {
      if (map['dob'] is Timestamp) {
        parsedDob = (map['dob'] as Timestamp).toDate();
      } else if (map['dob'] is String) {
        try {
          parsedDob = DateTime.parse(map['dob']);
        } catch (_) {}
      }
    }

    DateTime? parsedCreatedAt;
    if (map['createdAt'] != null && map['createdAt'] is Timestamp) {
      parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
    }

    DateTime? parsedUpdatedAt;
    if (map['updatedAt'] != null && map['updatedAt'] is Timestamp) {
      parsedUpdatedAt = (map['updatedAt'] as Timestamp).toDate();
    }

    return UserModel(
      uid: uid,
      name: map['name'] ?? map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      gender: map['gender'] ?? 'Not Specified',
      dob: parsedDob,
      age: map['age'],
      bloodType: map['bloodType'],
      allergies: List<String>.from(map['allergies'] ?? []),
      medications: List<String>.from(map['medications'] ?? []),
      medicalNotes: map['medicalNotes'],
      emergencyContacts: List<Map<String, dynamic>>.from(
        map['emergencyContacts'] ?? [],
      ),
      legalDocuments: List<String>.from(map['legalDocuments'] ?? []),
      settings: Map<String, bool>.from(map['settings'] ?? {
        'themeMode': false,
        'enableNotifications': true,
      }),
      privacy: Map<String, bool>.from(map['privacy'] ?? {
        'shareLocation': true,
        'shareBluetooth': true,
        'shareNotifications': true,
      }),
      permissionsGranted: Map<String, bool>.from(
        map['permissionsGranted'] ?? {},
      ),
      safetySettings: Map<String, dynamic>.from(map['safetySettings'] ?? {
        'emergencyAlerts': true,
        'locationTracking': true,
        'autoCallEmergency': false,
        'shareHealthData': true,
        'biometricLock': false,
        'crashDetection': true,
        'fallDetection': true,
        'sosCountdown': 5,
      }),
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'gender': gender,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'age': age,
      'bloodType': bloodType,
      'allergies': allergies,
      'medications': medications,
      'medicalNotes': medicalNotes,
      'emergencyContacts': emergencyContacts,
      'legalDocuments': legalDocuments,
      'settings': settings,
      'privacy': privacy,
      'permissionsGranted': permissionsGranted,
      'safetySettings': safetySettings,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? profileImageUrl,
    String? gender,
    DateTime? dob,
    int? age,
    String? bloodType,
    List<String>? allergies,
    List<String>? medications,
    String? medicalNotes,
    List<Map<String, dynamic>>? emergencyContacts,
    List<String>? legalDocuments,
    Map<String, bool>? settings,
    Map<String, bool>? privacy,
    Map<String, bool>? permissionsGranted,
    Map<String, dynamic>? safetySettings,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      age: age ?? this.age,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      legalDocuments: legalDocuments ?? this.legalDocuments,
      settings: settings ?? this.settings,
      privacy: privacy ?? this.privacy,
      permissionsGranted: permissionsGranted ?? this.permissionsGranted,
      safetySettings: safetySettings ?? this.safetySettings,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Check if user profile is complete
  bool get isProfileComplete {
    return name.isNotEmpty &&
        phone.isNotEmpty &&
        email.isNotEmpty &&
        gender != 'Not Specified' &&
        dob != null;
  }

  /// Get display name (first name only)
  String get firstName {
    return name.split(' ').first;
  }

  /// Get age string
  String get ageString {
    if (age == null) return 'Unknown';
    return '$age years';
  }

  /// Check if emergency contacts are configured
  bool get hasEmergencyContacts {
    return emergencyContacts.isNotEmpty;
  }
}