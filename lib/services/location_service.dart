import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  String? _currentAddress;
  
  // Callbacks
  Function(Position position)? onLocationUpdate;
  Function(String address)? onAddressUpdate;
  
  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }
      
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
      
      _currentPosition = position;
      return position;
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }
  
  // Get address from coordinates
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';
        
        if (place.street != null && place.street!.isNotEmpty) {
          address += '${place.street}, ';
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          address += place.locality!;
        }
        if (place.administrativeArea != null && 
            place.administrativeArea!.isNotEmpty) {
          address += ', ${place.administrativeArea}';
        }
        
        _currentAddress = address;
        return address;
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }
  
  // Start location tracking
  Future<void> startLocationTracking({
    int distanceFilter = 10, // meters
    int timeInterval = 5000, // milliseconds
  }) async {
    try {
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
      
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) async {
        _currentPosition = position;
        onLocationUpdate?.call(position);
        
        // Get address
        String? address = await getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (address != null) {
          onAddressUpdate?.call(address);
        }
      });
    } catch (e) {
      print('Error starting location tracking: $e');
    }
  }
  
  // Stop location tracking
  void stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
  
  // Calculate distance between two points
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
  
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  // Request location permission
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    return permission == LocationPermission.always ||
           permission == LocationPermission.whileInUse;
  }
  
  // Get location permission status
  Future<LocationPermission> getPermissionStatus() async {
    return await Geolocator.checkPermission();
  }
  
  // Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
  
  // Get current cached position
  Position? get currentPosition => _currentPosition;
  
  // Get current cached address
  String? get currentAddress => _currentAddress;
  
  // Dispose
  void dispose() {
    stopLocationTracking();
  }
}