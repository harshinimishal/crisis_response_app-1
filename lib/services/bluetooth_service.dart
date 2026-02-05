import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  
  // Callbacks
  Function(List<ScanResult> devices)? onDevicesFound;
  Function(BluetoothAdapterState state)? onBluetoothStateChanged;
  
  // Initialize Bluetooth service
  Future<void> initialize() async {
    // Listen to adapter state changes
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      print('Bluetooth adapter state: $state');
      onBluetoothStateChanged?.call(state);
    });
  }
  
  // Check if Bluetooth is enabled
  Future<bool> isBluetoothEnabled() async {
    try {
      BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
      return state == BluetoothAdapterState.on;
    } catch (e) {
      print('Error checking Bluetooth state: $e');
      return false;
    }
  }
  
  // Request to turn on Bluetooth
  Future<void> requestBluetoothEnable() async {
    try {
      if (await isBluetoothEnabled()) {
        return;
      }
      
      // Try to turn on Bluetooth (Android only)
      if (await FlutterBluePlus.isSupported) {
        await FlutterBluePlus.turnOn();
      }
    } catch (e) {
      print('Error requesting Bluetooth enable: $e');
      // On iOS or if Android fails, user needs to enable manually
    }
  }
  
  // Start scanning for nearby devices
  Future<void> startScanning({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      if (_isScanning) {
        await stopScanning();
      }
      
      _isScanning = true;
      _scanResults.clear();
      
      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: true,
      );
      
      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        _scanResults = results;
        onDevicesFound?.call(results);
      });
      
      print('Bluetooth scanning started');
    } catch (e) {
      print('Error starting Bluetooth scan: $e');
      _isScanning = false;
    }
  }
  
  // Stop scanning
  Future<void> stopScanning() async {
    try {
      await FlutterBluePlus.stopScan();
      _scanSubscription?.cancel();
      _isScanning = false;
      print('Bluetooth scanning stopped');
    } catch (e) {
      print('Error stopping Bluetooth scan: $e');
    }
  }
  
  // Connect to a device
  Future<BluetoothDevice?> connectToDevice(String deviceId) async {
  try {
    final result = _scanResults.firstWhere(
      (r) => r.device.remoteId.toString() == deviceId,
      orElse: () => throw Exception('Device not found'),
    );

    BluetoothDevice device = result.device;

    await device.connect(
      timeout: const Duration(seconds: 15),
      autoConnect: false,
      license: License.free,
    );

    print('Connected to device: ${device.platformName}');
    return device;
  } catch (e) {
    print('Error connecting to device: $e');
    return null;
  }
}

  
  // Disconnect from a device
  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      print('Disconnected from device: ${device.platformName}');
    } catch (e) {
      print('Error disconnecting from device: $e');
    }
  }
  
  // Broadcast emergency signal via BLE
  Future<void> broadcastEmergencySignal({
    required String emergencyType,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // This would require setting up a BLE peripheral/advertising
      // For now, this is a placeholder for the rescue mesh functionality
      
      print('Broadcasting emergency signal:');
      print('Type: $emergencyType');
      print('Location: $latitude, $longitude');
      
      // In a real implementation, you would:
      // 1. Start advertising as a BLE peripheral
      // 2. Include emergency data in the advertisement
      // 3. Other devices would scan and detect this
      
      // Note: BLE advertising is complex and platform-specific
      // iOS has restrictions on background advertising
      // Android allows more flexibility but requires specific setup
    } catch (e) {
      print('Error broadcasting emergency signal: $e');
    }
  }
  
  // Scan for emergency signals from other devices
  Future<List<Map<String, dynamic>>> scanForEmergencySignals({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      List<Map<String, dynamic>> emergencyDevices = [];
      
      await startScanning(timeout: timeout);
      
      // Wait for scan to complete
      await Future.delayed(timeout);
      
      // Filter devices that are broadcasting emergency signals
      // In a real implementation, you would check the advertisement data
      for (ScanResult result in _scanResults) {
        // Check if device is broadcasting emergency signal
        // This is a simplified check - in production, you'd parse the actual data
        if (result.advertisementData.serviceUuids.isNotEmpty) {
          emergencyDevices.add({
            'deviceId': result.device.remoteId.toString(),
            'deviceName': result.device.platformName,
            'rssi': result.rssi,
            'distance': _calculateDistanceFromRSSI(result.rssi),
          });
        }
      }
      
      await stopScanning();
      
      return emergencyDevices;
    } catch (e) {
      print('Error scanning for emergency signals: $e');
      return [];
    }
  }
  
  // Get list of connected devices
  Future<List<BluetoothDevice>> getConnectedDevices() async {
    try {
      return await FlutterBluePlus.connectedDevices;
    } catch (e) {
      print('Error getting connected devices: $e');
      return [];
    }
  }
  
  // Calculate approximate distance from RSSI
  double _calculateDistanceFromRSSI(int rssi) {
    // Simple calculation: d = 10 ^ ((TxPower - RSSI) / (10 * n))
    // Where n = path loss exponent (typically 2-4, using 2 for free space)
    // TxPower typically around -59 dBm at 1 meter
    
    int txPower = -59;
    double n = 2.0;
    
    if (rssi == 0) {
      return -1.0; // Unknown distance
    }
    
    double ratio = (txPower - rssi) / (10 * n);
    double distance = 10.0 * ratio;
    
    return distance;
  }
  
  // Get currently scanned devices
  List<ScanResult> get scanResults => _scanResults;
  
  // Check if currently scanning
  bool get isScanning => _isScanning;
  
  // Check if Bluetooth is supported
  Future<bool> isSupported() async {
    return await FlutterBluePlus.isSupported;
  }
  
  // Dispose resources
  void dispose() {
    stopScanning();
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
  }
}