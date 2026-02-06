import 'dart:async';
import 'dart:math';

class DummyFeaturesService {
  // Simulate Satellite Connection
  Stream<String> get satelliteStatus async* {
    yield 'Searching for Satin...';
    await Future.delayed(const Duration(seconds: 3));
    yield 'Handshaking...';
    await Future.delayed(const Duration(seconds: 2));
    yield 'Connected to StarLink-42';
    // yield 'Signal Strength: 85%';
  }

  Future<Map<String, dynamic>> checkDroneAvailability(double lat, double lng) async {
    await Future.delayed(const Duration(seconds: 2));
    // Randomly decide availability
    bool available = Random().nextBool();
    return {
      'available': available,
      'eta': available ? '${Random().nextInt(15) + 5} mins' : 'N/A',
      'droneId': available ? 'DRN-${Random().nextInt(9999)}' : null,
      'message': available ? 'Drone dispatch ready' : 'No drones in sector',
    };
  }

  Future<String> runAITriage(String medicalInfo) async {
    await Future.delayed(const Duration(seconds: 4));
    return "AI Analysis: Based on the profile ($medicalInfo), immediate risk factors include dehydration and shock. Recommended Action: Stay stationary, conserve heat.";
  }
}
