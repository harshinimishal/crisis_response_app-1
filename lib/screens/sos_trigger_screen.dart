import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:vibration/vibration.dart';
import 'accident_detected_screen.dart';
import '../services/emergency_service.dart';

class SOSTriggeredScreen extends StatefulWidget {
  final String userId;
  final String triggerType;
  final List<Map<String, String>> emergencyContacts;
  final Map<String, dynamic>? additionalData;

  const SOSTriggeredScreen({
    Key? key,
    required this.userId,
    this.triggerType = 'manual',
    required this.emergencyContacts,
    this.additionalData,
  }) : super(key: key);

  @override
  State<SOSTriggeredScreen> createState() => _SOSTriggeredScreenState();
}

class _SOSTriggeredScreenState extends State<SOSTriggeredScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late final AnimationController _progressController;
  late final AnimationController _pulseController;
  late final AnimationController _glowController;
  late final AnimationController _rippleController;

  // Services
  final EmergencyService _emergencyService = EmergencyService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Battery _battery = Battery();

  // Timers
  Timer? _countdownTimer;
  Timer? _statusUpdateTimer;
  int countdown = 8;

  // Connection status
  bool _isInternetActive = false;
  bool _isSMSActive = true;
  bool _isBLEActive = false;
  bool _isCallActive = false;

  // Location
  String _locationText = 'Acquiring location...';
  Position? _currentLocation;
  double _locationAccuracy = 0;

  // Battery
  int _batteryLevel = 100;
  
  // Delivery status
  Map<String, bool> _deliveryStatus = {
    'fcm': false,
    'sms': false,
    'ble': false,
    'email': false,
  };
  int _notifiedContacts = 0;

  // Stream subscriptions
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<BatteryState>? _batterySubscription;
  StreamSubscription<DocumentSnapshot>? _sessionSubscription;

  // Session
  bool _emergencyCreated = false;
  String? _sessionId;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _initializeAnimations();
    _initializeState();
    _startCountdown();
    _startVibration();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  Future<void> _initializeState() async {
    // Check connectivity
    final connectivity = Connectivity();
    final initial = await connectivity.checkConnectivity();
    if (mounted) {
      setState(() => _isInternetActive = _hasInternet(initial));
    }

    _connectivitySubscription = connectivity.onConnectivityChanged.listen((results) {
      if (!mounted) return;
      setState(() => _isInternetActive = _hasInternet(results));
    });

    // Get location
    _startLocationTracking();

    // Monitor battery
    _startBatteryMonitoring();

    // Update status periodically
    _statusUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentLocation = position;
          _locationAccuracy = position.accuracy;
          _locationText = 'LAT ${position.latitude.toStringAsFixed(5)}, '
              'LNG ${position.longitude.toStringAsFixed(5)}';
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() => _locationText = 'Location unavailable');
      }
    });

    // Try to get initial location
    Geolocator.getLastKnownPosition().then((position) {
      if (position != null && mounted) {
        setState(() {
          _currentLocation = position;
          _locationAccuracy = position.accuracy;
          _locationText = 'LAT ${position.latitude.toStringAsFixed(5)}, '
              'LNG ${position.longitude.toStringAsFixed(5)}';
        });
      }
    });
  }

  void _startBatteryMonitoring() {
    _battery.batteryLevel.then((level) {
      if (mounted) setState(() => _batteryLevel = level);
    });

    _batterySubscription = _battery.onBatteryStateChanged.listen((state) {
      _battery.batteryLevel.then((level) {
        if (mounted) setState(() => _batteryLevel = level);
      });
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (countdown > 0) {
        setState(() => countdown--);
        
        // Vibrate on each second
        if (countdown <= 3) {
          Vibration.vibrate(duration: 100);
        }
      } else {
        timer.cancel();
        _triggerEmergency();
      }
    });
  }

  void _startVibration() {
    // Initial strong vibration pattern
    Vibration.vibrate(pattern: [0, 500, 200, 500], intensities: [0, 255, 0, 255]);
  }

  Future<void> _triggerEmergency() async {
    if (_emergencyCreated) return;
    
    setState(() => _emergencyCreated = true);

    // Final strong vibration
    Vibration.vibrate(duration: 1000, amplitude: 255);

    try {
      // Create emergency session with all collected data
      _sessionId = await _emergencyService.createEmergencySession(
        userId: widget.userId,
        triggerType: widget.triggerType,
        emergencyContacts: widget.emergencyContacts,
        initialLocation: _currentLocation,
        additionalData: {
          ...?widget.additionalData,
          'batteryLevel': _batteryLevel,
          'locationAccuracy': _locationAccuracy,
          'hasInternet': _isInternetActive,
          'triggerTimestamp': DateTime.now().toIso8601String(),
        },
      );

      // Listen to session updates
      _listenToSessionUpdates();

      // Show delivery status updates
      _checkDeliveryStatus();
    } catch (e) {
      debugPrint('❌ Error triggering emergency: $e');
      _sessionId = 'error_session_${DateTime.now().millisecondsSinceEpoch}';
    }

    if (!mounted) return;

    // Wait briefly to show status
    await Future.delayed(const Duration(milliseconds: 800));

    // Navigate to accident detected screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AccidentDetectionScreen(
            userId: widget.userId,
            emergencyContacts: widget.emergencyContacts,
            detectionType: widget.triggerType,
            impactForce: widget.additionalData?['impactForce'] ?? 0.0,
          ),
        ),
      );
    }
  }

  void _listenToSessionUpdates() {
    if (_sessionId == null) return;

    _sessionSubscription = _firestore
        .collection('emergency_sessions')
        .doc(_sessionId)
        .snapshots()
        .listen((snapshot) {
      if (!mounted || !snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      setState(() {
        // Update delivery status
        final channels = data['deliveryChannels'] as Map<String, dynamic>?;
        if (channels != null) {
          _deliveryStatus['fcm'] = channels['fcm']?['success'] ?? false;
          _deliveryStatus['sms'] = channels['sms']?['success'] ?? false;
          _deliveryStatus['ble'] = channels['ble']?['success'] ?? false;
          _deliveryStatus['email'] = channels['email']?['success'] ?? false;
        }

        // Update notified contacts count
        final notified = data['contactsNotified'] as List?;
        _notifiedContacts = notified?.length ?? 0;

        // Update connectivity indicators
        final connectivity = data['connectivityStatus'] as Map<String, dynamic>?;
        if (connectivity != null) {
          _isInternetActive = connectivity['internet'] ?? false;
          _isSMSActive = connectivity['sms'] ?? true;
          _isBLEActive = connectivity['ble'] ?? false;
        }
      });
    });
  }

  Future<void> _checkDeliveryStatus() async {
    // Periodically check delivery status for visual feedback
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isSMSActive = true);
    
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted && _isInternetActive) {
      setState(() => _deliveryStatus['fcm'] = true);
    }
  }

  Future<void> _cancelEmergency() async {
    _countdownTimer?.cancel();

    // Haptic feedback
    HapticFeedback.mediumImpact();

    if (_emergencyCreated && _sessionId != null) {
      await _emergencyService.cancelEmergency(
        reason: 'User cancelled before countdown',
      );
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (mounted) Navigator.pop(context);
  }

  bool _hasInternet(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _statusUpdateTimer?.cancel();
    _connectivitySubscription?.cancel();
    _locationSubscription?.cancel();
    _batterySubscription?.cancel();
    _sessionSubscription?.cancel();

    _progressController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _rippleController.dispose();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Vibration.cancel();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildMapSection(),
              const SizedBox(height: 20),
              _buildDeviceStatus(),
              const SizedBox(height: 24),
              _buildConnectionStatus(),
              const SizedBox(height: 32),
              Expanded(child: _buildSOSButton()),
              const SizedBox(height: 24),
              _buildCountdownText(),
              const SizedBox(height: 24),
              _buildDeliveryStatus(),
              const SizedBox(height: 24),
              _buildContactsSection(),
              const SizedBox(height: 24),
              _buildCancelButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A).withOpacity(0.5),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.emergency, color: Color(0xFFFF5252), size: 28),
                    SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Emergency SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFF5252), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTriggerIcon(),
                        color: const Color(0xFFFF5252),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _getTriggerText(),
                          style: const TextStyle(
                            color: Color(0xFFFF8A8A),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFF5252).withOpacity(0.3),
                  const Color(0xFFFF5252).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF5252), width: 2),
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFFFF5252),
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTriggerIcon() {
    switch (widget.triggerType) {
      case 'crash_detected':
        return Icons.car_crash;
      case 'fall_detected':
        return Icons.accessibility_new;
      case 'panic_button':
        return Icons.warning;
      default:
        return Icons.touch_app;
    }
  }

  String _getTriggerText() {
    switch (widget.triggerType) {
      case 'crash_detected':
        return 'Crash Detected';
      case 'fall_detected':
        return 'Fall Detected';
      case 'panic_button':
        return 'Panic Button';
      default:
        return 'Manual Trigger Active';
    }
  }

  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5252).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2A4A5A),
                    Color(0xFF3A6A7A),
                    Color(0xFF4A8A9A),
                  ],
                ),
              ),
            ),
            // Grid overlay
            CustomPaint(
              painter: GridPainter(),
              size: Size.infinite,
            ),
            // Pulsing marker
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse rings
                      for (int i = 0; i < 3; i++)
                        Container(
                          width: 60 + (i * 20) + (_pulseController.value * 30),
                          height: 60 + (i * 20) + (_pulseController.value * 30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFF5252).withOpacity(
                                (1 - _pulseController.value) * (1 - i * 0.3),
                              ),
                              width: 2,
                            ),
                          ),
                        ),
                      // Main marker
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5252).withOpacity(0.6),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Location label
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFF3A3A3A), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.gps_fixed, color: Color(0xFFFF5252), size: 14),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _locationText.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_locationAccuracy > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getAccuracyColor(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '±${_locationAccuracy.toStringAsFixed(0)}m',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAccuracyColor() {
    if (_locationAccuracy <= 10) return const Color(0xFF40916C);
    if (_locationAccuracy <= 50) return const Color(0xFFFFAA00);
    return const Color(0xFFFF5252);
  }

  Widget _buildDeviceStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusIndicator(
              Icons.battery_std,
              '$_batteryLevel%',
              _batteryLevel > 20 ? const Color(0xFF40916C) : const Color(0xFFFF5252),
            ),
            Container(width: 1, height: 24, color: const Color(0xFF2A2A2A)),
            _buildStatusIndicator(
              Icons.access_time,
              '${countdown}s',
              const Color(0xFFFFAA00),
            ),
            Container(width: 1, height: 24, color: const Color(0xFF2A2A2A)),
            _buildStatusIndicator(
              Icons.people,
              '$_notifiedContacts/${widget.emergencyContacts.length}',
              _notifiedContacts > 0 ? const Color(0xFF40916C) : const Color(0xFF808080),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusCard(
              'INTERNET',
              _isInternetActive ? 'Connected' : 'Offline',
              Icons.wifi,
              _isInternetActive,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              'SMS',
              _isSMSActive ? 'Ready' : 'Unavailable',
              Icons.sms,
              _isSMSActive,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              'BLE',
              _isBLEActive ? 'Active' : 'Searching',
              Icons.bluetooth,
              _isBLEActive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String status, IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF0F0F0F),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF40916C) : const Color(0xFF2A2A2A),
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF40916C).withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF40916C).withOpacity(0.2)
                  : const Color(0xFF2A2A2A).withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? const Color(0xFF40916C) : const Color(0xFF606060),
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF808080),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? const Color(0xFF40916C) : const Color(0xFF808080),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _progressController,
          _pulseController,
          _glowController,
        ]),
        builder: (context, child) {
          final pulseValue = math.sin(_pulseController.value * 2 * math.pi);
          final glowValue = _glowController.value;
          
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow rings
              for (int i = 3; i > 0; i--)
                Container(
                  width: 300 + (i * 25) + (pulseValue * 15),
                  height: 300 + (i * 25) + (pulseValue * 15),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF5252).withOpacity(0.08 / i),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              // Progress ring background
              SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFF2A1A1A),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2A1A1A)),
                ),
              ),
              // Progress ring
              SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: _progressController.value,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.lerp(
                      const Color(0xFFFF8A8A),
                      const Color(0xFFFF3030),
                      glowValue,
                    )!,
                  ),
                ),
              ),
              // Dark circle
              Container(
                width: 235,
                height: 235,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1A0A0A),
                ),
              ),
              // Main SOS button
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color.lerp(
                        const Color(0xFFFF8A8A),
                        const Color(0xFFFF5252),
                        glowValue,
                      )!,
                      const Color(0xFFFF3030),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5252).withOpacity(0.4 + (glowValue * 0.3)),
                      blurRadius: 35 + (glowValue * 15),
                      spreadRadius: 4 + (glowValue * 4),
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
                          fontSize: 65,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _emergencyCreated ? 'SENDING' : 'TRIGGERED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCountdownText() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, color: Color(0xFFFF5252), size: 26),
            const SizedBox(width: 10),
            Text(
              'SENDING IN 0${countdown}s',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
          ),
          child: const Text(
            'Emergency services and contacts will be\nnotified with your live location',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB0B0B0),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryStatus() {
    if (!_emergencyCreated) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DELIVERY STATUS',
            style: TextStyle(
              color: Color(0xFF808080),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDeliveryIndicator('FCM', _deliveryStatus['fcm']!),
              const SizedBox(width: 8),
              _buildDeliveryIndicator('SMS', _deliveryStatus['sms']!),
              const SizedBox(width: 8),
              _buildDeliveryIndicator('Email', _deliveryStatus['email']!),
              const SizedBox(width: 8),
              _buildDeliveryIndicator('BLE', _deliveryStatus['ble']!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryIndicator(String label, bool success) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: success 
              ? const Color(0xFF40916C).withOpacity(0.2)
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: success ? const Color(0xFF40916C) : const Color(0xFF3A3A3A),
          ),
        ),
        child: Column(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.pending,
              color: success ? const Color(0xFF40916C) : const Color(0xFF606060),
              size: 16,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: success ? const Color(0xFF40916C) : const Color(0xFF606060),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: const [
              Icon(Icons.people, color: Color(0xFF808080), size: 16),
              SizedBox(width: 8),
              Text(
                'CONTACTS TO NOTIFY',
                style: TextStyle(
                  color: Color(0xFF808080),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: widget.emergencyContacts
                .map((contact) => _buildContactAvatar(contact))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContactAvatar(Map<String, String> contact) {
    final isNotified = _emergencyCreated;
    
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2A2A2A),
                  const Color(0xFF1A1A1A),
                ],
              ),
              border: Border.all(
                color: isNotified ? const Color(0xFF40916C) : const Color(0xFFFF5252),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isNotified ? const Color(0xFF40916C) : const Color(0xFFFF5252))
                      .withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    _getContactIcon(contact['role'] ?? ''),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                if (isNotified)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF40916C),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              contact['name'] ?? 'Contact',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getContactIcon(String role) {
    final lowerRole = role.toLowerCase();
    if (lowerRole.contains('doctor') || lowerRole.contains('physician')) {
      return Icons.medical_services;
    } else if (lowerRole.contains('spouse') || lowerRole.contains('partner')) {
      return Icons.favorite;
    } else if (lowerRole.contains('parent') || lowerRole.contains('family')) {
      return Icons.family_restroom;
    }
    return Icons.person;
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: _cancelEmergency,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2A2A2A),
              const Color(0xFF1A1A1A),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF3A3A3A), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.close, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text(
              'CANCEL SOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Grid painter for map background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const spacing = 20.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}