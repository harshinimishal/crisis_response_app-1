import 'package:crisis_response_app/screens/emergency_profile_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'auth_service.dart';
import '../services/emergency_service.dart';
import '../services/location_service.dart';
import '../services/weather_alert_service.dart';
import 'sos_trigger_screen.dart';
import 'emergency_profile_screen.dart';
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
  
  bool _isAutoDetectionEnabled = true;
  bool _isSafeModeActive = false;
  bool _isLoading = false;
  bool _isSOSPressed = false;
  int _selectedNavIndex = 0;
  
  Map<String, dynamic>? _userProfile;
  String _userName = 'John Doe';
  String _currentLocation = 'Pike St & 4th Ave, Seattle';
  int _batteryLevel = 88;
  
  Map<String, dynamic>? _weatherAlert;
  
  final AuthService _authService = AuthService();
  final EmergencyService _emergencyService = EmergencyService();
  final LocationService _locationService = LocationService();
  final WeatherAlertService _weatherAlertService = WeatherAlertService();
  
  Timer? _sosHoldTimer;

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

    _loadUserProfile();
    _loadWeatherAlert();
    _initializeLocation();
    
    // Start accident monitoring if enabled
    if (_isAutoDetectionEnabled) {
      _emergencyService.startAccidentMonitoring();
      _emergencyService.onEmergencyDetected = _handleEmergencyDetected;
    }
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
  
  Future<void> _loadWeatherAlert() async {
    final alert = await _weatherAlertService.getCurrentWeatherAlert();
    if (mounted) {
      setState(() {
        _weatherAlert = alert;
      });
    }
  }
  
  Future<void> _initializeLocation() async {
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
    }
  }
  
  void _handleEmergencyDetected(String type, Map<String, dynamic> data) {
    // Navigate to accident detected screen
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AccidentDetectedScreen(),
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
        ),
      );
    }
  }
  
  void _onSOSPressed() {
    setState(() => _isSOSPressed = true);
    
    // Start hold timer
    _sosHoldTimer = Timer(const Duration(seconds: 2), () {
      if (_isSOSPressed) {
        _triggerSOS();
      }
    });
  }
  
  void _onSOSReleased() {
    setState(() => _isSOSPressed = false);
    _sosHoldTimer?.cancel();
  }
  
  Future<void> _triggerSOS() async {
    // Navigate to SOS triggered screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SOSTriggeredScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sosGlowController.dispose();
    _sosHoldTimer?.cancel();
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
            if (_weatherAlert != null) _buildWeatherAlert(),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSOSButton(),
                    const SizedBox(height: 20),
                    _buildSystemStatus(),
                    const SizedBox(height: 20),
                    _buildAutoDetectionCard(),
                    const SizedBox(height: 20),
                    _buildMapPreview(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EmergencyProfileScreen(),
                              ),
                            );
                          },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF3A2E28),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD4A574),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFFD4A574),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSafeModeActive ? 'SAFE MODE' : 'NORMAL MODE',
                  style: TextStyle(
                    color: _isSafeModeActive
                        ? const Color(0xFF40916C)
                        : const Color(0xFFFF6B6B),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2A2A2A),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.wifi,
                  color: Color(0xFFFF6B6B),
                  size: 16,
                ),
                const SizedBox(width: 6),
                const Text(
                  'SMS/BLE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2A2A2A),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  '$_batteryLevel%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.battery_charging_full,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherAlert() {
    if (_weatherAlert == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4A4A2A),
            Color(0xFF3A3A1A),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4A574),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.cloud_outlined,
              color: Colors.black,
              size: 32,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _weatherAlert!['description'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Show weather details
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Text(
                    'Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 12,
                  ),
                ],
              ),
            ),
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
                  width: 340 + (pulseValue * 20),
                  height: 340 + (pulseValue * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFFFF5252).withOpacity(0.15 + (glowValue * 0.1)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Dark outer ring
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1A0A0A),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5252).withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Main SOS button
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: _isSOSPressed
                          ? [
                              const Color(0xFFFF8B8B),
                              const Color(0xFFFF6B6B),
                            ]
                          : [
                              const Color(0xFFFF6B6B),
                              const Color(0xFFFF5252),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5252)
                            .withOpacity(_isSOSPressed ? 0.6 : 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isSOSPressed ? 'RELEASING...' : 'HOLD TO TRIGGER',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF40916C),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF40916C),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'SYSTEM READY',
            style: TextStyle(
              color: Color(0xFF40916C),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
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
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _isAutoDetectionEnabled
                  ? const Color(0xFF40916C).withOpacity(0.2)
                  : const Color(0xFF3A3A3A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: _isAutoDetectionEnabled
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
                const Text(
                  'Auto-Detection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isAutoDetectionEnabled
                      ? 'Automatic fall & crash detection'
                      : 'Detection disabled',
                  style: const TextStyle(
                    color: Color(0xFF808080),
                    fontSize: 13,
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
                if (value) {
                  _emergencyService.startAccidentMonitoring();
                } else {
                  _emergencyService.stopAccidentMonitoring();
                }
              },
              activeColor: const Color(0xFF40916C),
              inactiveThumbColor: const Color(0xFF808080),
              inactiveTrackColor: const Color(0xFF3A3A3A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
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
                  ],
                ),
              ),
            ),
            // Location marker
            Center(
              child: Container(
                width: 20,
                height: 20,
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
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
            // Location label
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withOpacity(0.95),
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
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _currentLocation,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
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
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home, false),
          _buildNavItem(1, Icons.people_outline, false),
          _buildNavItem(2, Icons.add_circle, true),
          _buildNavItem(3, Icons.settings_outlined, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, bool isCenter) {
    final isSelected = _selectedNavIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
      },
      child: Container(
        width: isCenter ? 64 : 56,
        height: isCenter ? 64 : 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? const Color(0xFFFF5252)
              : (isCenter
                  ? const Color(0xFF2A2A2A)
                  : Colors.transparent),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF5252).withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isSelected
              ? Colors.white
              : (isCenter ? const Color(0xFF808080) : const Color(0xFF808080)),
          size: isCenter ? 32 : 26,
        ),
      ),
    );
  }
}

// Import the accident detected screen
class AccidentDetectedScreen extends StatelessWidget {
  const AccidentDetectedScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Use the existing accident_detected_screen.dart implementation
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'Accident Detected Screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}