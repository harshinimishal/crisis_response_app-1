import 'package:crisis_response_app/screens/emergency_profile_screen.dart' as profile;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math' as math;
import 'auth_service.dart';
import '../services/emergency_service.dart';
import '../services/location_service.dart';
import '../services/weather_alert_service.dart';
import 'sos_trigger_screen.dart' as sos;
import 'alerts_centre_screen.dart';
import 'advanced_sensors_screen.dart';
import 'connectivity_status_screen.dart';
import 'safety_map_screen.dart';
import 'community_alert.dart';
import 'responder_directory_screen.dart';
import 'event_history_screen.dart';
import 'cpr_guide.dart';
import 'first_aid_screen.dart';
import 'safety_tutorial_screen.dart';
import 'accident_detected_screen.dart';

class EmergencyDashboardScreen extends StatefulWidget {
  const EmergencyDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyDashboardScreen> createState() =>
      _EmergencyDashboardScreenState();
}

class _EmergencyDashboardScreenState extends State<EmergencyDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _sosGlowController;
  late AnimationController _statusPulseController;
  
  bool _isAutoDetectionEnabled = true;
  bool _isSafeModeActive = false;
  bool _isLoading = false;
  bool _isSOSPressed = false;
  int _selectedNavIndex = 0;
  
  Map<String, dynamic>? _userProfile;
  String _userName = 'John Doe';
  String _currentLocation = 'Fetching location...';
  String _systemStatus = 'INITIALIZING';
  Color _systemStatusColor = const Color(0xFFFF9800);
  
  Map<String, dynamic>? _weatherAlert;
  bool _hasLocationPermission = false;
  bool _isLocationServiceEnabled = false;
  
  final AuthService _authService = AuthService();
  final EmergencyService _emergencyService = EmergencyService();
  final LocationService _locationService = LocationService();
  final WeatherAlertService _weatherAlertService = WeatherAlertService();
  
  
  Timer? _sosHoldTimer;
  Timer? _systemStatusTimer;
  double _sosHoldProgress = 0.0;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    _sosGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _statusPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    // Load user profile
    await _loadUserProfile();
    
    // Check permissions
    await _checkPermissions();
    
    // Initialize location
    await _initializeLocation();
    
    // Load weather alerts
    await _loadWeatherAlert();
    
    // Start monitoring if enabled
    if (_isAutoDetectionEnabled && _hasLocationPermission) {
      _startBackgroundMonitoring();
    }
    
    // Update system status
    _updateSystemStatus();
  }
  
  Future<void> _loadUserProfile() async {
    final profile = await _authService.getUserProfile();
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _userName = profile?['fullName'] ?? 'John Doe';
        _isSafeModeActive = profile?['safeMode'] ?? false;
      });
    }
  }
  
  Future<void> _checkPermissions() async {
  final permissionStatus = await _locationService.getPermissionStatus();
  final locationPermission = permissionStatus == LocationPermission.always ||
                            permissionStatus == LocationPermission.whileInUse;
  final locationServiceEnabled = await _locationService.isLocationServiceEnabled();
  
  if (mounted) {
    setState(() {
      _hasLocationPermission = locationPermission;
      _isLocationServiceEnabled = locationServiceEnabled;
    });
  }
}
  
  Future<void> _loadWeatherAlert() async {
    try {
      final alert = await _weatherAlertService.getCurrentWeatherAlert();
      if (mounted) {
        setState(() {
          _weatherAlert = alert;
        });
      }
    } catch (e) {
      print('Error loading weather alert: $e');
    }
  }
  
  Future<void> _initializeLocation() async {
    if (!_hasLocationPermission) {
      setState(() {
        _currentLocation = 'Location permission required';
      });
      return;
    }
    
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (mounted && address != null) {
        setState(() {
          _currentLocation = address;
        });
      }
    } else {
      setState(() {
        _currentLocation = 'Unable to fetch location';
      });
    }
  }
  
  void _startBackgroundMonitoring() {
    // _emergencyService.startAccidentMonitoring();
    // _emergencyService.onEmergencyDetected = _handleEmergencyDetected;
    print('Background accident monitoring started');
  }
  
  void _updateSystemStatus() {
    if (!_hasLocationPermission || !_isLocationServiceEnabled) {
      setState(() {
        _systemStatus = 'LIMITED';
        _systemStatusColor = const Color(0xFFFF9800);
      });
    } else if (_isAutoDetectionEnabled) {
      setState(() {
        _systemStatus = 'READY';
        _systemStatusColor = const Color(0xFF40916C);
      });
    } else {
      setState(() {
        _systemStatus = 'STANDBY';
        _systemStatusColor = const Color(0xFF808080);
      });
    }
  }
  
  void _handleEmergencyDetected(String type, Map<String, dynamic> data) {
    // Navigate to accident detected screen
    if (mounted) {
      final List<Map<String, String>> safeContacts =
          (_userProfile?['emergencyContacts'] as List? ?? [])
              .map((e) => Map<String, String>.from(e as Map))
              .toList();
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AccidentDetectionScreen(
            userId: data['userId'],
            impactForce: data['impactForce'] ?? 0.0,
            detectionType: data['detectionType'] ?? 'unknown',
            emergencyContacts: safeContacts,
          ),
        ),
      );
    }
  }
  
  Future<void> _toggleSafeMode() async {
    setState(() => _isLoading = true);
    
    final newState = !_isSafeModeActive;
    var result = await _authService.updateSafeModeStatus(safeMode: newState);
    
    if (!mounted) return;
    
    setState(() => _isLoading = false);
    
    if (result['success']) {
      setState(() => _isSafeModeActive = newState);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newState ? 'Safe mode activated' : 'Safe mode deactivated',
          ),
          backgroundColor: newState ? const Color(0xFF40916C) : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
  
  void _onSOSPressed() {
    setState(() {
      _isSOSPressed = true;
      _sosHoldProgress = 0.0;
    });
    
    // Animated progress timer
    const totalDuration = 2000; // 2 seconds
    const updateInterval = 50; // Update every 50ms
    int elapsed = 0;
    
    _sosHoldTimer = Timer.periodic(
      const Duration(milliseconds: updateInterval),
      (timer) {
        elapsed += updateInterval;
        if (mounted) {
          setState(() {
            _sosHoldProgress = elapsed / totalDuration;
          });
        }
        
        if (elapsed >= totalDuration && _isSOSPressed) {
          timer.cancel();
          _triggerSOS();
        }
      },
    );
  }
  
  void _onSOSReleased() {
    setState(() {
      _isSOSPressed = false;
      _sosHoldProgress = 0.0;
    });
    _sosHoldTimer?.cancel();
  }
  
Future<void> _triggerSOS() async {
  // Haptic feedback
  // HapticFeedback.heavyImpact();
  
  // Navigate to SOS triggered screen
  final userId = _userProfile?['id'] ?? '';
  final List<Map<String, String>> safeContacts =
      (_userProfile?['emergencyContacts'] as List? ?? [])
          .map((e) => Map<String, String>.from(e as Map))
          .toList();

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => sos.SOSTriggeredScreen(
        userId: userId,
        emergencyContacts: safeContacts,
      ),
    ),
  );
}
  
  Future<void> _requestLocationPermission() async {
    final granted = await _locationService.requestLocationPermission();
    if (granted) {
      await _checkPermissions();
      await _initializeLocation();
      _updateSystemStatus();
      
      if (_isAutoDetectionEnabled) {
        _startBackgroundMonitoring();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sosGlowController.dispose();
    _statusPulseController.dispose();
    _sosHoldTimer?.cancel();
    _systemStatusTimer?.cancel();
    _emergencyService.dispose();
    _locationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    if (_weatherAlert != null) _buildWeatherAlert(),
                    if (_weatherAlert != null) const SizedBox(height: 16),
                    if (!_hasLocationPermission) _buildPermissionWarning(),
                    if (!_hasLocationPermission) const SizedBox(height: 16),
                    _buildSOSButton(),
                    const SizedBox(height: 20),
                    _buildSystemStatus(),
                    const SizedBox(height: 24),
                    _buildQuickAccessGrid(),
                    const SizedBox(height: 20),
                    _buildAutoDetectionCard(),
                    const SizedBox(height: 20),
                    _buildMapPreview(),
                    const SizedBox(height: 20),
                    _buildSafeModeCard(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF2A2A2A),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              final userId = _userProfile?['id'] ?? '';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const profile.UserProfileScreen(),
                ),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3A2E28),
                    const Color(0xFF2A1E18),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD4A574),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4A574).withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFFD4A574),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isSafeModeActive
                        ? const Color(0xFF40916C).withOpacity(0.15)
                        : const Color(0xFFFF6B6B).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isSafeModeActive
                          ? const Color(0xFF40916C)
                          : const Color(0xFFFF6B6B),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _isSafeModeActive ? 'SAFE MODE' : 'NORMAL MODE',
                    style: TextStyle(
                      color: _isSafeModeActive
                          ? const Color(0xFF40916C)
                          : const Color(0xFFFF6B6B),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionWarning() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B6B).withOpacity(0.2),
            const Color(0xFFFF5252).withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6B6B),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFFF6B6B),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Location Access Required',
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Enable location for emergency features',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _requestLocationPermission,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6B),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Enable',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherAlert() {
    if (_weatherAlert == null) return const SizedBox.shrink();
    
    IconData weatherIcon;
    String weatherType = _weatherAlert!['type'] ?? 'rain';
    
    switch (weatherType) {
      case 'storm':
        weatherIcon = Icons.thunderstorm;
        break;
      case 'snow':
        weatherIcon = Icons.ac_unit;
        break;
      default:
        weatherIcon = Icons.water_drop;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4A4A2A),
            const Color(0xFF3A3A1A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4A574),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A574).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFE066),
                  Color(0xFFFFD700),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              weatherIcon,
              color: Colors.black87,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _weatherAlert!['title'] ?? 'Weather Alert',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _weatherAlert!['description'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: Color(0xFFD4A574),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseController, _sosGlowController]),
        builder: (context, child) {
          double pulseValue = math.sin(_pulseController.value * 2 * math.pi);
          double glowValue = math.sin(_sosGlowController.value * 2 * math.pi);
          
          return GestureDetector(
            onTapDown: (_) => _onSOSPressed(),
            onTapUp: (_) => _onSOSReleased(),
            onTapCancel: () => _onSOSReleased(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow effect
                Container(
                  width: 320 + (pulseValue * 15),
                  height: 320 + (pulseValue * 15),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFFFF5252).withOpacity(0.12 + (glowValue * 0.08)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Progress ring
                if (_isSOSPressed)
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: _sosHoldProgress,
                      strokeWidth: 6,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                // Dark outer ring
                Container(
                  width: 270,
                  height: 270,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1A0A0A),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5252).withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
                // Main SOS button
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: _isSOSPressed
                          ? [
                              const Color(0xFFFF9B9B),
                              const Color(0xFFFF7B7B),
                              const Color(0xFFFF6B6B),
                            ]
                          : [
                              const Color(0xFFFF6B6B),
                              const Color(0xFFFF5252),
                              const Color(0xFFFF4242),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5252)
                            .withOpacity(_isSOSPressed ? 0.7 : 0.5),
                        blurRadius: _isSOSPressed ? 40 : 25,
                        spreadRadius: _isSOSPressed ? 8 : 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _isSOSPressed ? 68 : 64,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 10,
                            height: 1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _isSOSPressed 
                                ? 'HOLD ${(2 - (_sosHoldProgress * 2)).toInt()}s' 
                                : 'HOLD 2s TO TRIGGER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSystemStatus() {
    return AnimatedBuilder(
      animation: _statusPulseController,
      builder: (context, child) {
        double pulseValue = (math.sin(_statusPulseController.value * 2 * math.pi) + 1) / 2;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _systemStatusColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _systemStatusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _systemStatusColor.withOpacity(0.5 + (pulseValue * 0.3)),
                      blurRadius: 8 + (pulseValue * 4),
                      spreadRadius: 2 + (pulseValue * 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'SYSTEM $_systemStatus',
                style: TextStyle(
                  color: _systemStatusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
            children: [
              _buildQuickAccessCard(
                icon: Icons.medical_services_outlined,
                label: 'First Aid',
                color: const Color(0xFFFF6B6B),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FirstAidGuideScreen(),
                    ),
                  );
                },
              ),
              _buildQuickAccessCard(
                icon: Icons.favorite_outline,
                label: 'CPR Guide',
                color: const Color(0xFFFF5252),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CPRGuideScreen(),
                    ),
                  );
                },
              ),
              _buildQuickAccessCard(
                icon: Icons.map_outlined,
                label: 'Safety Map',
                color: const Color(0xFF40916C),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SafetyMapScreen(),
                    ),
                  );
                },
              ),
              _buildQuickAccessCard(
                icon: Icons.people_outline,
                label: 'Responders',
                color: const Color(0xFF3B82F6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResponderDirectoryPage(),
                    ),
                  );
                },
              ),
              _buildQuickAccessCard(
                icon: Icons.history,
                label: 'History',
                color: const Color(0xFF808080),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EventHistoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2A2A2A),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoDetectionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isAutoDetectionEnabled 
              ? const Color(0xFF40916C).withOpacity(0.3)
              : const Color(0xFF2A2A2A),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: _isAutoDetectionEnabled
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF40916C).withOpacity(0.3),
                        const Color(0xFF40916C).withOpacity(0.15),
                      ],
                    )
                  : null,
              color: _isAutoDetectionEnabled ? null : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: _isAutoDetectionEnabled
                  ? const Color(0xFF40916C)
                  : const Color(0xFF606060),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Auto-Detection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isAutoDetectionEnabled
                      ? 'Fall & crash detection active'
                      : 'Detection disabled',
                  style: TextStyle(
                    color: _isAutoDetectionEnabled 
                        ? const Color(0xFF40916C).withOpacity(0.8)
                        : const Color(0xFF707070),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.1,
            child: Switch(
              value: _isAutoDetectionEnabled,
              onChanged: (value) {
                setState(() {
                  _isAutoDetectionEnabled = value;
                });
                if (value && _hasLocationPermission) {
                  _startBackgroundMonitoring();
                } else {
                  // _emergencyService.stopAccidentMonitoring();
                }
                _updateSystemStatus();
              },
              activeColor: const Color(0xFF40916C),
              activeTrackColor: const Color(0xFF40916C).withOpacity(0.3),
              inactiveThumbColor: const Color(0xFF606060),
              inactiveTrackColor: const Color(0xFF2A2A2A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SafetyMapScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2A2A2A),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Map placeholder with gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2A3A2A),
                      Color(0xFF1A2A1A),
                      Color(0xFF0A1A0A),
                    ],
                  ),
                ),
              ),
              // Grid overlay for map effect
              CustomPaint(
                size: Size.infinite,
                painter: GridPainter(),
              ),
              // Location marker
              Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFFF5252),
                        blurRadius: 15,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              // Location label
              Positioned(
                bottom: 14,
                left: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A).withOpacity(0.92),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2A2A2A),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFFFF5252),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentLocation,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF606060),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafeModeCard() {
    return GestureDetector(
      onTap: _toggleSafeMode,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isSafeModeActive
                ? [
                    const Color(0xFF40916C).withOpacity(0.2),
                    const Color(0xFF2A6A4A).withOpacity(0.15),
                  ]
                : [
                    const Color(0xFF2A2A2A),
                    const Color(0xFF1A1A1A),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isSafeModeActive 
                ? const Color(0xFF40916C)
                : const Color(0xFF3A3A3A),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _isSafeModeActive
                    ? const Color(0xFF40916C).withOpacity(0.3)
                    : const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _isSafeModeActive ? Icons.verified_user : Icons.security,
                color: _isSafeModeActive
                    ? const Color(0xFF40916C)
                    : const Color(0xFF808080),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isSafeModeActive ? 'Safe Mode Active' : 'Activate Safe Mode',
                    style: TextStyle(
                      color: _isSafeModeActive 
                          ? const Color(0xFF40916C)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isSafeModeActive
                        ? 'You\'re marked as safe'
                        : 'Let contacts know you\'re safe',
                    style: const TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF40916C)),
                ),
              )
            else
              Icon(
                _isSafeModeActive ? Icons.check_circle : Icons.arrow_forward_ios,
                color: _isSafeModeActive 
                    ? const Color(0xFF40916C)
                    : const Color(0xFF606060),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home, false),
          _buildNavItem(1, Icons.notifications_outlined, Icons.notifications, false),
          _buildNavItem(2, Icons.add_circle_outline, Icons.add_circle, true),
          _buildNavItem(3, Icons.settings_outlined, Icons.settings, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconOutlined, IconData iconFilled, bool isCenter) {
    final isSelected = _selectedNavIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
        
        // Navigate based on index
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AlertsCenterPage(),
              ),
            );
            break;
          case 2:
            // Show more options
            _showMoreOptions();
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => profile.UserProfileScreen(),
              ),
            );
            break;
        }
      },
      child: Container(
        width: isCenter ? 64 : 56,
        height: isCenter ? 64 : 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    const Color(0xFFFF6B6B),
                    const Color(0xFFFF5252),
                  ],
                )
              : (isCenter
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF2A2A2A),
                        const Color(0xFF1A1A1A),
                      ],
                    )
                  : null),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF5252).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          isSelected ? iconFilled : iconOutlined,
          color: isSelected
              ? Colors.white
              : (isCenter ? const Color(0xFF606060) : const Color(0xFF808080)),
          size: isCenter ? 32 : 26,
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'More Options',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildBottomSheetOption(
                icon: Icons.sensors,
                label: 'Advanced Sensors',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdvancedSensorsPage(),
                    ),
                  );
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.wifi,
                label: 'Connectivity Status',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConnectivityStatusScreen(),
                    ),
                  );
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.group,
                label: 'Community Alerts',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommunityAlertsScreen(),
                    ),
                  );
                },
              ),
              _buildBottomSheetOption(
                icon: Icons.school,
                label: 'Safety Tutorial',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SafetyTutorialsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFFF6B6B),
          size: 22,
        ),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF606060),
      ),
      onTap: onTap,
    );
  }
}

// Grid painter for map effect
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A2A2A).withOpacity(0.3)
      ..strokeWidth = 1;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}