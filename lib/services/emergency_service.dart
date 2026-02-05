import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;

class EmergencyService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<Position>? _positionSubscription;
  
  // Impact detection thresholds
  static const double impactThreshold = 25.0; // G-force threshold
  static const double freefalDuration = 0.5; // seconds
  
  DateTime? _lastImpactTime;
  bool _isMonitoring = false;
  
  // Callbacks
  Function(String type, Map<String, dynamic> data)? onEmergencyDetected;
  
  // Start monitoring for accidents
  Future<void> startAccidentMonitoring() async {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    
    // Start accelerometer monitoring
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      _checkForImpact(event);
    });
    
    print('Accident monitoring started');
  }
  
  // Stop monitoring
  void stopAccidentMonitoring() {
    _accelerometerSubscription?.cancel();
    _positionSubscription?.cancel();
    _isMonitoring = false;
    print('Accident monitoring stopped');
  }
  
  // Check for impact/crash
  void _checkForImpact(AccelerometerEvent event) {
    // Calculate total acceleration magnitude
    double magnitude = math.sqrt(
      event.x * event.x + 
      event.y * event.y + 
      event.z * event.z
    );
    
    // Check if magnitude exceeds threshold
    if (magnitude > impactThreshold) {
      DateTime now = DateTime.now();
      
      // Prevent multiple detections within 5 seconds
      if (_lastImpactTime == null || 
          now.difference(_lastImpactTime!).inSeconds > 5) {
        _lastImpactTime = now;
        _handleImpactDetected(magnitude);
      }
    }
  }
  
  // Handle impact detection
  Future<void> _handleImpactDetected(double magnitude) async {
    print('Impact detected with magnitude: $magnitude');
    
    // Get current location
    Position? position = await getCurrentLocation();
    
    Map<String, dynamic> emergencyData = {
      'type': 'accident_detected',
      'magnitude': magnitude,
      'timestamp': DateTime.now().toIso8601String(),
      'latitude': position?.latitude ?? 0.0,
      'longitude': position?.longitude ?? 0.0,
      'accuracy': position?.accuracy ?? 0.0,
    };
    
    // Log emergency
    await logEmergency(
      emergencyType: 'Accident Detected',
      latitude: position?.latitude ?? 0.0,
      longitude: position?.longitude ?? 0.0,
      description: 'Automatic accident detection triggered',
      additionalData: emergencyData,
    );
    
    // Trigger callback
    onEmergencyDetected?.call('accident', emergencyData);
  }
  
  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return null;
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }
  
  // Log emergency to Firestore
  Future<Map<String, dynamic>> logEmergency({
    required String emergencyType,
    required double latitude,
    required double longitude,
    String? description,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }
      
      final reportRef = await _firestore.collection('emergencyReports').add({
        'userId': user.uid,
        'emergencyType': emergencyType,
        'location': GeoPoint(latitude, longitude),
        'description': description ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'resolved': false,
        'additionalData': additionalData ?? {},
        'notificationsSent': false,
      });
      
      return {
        'success': true,
        'message': 'Emergency logged',
        'reportId': reportRef.id,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to log emergency: ${e.toString()}',
      };
    }
  }
  
  // Trigger manual SOS
  Future<Map<String, dynamic>> triggerManualSOS({
    String? customMessage,
  }) async {
    try {
      Position? position = await getCurrentLocation();
      
      Map<String, dynamic> sosData = {
        'type': 'manual_sos',
        'timestamp': DateTime.now().toIso8601String(),
        'latitude': position?.latitude ?? 0.0,
        'longitude': position?.longitude ?? 0.0,
        'accuracy': position?.accuracy ?? 0.0,
        'customMessage': customMessage,
      };
      
      // Log SOS emergency
      var result = await logEmergency(
        emergencyType: 'Manual SOS',
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
        description: customMessage ?? 'Manual SOS triggered by user',
        additionalData: sosData,
      );
      
      if (result['success']) {
        // Send notifications to emergency contacts
        await _sendEmergencyNotifications(
          reportId: result['reportId'],
          emergencyType: 'SOS',
          location: position,
        );
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to trigger SOS: ${e.toString()}',
      };
    }
  }
  
  // Send emergency notifications
  Future<void> _sendEmergencyNotifications({
    required String reportId,
    required String emergencyType,
    Position? location,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;
      
      // Get user's emergency contacts
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      List<dynamic>? contacts = userDoc.data()?['emergencyContacts'];
      
      if (contacts != null && contacts.isNotEmpty) {
        // In a real app, this would send SMS/push notifications
        // For now, we'll just log the notification
        for (var contact in contacts) {
          print('Sending emergency notification to ${contact['name']} at ${contact['phoneNumber']}');
          
          // Create notification record
          await _firestore.collection('notifications').add({
            'reportId': reportId,
            'userId': user.uid,
            'contactName': contact['name'],
            'contactPhone': contact['phoneNumber'],
            'emergencyType': emergencyType,
            'latitude': location?.latitude,
            'longitude': location?.longitude,
            'timestamp': FieldValue.serverTimestamp(),
            'status': 'sent',
          });
        }
      }
      
      // Update report to mark notifications sent
      await _firestore.collection('emergencyReports').doc(reportId).update({
        'notificationsSent': true,
        'notificationsSentAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending notifications: $e');
    }
  }
  
  // Cancel emergency
  Future<Map<String, dynamic>> cancelEmergency(String reportId) async {
    try {
      await _firestore.collection('emergencyReports').doc(reportId).update({
        'status': 'cancelled',
        'resolved': true,
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      
      return {
        'success': true,
        'message': 'Emergency cancelled',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to cancel emergency: ${e.toString()}',
      };
    }
  }
  
  // Get emergency reports for current user
  Future<List<Map<String, dynamic>>> getEmergencyReports() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return [];
      
      final snapshot = await _firestore
          .collection('emergencyReports')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting emergency reports: $e');
      return [];
    }
  }
  
  // Check location permissions
  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }
  
  // Request location permissions
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }
  
  // Dispose resources
  void dispose() {
    stopAccidentMonitoring();
  }
}