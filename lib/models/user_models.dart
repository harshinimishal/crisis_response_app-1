class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String? profileImageUrl;
  final String medicalInfo;
  final List<Map<String, dynamic>> emergencyContacts;
  final Map<String, bool> settings; // theme, notifications
  final Map<String, bool> privacy; // location, bluetooth, medical, notificationsShare

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    this.profileImageUrl,
    required this.medicalInfo,
    required this.emergencyContacts,
    required this.settings,
    required this.privacy,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      medicalInfo: map['medicalInfo'] ?? '',
      emergencyContacts: List<Map<String, dynamic>>.from(map['emergencyContacts'] ?? []),
      settings: Map<String, bool>.from(map['settings'] ?? {
        'themeMode': false, // false = light/system, true = dark (simplified)
        'enableNotifications': true,
      }),
      privacy: Map<String, bool>.from(map['privacy'] ?? {
        'shareLocation': true,
        'shareBluetooth': true,
        'shareMedicalInfo': true,
        'shareNotifications': true,
      }),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'medicalInfo': medicalInfo,
      'emergencyContacts': emergencyContacts,
      'settings': settings,
      'privacy': privacy,
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? medicalInfo,
    String? profileImageUrl,
    List<Map<String, dynamic>>? emergencyContacts,
    Map<String, bool>? settings,
    Map<String, bool>? privacy,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      settings: settings ?? this.settings,
      privacy: privacy ?? this.privacy,
    );
  }
}
