import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherAlertService {
  // Use OpenWeatherMap API or similar
  static const String apiKey = 'f98e41c5562aecc8fd14dfc05e3668a0';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // Get current weather alerts
  Future<Map<String, dynamic>?> getCurrentWeatherAlert({
    double? latitude,
    double? longitude,
  }) async {
    try {
      Position? position;
      
      if (latitude == null || longitude == null) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
        latitude = position.latitude;
        longitude = position.longitude;
      }
      
      // In a real implementation, call weather API
      // For demo purposes, return mock data
      return _getMockWeatherAlert();
    } catch (e) {
      print('Error getting weather alert: $e');
      return null;
    }
  }
  
  // Mock weather alert for demo
  Map<String, dynamic> _getMockWeatherAlert() {
    // Simulate different alert types
    List<Map<String, dynamic>> alertTypes = [
      {
        'type': 'heavy_rain',
        'title': 'Heavy Rain in your area',
        'description': 'Flood advisory active for Seattle, WA',
        'severity': 'moderate',
        'icon': 'rain',
      },
      {
        'type': 'storm',
        'title': 'Severe Thunderstorm Warning',
        'description': 'Take shelter immediately',
        'severity': 'severe',
        'icon': 'storm',
      },
      {
        'type': 'snow',
        'title': 'Winter Storm Advisory',
        'description': 'Heavy snowfall expected in your area',
        'severity': 'moderate',
        'icon': 'snow',
      },
    ];
    
    // Return random alert or null (80% chance of alert for demo)
    if (DateTime.now().second % 5 == 0) {
      return alertTypes[0];
    }
    
    return alertTypes[0]; // Always show heavy rain for demo
  }
  
  // Get weather forecast
  Future<Map<String, dynamic>?> getWeatherForecast({
    double? latitude,
    double? longitude,
  }) async {
    try {
      Position? position;
      
      if (latitude == null || longitude == null) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
        latitude = position.latitude;
        longitude = position.longitude;
      }
      
      // Mock forecast data
      return {
        'temperature': 18,
        'condition': 'Rainy',
        'humidity': 85,
        'windSpeed': 12,
      };
    } catch (e) {
      print('Error getting weather forecast: $e');
      return null;
    }
  }
}