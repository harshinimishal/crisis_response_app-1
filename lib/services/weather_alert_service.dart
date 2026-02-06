import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherAlertService {
  static const String _apiKey = 'f98e41c5562aecc8fd14dfc05e3668a0';
  static const String _baseUrl = 'https://api.openweathermap.org/data/3.0/onecall';

  /// Get current weather alerts based on location
  Future<Map<String, dynamic>?> getCurrentWeatherAlert({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final Position position = await _resolveLocation(
        latitude: latitude,
        longitude: longitude,
      );

      final uri = Uri.parse(
        '$_baseUrl'
        '?lat=${position.latitude}'
        '&lon=${position.longitude}'
        '&exclude=minutely,hourly,daily'
        '&appid=$_apiKey'
        '&units=metric',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Weather API failed: ${response.statusCode}');
      }

      final Map<String, dynamic> data = json.decode(response.body);

      if (data['alerts'] == null || data['alerts'].isEmpty) {
        return null; // No active alerts
      }

      final alert = data['alerts'][0];

      return {
        'type': alert['event'],
        'title': alert['event'],
        'description': alert['description'],
        'severity': _mapSeverity(alert['event']),
        'start': alert['start'],
        'end': alert['end'],
        'source': alert['sender_name'],
      };
    } catch (e) {
      print('Weather alert error: $e');
      return null;
    }
  }

  /// Get current weather snapshot (for dashboard cards)
  Future<Map<String, dynamic>?> getWeatherForecast({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final Position position = await _resolveLocation(
        latitude: latitude,
        longitude: longitude,
      );

      final uri = Uri.parse(
        '$_baseUrl'
        '?lat=${position.latitude}'
        '&lon=${position.longitude}'
        '&exclude=minutely,hourly,alerts'
        '&appid=$_apiKey'
        '&units=metric',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Forecast API failed');
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final current = data['current'];

      return {
        'temperature': current['temp'],
        'condition': current['weather'][0]['main'],
        'description': current['weather'][0]['description'],
        'humidity': current['humidity'],
        'windSpeed': current['wind_speed'],
      };
    } catch (e) {
      print('Weather forecast error: $e');
      return null;
    }
  }

  /// Resolve location safely
  Future<Position> _resolveLocation({
    double? latitude,
    double? longitude,
  }) async {
    if (latitude != null && longitude != null) {
      return Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
  }

  /// Map alert type to severity
  String _mapSeverity(String event) {
    final lower = event.toLowerCase();

    if (lower.contains('severe') ||
        lower.contains('extreme') ||
        lower.contains('hurricane') ||
        lower.contains('tornado')) {
      return 'severe';
    }

    if (lower.contains('storm') ||
        lower.contains('flood') ||
        lower.contains('heat') ||
        lower.contains('snow')) {
      return 'moderate';
    }

    return 'minor';
  }
}
