import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// ============================================================================
// BLUETOOTH DEVICE MODEL
// ============================================================================
class BluetoothDeviceInfo {
  final String id;
  final String name;
  final int rssi;
  final DateTime lastSeen;
  final String deviceType;

  BluetoothDeviceInfo({
    required this.id,
    required this.name,
    required this.rssi,
    required this.lastSeen,
    required this.deviceType,
  });

  int get signalStrength {
    if (rssi >= -50) return 5;
    if (rssi >= -60) return 4;
    if (rssi >= -70) return 3;
    if (rssi >= -80) return 2;
    return 1;
  }

  String get distance {
    if (rssi >= -50) return '<1m';
    if (rssi >= -60) return '1-3m';
    if (rssi >= -70) return '3-5m';
    if (rssi >= -80) return '5-10m';
    return '>10m';
  }

  IconData get deviceIcon {
    if (deviceType.contains('phone')) return Icons.phone_android;
    if (deviceType.contains('computer')) return Icons.computer;
    if (deviceType.contains('headphones')) return Icons.headphones;
    if (deviceType.contains('watch')) return Icons.watch;
    return Icons.devices;
  }
}

// ============================================================================
// ACCIDENT DETECTION SCREEN
// ============================================================================
class AccidentDetectionScreen extends StatefulWidget {
  final String userId;
  final double impactForce;
  final String detectionType;
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
  late AnimationController _glowController;
  late AnimationController _shakeController;
  late AnimationController _rippleController;

  // Timers
  Timer? _countdownTimer;
  Timer? _simulationTimer;
  int countdown = 10;

  // Status flags
  bool _hasInternet = true;
  bool _isLocationAcquired = false;
  bool _emergencyTriggered = false;
  bool _bluetoothEnabled = false;
  bool _isBluetoothScanning = false;
  
  // Data
  String _locationText = 'Acquiring GPS...';
  double _locationAccuracy = 0;
  double _currentAcceleration = 8.5;
  String _motionPattern = 'Analyzing motion...';
  int _batteryLevel = 87;
  String _sessionId = '';

  // Bluetooth
  final Map<String, BluetoothDeviceInfo> _nearbyDevices = {};
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _initializeAnimations();
    _startCountdown();
    _startSimulation();
    _generateSessionId();
    _simulateLocationAcquisition();
    _initializeBluetooth();
    
    // Haptic feedback
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 500), () {
      HapticFeedback.mediumImpact();
    });
  }

  void _initializeAnimations() {
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  void _generateSessionId() {
    _sessionId = 'EMG_${DateTime.now().millisecondsSinceEpoch}_${widget.userId.substring(0, 8)}';
  }

  // ============================================================================
  // BLUETOOTH IMPLEMENTATION
  // ============================================================================
  
  Future<void> _initializeBluetooth() async {
    try {
      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        debugPrint("Bluetooth not supported by this device");
        return;
      }

      // Listen to Bluetooth adapter state
      _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
        if (mounted) {
          setState(() {
            _bluetoothEnabled = state == BluetoothAdapterState.on;
          });
          
          if (state == BluetoothAdapterState.on && !_isBluetoothScanning) {
            _startBluetoothScan();
          } else if (state != BluetoothAdapterState.on) {
            _stopBluetoothScan();
          }
        }
      });

      // Request permissions
      await _requestBluetoothPermissions();
      
      // Check initial state
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState == BluetoothAdapterState.on) {
        _startBluetoothScan();
      } else {
        // Try to turn on Bluetooth (Android only)
        if (Theme.of(context).platform == TargetPlatform.android) {
          await FlutterBluePlus.turnOn();
        }
      }
    } catch (e) {
      debugPrint("Error initializing Bluetooth: $e");
    }
  }

  Future<void> _requestBluetoothPermissions() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      // Android 12+ requires different permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      bool allGranted = statuses.values.every((status) => status.isGranted);
      
      if (!allGranted) {
        debugPrint("Bluetooth permissions not granted");
      }
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      // iOS permissions are handled automatically
      await Permission.bluetooth.request();
    }
  }

  Future<void> _startBluetoothScan() async {
    if (_isBluetoothScanning) return;

    try {
      setState(() => _isBluetoothScanning = true);

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 30),
        androidUsesFineLocation: true,
      );

      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          if (!mounted) return;

          for (ScanResult result in results) {
            final device = result.device;
            final rssi = result.rssi;
            
            // Get device name (may be empty for some devices)
            String deviceName = device.platformName.isNotEmpty 
                ? device.platformName 
                : device.remoteId.toString().substring(0, 17);

            // Determine device type from advertised data
            String deviceType = _determineDeviceType(result);

            // Update or add device
            setState(() {
              _nearbyDevices[device.remoteId.toString()] = BluetoothDeviceInfo(
                id: device.remoteId.toString(),
                name: deviceName,
                rssi: rssi,
                lastSeen: DateTime.now(),
                deviceType: deviceType,
              );
            });
          }

          // Remove devices not seen in last 10 seconds
          _cleanupStaleDevices();
        },
        onError: (e) {
          debugPrint("Scan error: $e");
        },
      );
    } catch (e) {
      debugPrint("Error starting Bluetooth scan: $e");
      setState(() => _isBluetoothScanning = false);
    }
  }

  String _determineDeviceType(ScanResult result) {
    // Check service UUIDs to determine device type
    final serviceUuids = result.advertisementData.serviceUuids;
    
    // Common Bluetooth service UUIDs
    if (serviceUuids.any((uuid) => uuid.toString().contains('180f'))) {
      return 'phone'; // Battery service - common in phones
    } else if (serviceUuids.any((uuid) => uuid.toString().contains('180a'))) {
      return 'computer'; // Device Information - common in computers
    } else if (serviceUuids.any((uuid) => uuid.toString().contains('110b'))) {
      return 'headphones'; // Audio Sink - headphones/speakers
    } else if (serviceUuids.any((uuid) => uuid.toString().contains('1816'))) {
      return 'watch'; // Cycling Speed and Cadence - fitness devices
    }
    
    // Fallback: try to guess from device name
    final name = result.device.platformName.toLowerCase();
    if (name.contains('phone') || name.contains('iphone') || name.contains('galaxy')) {
      return 'phone';
    } else if (name.contains('mac') || name.contains('laptop') || name.contains('pc')) {
      return 'computer';
    } else if (name.contains('airpod') || name.contains('headphone') || name.contains('buds')) {
      return 'headphones';
    } else if (name.contains('watch') || name.contains('band') || name.contains('fit')) {
      return 'watch';
    }
    
    return 'unknown';
  }

  void _cleanupStaleDevices() {
    final now = DateTime.now();
    final staleDeviceIds = <String>[];

    for (var entry in _nearbyDevices.entries) {
      if (now.difference(entry.value.lastSeen).inSeconds > 10) {
        staleDeviceIds.add(entry.key);
      }
    }

    if (staleDeviceIds.isNotEmpty) {
      setState(() {
        for (var id in staleDeviceIds) {
          _nearbyDevices.remove(id);
        }
      });
    }
  }

  Future<void> _stopBluetoothScan() async {
    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      setState(() => _isBluetoothScanning = false);
    } catch (e) {
      debugPrint("Error stopping Bluetooth scan: $e");
    }
  }

  // ============================================================================
  // COUNTDOWN & EMERGENCY LOGIC
  // ============================================================================

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (countdown > 0) {
        setState(() => countdown--);
        
        if (countdown <= 3) {
          HapticFeedback.heavyImpact();
          _shakeController.forward(from: 0);
        } else if (countdown <= 5) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.lightImpact();
        }
      } else {
        timer.cancel();
        _triggerEmergency();
      }
    });
  }

  void _startSimulation() {
    final random = math.Random();
    
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      
      setState(() {
        // Simulate motion analysis
        _currentAcceleration = 8.0 + random.nextDouble() * 2.0;
        
        if (_currentAcceleration < 3) {
          _motionPattern = 'No movement detected';
        } else if (_currentAcceleration < 6) {
          _motionPattern = 'Minor motion detected';
        } else if (_currentAcceleration < 9) {
          _motionPattern = 'Significant motion';
        } else {
          _motionPattern = 'Severe impact pattern';
        }

        // Randomly toggle internet (simulating network issues)
        if (random.nextDouble() > 0.9) {
          _hasInternet = !_hasInternet;
        }
      });
    });
  }

  void _simulateLocationAcquisition() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLocationAcquired = true;
          _locationText = '37.7749° N, 122.4194° W';
          _locationAccuracy = 8.5;
        });
      }
    });
  }

  Future<void> _triggerEmergency() async {
    if (_emergencyTriggered) return;
    
    setState(() => _emergencyTriggered = true);
    HapticFeedback.heavyImpact();

    await Future.delayed(const Duration(milliseconds: 500));
    HapticFeedback.heavyImpact();

    if (mounted) {
      _showEmergencyDialog(
        'Emergency Activated',
        _hasInternet
            ? 'Emergency alert sent to all contacts via SMS, call, and app notification.'
            : 'Emergency broadcast initiated via Bluetooth mesh and DTN network.',
        true,
      );
    }

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context); // Close dialog
      _navigateToActiveEmergency();
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
      builder: (context) => _buildCancelDialog(),
    );

    if (confirmed != true) return;

    HapticFeedback.mediumImpact();
    _countdownTimer?.cancel();

    _showEmergencyDialog(
      'Emergency Cancelled',
      'You have confirmed you are safe. The emergency alert has been cancelled.',
      false,
    );

    await Future.delayed(const Duration(seconds: 2));
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  void _navigateToActiveEmergency() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emergency,
                    color: Color(0xFFFF4444),
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'EMERGENCY ACTIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Help is on the way',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF88),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Return to Home',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEmergencyDialog(String title, String message, bool isAlert) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildEmergencyDialog(title, message, isAlert),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _simulationTimer?.cancel();
    _scanSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    _stopBluetoothScan();
    _countdownController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _shakeController.dispose();
    _rippleController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0A0A0A),
                const Color(0xFF1A0505),
                const Color(0xFF0A0A0A),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                _buildAnimatedBackground(),
                _buildMainContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(4, (index) {
            final progress = (_rippleController.value + index * 0.25) % 1.0;
            final size = MediaQuery.of(context).size.width * (1 + progress * 2);
            final opacity = (1 - progress) * 0.05;

            return Positioned(
              top: MediaQuery.of(context).size.height / 2 - size / 2,
              left: MediaQuery.of(context).size.width / 2 - size / 2,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFF4444).withOpacity(opacity),
                    width: 2,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAlertHeader(),
            const SizedBox(height: 24),
            _buildQuickStats(),
            const SizedBox(height: 28),
            _buildCountdownCircle(),
            const SizedBox(height: 28),
            _buildDetailsCard(),
            const SizedBox(height: 20),
            if (_nearbyDevices.isNotEmpty) _buildBluetoothSection(),
            if (_nearbyDevices.isNotEmpty) const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 16),
            _buildNetworkStatus(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertHeader() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(
                  const Color(0xFFFF4444),
                  const Color(0xFFFF2020),
                  _glowController.value,
                )!.withOpacity(0.2),
                const Color(0xFFFF4444).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFF4444).withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4444).withOpacity(0.3),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ACCIDENT DETECTED',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getDetectionTypeText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
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
        return 'VEHICLE CRASH IMPACT';
      case 'fall':
        return 'SEVERE FALL DETECTED';
      case 'sudden_stop':
        return 'SUDDEN IMPACT EVENT';
      default:
        return 'HIGH IMPACT DETECTED';
    }
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: _hasInternet ? Icons.wifi : Icons.wifi_off,
            label: 'Network',
            value: _hasInternet ? 'Online' : 'Offline',
            color: _hasInternet ? const Color(0xFF00FF88) : const Color(0xFFFF4444),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: _isLocationAcquired ? Icons.gps_fixed : Icons.gps_not_fixed,
            label: 'GPS',
            value: _isLocationAcquired ? '±${_locationAccuracy.toInt()}m' : 'Acquiring',
            color: _isLocationAcquired ? const Color(0xFF00FF88) : const Color(0xFFFFAA00),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.bluetooth,
            label: 'Nearby',
            value: '${_nearbyDevices.length}',
            color: _bluetoothEnabled ? const Color(0xFF4A9EFF) : const Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownCircle() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _countdownController,
        _pulseController,
        _glowController,
        _shakeController,
      ]),
      builder: (context, child) {
        final pulseValue = math.sin(_pulseController.value * 2 * math.pi);
        final glowValue = _glowController.value;
        final shakeValue = math.sin(_shakeController.value * math.pi * 4) * 8;

        return Transform.translate(
          offset: Offset(shakeValue, 0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ripples
              for (int i = 0; i < 3; i++)
                Container(
                  width: 300 + (i * 40) + (pulseValue * 20),
                  height: 300 + (i * 40) + (pulseValue * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF4444).withOpacity(
                        (0.4 - i * 0.12) * (1 - _pulseController.value),
                      ),
                      width: 2,
                    ),
                  ),
                ),
              
              // Progress ring
              SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: _countdownController.value,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.lerp(
                      const Color(0xFFFF8080),
                      const Color(0xFFFF2020),
                      glowValue,
                    )!,
                  ),
                ),
              ),

              // Center circle
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color.lerp(
                        const Color(0xFFFF5555),
                        const Color(0xFFFF3333),
                        glowValue,
                      )!.withOpacity(0.6),
                      const Color(0xFFFF2020).withOpacity(0.4),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4444).withOpacity(0.6),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      countdown.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 100,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      countdown == 1 ? 'SECOND' : 'SECONDS',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A9EFF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4A9EFF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF4A9EFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Impact Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            Icons.my_location,
            'Location',
            _locationText,
            const Color(0xFF00FF88),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 24),
          _buildDetailRow(
            Icons.speed,
            'Impact Force',
            '${widget.impactForce.toStringAsFixed(1)}G',
            const Color(0xFFFF4444),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 24),
          _buildDetailRow(
            Icons.analytics,
            'Motion Pattern',
            _motionPattern,
            const Color(0xFFFFAA00),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 24),
          _buildDetailRow(
            Icons.battery_charging_full,
            'Battery',
            '$_batteryLevel%',
            _batteryLevel > 20 ? const Color(0xFF00FF88) : const Color(0xFFFF4444),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 24),
          _buildDetailRow(
            Icons.fingerprint,
            'Session ID',
            _sessionId,
            const Color(0xFF4A9EFF),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBluetoothSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              const Icon(
                Icons.bluetooth_connected,
                color: Color(0xFF4A9EFF),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Nearby Devices (${_nearbyDevices.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              if (_isBluetoothScanning)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A9EFF)),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _nearbyDevices.length,
            itemBuilder: (context, index) {
              final device = _nearbyDevices.values.elementAt(index);
              return _buildBluetoothCard(device);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBluetoothCard(BluetoothDeviceInfo device) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A9EFF).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                device.deviceIcon,
                color: const Color(0xFF4A9EFF),
                size: 24,
              ),
              Row(
                children: List.generate(
                  device.signalStrength,
                  (i) => Container(
                    width: 3,
                    height: 10 + (i * 2.5),
                    margin: const EdgeInsets.only(left: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF88),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            device.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                device.distance,
                style: const TextStyle(
                  color: Color(0xFF00FF88),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${device.rssi} dBm',
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Text(
          'Emergency will be sent in ${countdown}s',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        
        // I'm Safe Button
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00FF88), Color(0xFF00CC6E)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF88).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _cancelEmergency,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'I\'M SAFE - CANCEL',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Send SOS Now Button
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFF4444).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _sendSOSNow,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emergency_share,
                    color: Color(0xFFFF4444),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'SEND SOS NOW',
                    style: TextStyle(
                      color: Color(0xFFFF4444),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _hasInternet ? Icons.cloud_done : Icons.bluetooth,
            color: _hasInternet ? const Color(0xFF00FF88) : const Color(0xFF4A9EFF),
            size: 18,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              _hasInternet
                  ? 'Alert will be sent via Internet'
                  : 'Alert will broadcast via Bluetooth & DTN',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelDialog() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: const Color(0xFF00FF88).withOpacity(0.3),
            width: 2,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00FF88).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF00FF88),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Are You Safe?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This will cancel the emergency alert. Only confirm if you are completely safe and uninjured.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'No, Send Alert',
              style: TextStyle(
                color: Color(0xFFFF4444),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00FF88), Color(0xFF00CC6E)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Yes, I\'m Safe',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyDialog(String title, String message, bool isAlert) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: (isAlert ? const Color(0xFFFF4444) : const Color(0xFF00FF88))
                .withOpacity(0.3),
            width: 2,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isAlert ? const Color(0xFFFF4444) : const Color(0xFF00FF88))
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isAlert ? Icons.emergency : Icons.check_circle,
                color: isAlert ? const Color(0xFFFF4444) : const Color(0xFF00FF88),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}