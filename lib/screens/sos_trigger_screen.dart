import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
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
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;

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
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      value: 1.0,
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
  }

  Future<void> _initializeState() async {
    final connectivity = Connectivity();
    final initial = await connectivity.checkConnectivity();
    if (mounted) {
      setState(() => _isInternetActive = _hasInternet(initial));
    }

    _connectivitySubscription = connectivity.onConnectivityChanged.listen((results) {
      if (!mounted) return;
      setState(() => _isInternetActive = _hasInternet(results));
    });

    _startLocationTracking();
    _startBatteryMonitoring();

    _statusUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
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
          _locationText = '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() => _locationText = 'Location unavailable');
      }
    });

    Geolocator.getLastKnownPosition().then((position) {
      if (position != null && mounted) {
        setState(() {
          _currentLocation = position;
          _locationAccuracy = position.accuracy;
          _locationText = '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
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
    Vibration.vibrate(pattern: [0, 500, 200, 500], intensities: [0, 255, 0, 255]);
  }

  Future<void> _triggerEmergency() async {
    if (_emergencyCreated) return;

    setState(() => _emergencyCreated = true);
    Vibration.vibrate(duration: 1000, amplitude: 255);

    try {
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

      _listenToSessionUpdates();
      _checkDeliveryStatus();
    } catch (e) {
      debugPrint('❌ Error triggering emergency: $e');
      _sessionId = 'error_session_${DateTime.now().millisecondsSinceEpoch}';
    }

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 800));

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
        final channels = data['deliveryChannels'] as Map<String, dynamic>?;
        if (channels != null) {
          _deliveryStatus['fcm'] = channels['fcm']?['success'] ?? false;
          _deliveryStatus['sms'] = channels['sms']?['success'] ?? false;
          _deliveryStatus['ble'] = channels['ble']?['success'] ?? false;
          _deliveryStatus['email'] = channels['email']?['success'] ?? false;
        }

        final notified = data['contactsNotified'] as List?;
        _notifiedContacts = notified?.length ?? 0;

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
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isSMSActive = true);

    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted && _isInternetActive) {
      setState(() => _deliveryStatus['fcm'] = true);
    }
  }

  Future<void> _cancelEmergency() async {
    _countdownTimer?.cancel();
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
    _fadeController.dispose();
    _scaleController.dispose();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Vibration.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0D0D0D),
                const Color(0xFF1A0A0A),
                const Color(0xFF0D0D0D),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Animated background effects
                _buildBackgroundEffects(),
                
                // Main content
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildModernHeader(),
                        const SizedBox(height: 32),
                        _buildMainSOSSection(),
                        const SizedBox(height: 32),
                        _buildInfoCards(),
                        const SizedBox(height: 24),
                        _buildLocationCard(),
                        const SizedBox(height: 24),
                        _buildConnectionGrid(),
                        if (_emergencyCreated) ...[
                          const SizedBox(height: 24),
                          _buildDeliveryProgress(),
                        ],
                        const SizedBox(height: 24),
                        _buildEmergencyContacts(),
                        const SizedBox(height: 32),
                        _buildCancelButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundEffects() {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        return Stack(
          children: [
            for (int i = 0; i < 3; i++)
              Positioned(
                top: -100 + (i * 200),
                left: -100 + (_rippleController.value * 50),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF5252).withOpacity(0.03),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildModernHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF5252),
                      const Color(0xFFFF3030),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5252).withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Emergency SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFF5252).withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTriggerIcon(),
                            color: const Color(0xFFFF8A8A),
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getTriggerText(),
                            style: const TextStyle(
                              color: Color(0xFFFF8A8A),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainSOSSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _progressController,
        _pulseController,
        _glowController,
      ]),
      builder: (context, child) {
        final pulseValue = math.sin(_pulseController.value * 2 * math.pi);
        final glowIntensity = _glowController.value;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer ripple effects
            for (int i = 0; i < 4; i++)
              Container(
                width: 320 + (i * 40) + (pulseValue * 20),
                height: 320 + (i * 40) + (pulseValue * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFF5252).withOpacity(
                      (0.15 - i * 0.03) * (1 - _pulseController.value),
                    ),
                    width: 2,
                  ),
                ),
              ),

            // Main SOS button with progress
            SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progress ring
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: _progressController.value,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.lerp(
                          const Color(0xFFFF8A8A),
                          const Color(0xFFFF3030),
                          glowIntensity,
                        )!,
                      ),
                    ),
                  ),

                  // Inner circle with glassmorphism
                  ClipRRect(
                    borderRadius: BorderRadius.circular(130),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color.lerp(
                                const Color(0xFFFF6B6B),
                                const Color(0xFFFF4444),
                                glowIntensity,
                              )!,
                              const Color(0xFFFF2020),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5252).withOpacity(
                                0.5 + (glowIntensity * 0.3),
                              ),
                              blurRadius: 40 + (glowIntensity * 20),
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 8,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              countdown > 0 ? '$countdown' : '0',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _emergencyCreated ? 'SENDING' : 'TRIGGERED',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: _buildGlassCard(
            icon: Icons.battery_charging_full,
            value: '$_batteryLevel%',
            label: 'Battery',
            color: _batteryLevel > 20
                ? const Color(0xFF4CAF50)
                : const Color(0xFFFF5252),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGlassCard(
            icon: Icons.people_outline,
            value: '$_notifiedContacts/${widget.emergencyContacts.length}',
            label: 'Notified',
            color: _notifiedContacts > 0
                ? const Color(0xFF4CAF50)
                : const Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGlassCard(
            icon: Icons.location_on_outlined,
            value: _locationAccuracy > 0 ? '±${_locationAccuracy.toInt()}m' : '--',
            label: 'Accuracy',
            color: _getAccuracyColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Color(0xFFFF5252),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Live Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place,
                      color: Color(0xFFFF8A8A),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _locationText,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildConnectionCard(
            'Internet',
            _isInternetActive,
            Icons.wifi,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildConnectionCard(
            'SMS',
            _isSMSActive,
            Icons.message,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildConnectionCard(
            'Bluetooth',
            _isBLEActive,
            Icons.bluetooth,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionCard(String label, bool isActive, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isActive
                    ? const Color(0xFF4CAF50).withOpacity(0.15)
                    : Colors.white.withOpacity(0.05),
                isActive
                    ? const Color(0xFF4CAF50).withOpacity(0.05)
                    : Colors.white.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF4CAF50).withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFF4CAF50) : Colors.white.withOpacity(0.3),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? const Color(0xFF4CAF50) : Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF4CAF50) : Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryProgress() {
    final deliveryMethods = [
      {'label': 'FCM', 'status': _deliveryStatus['fcm']!, 'icon': Icons.notifications},
      {'label': 'SMS', 'status': _deliveryStatus['sms']!, 'icon': Icons.sms},
      {'label': 'Email', 'status': _deliveryStatus['email']!, 'icon': Icons.email},
      {'label': 'BLE', 'status': _deliveryStatus['ble']!, 'icon': Icons.bluetooth},
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.send,
                    color: Color(0xFF4CAF50),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Delivery Status',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: deliveryMethods.map((method) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: method['status'] as bool
                              ? const Color(0xFF4CAF50).withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: method['status'] as bool
                                ? const Color(0xFF4CAF50)
                                : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Icon(
                          method['status'] as bool ? Icons.check_circle : Icons.pending,
                          color: method['status'] as bool
                              ? const Color(0xFF4CAF50)
                              : Colors.white.withOpacity(0.3),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        method['label'] as String,
                        style: TextStyle(
                          color: method['status'] as bool
                              ? const Color(0xFF4CAF50)
                              : Colors.white.withOpacity(0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Emergency Contacts',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.emergencyContacts.length,
            itemBuilder: (context, index) {
              final contact = widget.emergencyContacts[index];
              final isNotified = _emergencyCreated && index < _notifiedContacts;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 90,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isNotified
                              ? const Color(0xFF4CAF50).withOpacity(0.5)
                              : Colors.white.withOpacity(0.1),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isNotified
                                      ? const Color(0xFF4CAF50).withOpacity(0.2)
                                      : Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getContactIcon(contact['role'] ?? ''),
                                  color: isNotified
                                      ? const Color(0xFF4CAF50)
                                      : Colors.white.withOpacity(0.6),
                                  size: 20,
                                ),
                              ),
                              if (isNotified)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4CAF50),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            contact['name'] ?? 'Contact',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: _cancelEmergency,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close_rounded, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'CANCEL SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
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
        return Icons.warning_amber_rounded;
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
        return 'Manual Trigger';
    }
  }

  Color _getAccuracyColor() {
    if (_locationAccuracy <= 10) return const Color(0xFF4CAF50);
    if (_locationAccuracy <= 50) return const Color(0xFFFFA726);
    return const Color(0xFFFF5252);
  }

  IconData _getContactIcon(String role) {
    switch (role.toLowerCase()) {
      case 'emergency':
        return Icons.local_hospital;
      case 'family':
        return Icons.people;
      case 'friend':
        return Icons.person;
      case 'police':
        return Icons.security;
      default:
        return Icons.person_outline;
    }
  }
}