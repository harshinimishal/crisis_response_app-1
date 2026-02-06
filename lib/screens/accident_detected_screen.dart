import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:convert';

import '../services/emergency_service.dart';
import '../services/dtn_service.dart';
import 'emergency_beacon_screen.dart';

class AccidentDetectionScreen extends StatefulWidget {
  final String userId;
  final double impactForce; // G-force detected
  final String detectionType; // crash, fall, sudden_stop
  final List<Map<String, String>> emergencyContacts;

  const AccidentDetectionScreen({
    Key? key,
    required this.userId,
    required this.impactForce,
    required this.detectionType,
    required this.emergencyContacts,
  }) : super(key: key);

  @override
  State<AccidentDetectionScreen> createState() => _AccidentDetectionScreenState();
}

class _AccidentDetectionScreenState extends State<AccidentDetectionScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _countdownController;
  late AnimationController _pulseController;
  late AnimationController _impactWaveController;
  late AnimationController _alertController;

  // Services
  final EmergencyService _emergencyService = EmergencyService();
  final DTNService _dtnService = DTNService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Battery _battery = Battery();

  // Timers
  Timer? _countdownTimer;
  Timer? _sensorMonitorTimer;
  int countdown = 10;

  // Network & Status
  bool _hasInternet = false;
  bool _isLocationAcquired = false;
  bool _emergencyTriggered = false;
  bool _dtnModeActive = false;
  String _sessionId = '';

  // Location
  Position? _currentLocation;
  String _locationText = 'Acquiring GPS...';
  double _locationAccuracy = 0;

  // Sensor data
  double _currentAcceleration = 0;
  String _motionPattern = 'analyzing...';
  
  // Emergency packet
  Map<String, dynamic>? _emergencyPacket;

  // Stream subscriptions
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
=======
import 'dart:async';
import 'dart:math' as math;

class AccidentDetectedScreen extends StatefulWidget {
  const AccidentDetectedScreen({Key? key}) : super(key: key);

  @override
  State<AccidentDetectedScreen> createState() => _AccidentDetectedScreenState();
}

class _AccidentDetectedScreenState extends State<AccidentDetectedScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  int countdown = 10;
  late Timer _countdownTimer;
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _initializeAnimations();
    _checkConnectivity();
    _acquireLocation();
    _monitorSensors();
    _startCountdown();
    _prepareEmergencyPacket();
    
    // Critical vibration pattern
    Vibration.vibrate(
      pattern: [0, 1000, 300, 1000, 300, 1000],
      intensities: [0, 255, 0, 255, 0, 255],
    );
  }

  void _initializeAnimations() {
    _countdownController = AnimationController(
=======
    _progressController = AnimationController(
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
      vsync: this,
      duration: const Duration(seconds: 10),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
<<<<<<< HEAD
      duration: const Duration(milliseconds: 800),
    )..repeat();

    _impactWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _alertController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  Future<void> _checkConnectivity() async {
    final connectivity = Connectivity();
    final results = await connectivity.checkConnectivity();
    
    setState(() {
      _hasInternet = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);
    });

    _connectivitySubscription = connectivity.onConnectivityChanged.listen((results) {
      final wasOffline = !_hasInternet;
      
      setState(() {
        _hasInternet = results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.wifi) ||
            results.contains(ConnectivityResult.ethernet);
      });

      // If we just came online and have pending emergency
      if (wasOffline && _hasInternet && _dtnModeActive) {
        _syncDTNToOnline();
      }
    });
  }

  Future<void> _acquireLocation() async {
    try {
      // Try to get last known position first (faster)
      Position? position = await Geolocator.getLastKnownPosition();
      
      if (position != null) {
        _updateLocation(position);
      }

      // Start high-accuracy tracking
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      );

      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        _updateLocation(position);
      }, onError: (error) {
        debugPrint('❌ Location error: $error');
        setState(() {
          _locationText = 'GPS unavailable';
        });
      });
    } catch (e) {
      debugPrint('❌ Location acquisition failed: $e');
      setState(() {
        _locationText = 'GPS unavailable';
      });
    }
  }

  void _updateLocation(Position position) {
    setState(() {
      _currentLocation = position;
      _locationAccuracy = position.accuracy;
      _isLocationAcquired = true;
      _locationText = 'GPS: ${position.latitude.toStringAsFixed(4)}, '
          '${position.longitude.toStringAsFixed(4)}';
    });

    // Update emergency packet with location
    if (_emergencyPacket != null) {
      _emergencyPacket!['location'] = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': position.timestamp?.toIso8601String(),
      };
    }
  }

  void _monitorSensors() {
    // Monitor accelerometer for continued motion patterns
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      final acceleration = math.sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      setState(() {
        _currentAcceleration = acceleration;
        
        // Analyze motion pattern
        if (acceleration < 2) {
          _motionPattern = 'No movement detected';
        } else if (acceleration < 8) {
          _motionPattern = 'Minor motion';
        } else if (acceleration < 15) {
          _motionPattern = 'Significant motion';
        } else {
          _motionPattern = 'Severe impact detected';
        }
      });
    });

    // Periodic sensor health check
    _sensorMonitorTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        // Check if device is stationary (possible unconscious user)
        if (_currentAcceleration < 1.5 && countdown <= 5) {
          debugPrint('⚠️ Device stationary - user may be unconscious');
        }
      }
    });
  }

  Future<void> _prepareEmergencyPacket() async {
    final batteryLevel = await _battery.batteryLevel;
    
    _sessionId = 'accident_${DateTime.now().millisecondsSinceEpoch}_${widget.userId}';
    
    _emergencyPacket = {
      'sessionId': _sessionId,
      'userId': widget.userId,
      'emergencyType': 'accident_detected',
      'detectionType': widget.detectionType,
      'impactForce': widget.impactForce,
      'timestamp': DateTime.now().toIso8601String(),
      'location': _currentLocation != null ? {
        'latitude': _currentLocation!.latitude,
        'longitude': _currentLocation!.longitude,
        'accuracy': _currentLocation!.accuracy,
        'timestamp': _currentLocation!.timestamp?.toIso8601String(),
      } : null,
      'deviceStatus': {
        'battery': batteryLevel,
        'hasInternet': _hasInternet,
        'locationAcquired': _isLocationAcquired,
      },
      'emergencyContacts': widget.emergencyContacts,
      'motionPattern': _motionPattern,
      'acceleration': _currentAcceleration,
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Persist locally immediately
    await _saveEmergencyPacketLocally();
  }

  Future<void> _saveEmergencyPacketLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_emergency', jsonEncode(_emergencyPacket));
      debugPrint('💾 Emergency packet saved locally');
    } catch (e) {
      debugPrint('❌ Failed to save emergency packet: $e');
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (countdown > 0) {
        setState(() => countdown--);
        
        // Escalating vibration
        if (countdown <= 3) {
          Vibration.vibrate(duration: 200, amplitude: 255);
        } else if (countdown <= 5) {
          Vibration.vibrate(duration: 100);
        }
      } else {
        timer.cancel();
        _triggerEmergency();
=======
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
        // SOS would be sent automatically here
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
      }
    });
  }

<<<<<<< HEAD
  Future<void> _triggerEmergency() async {
    if (_emergencyTriggered) return;
    
    setState(() => _emergencyTriggered = true);
    
    // Final critical vibration
    Vibration.vibrate(duration: 1500, amplitude: 255);

    if (_hasInternet) {
      await _triggerOnlineEmergency();
    } else {
      await _triggerDTNEmergency();
    }
  }

  Future<void> _triggerOnlineEmergency() async {
    try {
      debugPrint('🌐 Triggering ONLINE emergency');
      
      // Create emergency session via EmergencyService
      final sessionId = await _emergencyService.createEmergencySession(
        userId: widget.userId,
        triggerType: 'accident_${widget.detectionType}',
        emergencyContacts: widget.emergencyContacts,
        initialLocation: _currentLocation,
        additionalData: {
          'impactForce': widget.impactForce,
          'detectionType': widget.detectionType,
          'motionPattern': _motionPattern,
          'autoDetected': true,
        },
      );

      // Log to Firestore
      await _firestore.collection('accident_detections').add({
        'sessionId': sessionId,
        'userId': widget.userId,
        'impactForce': widget.impactForce,
        'detectionType': widget.detectionType,
        'location': _currentLocation != null ? {
          'latitude': _currentLocation!.latitude,
          'longitude': _currentLocation!.longitude,
        } : null,
        'timestamp': FieldValue.serverTimestamp(),
        'triggered': true,
        'mode': 'online',
      });

      // Clear local emergency packet
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pending_emergency');

      _showSuccessMessage('Emergency sent to all contacts');
      
      // Navigate to emergency active screen
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToEmergencyActive();
      
    } catch (e) {
      debugPrint('❌ Online emergency failed: $e');
      // Fallback to DTN
      await _triggerDTNEmergency();
    }
  }

  Future<void> _triggerDTNEmergency() async {
    try {
      debugPrint('📡 Triggering DTN emergency (OFFLINE MODE)');
      
      setState(() => _dtnModeActive = true);
      
      // Initialize DTN service
      await _dtnService.initialize(
        userId: widget.userId,
        emergencyPacket: _emergencyPacket!,
      );

      // Start DTN broadcasting
      await _dtnService.startBroadcasting();

      _showWarningMessage('Offline mode - Broadcasting via DTN');
      
      // Navigate to Emergency Beacon Screen
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToDTNBeacon();
      
    } catch (e) {
      debugPrint('❌ DTN emergency failed: $e');
      _showErrorMessage('Failed to trigger emergency');
    }
  }

  Future<void> _syncDTNToOnline() async {
    try {
      debugPrint('🔄 Syncing DTN to Online');
      
      // Get DTN packet
      final dtnPacket = await _dtnService.getEmergencyPacket();
      
      if (dtnPacket != null) {
        // Upload to Firestore
        await _firestore
            .collection('emergency_sessions')
            .doc(dtnPacket['sessionId'])
            .set({
          ...dtnPacket,
          'syncedFromDTN': true,
          'syncTimestamp': FieldValue.serverTimestamp(),
        });

        // Send notifications
        await _emergencyService.createEmergencySession(
          userId: widget.userId,
          triggerType: 'accident_${widget.detectionType}_dtn_sync',
          emergencyContacts: widget.emergencyContacts,
          initialLocation: _currentLocation,
          additionalData: dtnPacket,
        );

        _showSuccessMessage('Emergency synced to cloud');
        
        // Stop DTN mode
        await _dtnService.stopBroadcasting();
        setState(() => _dtnModeActive = false);
      }
    } catch (e) {
      debugPrint('❌ DTN sync failed: $e');
    }
  }

  Future<void> _sendSOSNow() async {
    HapticFeedback.heavyImpact();
    _countdownTimer?.cancel();
    countdown = 0;
    await _triggerEmergency();
  }

  Future<void> _cancelEmergency() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF40916C), size: 28),
            SizedBox(width: 12),
            Text('Are You Safe?', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'This will cancel the emergency alert. Only confirm if you are uninjured.',
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No, Send SOS', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF40916C),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Yes, I\'m Safe', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    HapticFeedback.mediumImpact();
    _countdownTimer?.cancel();

    try {
      // Cancel in both modes
      if (_hasInternet) {
        await _emergencyService.cancelEmergency(
          reason: 'False detection - User confirmed safe',
        );
      }
      
      if (_dtnModeActive) {
        await _dtnService.broadcastCancellation(_sessionId);
      }

      // Log cancellation
      await _firestore.collection('accident_detections').add({
        'sessionId': _sessionId,
        'userId': widget.userId,
        'impactForce': widget.impactForce,
        'detectionType': widget.detectionType,
        'timestamp': FieldValue.serverTimestamp(),
        'triggered': false,
        'cancelled': true,
        'cancellationReason': 'User confirmed safe',
      });

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pending_emergency');

      _showSuccessMessage('Emergency cancelled');
      
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      Navigator.popUntil(context, (route) => route.isFirst);
      
    } catch (e) {
      debugPrint('❌ Cancellation failed: $e');
      _showErrorMessage('Failed to cancel');
    }
  }

  void _navigateToEmergencyActive() {
    // Navigate to active emergency monitoring screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text(
              'Emergency Active - Navigate to monitoring screen',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDTNBeacon() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EmergencyBeaconScreen(
          sessionId: _sessionId,
          emergencyPacket: _emergencyPacket!,
          userId: widget.userId,
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF40916C),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showWarningMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFFFAA00),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFFF5252),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _sensorMonitorTimer?.cancel();
    _connectivitySubscription?.cancel();
    _locationSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    
    _countdownController.dispose();
    _pulseController.dispose();
    _impactWaveController.dispose();
    _alertController.dispose();
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Vibration.cancel();
    
=======
  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _countdownTimer.cancel();
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: SafeArea(
          child: Column(
            children: [
              _buildAlertHeader(),
              const SizedBox(height: 20),
              _buildStatusIndicators(),
              const SizedBox(height: 24),
              _buildDetectionInfo(),
              const SizedBox(height: 32),
              Expanded(child: _buildCountdownDisplay()),
              const SizedBox(height: 32),
              _buildActionButtons(),
              const SizedBox(height: 24),
              _buildFooterInfo(),
              const SizedBox(height: 20),
            ],
          ),
=======
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildCriticalAlertHeader(),
            const SizedBox(height: 30),
            _buildAccidentTitle(),
            const SizedBox(height: 40),
            Expanded(
              child: _buildCountdownTimer(),
            ),
            const SizedBox(height: 30),
            _buildSendingStatus(),
            const SizedBox(height: 30),
            _buildLocationSection(),
            const SizedBox(height: 30),
            _buildCancelInfo(),
            const SizedBox(height: 20),
            _buildSafeButton(),
            const SizedBox(height: 16),
            _buildCallButton(),
            const SizedBox(height: 20),
          ],
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildAlertHeader() {
    return AnimatedBuilder(
      animation: _alertController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(
                  const Color(0xFFFF3030),
                  const Color(0xFFFF5252),
                  _alertController.value,
                )!,
                const Color(0xFFFF5252),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF5252).withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.emergency, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Text(
                    'ACCIDENT DETECTED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getDetectionTypeText(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDetectionTypeText() {
    switch (widget.detectionType) {
      case 'crash':
        return 'Vehicle Crash Detected';
      case 'fall':
        return 'Severe Fall Detected';
      case 'sudden_stop':
        return 'Sudden Impact Detected';
      default:
        return 'Impact Detected';
    }
  }

  Widget _buildStatusIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusCard(
              _hasInternet ? Icons.wifi : Icons.wifi_off,
              _hasInternet ? 'ONLINE' : 'OFFLINE',
              _hasInternet ? const Color(0xFF40916C) : const Color(0xFFFF5252),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              _isLocationAcquired ? Icons.gps_fixed : Icons.gps_not_fixed,
              _isLocationAcquired ? 'GPS OK' : 'ACQUIRING',
              _isLocationAcquired ? const Color(0xFF40916C) : const Color(0xFFFFAA00),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusCard(
              Icons.sensors,
              '${widget.impactForce.toStringAsFixed(1)}G',
              widget.impactForce > 20 ? const Color(0xFFFF5252) : const Color(0xFFFFAA00),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
=======
  Widget _buildCriticalAlertHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF5252),
            Color(0xFFFF6B6B),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.warning,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(width: 12),
          Text(
            'CRITICAL ALERT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildDetectionInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LOCATION',
                    style: TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _locationText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (_locationAccuracy > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getAccuracyColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '±${_locationAccuracy.toStringAsFixed(0)}m',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MOTION ANALYSIS',
                    style: TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _motionPattern,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF5252)),
                ),
                child: Text(
                  '${_currentAcceleration.toStringAsFixed(1)} m/s²',
                  style: const TextStyle(
                    color: Color(0xFFFF5252),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getAccuracyColor() {
    if (_locationAccuracy <= 10) return const Color(0xFF40916C);
    if (_locationAccuracy <= 50) return const Color(0xFFFFAA00);
    return const Color(0xFFFF5252);
  }

  Widget _buildCountdownDisplay() {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _countdownController,
          _pulseController,
          _impactWaveController,
        ]),
        builder: (context, child) {
          final pulseValue = math.sin(_pulseController.value * 2 * math.pi);
          final waveValue = _impactWaveController.value;
          
          return Stack(
            alignment: Alignment.center,
            children: [
              // Impact waves
              for (int i = 0; i < 3; i++)
                Container(
                  width: 300 + (waveValue * 150) + (i * 40),
                  height: 300 + (waveValue * 150) + (i * 40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF5252).withOpacity(
                        (1 - waveValue) * (1 - i * 0.3),
                      ),
                      width: 3,
                    ),
                  ),
                ),
              // Pulsing glow
              Container(
                width: 280 + (pulseValue * 20),
                height: 280 + (pulseValue * 20),
=======
  Widget _buildAccidentTitle() {
    return Column(
      children: const [
        Text(
          'POSSIBLE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            height: 1.1,
          ),
        ),
        Text(
          'ACCIDENT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            height: 1.1,
          ),
        ),
        Text(
          'DETECTED',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownTimer() {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_progressController, _pulseController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing background glow
              Container(
                width: 280 + (math.sin(_pulseController.value * 2 * math.pi) * 20),
                height: 280 + (math.sin(_pulseController.value * 2 * math.pi) * 20),
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
<<<<<<< HEAD
                      const Color(0xFFFF5252).withOpacity(0.4),
=======
                      const Color(0xFFFF5252).withOpacity(0.3),
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Progress ring
              SizedBox(
<<<<<<< HEAD
                width: 250,
                height: 250,
                child: Transform.rotate(
                  angle: -math.pi / 2,
                  child: CircularProgressIndicator(
                    value: _countdownController.value,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFF2A1A1A),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF5252),
                    ),
                  ),
                ),
              ),
              // Inner circle
              Container(
                width: 220,
                height: 220,
=======
                width: 240,
                height: 240,
                child: Transform.rotate(
                  angle: -math.pi / 2,
                  child: CircularProgressIndicator(
                    value: _progressController.value,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFF2A1A1A),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)),
                  ),
                ),
              ),
              // Dark background circle
              Container(
                width: 210,
                height: 210,
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1A0A0A),
                ),
              ),
<<<<<<< HEAD
              // Countdown
=======
              // Countdown number
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    countdown.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 90,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'SECONDS',
                    style: TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
<<<<<<< HEAD
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFF5252)),
                    ),
                    child: const Text(
                      'Auto-sending SOS',
                      style: TextStyle(
                        color: Color(0xFFFF5252),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
=======
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
                ],
              ),
            ],
          );
        },
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Text(
            'If this is a false alarm, cancel now',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF808080),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          // I'm Safe Button
          GestureDetector(
            onTap: _cancelEmergency,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF40916C), Color(0xFF52B788)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF40916C).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'I\'M SAFE - CANCEL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Send SOS Now Button
          GestureDetector(
            onTap: _sendSOSNow,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF5252), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.emergency_share, color: Color(0xFFFF5252), size: 24),
                  SizedBox(width: 12),
                  Text(
                    'SEND SOS NOW',
                    style: TextStyle(
                      color: Color(0xFFFF5252),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
=======
  Widget _buildSendingStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1A1A),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF5252),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF5252),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Sending SOS via SMS in ${countdown}s...',
            style: const TextStyle(
              color: Color(0xFF808080),
              fontSize: 15,
              fontWeight: FontWeight.w600,
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
            ),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildFooterInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _hasInternet ? Icons.cloud : Icons.bluetooth,
            color: _hasInternet ? const Color(0xFF40916C) : const Color(0xFF00E5CC),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            _hasInternet
                ? 'Emergency will be sent via Internet'
                : 'Emergency will be sent via DTN Mesh',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
=======
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'LOCATION OF EVENT',
            style: TextStyle(
              color: Color(0xFF808080),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Map placeholder
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFD0D0D0),
                        Color(0xFFE8E8E8),
                      ],
                    ),
                  ),
                ),
                // Placeholder dimensions text
                const Center(
                  child: Text(
                    '300×300',
                    style: TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 24,
                    ),
                  ),
                ),
                // Location marker
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF5252).withOpacity(0.2),
                    ),
                    child: Center(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5252),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '37.7749° N, 122.4194° W',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Accuracy: 5m',
                style: TextStyle(
                  color: Color(0xFF808080),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCancelInfo() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Tap if you are uninjured to cancel emergency\nprotocols',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF808080),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSafeButton() {
    return GestureDetector(
      onTap: () {
        // Cancel the emergency and go back
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF5252),
              Color(0xFFFF6B6B),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5252).withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text(
              'I AM SAFE / CANCEL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton() {
    return GestureDetector(
      onTap: () {
        // Trigger manual call to 911
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF3A3A3A), width: 1),
        ),
        child: const Center(
          child: Text(
            'MANUALLY CALL 911',
            style: TextStyle(
              color: Color(0xFF808080),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
      ),
    );
  }
}