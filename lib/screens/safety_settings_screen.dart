import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/settings_service.dart';
import '../models/user_models.dart';

class SafetySettingsScreen extends StatefulWidget {
  const SafetySettingsScreen({Key? key}) : super(key: key);

  @override
  State<SafetySettingsScreen> createState() => _SafetySettingsScreenState();
}

class _SafetySettingsScreenState extends State<SafetySettingsScreen>
    with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SettingsService _settingsService = SettingsService();

  UserModel? _user;
  bool _isLoading = true;
  late AnimationController _animationController;

  // Settings
  bool _emergencyAlerts = true;
  bool _locationTracking = true;
  bool _autoCallEmergency = false;
  bool _shareHealthData = true;
  bool _biometricLock = false;
  bool _crashDetection = true;
  bool _fallDetection = true;
  int _sosCountdown = 5; // seconds

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get _userId => _auth.currentUser?.uid ?? '';

  Future<void> _loadSettings() async {
    if (_userId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      setState(() => _isLoading = true);

      final doc = await _firestore.collection('users').doc(_userId).get();
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data()!, _userId);

        // Load safety settings
        final safetySettings = doc.data()?['safetySettings'] as Map<String, dynamic>?;
        if (safetySettings != null) {
          setState(() {
            _emergencyAlerts = safetySettings['emergencyAlerts'] ?? true;
            _locationTracking = safetySettings['locationTracking'] ?? true;
            _autoCallEmergency = safetySettings['autoCallEmergency'] ?? false;
            _shareHealthData = safetySettings['shareHealthData'] ?? true;
            _biometricLock = safetySettings['biometricLock'] ?? false;
            _crashDetection = safetySettings['crashDetection'] ?? true;
            _fallDetection = safetySettings['fallDetection'] ?? true;
            _sosCountdown = safetySettings['sosCountdown'] ?? 5;
          });
        }
      }

      _animationController.forward();
    } catch (e) {
      print('Error loading settings: $e');
      _showSnackBar('Error loading settings: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    if (_userId.isEmpty) return;

    try {
      await _firestore.collection('users').doc(_userId).update({
        'safetySettings.$key': value,
      });
    } catch (e) {
      print('Error saving setting: $e');
      _showSnackBar('Failed to save: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          title: const Text('Safety Settings'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF5252)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 24),
                  _buildEmergencySection(),
                  const SizedBox(height: 20),
                  _buildLocationSection(),
                  const SizedBox(height: 20),
                  _buildSecuritySection(),
                  const SizedBox(height: 20),
                  _buildDetectionSection(),
                  const SizedBox(height: 20),
                  _buildSOSCountdownSection(),
                  const SizedBox(height: 32),
                  _buildDangerZone(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0A),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Safety Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF5252).withOpacity(0.3),
                const Color(0xFF0A0A0A),
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.shield_outlined,
              size: 60,
              color: Color(0xFFFF5252),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF5252).withOpacity(0.2),
            const Color(0xFF1A1A1A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF5252).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFFF5252),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Safety Matters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Configure emergency features and safety protocols',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencySection() {
    return _buildSettingsCard(
      'Emergency Features',
      Icons.emergency,
      Colors.red,
      [
        _buildToggleTile(
          'Emergency Alerts',
          'Receive critical emergency notifications',
          Icons.notification_important,
          _emergencyAlerts,
          (value) {
            setState(() => _emergencyAlerts = value);
            _saveSetting('emergencyAlerts', value);
          },
        ),
        const Divider(color: Color(0xFF2A2A2A), height: 1),
        _buildToggleTile(
          'Auto-Call Emergency',
          'Automatically call emergency services when SOS is triggered',
          Icons.phone_in_talk,
          _autoCallEmergency,
          (value) {
            setState(() => _autoCallEmergency = value);
            _saveSetting('autoCallEmergency', value);
          },
        ),
        const Divider(color: Color(0xFF2A2A2A), height: 1),
        _buildToggleTile(
          'Share Health Data',
          'Share medical info with emergency responders',
          Icons.medical_services,
          _shareHealthData,
          (value) {
            setState(() => _shareHealthData = value);
            _saveSetting('shareHealthData', value);
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return _buildSettingsCard(
      'Location & Tracking',
      Icons.location_on,
      Colors.blue,
      [
        _buildToggleTile(
          'Location Tracking',
          'Share real-time location during emergencies',
          Icons.my_location,
          _locationTracking,
          (value) {
            setState(() => _locationTracking = value);
            _saveSetting('locationTracking', value);
            
            if (value) {
              _showSnackBar('Location tracking enabled');
            }
          },
        ),
        if (_locationTracking) ...[
          const Divider(color: Color(0xFF2A2A2A), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Location shared only during active emergencies',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSettingsCard(
      'Security',
      Icons.security,
      Colors.green,
      [
        _buildToggleTile(
          'Biometric Lock',
          'Require fingerprint/face ID for SOS cancellation',
          Icons.fingerprint,
          _biometricLock,
          (value) {
            setState(() => _biometricLock = value);
            _saveSetting('biometricLock', value);
          },
        ),
      ],
    );
  }

  Widget _buildDetectionSection() {
    return _buildSettingsCard(
      'Smart Detection',
      Icons.psychology,
      Colors.purple,
      [
        _buildToggleTile(
          'Crash Detection',
          'Detect vehicle crashes and alert contacts',
          Icons.car_crash,
          _crashDetection,
          (value) {
            setState(() => _crashDetection = value);
            _saveSetting('crashDetection', value);
          },
        ),
        const Divider(color: Color(0xFF2A2A2A), height: 1),
        _buildToggleTile(
          'Fall Detection',
          'Detect hard falls and trigger emergency protocol',
          Icons.accessibility_new,
          _fallDetection,
          (value) {
            setState(() => _fallDetection = value);
            _saveSetting('fallDetection', value);
          },
        ),
      ],
    );
  }

  Widget _buildSOSCountdownSection() {
    return _buildSettingsCard(
      'SOS Countdown',
      Icons.timer,
      Colors.orange,
      [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Countdown Duration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withOpacity(0.3),
                          Colors.orange.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_sosCountdown sec',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.orange,
                  inactiveTrackColor: Colors.orange.withOpacity(0.3),
                  thumbColor: Colors.orange,
                  overlayColor: Colors.orange.withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12,
                  ),
                ),
                child: Slider(
                  value: _sosCountdown.toDouble(),
                  min: 3,
                  max: 10,
                  divisions: 7,
                  label: '$_sosCountdown seconds',
                  onChanged: (value) {
                    setState(() => _sosCountdown = value.round());
                  },
                  onChangeEnd: (value) {
                    _saveSetting('sosCountdown', value.round());
                  },
                ),
              ),
              const Text(
                'Time before SOS alert is sent to emergency contacts',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 12),
              const Text(
                'Danger Zone',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDangerButton(
            'Test Emergency Alert',
            'Send a test alert to your emergency contacts',
            Icons.send,
            () {
              _showTestAlertDialog();
            },
          ),
          const SizedBox(height: 12),
          _buildDangerButton(
            'Reset All Settings',
            'Restore default safety settings',
            Icons.restore,
            () {
              _showResetDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
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
                  color.withOpacity(0.2),
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
                Icon(icon, color: color),
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value
                  ? const Color(0xFFFF5252).withOpacity(0.2)
                  : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value ? const Color(0xFFFF5252) : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFFFF5252),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTestAlertDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.send, color: Color(0xFFFF5252)),
            SizedBox(width: 12),
            Text(
              'Test Emergency Alert',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          'This will send a test notification to all your emergency contacts. Continue?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackBar('Test alert sent successfully!');
              // TODO: Implement actual test alert
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Send Test'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 12),
            Text(
              'Reset Settings',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          'This will reset all safety settings to default values. This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _resetSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetSettings() async {
    setState(() {
      _emergencyAlerts = true;
      _locationTracking = true;
      _autoCallEmergency = false;
      _shareHealthData = true;
      _biometricLock = false;
      _crashDetection = true;
      _fallDetection = true;
      _sosCountdown = 5;
    });

    try {
      await _firestore.collection('users').doc(_userId).update({
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
      });

      _showSnackBar('Settings reset to defaults');
    } catch (e) {
      _showSnackBar('Failed to reset: $e', isError: true);
    }
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
}