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
        ],
      ),
    );
  }

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
                  ),
                ),
              ],
            ),
          ),
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
        ],
      ),
    );
  }

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
        ],
      ),
    );
  }

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
        ),
      ),
    );
  }
}
