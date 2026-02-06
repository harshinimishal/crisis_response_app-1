<<<<<<< HEAD
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Services
import '../models/user_models.dart';
import '../services/cloudinary_service.dart';
import '../services/settings_service.dart';
import '../services/profile_features_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final SettingsService _settingsService = SettingsService();
  final DummyFeaturesService _dummyService = DummyFeaturesService();

  UserModel? _user;
  bool _isLoading = true;
  late TabController _tabController;

  // Edit Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _medicalController = TextEditingController();

  // Dummy Feature States
  String _satelliteStatus = 'Offline';
  String _droneStatus = 'Standby';
  String _aiAnalysis = 'Pending Scan';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      // Handle guest or redirect
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data()!, uid);
        _nameController.text = _user!.name;
        _phoneController.text = _user!.phone;
        _medicalController.text = _user!.medicalInfo;
      } else {
        // Create default user struct if not exists
        _user = UserModel(
            uid: uid,
            name: '',
            phone: '',
            email: _auth.currentUser!.email ?? '',
            medicalInfo: '',
            emergencyContacts: [],
            settings: {'themeMode': false, 'enableNotifications': true},
            privacy: {'shareLocation': true, 'shareBluetooth': true, 'shareMedicalInfo': true, 'shareNotifications': true}
        );
      }
    } catch (e) {
      print('Error fetching user: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;
    
    setState(() => _isLoading = true);
    
    final updatedUser = _user!.copyWith(
      name: _nameController.text,
      phone: _phoneController.text,
      medicalInfo: _medicalController.text,
    );

    try {
      await _firestore.collection('users').doc(_user!.uid).set(updatedUser.toMap(), SetOptions(merge: true));
      _user = updatedUser;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Saved!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() => _isLoading = true);
      final url = await _cloudinaryService.uploadImage(File(pickedFile.path));
      
      if (url != null) {
        // Update in Firestore immediately
        await _firestore.collection('users').doc(_user!.uid).update({'profileImageUrl': url});
        setState(() {
          _user = _user!.copyWith(profileImageUrl: url);
        });
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importContacts() async {
    // Stub for native contact picker
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Native Contacts... (Stub)')));
  }

  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFF5252))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('User Profile & Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF5252),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          tabs: const [
            Tab(text: 'PROFILE'),
            Tab(text: 'MEDICAL ID'),
            Tab(text: 'PRIVACY'),
            Tab(text: 'ADVANCED'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildMedicalIdTab(),
          _buildPrivacyTab(),
          _buildAdvancedTab(),
=======
import 'package:flutter/material.dart';

class EmergencyProfileScreen extends StatefulWidget {
  const EmergencyProfileScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyProfileScreen> createState() => _EmergencyProfileScreenState();
}

class _EmergencyProfileScreenState extends State<EmergencyProfileScreen> {
  bool showOnLockScreen = true;
  bool respondersOnly = true;
  bool locationSharing = false;

  final List<Map<String, dynamic>> emergencyContacts = [
    {
      'name': 'Jane Doe',
      'role': 'Spouse',
      'type': 'Primary',
      'icon': Icons.person,
    },
    {
      'name': 'Dr. Michael Smith',
      'role': 'Primary Physician',
      'type': '',
      'icon': Icons.medical_services,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2D2D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2D2D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Emergency Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Profile Avatar and Info
            _buildProfileHeader(),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medical ID Section
                  _buildMedicalIDSection(),
                  const SizedBox(height: 32),

                  // Emergency Contacts Section
                  _buildEmergencyContactsSection(),
                  const SizedBox(height: 32),

                  // Privacy Settings Section
                  _buildPrivacySettingsSection(),
                  const SizedBox(height: 24),

                  // Export Button
                  _buildExportButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00E5CC), width: 3),
              ),
              child: ClipOval(
                child: Container(
                  color: const Color(0xFF5A7F7F),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5CC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'VERIFIED',
                  style: TextStyle(
                    color: Color(0xFF0D2D2D),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'John Doe',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '34 years old • Male',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF143838),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.circle, color: Color(0xFF00E5CC), size: 8),
              SizedBox(width: 8),
              Text(
                'Profile Active',
                style: TextStyle(
                  color: Color(0xFF00E5CC),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalIDSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF143838),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F4D4D), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.local_hospital, color: Color(0xFF00E5CC), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Medical ID',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Color(0xFF00E5CC),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F4D4D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: const [
                    Text(
                      'BLOOD',
                      style: TextStyle(
                        color: Color(0xFF00E5CC),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'O+',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ALLERGIES',
                      style: TextStyle(
                        color: Color(0xFF00E5CC),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Penicillin, Peanuts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'MEDICAL CONDITIONS',
                      style: TextStyle(
                        color: Color(0xFF00E5CC),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'None Reported',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.white38, size: 16),
              SizedBox(width: 8),
              Text(
                'Last updated on Oct 24, 2023',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GestureDetector(
            onTap: _uploadImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade900,
                  backgroundImage: _user?.profileImageUrl != null
                      ? NetworkImage(_user!.profileImageUrl!)
                      : null,
                  child: _user?.profileImageUrl == null
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFFFF5252), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
=======
  Widget _buildEmergencyContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.contacts, color: Color(0xFF00E5CC), size: 20),
                SizedBox(width: 8),
                Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Manage',
                style: TextStyle(
                  color: Color(0xFF00E5CC),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...emergencyContacts.map((contact) => _buildContactCard(contact)),
      ],
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF143838),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F4D4D), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF1F4D4D),
              shape: BoxShape.circle,
            ),
            child: Icon(
              contact['icon'],
              color: const Color(0xFF00E5CC),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${contact['role']}${contact['type'].isNotEmpty ? ' • ${contact['type']}' : ''}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
                  ),
                ),
              ],
            ),
          ),
<<<<<<< HEAD
          const SizedBox(height: 30),
          
          _buildTextField('Full Name', _nameController, Icons.person),
          const SizedBox(height: 16),
          _buildTextField('Phone Number', _phoneController, Icons.phone),
          const SizedBox(height: 16),
          _buildTextField('Medical Conditions', _medicalController, Icons.medical_services, maxLines: 3),
          
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('SAVE PROFILE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 30),
          
          const Align(alignment: Alignment.centerLeft, child: Text("Emergency Contacts", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),
          ListTile(
            onTap: _importContacts,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.contacts, color: Colors.blue),
            ),
            title: const Text('Import from Phone Contacts', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
          if (_user != null)
            ..._user!.emergencyContacts.map((c) => ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xFF2A2A2A), child: Icon(Icons.person, color: Colors.white)),
              title: Text(c['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
              subtitle: Text(c['phone'] ?? '', style: const TextStyle(color: Colors.grey)),
            )),
=======
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF00E5CC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone,
              color: Color(0xFF0D2D2D),
              size: 20,
            ),
          ),
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildMedicalIdTab() {
    final qrData = "ID:${_user?.uid ?? 'N/A'}\nMED:${_user?.medicalInfo ?? 'None'}";

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('MEDICAL ID', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 2)),
                    Icon(Icons.medical_information, color: Color(0xFFFF5252), size: 30),
                  ],
                ),
                const SizedBox(height: 20),
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 10),
                Text('Scan by First Responders', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download, color: Color(0xFFFF5252)),
            label: const Text('EXPORT DATA (JSON)', style: TextStyle(color: Color(0xFFFF5252))),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF5252)),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
          ),
          const SizedBox(height: 20),
=======
  Widget _buildPrivacySettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.remove_red_eye, color: Color(0xFF00E5CC), size: 20),
            SizedBox(width: 8),
            Text(
              'Privacy Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPrivacyToggle(
          title: 'Show on Lock Screen',
          subtitle: 'Allow access without unlocking',
          value: showOnLockScreen,
          onChanged: (value) {
            setState(() {
              showOnLockScreen = value;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildPrivacyToggle(
          title: 'Responders Only',
          subtitle: 'Only verified first responders can see info',
          value: respondersOnly,
          onChanged: (value) {
            setState(() {
              respondersOnly = value;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildPrivacyToggle(
          title: 'Location Sharing',
          subtitle: 'Share current coordinates during SOS',
          value: locationSharing,
          onChanged: (value) {
            setState(() {
              locationSharing = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPrivacyToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF143838),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F4D4D), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00E5CC),
            activeTrackColor: const Color(0xFF1F4D4D),
          ),
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildPrivacyTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Permisisons Health'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPermissionIcon(Icons.location_on, 'Location', true),
              _buildPermissionIcon(Icons.bluetooth, 'Bluetooth', true),
              _buildPermissionIcon(Icons.notifications, 'Notif', true),
              _buildPermissionIcon(Icons.contacts, 'Contacts', false),
            ],
          ),
        ),
        const SizedBox(height: 30),
        _buildSectionHeader('Privacy Controls'),
        _buildPrivacyToggle('Share Location', 'shareLocation'),
        _buildPrivacyToggle('Bluetooth Sharing', 'shareBluetooth'),
        _buildPrivacyToggle('Share Medical Info', 'shareMedicalInfo'),
        _buildPrivacyToggle('Allow Notifications', 'shareNotifications'),
      ],
    );
  }

  Widget _buildAdvancedTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Futuristic Capabilities (Dummy)'),
        const SizedBox(height: 10),
        _buildFeatureCard(
          'Satellite Uplink',
          _satelliteStatus,
          Icons.satellite_alt,
          Colors.blue,
          onTap: () async {
            setState(() => _satelliteStatus = 'Connecting...');
            await for (final status in _dummyService.satelliteStatus) {
              if (mounted) setState(() => _satelliteStatus = status);
            }
          },
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          'Drone Dispatch',
          _droneStatus,
          Icons.airplanemode_active,
          Colors.orange,
          onTap: () async {
            setState(() => _droneStatus = 'Checking airspace...');
            final res = await _dummyService.checkDroneAvailability(0,0);
            if (mounted) setState(() => _droneStatus = res['message']);
          },
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          'AI Crisis Analysis',
          _aiAnalysis,
          Icons.psychology,
          Colors.purple,
          onTap: () async {
            setState(() => _aiAnalysis = 'Analyzing biometric patterns...');
            final res = await _dummyService.runAITriage(_medicalController.text);
            if (mounted) setState(() => _aiAnalysis = res);
          },
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPrivacyToggle(String title, String key) {
    if (_user == null) return const SizedBox();
    bool value = _user!.privacy[key] ?? false;
    return SwitchListTile(
      value: value,
      activeColor: const Color(0xFFFF5252),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onChanged: (v) {
        setState(() {
          _user!.privacy[key] = v;
        });
        _settingsService.updatePrivacySetting(key, v);
      },
    );
  }

  Widget _buildPermissionIcon(IconData icon, String label, bool granted) {
    return Column(
      children: [
        Icon(icon, color: granted ? Colors.green : Colors.red),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: granted ? Colors.green : Colors.red, fontSize: 10)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildFeatureCard(String title, String status, IconData icon, Color color, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(status, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.play_circle_fill, color: color.withOpacity(0.5)),
          ],
=======
  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.file_download, size: 20),
        label: const Text(
          'Export for Emergency',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5CC),
          foregroundColor: const Color(0xFF0D2D2D),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
