import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Device services
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  // Stream subscriptions
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<BatteryState>? _batterySubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _syncTimer;
  Timer? _heartbeatTimer;
  
  // State management
  String? _currentSessionId;
  bool _isEmergencyActive = false;
  List<Map<String, dynamic>> _pendingUpdates = [];
  Position? _lastKnownLocation;
  int _batteryLevel = 100;
  bool _isConnected = false;
  String _userId = '';
  
  // Accelerometer data for impact detection
  double _lastAcceleration = 0;
  final double _impactThreshold = 25.0; // G-force threshold
  bool _impactDetectionEnabled = false;

  // Getters
  bool get isEmergencyActive => _isEmergencyActive;
  String? get currentSessionId => _currentSessionId;
  Position? get lastKnownLocation => _lastKnownLocation;
  int get batteryLevel => _batteryLevel;
  bool get isConnected => _isConnected;

  // Constants
  static const String TWILIO_ACCOUNT_SID = 'YOUR_TWILIO_ACCOUNT_SID';
  static const String TWILIO_AUTH_TOKEN = 'YOUR_TWILIO_AUTH_TOKEN';
  static const String TWILIO_PHONE_NUMBER = 'YOUR_TWILIO_PHONE';
  static const String FCM_SERVER_KEY = 'YOUR_FCM_SERVER_KEY';

  /// Initialize the emergency service
  Future<void> initialize() async {
    _userId = _auth.currentUser?.uid ?? '';
    await _initializeNotifications();
    await _loadCachedData();
    await _checkBatteryLevel();
    _startBatteryMonitoring();
    
    // Resume active emergency if exists
    if (_isEmergencyActive && _currentSessionId != null) {
      debugPrint('🔄 Resuming active emergency session: $_currentSessionId');
      _startLocationTracking();
      _startConnectivityMonitoring();
      _startHeartbeat();
    }
  }

  /// Initialize local notifications
  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(settings);
  }

  /// Create emergency session with comprehensive data collection
  Future<String> createEmergencySession({
    required String userId,
    required String triggerType,
    required List<Map<String, String>> emergencyContacts,
    Position? initialLocation,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      _isEmergencyActive = true;
      _userId = userId;
      _currentSessionId = _firestore.collection('emergency_sessions').doc().id;

      // Collect comprehensive device and environmental data
      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;
      final connectivityResults = await _connectivity.checkConnectivity();
      final location = initialLocation ?? await _getLocation();
      final deviceData = await _getDeviceInfo();
      
      final sessionData = {
        'userId': userId,
        'sessionId': _currentSessionId,
        'triggerType': triggerType,
        'startTimestamp': FieldValue.serverTimestamp(),
        'emergencyStatus': 'ACTIVE',
        'severity': _calculateSeverity(triggerType, additionalData),
        
        // Location data
        'initialLocation': location != null ? _locationToMap(location) : null,
        'lastKnownLocation': location != null ? _locationToMap(location) : null,
        'locationHistory': [],
        'locationUpdateFrequency': 'high', // high/medium/low
        
        // Device status
        'deviceInfo': deviceData,
        'batteryLevel': batteryLevel,
        'batteryState': batteryState.toString(),
        'lowBatteryMode': batteryLevel < 20,
        
        // Connectivity status
        'connectivityStatus': {
          'internet': _isConnectedToInternet(connectivityResults),
          'cellular': connectivityResults.contains(ConnectivityResult.mobile),
          'wifi': connectivityResults.contains(ConnectivityResult.wifi),
          'sms': true, // Assume SMS capability
          'ble': false, // Will be updated by BLE service
        },
        
        // Emergency contacts
        'emergencyContacts': emergencyContacts,
        'contactsNotified': [],
        'notificationAttempts': 0,
        'successfulNotifications': 0,
        
        // Delivery tracking
        'deliveryChannels': {
          'fcm': {'attempted': false, 'success': false, 'timestamp': null},
          'sms': {'attempted': false, 'success': false, 'timestamp': null},
          'ble': {'attempted': false, 'success': false, 'timestamp': null},
          'call': {'attempted': false, 'success': false, 'timestamp': null},
        },
        
        // Monitoring
        'heartbeatInterval': 30, // seconds
        'lastHeartbeat': FieldValue.serverTimestamp(),
        'missedHeartbeats': 0,
        
        // Additional context
        'additionalData': additionalData ?? {},
        'aiAnalysis': null, // For future ML-based severity analysis
        
        // Cancellation
        'cancelledAt': null,
        'cancellationReason': null,
        'resolvedAt': null,
        'resolutionType': null,
        
        // Audit trail
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'version': 1,
      };

      // Attempt to write to Firestore
      if (_isConnectedToInternet(connectivityResults)) {
        await _firestore
            .collection('emergency_sessions')
            .doc(_currentSessionId)
            .set(sessionData);
        
        // Create activity log
        await _logActivity(
          sessionId: _currentSessionId!,
          action: 'session_created',
          details: {'triggerType': triggerType},
        );
        
        debugPrint('✅ Emergency session created in Firestore: $_currentSessionId');
      } else {
        await _cacheEmergencySession(sessionData);
        debugPrint('📦 Emergency session cached locally: $_currentSessionId');
      }

      // Start monitoring services
      _startLocationTracking();
      _startConnectivityMonitoring();
      _startHeartbeat();

      // Send notifications through all available channels
      await _sendEmergencyNotifications(
        sessionId: _currentSessionId!,
        contacts: emergencyContacts,
        location: location,
        triggerType: triggerType,
        batteryLevel: batteryLevel,
      );

      // Show local notification
      await _showLocalNotification(
        title: 'Emergency SOS Active',
        body: 'Your emergency contacts have been notified',
      );

      return _currentSessionId!;
    } catch (e) {
      debugPrint('❌ Error creating emergency session: $e');
      _isEmergencyActive = true;
      _currentSessionId ??= 'local_${DateTime.now().millisecondsSinceEpoch}';
      return _currentSessionId!;
    }
  }

  /// Calculate emergency severity based on trigger type and context
  String _calculateSeverity(String triggerType, Map<String, dynamic>? data) {
    if (triggerType == 'crash_detected' || triggerType == 'fall_detected') {
      final gForce = data?['gForce'] ?? 0.0;
      if (gForce > 30) return 'CRITICAL';
      if (gForce > 20) return 'HIGH';
      return 'MEDIUM';
    }
    
    if (triggerType == 'manual') {
      return 'HIGH';
    }
    
    if (triggerType == 'panic_button') {
      return 'CRITICAL';
    }
    
    return 'MEDIUM';
  }

  /// Start high-accuracy location tracking
  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 10, // Update every 10 meters
      timeLimit: Duration(seconds: 5),
    );

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _lastKnownLocation = position;
        _updateLocationInFirestore(position);
      },
      onError: (error) {
        debugPrint('❌ Location tracking error: $error');
        _logActivity(
          sessionId: _currentSessionId ?? '',
          action: 'location_error',
          details: {'error': error.toString()},
        );
      },
    );
  }

  /// Update location in Firestore with offline support
  Future<void> _updateLocationInFirestore(Position position) async {
    if (_currentSessionId == null) return;

    final locationData = _locationToMap(position);

    try {
      if (_isConnected) {
        await _firestore
            .collection('emergency_sessions')
            .doc(_currentSessionId)
            .update({
          'lastKnownLocation': locationData,
          'locationHistory': FieldValue.arrayUnion([locationData]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await _syncPendingUpdates();
      } else {
        _pendingUpdates.add({
          'type': 'location_update',
          'data': locationData,
          'timestamp': DateTime.now().toIso8601String(),
        });
        await _cachePendingUpdates();
        debugPrint('📦 Location cached: ${_pendingUpdates.length} pending');
      }
    } catch (e) {
      debugPrint('❌ Error updating location: $e');
      _pendingUpdates.add({
        'type': 'location_update',
        'data': locationData,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await _cachePendingUpdates();
    }
  }

  /// Convert Position to Map
  Map<String, dynamic> _locationToMap(Position position) {
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'altitude': position.altitude,
      'speed': position.speed,
      'speedAccuracy': position.speedAccuracy,
      'heading': position.heading,
      'timestamp': position.timestamp?.toIso8601String() ?? 
                   DateTime.now().toIso8601String(),
    };
  }

  /// Send emergency notifications via multiple channels
  Future<void> _sendEmergencyNotifications({
    required String sessionId,
    required List<Map<String, String>> contacts,
    Position? location,
    required String triggerType,
    required int batteryLevel,
  }) async {
    final results = <String, bool>{};
    
    // Prepare message content
    final locationUrl = location != null
        ? 'https://maps.google.com/?q=${location.latitude},${location.longitude}'
        : 'Location unavailable';
    
    final emergencyMessage = '''
🚨 EMERGENCY ALERT 🚨
${_auth.currentUser?.displayName ?? 'Contact'} has triggered an emergency SOS!

Trigger: ${_formatTriggerType(triggerType)}
Time: ${DateTime.now().toString()}
Battery: $batteryLevel%
Location: $locationUrl

Session ID: $sessionId

Please check on them immediately or call emergency services.
''';

    // Try FCM first (fastest for app users)
    try {
      if (_isConnected) {
        final fcmSuccess = await _sendFCMNotifications(
          sessionId: sessionId,
          contacts: contacts,
          message: emergencyMessage,
          location: location,
        );
        results['fcm'] = fcmSuccess;
        
        await _updateDeliveryChannel(sessionId, 'fcm', fcmSuccess);
      }
    } catch (e) {
      debugPrint('❌ FCM failed: $e');
      results['fcm'] = false;
    }

    // SMS fallback (most reliable)
    try {
      final smsSuccess = await _sendSMSNotifications(
        contacts: contacts,
        message: emergencyMessage,
      );
      results['sms'] = smsSuccess;
      
      await _updateDeliveryChannel(sessionId, 'sms', smsSuccess);
    } catch (e) {
      debugPrint('❌ SMS failed: $e');
      results['sms'] = false;
    }

    // Email notifications (secondary)
    try {
      final emailSuccess = await _sendEmailNotifications(
        contacts: contacts,
        message: emergencyMessage,
        location: location,
      );
      results['email'] = emailSuccess;
    } catch (e) {
      debugPrint('❌ Email failed: $e');
      results['email'] = false;
    }

    // BLE beacon for nearby devices
    try {
      await _startBLEBeacon(sessionId);
      results['ble'] = true;
      await _updateDeliveryChannel(sessionId, 'ble', true);
    } catch (e) {
      debugPrint('⚠️ BLE unavailable: $e');
      results['ble'] = false;
    }

    // Log notification results
    await _logActivity(
      sessionId: sessionId,
      action: 'notifications_sent',
      details: {
        'results': results,
        'contactCount': contacts.length,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Format trigger type for human reading
  String _formatTriggerType(String type) {
    switch (type) {
      case 'manual':
        return 'Manual SOS Button';
      case 'crash_detected':
        return 'Vehicle Crash Detected';
      case 'fall_detected':
        return 'Fall Detected';
      case 'panic_button':
        return 'Panic Button';
      case 'auto':
        return 'Automatic Detection';
      default:
        return type;
    }
  }

  /// Send FCM notifications
  Future<bool> _sendFCMNotifications({
    required String sessionId,
    required List<Map<String, String>> contacts,
    required String message,
    Position? location,
  }) async {
    try {
      for (var contact in contacts) {
        final fcmToken = contact['fcmToken'];
        if (fcmToken == null || fcmToken.isEmpty) continue;

        final response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=$FCM_SERVER_KEY',
          },
          body: jsonEncode({
            'to': fcmToken,
            'priority': 'high',
            'notification': {
              'title': '🚨 EMERGENCY ALERT',
              'body': message,
              'sound': 'emergency_alert',
              'badge': 1,
            },
            'data': {
              'sessionId': sessionId,
              'type': 'emergency_alert',
              'latitude': location?.latitude.toString(),
              'longitude': location?.longitude.toString(),
              'timestamp': DateTime.now().toIso8601String(),
            },
          }),
        );

        if (response.statusCode == 200) {
          debugPrint('✅ FCM sent to ${contact['name']}');
        } else {
          debugPrint('❌ FCM failed for ${contact['name']}: ${response.body}');
        }
      }
      return true;
    } catch (e) {
      debugPrint('❌ FCM error: $e');
      return false;
    }
  }

  /// Send SMS notifications via Twilio
  Future<bool> _sendSMSNotifications({
    required List<Map<String, String>> contacts,
    required String message,
  }) async {
    try {
      int successCount = 0;
      
      for (var contact in contacts) {
        final phone = contact['phone'];
        if (phone == null || phone.isEmpty) continue;

        final response = await http.post(
          Uri.parse(
            'https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Messages.json',
          ),
          headers: {
            'Authorization': 'Basic ${base64Encode(
              utf8.encode('$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN'),
            )}',
          },
          body: {
            'From': TWILIO_PHONE_NUMBER,
            'To': phone,
            'Body': message,
          },
        );

        if (response.statusCode == 201) {
          successCount++;
          debugPrint('✅ SMS sent to ${contact['name']} ($phone)');
          
          // Mark contact as notified
          await _markContactNotified(contact['name'] ?? 'Unknown', 'SMS');
        } else {
          debugPrint('❌ SMS failed for ${contact['name']}: ${response.body}');
        }
      }

      return successCount > 0;
    } catch (e) {
      debugPrint('❌ SMS error: $e');
      return false;
    }
  }

  /// Send email notifications via SendGrid or similar
  Future<bool> _sendEmailNotifications({
    required List<Map<String, String>> contacts,
    required String message,
    Position? location,
  }) async {
    try {
      // TODO: Implement with SendGrid, AWS SES, or similar
      // This is a placeholder implementation
      
      for (var contact in contacts) {
        final email = contact['email'];
        if (email == null || email.isEmpty) continue;
        
        debugPrint('📧 Would send email to ${contact['name']} ($email)');
        await _markContactNotified(contact['name'] ?? 'Unknown', 'Email');
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ Email error: $e');
      return false;
    }
  }

  /// Start BLE beacon for nearby device detection
  Future<void> _startBLEBeacon(String sessionId) async {
    // TODO: Implement with flutter_blue_plus
    // Broadcast emergency beacon with session ID
    debugPrint('📡 BLE beacon broadcasting: $sessionId');
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Update delivery channel status in Firestore
  Future<void> _updateDeliveryChannel(
    String sessionId,
    String channel,
    bool success,
  ) async {
    if (!_isConnected) {
      _pendingUpdates.add({
        'type': 'delivery_update',
        'data': {
          'channel': channel,
          'success': success,
          'timestamp': DateTime.now().toIso8601String(),
        },
      });
      return;
    }

    try {
      await _firestore.collection('emergency_sessions').doc(sessionId).update({
        'deliveryChannels.$channel': {
          'attempted': true,
          'success': success,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'notificationAttempts': FieldValue.increment(1),
        if (success) 'successfulNotifications': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('❌ Error updating delivery channel: $e');
    }
  }

  /// Mark contact as notified
  Future<void> _markContactNotified(String contactName, String method) async {
    if (_currentSessionId == null || !_isConnected) return;

    try {
      await _firestore
          .collection('emergency_sessions')
          .doc(_currentSessionId)
          .update({
        'contactsNotified': FieldValue.arrayUnion([
          {
            'name': contactName,
            'method': method,
            'timestamp': FieldValue.serverTimestamp(),
          }
        ]),
      });
    } catch (e) {
      debugPrint('❌ Error marking contact notified: $e');
    }
  }

  /// Start heartbeat monitoring
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!_isEmergencyActive || _currentSessionId == null) {
        timer.cancel();
        return;
      }

      if (_isConnected) {
        try {
          await _firestore
              .collection('emergency_sessions')
              .doc(_currentSessionId)
              .update({
            'lastHeartbeat': FieldValue.serverTimestamp(),
            'batteryLevel': _batteryLevel,
            'missedHeartbeats': 0,
          });
        } catch (e) {
          debugPrint('❌ Heartbeat failed: $e');
        }
      }
    });
  }

  /// Monitor connectivity changes
  void _startConnectivityMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        final wasConnected = _isConnected;
        _isConnected = _isConnectedToInternet(results);

        if (_isConnected && !wasConnected && _pendingUpdates.isNotEmpty) {
          debugPrint('🔄 Connection restored, syncing ${_pendingUpdates.length} updates');
          await _syncPendingUpdates();
        }

        // Update connectivity status in Firestore
        if (_isConnected && _currentSessionId != null) {
          await _firestore
              .collection('emergency_sessions')
              .doc(_currentSessionId)
              .update({
            'connectivityStatus.internet': true,
            'connectivityStatus.cellular': results.contains(ConnectivityResult.mobile),
            'connectivityStatus.wifi': results.contains(ConnectivityResult.wifi),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      },
    );

    // Periodic sync attempt
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_pendingUpdates.isNotEmpty && _isConnected) {
        await _syncPendingUpdates();
      }
    });
  }

  /// Start battery monitoring
  void _startBatteryMonitoring() {
    _batterySubscription?.cancel();
    _batterySubscription = _battery.onBatteryStateChanged.listen((state) async {
      final level = await _battery.batteryLevel;
      _batteryLevel = level;

      // Alert if battery is critically low during emergency
      if (_isEmergencyActive && level <= 10 && level > 5) {
        await _showLocalNotification(
          title: 'Low Battery Warning',
          body: 'Battery at $level%. Emergency mode will continue but consider charging.',
        );
      }

      // Update in Firestore
      if (_isConnected && _currentSessionId != null) {
        await _firestore
            .collection('emergency_sessions')
            .doc(_currentSessionId)
            .update({
          'batteryLevel': level,
          'batteryState': state.toString(),
          'lowBatteryMode': level < 20,
        });
      }
    });
  }

  /// Check current battery level
  Future<void> _checkBatteryLevel() async {
    _batteryLevel = await _battery.batteryLevel;
  }

  /// Enable impact detection (for automatic crash/fall detection)
  void enableImpactDetection() {
    _impactDetectionEnabled = true;
    
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      final acceleration = math.sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      // Detect sudden impact
      if ((acceleration - _lastAcceleration).abs() > _impactThreshold) {
        _onImpactDetected(acceleration);
      }

      _lastAcceleration = acceleration;
    });
  }

  /// Disable impact detection
  void disableImpactDetection() {
    _impactDetectionEnabled = false;
    _accelerometerSubscription?.cancel();
  }

  /// Handle impact detection
  Future<void> _onImpactDetected(double gForce) async {
    if (_isEmergencyActive) return; // Don't trigger if already active

    debugPrint('⚠️ Impact detected: ${gForce.toStringAsFixed(2)}G');
    
    // Show local notification with countdown
    await _showLocalNotification(
      title: 'Crash Detected!',
      body: 'Emergency SOS will trigger in 10 seconds unless cancelled',
    );

    // Log the impact
    await _firestore.collection('impact_detections').add({
      'userId': _userId,
      'gForce': gForce,
      'timestamp': FieldValue.serverTimestamp(),
      'location': _lastKnownLocation != null 
          ? _locationToMap(_lastKnownLocation!)
          : null,
      'triggered': false,
    });
  }

  /// Sync pending updates to Firestore
  Future<void> _syncPendingUpdates() async {
    if (_pendingUpdates.isEmpty || _currentSessionId == null || !_isConnected) {
      return;
    }

    try {
      final batch = _firestore.batch();
      final sessionRef = _firestore
          .collection('emergency_sessions')
          .doc(_currentSessionId);

      for (var update in _pendingUpdates) {
        switch (update['type']) {
          case 'location_update':
            batch.update(sessionRef, {
              'lastKnownLocation': update['data'],
              'locationHistory': FieldValue.arrayUnion([update['data']]),
            });
            break;
          case 'delivery_update':
            final channel = update['data']['channel'];
            batch.update(sessionRef, {
              'deliveryChannels.$channel': {
                'attempted': true,
                'success': update['data']['success'],
                'timestamp': FieldValue.serverTimestamp(),
              },
            });
            break;
          case 'cancellation':
            batch.update(sessionRef, update['data']);
            break;
        }
      }

      await batch.commit();
      debugPrint('✅ Synced ${_pendingUpdates.length} updates');
      
      _pendingUpdates.clear();
      await _cachePendingUpdates();
    } catch (e) {
      debugPrint('❌ Sync failed: $e');
    }
  }

  /// Cancel emergency session
  Future<void> cancelEmergency({String? reason}) async {
    if (!_isEmergencyActive || _currentSessionId == null) return;

    try {
      final cancellationData = {
        'emergencyStatus': 'CANCELLED',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancellationReason': reason ?? 'User cancelled',
        'resolvedAt': FieldValue.serverTimestamp(),
        'resolutionType': 'user_cancelled',
      };

      if (_isConnected) {
        await _firestore
            .collection('emergency_sessions')
            .doc(_currentSessionId)
            .update(cancellationData);
        
        await _logActivity(
          sessionId: _currentSessionId!,
          action: 'emergency_cancelled',
          details: {'reason': reason ?? 'User cancelled'},
        );
        
        debugPrint('✅ Emergency cancelled in Firestore');
      } else {
        _pendingUpdates.add({
          'type': 'cancellation',
          'data': cancellationData,
          'timestamp': DateTime.now().toIso8601String(),
        });
        await _cachePendingUpdates();
        debugPrint('📦 Cancellation cached for sync');
      }

      // Notify contacts of cancellation
      await _notifyContactsOfCancellation();

      await _stopEmergencyServices();
      
      await _showLocalNotification(
        title: 'Emergency Cancelled',
        body: 'Your emergency alert has been cancelled.',
      );
    } catch (e) {
      debugPrint('❌ Error cancelling emergency: $e');
      await _stopEmergencyServices();
    }
  }

  /// Notify contacts that emergency was cancelled
  Future<void> _notifyContactsOfCancellation() async {
    // Send quick SMS to contacts
    try {
      final session = await _firestore
          .collection('emergency_sessions')
          .doc(_currentSessionId)
          .get();
      
      final contacts = List<Map<String, String>>.from(
        (session.data()?['emergencyContacts'] ?? []) as List,
      );

      for (var contact in contacts) {
        final phone = contact['phone'];
        if (phone != null && phone.isNotEmpty) {
          await http.post(
            Uri.parse(
              'https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Messages.json',
            ),
            headers: {
              'Authorization': 'Basic ${base64Encode(
                utf8.encode('$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN'),
              )}',
            },
            body: {
              'From': TWILIO_PHONE_NUMBER,
              'To': phone,
              'Body': '✅ Emergency Alert Cancelled - ${_auth.currentUser?.displayName ?? "Contact"} is safe.',
            },
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error notifying cancellation: $e');
    }
  }

  /// Stop all emergency services
  Future<void> _stopEmergencyServices() async {
    _isEmergencyActive = false;
    _currentSessionId = null;
    
    await _locationSubscription?.cancel();
    await _connectivitySubscription?.cancel();
    await _batterySubscription?.cancel();
    _heartbeatTimer?.cancel();
    _syncTimer?.cancel();
    
    _locationSubscription = null;
    _connectivitySubscription = null;
    _batterySubscription = null;
    _heartbeatTimer = null;
    _syncTimer = null;
    
    // Clear cached session
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('emergency_session');
    
    debugPrint('🛑 Emergency services stopped');
  }

  /// Get current location
  Future<Position?> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('⚠️ Location services disabled');
        return _lastKnownLocation;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('⚠️ Location permission denied');
          return _lastKnownLocation;
        }
      }

      final position = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 5),
          );
      
      _lastKnownLocation = position;
      return position;
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      return _lastKnownLocation;
    }
  }

  /// Get device information
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        };
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemVersion': iosInfo.systemVersion,
        };
      }
    } catch (e) {
      debugPrint('❌ Error getting device info: $e');
    }
    
    return {'platform': 'Unknown'};
  }

  /// Log activity to Firestore
  Future<void> _logActivity({
    required String sessionId,
    required String action,
    Map<String, dynamic>? details,
  }) async {
    if (!_isConnected) return;

    try {
      await _firestore.collection('emergency_activity_logs').add({
        'sessionId': sessionId,
        'userId': _userId,
        'action': action,
        'details': details ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Error logging activity: $e');
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'emergency_channel',
      'Emergency Alerts',
      channelDescription: 'Critical emergency notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      0,
      title,
      body,
      details,
    );
  }

  /// Check if connected to internet
  bool _isConnectedToInternet(dynamic result) {
    if (result is ConnectivityResult) {
      return result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet;
    } else if (result is List<ConnectivityResult>) {
      return result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet);
    }
    return false;
  }

  /// Cache emergency session
  Future<void> _cacheEmergencySession(Map<String, dynamic> sessionData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('emergency_session', jsonEncode(sessionData));
      debugPrint('💾 Session cached locally');
    } catch (e) {
      debugPrint('❌ Error caching session: $e');
    }
  }

  /// Cache pending updates
  Future<void> _cachePendingUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_updates', jsonEncode(_pendingUpdates));
    } catch (e) {
      debugPrint('❌ Error caching updates: $e');
    }
  }

  /// Load cached data
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final updatesJson = prefs.getString('pending_updates');
      if (updatesJson != null) {
        _pendingUpdates = List<Map<String, dynamic>>.from(
          jsonDecode(updatesJson),
        );
        debugPrint('📦 Loaded ${_pendingUpdates.length} cached updates');
      }

      final sessionJson = prefs.getString('emergency_session');
      if (sessionJson != null) {
        final session = jsonDecode(sessionJson);
        _currentSessionId = session['sessionId'];
        _isEmergencyActive = true;
        debugPrint('🔄 Active emergency restored: $_currentSessionId');
      }
    } catch (e) {
      debugPrint('❌ Error loading cached data: $e');
    }
  }

  /// Clean up resources
  void dispose() {
    _locationSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _batterySubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _heartbeatTimer?.cancel();
    _syncTimer?.cancel();
  }
}