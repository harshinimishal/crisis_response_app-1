import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:convert';

import '../services/dtn_service.dart';
import '../services/emergency_service.dart';

class EmergencyBeaconScreen extends StatefulWidget {
  final String sessionId;
  final Map<String, dynamic> emergencyPacket;
  final String userId;

  const EmergencyBeaconScreen({
    Key? key,
    required this.sessionId,
    required this.emergencyPacket,
    required this.userId,
  }) : super(key: key);
=======

class EmergencyBeaconScreen extends StatefulWidget {
  const EmergencyBeaconScreen({Key? key}) : super(key: key);
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b

  @override
  State<EmergencyBeaconScreen> createState() => _EmergencyBeaconScreenState();
}

<<<<<<< HEAD
class _EmergencyBeaconScreenState extends State<EmergencyBeaconScreen>
    with TickerProviderStateMixin {
  // Services
  final DTNService _dtnService = DTNService();
  final EmergencyService _emergencyService = EmergencyService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Battery _battery = Battery();

  // Animation controllers
  late AnimationController _beaconPulseController;
  late AnimationController _relayWaveController;
  late AnimationController _rotationController;

  // Beacon status
  bool _isBeaconActive = true;
  bool _isBroadcasting = false;
  String _privacyId = '';
  String _timeRemaining = '02:45';
  int _rotationSeconds = 180; // 3 minutes

  // DTN relay status
  String _relayStatus = 'SEARCHING';
  Color _relayStatusColor = Colors.orange;
  int _hopCount = 0;
  int _nearbyPeerCount = 0;
  DateTime? _lastRelayTimestamp;
  bool _gatewayFound = false;

  // Peers
  List<Map<String, dynamic>> _nearbyPeers = [];
  Map<String, int> _peerSignals = {};

  // Delivery status
  bool _packetDelivered = false;
  int _totalRelays = 0;
  int _activeRelays = 0;

  // Network
  bool _hasInternet = false;
  int _batteryLevel = 100;

  // Timers
  Timer? _privacyRotationTimer;
  Timer? _peerDiscoveryTimer;
  Timer? _heartbeatTimer;
  Timer? _relayCheckTimer;

  // Stream subscriptions
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<BatteryState>? _batterySubscription;

  @override
  void initState() {
    super.initState();
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _initializeAnimations();
    _initializeDTN();
    _generatePrivacyId();
    _startPrivacyRotation();
    _checkConnectivity();
    _monitorBattery();
    _startPeerDiscovery();
    _startHeartbeat();
  }

  void _initializeAnimations() {
    _beaconPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _relayWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 180),
    )..forward();
  }

  Future<void> _initializeDTN() async {
    try {
      await _dtnService.initialize(
        userId: widget.userId,
        emergencyPacket: widget.emergencyPacket,
      );

      setState(() => _isBroadcasting = true);

      await _dtnService.startBroadcasting();
      
      debugPrint('📡 DTN Beacon initialized');
      
      // Listen for DTN events
      _listenToDTNEvents();
      
    } catch (e) {
      debugPrint('❌ DTN initialization failed: $e');
      _showError('Failed to start DTN beacon');
    }
  }

  void _listenToDTNEvents() {
    // Listen for peer discoveries
    _dtnService.peerStream.listen((peers) {
      setState(() {
        _nearbyPeers = peers;
        _nearbyPeerCount = peers.length;
        _updateRelayStatus();
      });
    });

    // Listen for relay events
    _dtnService.relayStream.listen((event) {
      setState(() {
        _totalRelays++;
        _lastRelayTimestamp = DateTime.now();
        _updateRelayStatus();
      });
    });

    // Listen for gateway detection
    _dtnService.gatewayStream.listen((gateway) {
      if (gateway != null) {
        _onGatewayFound(gateway);
      }
    });

    // Listen for delivery confirmation
    _dtnService.deliveryStream.listen((delivered) {
      if (delivered) {
        _onPacketDelivered();
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final connectivity = Connectivity();
    final results = await connectivity.checkConnectivity();
    
    setState(() {
      _hasInternet = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);
    });

    if (_hasInternet) {
      _attemptCloudSync();
    }

    _connectivitySubscription = connectivity.onConnectivityChanged.listen((results) {
      final wasOffline = !_hasInternet;
      
      setState(() {
        _hasInternet = results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.wifi) ||
            results.contains(ConnectivityResult.ethernet);
      });

      if (wasOffline && _hasInternet) {
        _attemptCloudSync();
      }
    });
  }

  Future<void> _monitorBattery() async {
    _batteryLevel = await _battery.batteryLevel;
    setState(() {});

    _batterySubscription = _battery.onBatteryStateChanged.listen((state) async {
      _batteryLevel = await _battery.batteryLevel;
      
      // Optimize for low battery
      if (_batteryLevel <= 20 && _batteryLevel > 10) {
        _optimizeForLowBattery();
      } else if (_batteryLevel <= 10) {
        _enterUltraLowPowerMode();
      }
      
      setState(() {});
    });
  }

  void _optimizeForLowBattery() {
    debugPrint('🔋 Low battery - optimizing');
    // Reduce broadcast frequency
    _dtnService.setBroadcastInterval(const Duration(seconds: 30));
  }

  void _enterUltraLowPowerMode() {
    debugPrint('🔋 Ultra low battery - emergency power mode');
    // Minimal broadcasts to extend battery
    _dtnService.setBroadcastInterval(const Duration(minutes: 1));
  }

  void _generatePrivacyId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = math.Random.secure();
    
    _privacyId = List.generate(
      8,
      (index) => index == 4 ? '-' : chars[random.nextInt(chars.length)],
    ).join();
    
    setState(() {});
    
    // Update DTN service with new privacy ID
    _dtnService.updatePrivacyId(_privacyId);
  }

  void _startPrivacyRotation() {
    _rotationSeconds = 180;
    
    _privacyRotationTimer?.cancel();
    _privacyRotationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_rotationSeconds > 0) {
        _rotationSeconds--;
        final minutes = _rotationSeconds ~/ 60;
        final seconds = _rotationSeconds % 60;
        setState(() {
          _timeRemaining = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
      } else {
        _generatePrivacyId();
        _rotationSeconds = 180;
        _rotationController.reset();
        _rotationController.forward();
      }
    });
  }

  void _startPeerDiscovery() {
    _peerDiscoveryTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _dtnService.scanForPeers();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!_isBeaconActive) return;
      
      // Update local storage
      await _persistBeaconState();
      
      // Check relay health
      _checkRelayHealth();
    });
  }

  Future<void> _persistBeaconState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('beacon_state', jsonEncode({
        'sessionId': widget.sessionId,
        'isActive': _isBeaconActive,
        'privacyId': _privacyId,
        'lastHeartbeat': DateTime.now().toIso8601String(),
        'totalRelays': _totalRelays,
        'nearbyPeers': _nearbyPeerCount,
      }));
    } catch (e) {
      debugPrint('❌ Failed to persist beacon state: $e');
    }
  }

  void _checkRelayHealth() {
    if (_lastRelayTimestamp != null) {
      final timeSinceLastRelay = DateTime.now().difference(_lastRelayTimestamp!);
      
      if (timeSinceLastRelay.inMinutes > 5) {
        setState(() {
          _relayStatus = 'NO RECENT RELAYS';
          _relayStatusColor = Colors.orange;
        });
      }
    }

    // Count active relays (relayed in last 2 minutes)
    _activeRelays = _nearbyPeers.where((peer) {
      final lastSeen = peer['lastSeen'] as DateTime?;
      if (lastSeen == null) return false;
      return DateTime.now().difference(lastSeen).inMinutes < 2;
    }).length;
  }

  void _updateRelayStatus() {
    if (_gatewayFound) {
      setState(() {
        _relayStatus = 'GATEWAY FOUND';
        _relayStatusColor = const Color(0xFF40916C);
      });
    } else if (_nearbyPeerCount > 0) {
      setState(() {
        _relayStatus = 'ACTIVE HOP';
        _relayStatusColor = const Color(0xFF00E5CC);
      });
    } else {
      setState(() {
        _relayStatus = 'SEARCHING';
        _relayStatusColor = Colors.orange;
      });
    }
  }

  Future<void> _onGatewayFound(Map<String, dynamic> gateway) async {
    debugPrint('🌐 Gateway found: ${gateway['peerId']}');
    
    setState(() {
      _gatewayFound = true;
      _relayStatus = 'GATEWAY FOUND';
      _relayStatusColor = const Color(0xFF40916C);
    });

    _showSuccess('Gateway found - uploading emergency');
    
    // Attempt to sync via gateway
    await _attemptCloudSync();
  }

  Future<void> _onPacketDelivered() async {
    debugPrint('✅ Emergency packet delivered');
    
    setState(() => _packetDelivered = true);
    
    _showSuccess('Emergency delivered to network');
    
    // Optionally reduce beacon intensity after delivery
    _dtnService.setBroadcastInterval(const Duration(seconds: 60));
  }

  Future<void> _attemptCloudSync() async {
    if (!_hasInternet && !_gatewayFound) return;
    
    try {
      debugPrint('🔄 Attempting cloud sync');
      
      // Upload emergency packet to Firestore
      await _firestore
          .collection('emergency_sessions')
          .doc(widget.sessionId)
          .set({
        ...widget.emergencyPacket,
        'syncedFromDTN': true,
        'syncTimestamp': FieldValue.serverTimestamp(),
        'dtnMetrics': {
          'totalRelays': _totalRelays,
          'hopCount': _hopCount,
          'peersDiscovered': _nearbyPeerCount,
          'privacyId': _privacyId,
        },
      });

      // Send notifications via EmergencyService
      await _emergencyService.createEmergencySession(
        userId: widget.userId,
        triggerType: 'dtn_sync',
        emergencyContacts: List<Map<String, String>>.from(
          widget.emergencyPacket['emergencyContacts'] ?? [],
        ),
        additionalData: widget.emergencyPacket,
      );

      setState(() => _packetDelivered = true);
      
      _showSuccess('Emergency synced to cloud');
      
      // Show sync success dialog
      _showSyncSuccessDialog();
      
    } catch (e) {
      debugPrint('❌ Cloud sync failed: $e');
      _showError('Cloud sync failed - continuing DTN');
    }
  }

  Future<void> _toggleBeacon() async {
    HapticFeedback.mediumImpact();
    
    setState(() => _isBeaconActive = !_isBeaconActive);

    if (_isBeaconActive) {
      await _dtnService.startBroadcasting();
      _showSuccess('Beacon activated');
    } else {
      await _dtnService.stopBroadcasting();
      _showWarning('Beacon paused');
    }
  }

  Future<void> _regeneratePrivacyId() async {
    HapticFeedback.lightImpact();
    
    _generatePrivacyId();
    _rotationSeconds = 180;
    _rotationController.reset();
    _rotationController.forward();
    
    _showSuccess('Privacy ID regenerated');
  }

  Future<void> _cancelEmergency() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel Emergency?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will broadcast a cancellation packet to all peers.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF40916C),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Broadcast cancellation packet
      await _dtnService.broadcastCancellation(widget.sessionId);
      
      // Stop beacon
      await _dtnService.stopBroadcasting();
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('beacon_state');
      await prefs.remove('pending_emergency');
      
      _showSuccess('Emergency cancelled');
      
      // Navigate back
      Navigator.popUntil(context, (route) => route.isFirst);
      
    } catch (e) {
      debugPrint('❌ Cancellation failed: $e');
      _showError('Failed to cancel');
    }
  }

  void _showSyncSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.cloud_done, color: Color(0xFF40916C), size: 32),
            SizedBox(width: 12),
            Text('Synced to Cloud', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Your emergency has been uploaded and contacts have been notified.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Beacon', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelEmergency();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF40916C),
            ),
            child: const Text('End Emergency'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showWarning(String message) {
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
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
    _privacyRotationTimer?.cancel();
    _peerDiscoveryTimer?.cancel();
    _heartbeatTimer?.cancel();
    _relayCheckTimer?.cancel();
    _connectivitySubscription?.cancel();
    _batterySubscription?.cancel();
    
    _beaconPulseController.dispose();
    _relayWaveController.dispose();
    _rotationController.dispose();
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    super.dispose();
  }
=======
class _EmergencyBeaconScreenState extends State<EmergencyBeaconScreen> {
  bool isBeaconActive = true;
  String privacyId = "4X92-LZ11";
  String timeRemaining = "02:45";

  final List<Map<String, dynamic>> nearbyPeers = [
    {
      'name': 'Node-771B',
      'distance': '~12m',
      'signal': -64,
      'status': 'STRONG',
      'color': Colors.green,
    },
    {
      'name': 'Relay-Alpha',
      'distance': '~45m',
      'signal': -88,
      'status': 'FADING',
      'color': Colors.amber,
    },
    {
      'name': 'Node-Z920',
      'distance': 'Last seen 2m ago',
      'signal': -98,
      'status': 'LOST',
      'color': Colors.grey,
    },
  ];
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2D2D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2D2D),
        elevation: 0,
        leading: const Icon(Icons.bluetooth, color: Color(0xFF00E5CC)),
        title: const Text(
          'Emergency Beacon',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
<<<<<<< HEAD
        actions: [
          if (_packetDelivered)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.cloud_done, color: Color(0xFF40916C)),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              _hasInternet ? Icons.wifi : Icons.wifi_off,
              color: _hasInternet ? const Color(0xFF40916C) : const Color(0xFFFF5252),
            ),
=======
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.signal_cellular_alt, color: Color(0xFF00E5CC)),
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            _buildBeaconVisualization(),
            const SizedBox(height: 24),
            _buildBeaconModeCard(),
            const SizedBox(height: 16),
            _buildDTNRelayCard(),
            const SizedBox(height: 16),
            _buildMetricsCard(),
            const SizedBox(height: 16),
            _buildPrivacyIDCard(),
            const SizedBox(height: 24),
            _buildNearbyPeersSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 16),
=======
            // Beacon Mode Card
            _buildBeaconModeCard(),
            const SizedBox(height: 16),

            // DTN Relay Status Card
            _buildDTNRelayCard(),
            const SizedBox(height: 16),

            // Security/Privacy ID Card
            _buildPrivacyIDCard(),
            const SizedBox(height: 24),

            // Nearby Peers Section
            _buildNearbyPeersSection(),
            const SizedBox(height: 16),

            // Footer
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
            _buildFooter(),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildBeaconVisualization() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F4D4D)),
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_beaconPulseController, _relayWaveController]),
        builder: (context, child) {
          final pulseValue = math.sin(_beaconPulseController.value * 2 * math.pi);
          final waveValue = _relayWaveController.value;
          
          return Stack(
            alignment: Alignment.center,
            children: [
              // Relay waves
              if (_isBroadcasting)
                for (int i = 0; i < 4; i++)
                  Container(
                    width: 100 + (waveValue * 150) + (i * 30),
                    height: 100 + (waveValue * 150) + (i * 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00E5CC).withOpacity(
                          (1 - waveValue) * (1 - i * 0.25),
                        ),
                        width: 2,
                      ),
                    ),
                  ),
              // Central beacon
              Container(
                width: 80 + (pulseValue * 10),
                height: 80 + (pulseValue * 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00E5CC),
                      const Color(0xFF00E5CC).withOpacity(0.5),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5CC).withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  _isBeaconActive ? Icons.sensors : Icons.sensors_off,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              // Peer indicators
              ..._buildPeerIndicators(),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildPeerIndicators() {
    return List.generate(_nearbyPeerCount.clamp(0, 6), (index) {
      final angle = (index / 6) * 2 * math.pi;
      final radius = 120.0;
      
      return Positioned(
        left: 100 + radius * math.cos(angle),
        top: 100 + radius * math.sin(angle),
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF00E5CC),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      );
    });
  }

=======
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
  Widget _buildBeaconModeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF143838),
        borderRadius: BorderRadius.circular(16),
<<<<<<< HEAD
        border: Border.all(
          color: _isBeaconActive ? const Color(0xFF00E5CC) : const Color(0xFF1F4D4D),
          width: 2,
        ),
=======
        border: Border.all(color: const Color(0xFF1F4D4D), width: 1),
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
<<<<<<< HEAD
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Beacon Mode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isBeaconActive
                      ? const Color(0xFF00E5CC).withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isBeaconActive ? const Color(0xFF00E5CC) : Colors.grey,
                  ),
                ),
                child: Text(
                  _isBeaconActive ? 'ACTIVE' : 'PAUSED',
                  style: TextStyle(
                    color: _isBeaconActive ? const Color(0xFF00E5CC) : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
=======
          const Text(
            'Beacon Mode',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
<<<<<<< HEAD
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _isBeaconActive ? const Color(0xFF00E5CC) : Colors.grey,
                  shape: BoxShape.circle,
                  boxShadow: _isBeaconActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFF00E5CC),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _isBeaconActive ? 'Broadcasting...' : 'Beacon paused',
                style: TextStyle(
                  color: _isBeaconActive ? const Color(0xFF00E5CC) : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
=======
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00E5CC),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Broadcasting...',
                style: TextStyle(
                  color: Color(0xFF00E5CC),
                  fontSize: 16,
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
<<<<<<< HEAD
          Row(
            children: [
              Expanded(
                child: Text(
                  _isBeaconActive
                      ? 'Emergency packet is being broadcast to nearby devices'
                      : 'Tap switch to resume broadcasting',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ),
              Switch(
                value: _isBeaconActive,
                onChanged: (value) => _toggleBeacon(),
                activeColor: const Color(0xFF00E5CC),
                activeTrackColor: const Color(0xFF1F4D4D),
              ),
            ],
=======
          Switch(
            value: isBeaconActive,
            onChanged: (value) {
              setState(() {
                isBeaconActive = value;
              });
            },
            activeColor: const Color(0xFF00E5CC),
            activeTrackColor: const Color(0xFF1F4D4D),
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
          ),
        ],
      ),
    );
  }

  Widget _buildDTNRelayCard() {
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
              const Text(
                'DTN Relay Status',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Icon(
                Icons.hub_outlined,
<<<<<<< HEAD
                color: _relayStatusColor,
=======
                color: const Color(0xFF00E5CC),
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
                size: 24,
              ),
            ],
          ),
<<<<<<< HEAD
          const SizedBox(height: 12),
          Text(
            _relayStatus,
            style: TextStyle(
              color: _relayStatusColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_lastRelayTimestamp != null)
            Text(
              'Last relay: ${_getTimeAgo(_lastRelayTimestamp!)}',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF143838),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F4D4D)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildMetricItem('Nearby Peers', '$_nearbyPeerCount')),
              Container(width: 1, height: 40, color: const Color(0xFF1F4D4D)),
              Expanded(child: _buildMetricItem('Total Relays', '$_totalRelays')),
              Container(width: 1, height: 40, color: const Color(0xFF1F4D4D)),
              Expanded(child: _buildMetricItem('Battery', '$_batteryLevel%')),
            ],
=======
          const SizedBox(height: 8),
          const Text(
            'Active Hop',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'CONNECTED',
            style: TextStyle(
              color: Color(0xFF00CC88),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF00E5CC),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

=======
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
  Widget _buildPrivacyIDCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF143838),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F4D4D), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SECURITY',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Rotating Privacy ID',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
<<<<<<< HEAD
                  _privacyId,
                  style: const TextStyle(
                    color: Color(0xFF00E5CC),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.white54, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Auto-rotates in $_timeRemaining',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _regeneratePrivacyId,
=======
                  privacyId,
                  style: const TextStyle(
                    color: Color(0xFF00E5CC),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Auto-rotates in $timeRemaining',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Regenerate ID logic
                  },
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Regenerate ID'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5CC),
                    foregroundColor: const Color(0xFF0D2D2D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
<<<<<<< HEAD
          SizedBox(
            width: 100,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: 1 - _rotationController.value,
                      strokeWidth: 4,
                      backgroundColor: const Color(0xFF1F4D4D),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF00E5CC),
                      ),
                    );
                  },
                ),
                const Icon(
                  Icons.shield,
                  color: Color(0xFF00E5CC),
                  size: 48,
                ),
              ],
=======
          Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF1F4D4D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield,
              color: Color(0xFF00E5CC),
              size: 48,
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPeersSection() {
    return Column(
<<<<<<< HEAD
      crossAxisAlignment: CrossAxisAlignment.start,
=======
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
<<<<<<< HEAD
              'Nearby Peers',
=======
              'Nearby Peers Found',
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1F4D4D),
                borderRadius: BorderRadius.circular(12),
              ),
<<<<<<< HEAD
              child: Text(
                '$_nearbyPeerCount ONLINE',
                style: const TextStyle(
=======
              child: const Text(
                '6 ONLINE',
                style: TextStyle(
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
                  color: Color(0xFF00E5CC),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
<<<<<<< HEAD
        if (_nearbyPeers.isEmpty)
          _buildNoPeersPlaceholder()
        else
          ..._nearbyPeers.map((peer) => _buildPeerCard(peer)),
=======
        ...nearbyPeers.map((peer) => _buildPeerCard(peer)),
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildNoPeersPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF143838).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F4D4D)),
      ),
      child: Column(
        children: const [
          Icon(Icons.search, color: Colors.white38, size: 48),
          SizedBox(height: 16),
          Text(
            'Searching for peers...',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Emergency packet will relay when peers are found',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeerCard(Map<String, dynamic> peer) {
    final signal = peer['signal'] ?? -100;
    final status = _getPeerStatus(signal);
    final color = _getPeerColor(signal);

=======
  Widget _buildPeerCard(Map<String, dynamic> peer) {
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
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
            decoration: BoxDecoration(
              color: const Color(0xFF1F4D4D),
              shape: BoxShape.circle,
<<<<<<< HEAD
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              peer['isGateway'] == true ? Icons.router : Icons.person,
              color: color,
=======
            ),
            child: Icon(
              Icons.person,
              color: peer['color'],
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
<<<<<<< HEAD
                  peer['name'] ?? 'Node-${peer['id']?.substring(0, 4)}',
=======
                  peer['name'],
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
<<<<<<< HEAD
                  peer['distance'] ?? '~${_estimateDistance(signal)}m',
=======
                  peer['distance'],
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
<<<<<<< HEAD
                '$signal dBm',
                style: TextStyle(
                  color: color,
=======
                '${peer['signal']} dBm',
                style: TextStyle(
                  color: peer['color'],
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
<<<<<<< HEAD
                status,
                style: TextStyle(
                  color: color,
=======
                peer['status'],
                style: TextStyle(
                  color: peer['color'],
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.signal_cellular_alt,
<<<<<<< HEAD
            color: color,
=======
            color: peer['color'],
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
            size: 24,
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  String _getPeerStatus(int signal) {
    if (signal > -60) return 'STRONG';
    if (signal > -80) return 'GOOD';
    if (signal > -90) return 'WEAK';
    return 'FADING';
  }

  Color _getPeerColor(int signal) {
    if (signal > -60) return const Color(0xFF40916C);
    if (signal > -80) return const Color(0xFF00E5CC);
    if (signal > -90) return Colors.amber;
    return Colors.grey;
  }

  String _estimateDistance(int signal) {
    if (signal > -60) return '5-10';
    if (signal > -70) return '10-20';
    if (signal > -80) return '20-40';
    if (signal > -90) return '40-60';
    return '60+';
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_packetDelivered)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF40916C).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF40916C)),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle, color: Color(0xFF40916C)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Emergency delivered to network',
                    style: TextStyle(
                      color: Color(0xFF40916C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _cancelEmergency,
            icon: const Icon(Icons.cancel, size: 20),
            label: const Text(
              'Cancel Emergency',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

=======
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_tethering,
            color: Color(0xFF00E5CC),
            size: 16,
          ),
          const SizedBox(width: 8),
          const Text(
            'DTN MESH ACTIVE',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 24),
<<<<<<< HEAD
          Text(
            'Session: ${widget.sessionId.substring(0, 8)}',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
=======
          const Text(
            'V2.4.0-STABLE',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
            ),
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
=======
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
}