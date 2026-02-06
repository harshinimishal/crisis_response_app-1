import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:crypto/crypto.dart';

class DTNService {
  static final DTNService _instance = DTNService._internal();
  factory DTNService() => _instance;
  DTNService._internal();

  // Bluetooth
  // FlutterBluePlus methods are static, no instance needed
  
  // State
  String? _userId;
  Map<String, dynamic>? _emergencyPacket;
  String _privacyId = '';
  bool _isBroadcasting = false;
  
  // DTN packet tracking
  final Set<String> _seenPackets = {};
  final Map<String, DateTime> _packetTimestamps = {};
  final Map<String, int> _packetHopCounts = {};
  
  // Peers
  final Map<String, Map<String, dynamic>> _discoveredPeers = {};
  final Map<String, DateTime> _peerLastSeen = {};
  
  // Broadcast settings
  Duration _broadcastInterval = const Duration(seconds: 15);
  int _maxHops = 5;
  int _packetTTL = 3600; // 1 hour in seconds
  
  // Streams
  final _peerStreamController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _relayStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _gatewayStreamController = StreamController<Map<String, dynamic>?>.broadcast();
  final _deliveryStreamController = StreamController<bool>.broadcast();
  
  Stream<List<Map<String, dynamic>>> get peerStream => _peerStreamController.stream;
  Stream<Map<String, dynamic>> get relayStream => _relayStreamController.stream;
  Stream<Map<String, dynamic>?> get gatewayStream => _gatewayStreamController.stream;
  Stream<bool> get deliveryStream => _deliveryStreamController.stream;
  
  // Timers
  Timer? _broadcastTimer;
  Timer? _peerCleanupTimer;
  Timer? _packetCleanupTimer;

  /// Initialize DTN service
  Future<void> initialize({
    required String userId,
    required Map<String, dynamic> emergencyPacket,
  }) async {
    _userId = userId;
    _emergencyPacket = emergencyPacket;
    
    // Generate initial privacy ID
    _generatePrivacyId();
    
    // Initialize Bluetooth
    await _initializeBluetooth();
    
    // Start cleanup timers
    _startPeerCleanup();
    _startPacketCleanup();
    
    debugPrint('📡 DTN Service initialized');
  }

  Future<void> _initializeBluetooth() async {
    try {
      // Check if Bluetooth is available
      final isSupported = await FlutterBluePlus.isSupported;
      if (!isSupported) {
        debugPrint('⚠️ Bluetooth not available');
        return;
      }

      // Check if Bluetooth is on
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        debugPrint('⚠️ Bluetooth is off');
        // Request to turn on Bluetooth
        await FlutterBluePlus.turnOn();
      }

      debugPrint('✅ Bluetooth initialized');
    } catch (e) {
      debugPrint('❌ Bluetooth initialization failed: $e');
    }
  }

  void _generatePrivacyId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final hash = sha256.convert(utf8.encode(random + _userId!)).toString();
    
    _privacyId = hash.substring(0, 4).toUpperCase() + 
                 '-' + 
                 hash.substring(4, 8).toUpperCase();
  }

  void updatePrivacyId(String newId) {
    _privacyId = newId;
  }

  /// Start broadcasting emergency packet
  Future<void> startBroadcasting() async {
    if (_isBroadcasting) return;
    
    _isBroadcasting = true;
    
    // Add packet to seen list (don't relay our own packet back)
    final packetId = _emergencyPacket!['sessionId'];
    _seenPackets.add(packetId);
    _packetTimestamps[packetId] = DateTime.now();
    _packetHopCounts[packetId] = 0;
    
    // Start periodic broadcasting
    _broadcastTimer = Timer.periodic(_broadcastInterval, (timer) async {
      await _broadcastEmergencyPacket();
    });
    
    // Immediate first broadcast
    await _broadcastEmergencyPacket();
    
    // Start scanning for peers
    await _startScanning();
    
    debugPrint('📡 DTN broadcasting started');
  }

  /// Stop broadcasting
  Future<void> stopBroadcasting() async {
    _isBroadcasting = false;
    _broadcastTimer?.cancel();
    await FlutterBluePlus.stopScan();
    debugPrint('🛑 DTN broadcasting stopped');
  }

  /// Broadcast emergency packet via BLE
  Future<void> _broadcastEmergencyPacket() async {
    if (!_isBroadcasting) return;
    
    try {
      // Create DTN packet
      final dtnPacket = _createDTNPacket();
      
      // Broadcast via BLE advertising
      // Note: In real implementation, use BLE advertising or GATT characteristics
      // For now, we'll use BLE scanning and connection
      await _advertisePacket(dtnPacket);
      
      debugPrint('📤 Broadcast emergency packet');
    } catch (e) {
      debugPrint('❌ Broadcast failed: $e');
    }
  }

  Map<String, dynamic> _createDTNPacket() {
    return {
      'packetType': 'EMERGENCY',
      'sessionId': _emergencyPacket!['sessionId'],
      'privacyId': _privacyId,
      'hopCount': _packetHopCounts[_emergencyPacket!['sessionId']] ?? 0,
      'ttl': _packetTTL,
      'timestamp': DateTime.now().toIso8601String(),
      'payload': {
        'userId': _userId,
        'emergencyType': _emergencyPacket!['emergencyType'],
        'location': _emergencyPacket!['location'],
        'detectionType': _emergencyPacket!['detectionType'],
        'impactForce': _emergencyPacket!['impactForce'],
        'timestamp': _emergencyPacket!['timestamp'],
      },
      'relayPath': [_privacyId],
    };
  }

  Future<void> _advertisePacket(Map<String, dynamic> packet) async {
    // In real implementation, this would use BLE advertising
    // For simulation, we'll store in SharedPreferences for peer discovery
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dtn_packet_${packet['sessionId']}', jsonEncode(packet));
      await prefs.setInt('dtn_packet_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('❌ Packet advertising failed: $e');
    }
  }

  /// Start scanning for peers
  Future<void> _startScanning() async {
    try {
      // Start BLE scan
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
      );

      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) {
        for (var result in results) {
          _handleDiscoveredDevice(result);
        }
      });
    } catch (e) {
      debugPrint('❌ Scan failed: $e');
    }
  }

  void _handleDiscoveredDevice(ScanResult result) {
    final device = result.device;
    final deviceId = device.id.toString();
    final rssi = result.rssi;

    // Check if this is a DTN peer (simplified check)
    // In real implementation, check for specific service UUIDs
    
    final peerData = {
      'id': deviceId,
      'name': device.name.isNotEmpty ? device.name : 'Node-${deviceId.substring(0, 4)}',
      'signal': rssi,
      'lastSeen': DateTime.now(),
      'isGateway': false, // Check for gateway capability
    };

    _discoveredPeers[deviceId] = peerData;
    _peerLastSeen[deviceId] = DateTime.now();

    // Check if peer has internet (gateway)
    _checkIfGateway(deviceId, device);

    // Update peer stream
    _updatePeerStream();

    // Attempt to relay packet to this peer
    _relayToPeer(deviceId, device);
  }

  Future<void> _checkIfGateway(String peerId, BluetoothDevice device) async {
    // In real implementation, query device for gateway capability
    // For simulation, randomly mark some as gateways
    if (_discoveredPeers[peerId]!['signal'] > -60) {
      _discoveredPeers[peerId]!['isGateway'] = true;
      _gatewayStreamController.add(_discoveredPeers[peerId]);
    }
  }

  Future<void> _relayToPeer(String peerId, BluetoothDevice device) async {
    try {
      // In real implementation, connect to device and transfer packet
      // For simulation, just log the relay
      
      final packet = _createDTNPacket();
      
      // Check hop count
      if (packet['hopCount'] >= _maxHops) {
        debugPrint('⚠️ Max hops reached, not relaying');
        return;
      }

      // Increment hop count
      packet['hopCount'] = packet['hopCount'] + 1;
      packet['relayPath'].add(peerId);

      // Simulate relay
      debugPrint('📡 Relayed packet to $peerId (hop ${packet['hopCount']})');
      
      // Notify relay event
      _relayStreamController.add({
        'peerId': peerId,
        'hopCount': packet['hopCount'],
        'timestamp': DateTime.now(),
      });

      // Check for delivery
      if (_discoveredPeers[peerId]!['isGateway'] == true) {
        _deliveryStreamController.add(true);
      }
    } catch (e) {
      debugPrint('❌ Relay to peer failed: $e');
    }
  }

  /// Scan for peers (manual trigger)
  Future<void> scanForPeers() async {
    if (await FlutterBluePlus.isScanning.first) return;
    
    await _startScanning();
    
    // Auto-stop after timeout
    await Future.delayed(const Duration(seconds: 5));
    await FlutterBluePlus.stopScan();
  }

  void _updatePeerStream() {
    final peers = _discoveredPeers.values.toList();
    _peerStreamController.add(peers);
  }

  /// Broadcast cancellation packet
  Future<void> broadcastCancellation(String sessionId) async {
    final cancellationPacket = {
      'packetType': 'CANCELLATION',
      'sessionId': sessionId,
      'privacyId': _privacyId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _advertisePacket(cancellationPacket);
    debugPrint('📡 Broadcast cancellation packet');
  }

  /// Get current emergency packet
  Future<Map<String, dynamic>?> getEmergencyPacket() async {
    return _emergencyPacket;
  }

  /// Set broadcast interval
  void setBroadcastInterval(Duration interval) {
    _broadcastInterval = interval;
    
    // Restart broadcasting with new interval
    if (_isBroadcasting) {
      _broadcastTimer?.cancel();
      _broadcastTimer = Timer.periodic(_broadcastInterval, (timer) async {
        await _broadcastEmergencyPacket();
      });
    }
  }

  /// Clean up old peers
  void _startPeerCleanup() {
    _peerCleanupTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      final now = DateTime.now();
      final toRemove = <String>[];

      _peerLastSeen.forEach((peerId, lastSeen) {
        if (now.difference(lastSeen).inMinutes > 2) {
          toRemove.add(peerId);
        }
      });

      for (var peerId in toRemove) {
        _discoveredPeers.remove(peerId);
        _peerLastSeen.remove(peerId);
      }

      if (toRemove.isNotEmpty) {
        _updatePeerStream();
      }
    });
  }

  /// Clean up old packets
  void _startPacketCleanup() {
    _packetCleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      final now = DateTime.now();
      final toRemove = <String>[];

      _packetTimestamps.forEach((packetId, timestamp) {
        if (now.difference(timestamp).inSeconds > _packetTTL) {
          toRemove.add(packetId);
        }
      });

      for (var packetId in toRemove) {
        _seenPackets.remove(packetId);
        _packetTimestamps.remove(packetId);
        _packetHopCounts.remove(packetId);
      }

      debugPrint('🧹 Cleaned up ${toRemove.length} expired packets');
    });
  }

  /// Dispose resources
  void dispose() {
    _broadcastTimer?.cancel();
    _peerCleanupTimer?.cancel();
    _packetCleanupTimer?.cancel();
    
    _peerStreamController.close();
    _relayStreamController.close();
    _gatewayStreamController.close();
    _deliveryStreamController.close();
    
    FlutterBluePlus.stopScan();
  }
}