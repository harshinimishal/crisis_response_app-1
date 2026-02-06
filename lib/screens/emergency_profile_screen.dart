import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

// Services
import '../models/user_models.dart';
import '../services/cloudinary_service.dart';
import '../services/settings_service.dart';
import '../services/profile_features_service.dart';
import 'safety_settings_screen.dart';

class EmergencyProfileScreen extends StatefulWidget {
  final String? userId;
  const EmergencyProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<EmergencyProfileScreen> createState() => _EmergencyProfileScreenState();
}

class _EmergencyProfileScreenState extends State<EmergencyProfileScreen> 
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final SettingsService _settingsService = SettingsService();
  final DummyFeaturesService _dummyService = DummyFeaturesService();

  UserModel? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  late TabController _tabController;
  late AnimationController _animationController;

  // Edit Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  // Profile Fields
  String _gender = 'Not Specified';
  DateTime? _dob;
  int? _age;
  
  // Emergency Contacts
  List<Map<String, dynamic>> _contactsList = [];
  
  // Legal Docs
  List<String> _legalDocs = [];

  // Dummy Feature States
  String _satelliteStatus = 'Offline';
  String _droneStatus = 'Standby';
  String _aiAnalysis = 'Pending Scan';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fetchUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String get _targetUid => widget.userId ?? _auth.currentUser?.uid ?? '';

  Future<void> _fetchUserData() async {
    if (_targetUid.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      setState(() => _isLoading = true);
      
      // 1. Fetch User Doc
      final doc = await _firestore.collection('users').doc(_targetUid).get();
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data()!, _targetUid);
        _nameController.text = _user!.name;
        _phoneController.text = _user!.phone;
        _emailController.text = _user!.email;
        _gender = _user!.gender;
        _dob = _user!.dob;
        _age = _user!.age;
        _legalDocs = List.from(_user!.legalDocuments);
      } else {
        _user = UserModel(
          uid: _targetUid,
          name: '',
          phone: '',
          email: _auth.currentUser?.email ?? '',
          settings: {'themeMode': false, 'enableNotifications': true},
          privacy: {
            'shareLocation': true,
            'shareBluetooth': true,
            'shareNotifications': true,
          },
        );
      }

      // 2. Fetch Emergency Contacts Subcollection
      final contactsSnapshot = await _firestore
          .collection('users')
          .doc(_targetUid)
          .collection('emergency_contacts')
          .orderBy('addedAt', descending: true)
          .get();
      
      _contactsList = contactsSnapshot.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();

      // 3. Fetch Permissions Status
      await _fetchPermissionsStatus();

    } catch (e) {
      print('Error fetching user: $e');
      _showSnackBar('Error loading data: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _animationController.forward();
      }
    }
  }

  Future<void> _fetchPermissionsStatus() async {
    try {
      final permissions = await _settingsService.checkPermissions();
      
      final permissionsMap = <String, bool>{
        'location': permissions['Location'] == 'Granted',
        'bluetooth': permissions['Bluetooth'] == 'Granted',
        'notification': permissions['Notifications'] == 'Granted',
        'contacts': permissions['Start Contacts'] == 'Granted',
        'microphone': permissions['Microphone'] == 'Granted',
      };

      await _firestore.collection('users').doc(_targetUid).update({
        'permissionsGranted': permissionsMap,
      });

      if (mounted) {
        setState(() {
          _user = _user?.copyWith(permissionsGranted: permissionsMap);
        });
      }
    } catch (e) {
      print('Error fetching permissions: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;
    
    // Validation
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Name is required', isError: true);
      return;
    }
    
    if (_phoneController.text.trim().isEmpty) {
      _showSnackBar('Phone is required', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    
    // Calculate Age if DOB is present
    if (_dob != null) {
      final now = DateTime.now();
      _age = now.year - _dob!.year;
      if (now.month < _dob!.month || 
          (now.month == _dob!.month && now.day < _dob!.day)) {
        _age = _age! - 1;
      }
    }

    final updatedUser = _user!.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      gender: _gender,
      dob: _dob,
      age: _age,
      legalDocuments: _legalDocs,
    );

    try {
      await _firestore.collection('users').doc(_targetUid).set(
        updatedUser.toMap(),
        SetOptions(merge: true),
      );
      
      setState(() {
        _user = updatedUser;
        _isEditing = false;
      });
      
      _showSnackBar('Profile saved successfully!');
    } catch (e) {
      print('Error saving profile: $e');
      _showSnackBar('Failed to save: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadImage({bool isLegalDoc = false}) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      
      if (pickedFile != null) {
        setState(() => _isLoading = true);
        
        final url = await _cloudinaryService.uploadFile(File(pickedFile.path));
        
        if (url != null) {
          if (isLegalDoc) {
            await _firestore.collection('users').doc(_targetUid).update({
              'legalDocuments': FieldValue.arrayUnion([url])
            });
            setState(() => _legalDocs.add(url));
            _showSnackBar('Document uploaded successfully!');
          } else {
            await _firestore.collection('users').doc(_targetUid).update({
              'profileImageUrl': url
            });
            setState(() {
              _user = _user!.copyWith(profileImageUrl: url);
            });
            _showSnackBar('Profile image updated!');
          }
        } else {
          _showSnackBar('Upload failed', isError: true);
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
      _showSnackBar('Upload error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteLegalDoc(String url) async {
    try {
      setState(() => _isLoading = true);
      
      await _firestore.collection('users').doc(_targetUid).update({
        'legalDocuments': FieldValue.arrayRemove([url])
      });
      
      setState(() => _legalDocs.remove(url));
      _showSnackBar('Document deleted');
    } catch (e) {
      _showSnackBar('Failed to delete: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- Emergency Contacts Logic ---

  Future<void> _addEmergencyContact(String name, String phone, String relation) async {
    if (name.trim().isEmpty || phone.trim().isEmpty) {
      _showSnackBar('Name and phone are required', isError: true);
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final newContact = {
        'name': name.trim(),
        'phone': phone.trim(),
        'relation': relation.trim().isEmpty ? 'Other' : relation.trim(),
        'addedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore
          .collection('users')
          .doc(_targetUid)
          .collection('emergency_contacts')
          .add(newContact);
      
      await _fetchUserData();
      _showSnackBar('Contact added successfully!');
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      print('Error adding contact: $e');
      _showSnackBar('Failed to add contact: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateEmergencyContact(
    String contactId,
    String name,
    String phone,
    String relation,
  ) async {
    if (name.trim().isEmpty || phone.trim().isEmpty) {
      _showSnackBar('Name and phone are required', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _firestore
          .collection('users')
          .doc(_targetUid)
          .collection('emergency_contacts')
          .doc(contactId)
          .update({
        'name': name.trim(),
        'phone': phone.trim(),
        'relation': relation.trim().isEmpty ? 'Other' : relation.trim(),
      });
      
      await _fetchUserData();
      _showSnackBar('Contact updated!');
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Failed to update: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEmergencyContact(String contactId) async {
    final confirmed = await _showConfirmDialog(
      'Delete Contact',
      'Are you sure you want to delete this emergency contact?',
    );
    
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await _firestore
          .collection('users')
          .doc(_targetUid)
          .collection('emergency_contacts')
          .doc(contactId)
          .delete();
          
      setState(() {
        _contactsList.removeWhere((c) => c['id'] == contactId);
      });
      
      _showSnackBar('Contact deleted');
    } catch (e) {
      _showSnackBar('Failed to delete: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddContactDialog() {
    final nController = TextEditingController();
    final pController = TextEditingController();
    final rController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Add Emergency Contact',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField('Name *', nController, Icons.person),
              const SizedBox(height: 12),
              _buildDialogTextField('Phone *', pController, Icons.phone),
              const SizedBox(height: 12),
              _buildDialogTextField('Relation', rController, Icons.people),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => _addEmergencyContact(
              nController.text,
              pController.text,
              rController.text,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditContactDialog(Map<String, dynamic> contact) {
    final nController = TextEditingController(text: contact['name']);
    final pController = TextEditingController(text: contact['phone']);
    final rController = TextEditingController(text: contact['relation'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Emergency Contact',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField('Name *', nController, Icons.person),
              const SizedBox(height: 12),
              _buildDialogTextField('Phone *', pController, Icons.phone),
              const SizedBox(height: 12),
              _buildDialogTextField('Relation', rController, Icons.people),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => _updateEmergencyContact(
              contact['id'],
              nController.text,
              pController.text,
              rController.text,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Update', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromContacts() async {
    _showSnackBar('Contact import feature coming soon!');
    // TODO: Implement flutter_contacts integration
  }

  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: _isLoading && _user == null
          ? _buildLoadingState()
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      _buildTabBar(),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProfileTab(),
                      _buildContactsTab(),
                      _buildPrivacyTab(),
                      _buildAdvancedTab(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: _isLoading
          ? null
          : _buildFloatingActionButton(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFFFF5252),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading Profile...',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0A),
      elevation: 0,
      title: const Text(
        'Emergency Profile',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings, color: Color(0xFFFF5252)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SafetySettingsScreen(),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _uploadImage(isLegalDoc: false),
            child: Hero(
              tag: 'profile_image',
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5252).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFF1A1A1A),
                      backgroundImage: _user?.profileImageUrl != null
                          ? NetworkImage(_user!.profileImageUrl!)
                          : null,
                      child: _user?.profileImageUrl == null
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5252), Color(0xFFFF8A80)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF5252).withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _user?.name ?? 'No Name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user?.email ?? '',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          if (_age != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.3)),
              ),
              child: Text(
                '$_age years • $_gender',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5252), Color(0xFFFF8A80)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        isScrollable: true,
        tabs: const [
          Tab(text: 'PROFILE'),
          Tab(text: 'CONTACTS'),
          Tab(text: 'PRIVACY'),
          Tab(text: 'ADVANCED'),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            'Personal Information',
            Icons.person_outline,
            [
              _buildTextField('Full Name', _nameController, Icons.person, enabled: _isEditing),
              const SizedBox(height: 16),
              _buildTextField('Phone (Primary)', _phoneController, Icons.phone, enabled: _isEditing),
              const SizedBox(height: 16),
              _buildTextField('Email', _emailController, Icons.email, enabled: false),
              const SizedBox(height: 16),
              _buildGenderDropdown(),
              const SizedBox(height: 16),
              _buildDOBPicker(),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            'Legal Documents',
            Icons.description_outlined,
            [
              _buildLegalDocsGrid(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _importFromContacts,
                  icon: const Icon(Icons.perm_contact_calendar, size: 20),
                  label: const Text('Import'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A2A2A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5252), Color(0xFFFF8A80)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5252).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showAddContactDialog,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _contactsList.isEmpty
              ? _buildEmptyState(
                  'No Emergency Contacts',
                  'Add contacts who should be notified in emergencies',
                  Icons.contacts_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _contactsList.length,
                  itemBuilder: (ctx, index) => _buildContactCard(_contactsList[index], index),
                ),
        ),
      ],
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFF5252).withOpacity(0.2),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showEditContactDialog(contact),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF5252).withOpacity(0.3),
                          const Color(0xFFFF8A80).withOpacity(0.3),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      contact['name'].toString().substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
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
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contact['phone'],
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            contact['relation'] ?? 'Other',
                            style: const TextStyle(
                              color: Color(0xFFFF8A80),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteEmergencyContact(contact['id']),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionCard(
          'Permissions Status',
          Icons.security_outlined,
          [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildPermissionIcon(
                    Icons.location_on,
                    'Location',
                    _user?.permissionsGranted['location'] ?? false,
                  ),
                  _buildPermissionIcon(
                    Icons.bluetooth,
                    'Bluetooth',
                    _user?.permissionsGranted['bluetooth'] ?? false,
                  ),
                  _buildPermissionIcon(
                    Icons.notifications,
                    'Notifications',
                    _user?.permissionsGranted['notification'] ?? false,
                  ),
                  _buildPermissionIcon(
                    Icons.contacts,
                    'Contacts',
                    _user?.permissionsGranted['contacts'] ?? false,
                  ),
                  _buildPermissionIcon(
                    Icons.mic,
                    'Microphone',
                    _user?.permissionsGranted['microphone'] ?? false,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildSectionCard(
          'Privacy Controls',
          Icons.privacy_tip_outlined,
          _user != null
              ? [
                  _buildPrivacyToggle('Share Location', 'shareLocation'),
                  const Divider(color: Color(0xFF2A2A2A), height: 1),
                  _buildPrivacyToggle('Share Bluetooth', 'shareBluetooth'),
                  const Divider(color: Color(0xFF2A2A2A), height: 1),
                  _buildPrivacyToggle(
                    'Share Notifications',
                    'shareNotifications',
                  ),
                ]
              : [],
        ),
      ],
    );
  }

  Widget _buildAdvancedTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('Futuristic Capabilities'),
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
            final res = await _dummyService.checkDroneAvailability(0, 0);
            if (mounted) {
              setState(() => _droneStatus = res['message']);
            }
          },
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          'AI Medical Triage',
          _aiAnalysis,
          Icons.psychology,
          Colors.purple,
          onTap: () async {
            setState(() => _aiAnalysis = 'Analyzing...');
            final analysis = await _dummyService.runAITriage(
              'Age: $_age, Gender: $_gender',
            );
            if (mounted) setState(() => _aiAnalysis = analysis);
          },
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF5252).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF5252).withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFFF5252)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? Colors.white : Colors.grey,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFFF5252)),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: enabled ? const Color(0xFF0A0A0A) : const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFFF5252).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5252), width: 2),
        ),
      ),
    );
  }

  Widget _buildDialogTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFFF5252)),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF0A0A0A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5252)),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _isEditing ? const Color(0xFF0A0A0A) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isEditing
              ? const Color(0xFFFF5252).withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _gender,
          dropdownColor: const Color(0xFF1A1A1A),
          style: TextStyle(
            color: _isEditing ? Colors.white : Colors.grey,
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: _isEditing ? const Color(0xFFFF5252) : Colors.grey,
          ),
          isExpanded: true,
          items: ['Not Specified', 'Male', 'Female', 'Other']
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  const Icon(Icons.person, size: 20, color: Color(0xFFFF5252)),
                  const SizedBox(width: 12),
                  Text(value),
                ],
              ),
            );
          }).toList(),
          onChanged: _isEditing
              ? (newValue) => setState(() => _gender = newValue!)
              : null,
        ),
      ),
    );
  }

  Widget _buildDOBPicker() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _isEditing
                ? () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dob ?? DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFFFF5252),
                              onPrimary: Colors.white,
                              surface: Color(0xFF1A1A1A),
                              onSurface: Colors.white,
                            ),
                            dialogBackgroundColor: const Color(0xFF0A0A0A),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) setState(() => _dob = picked);
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isEditing ? const Color(0xFF0A0A0A) : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isEditing
                      ? const Color(0xFFFF5252).withOpacity(0.3)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: _isEditing ? const Color(0xFFFF5252) : Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _dob == null
                        ? 'Select Date of Birth'
                        : DateFormat('MMM dd, yyyy').format(_dob!),
                    style: TextStyle(
                      color: _isEditing ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF5252).withOpacity(0.3),
                const Color(0xFFFF8A80).withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Age: ${_age ?? "?"}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalDocsGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ..._legalDocs.asMap().entries.map((entry) {
          final index = entry.key;
          final url = entry.value;
          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: GestureDetector(
              onTap: () => launchUrl(Uri.parse(url)),
              onLongPress: () => _deleteLegalDoc(url),
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(url),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5252).withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _deleteLegalDoc(url),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (_isEditing)
          GestureDetector(
            onTap: () => _uploadImage(isLegalDoc: true),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFF5252).withOpacity(0.5),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Icon(
                Icons.add_photo_alternate,
                color: Color(0xFFFF5252),
                size: 40,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPrivacyToggle(String title, String key) {
    final value = _user!.privacy[key] ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFFFF5252),
            onChanged: (v) {
              setState(() {
                _user!.privacy[key] = v;
              });
              _settingsService.updatePrivacySetting(key, v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionIcon(IconData icon, String label, bool granted) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: granted
                ? const Color(0xFF4CAF50).withOpacity(0.2)
                : const Color(0xFFFF5252).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: granted ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: granted ? const Color(0xFF4CAF50) : const Color(0xFFFF5252),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String status,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    status,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_fill, color: color.withOpacity(0.5), size: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFF5252).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF5252),
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    return _tabController.index == 0
        ? FloatingActionButton.extended(
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
            backgroundColor: const Color(0xFFFF5252),
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            label: Text(
              _isEditing ? 'SAVE' : 'EDIT',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        : null;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}