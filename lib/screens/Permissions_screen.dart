import 'dart:async';
import 'emergency_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class SafetyPermissionsScreen extends StatefulWidget {
  const SafetyPermissionsScreen({Key? key}) : super(key: key);

  @override
  State<SafetyPermissionsScreen> createState() =>
      _SafetyPermissionsScreenState();
}

class _SafetyPermissionsScreenState extends State<SafetyPermissionsScreen>
    with WidgetsBindingObserver {
  bool _emergencyLocation = false;
  bool _impactDetection = false;
  bool _safetyAlerts = false;
  bool _rescueMesh = false;

  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAllPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAllPermissions();
    }
  }

  Future<void> _checkAllPermissions() async {
    final locationStatus = await Permission.location.status;
    final sensorStatus = await Permission.sensors.status;
    final notificationStatus = await Permission.notification.status;
    final bluetoothStatus = await Permission.bluetoothConnect.status;

    if (mounted) {
      setState(() {
        _emergencyLocation = locationStatus.isGranted;
        _impactDetection = sensorStatus.isGranted;
        _safetyAlerts = notificationStatus.isGranted;
        _rescueMesh = bluetoothStatus.isGranted;
      });
    }
  }

  Future<void> _requestLocationPermission(bool value) async {
    if (_isRequesting) return;

    if (!value) {
      setState(() => _emergencyLocation = false);
      return;
    }

    setState(() => _isRequesting = true);

    try {
      // Check if location service is enabled
      final serviceStatus = await Permission.location.serviceStatus;

      if (!serviceStatus.isEnabled) {
        setState(() => _isRequesting = false);

        final result = await _showServiceDialog(
          icon: Icons.location_on,
          title: 'Enable Location',
          message:
              'Location services are turned off. Please enable them in Settings to use Emergency Location.',
        );

        if (result == true) {
          await openAppSettings();
        }
        return;
      }

      // Request permission
      final status = await Permission.location.request().timeout(
        const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _emergencyLocation = status.isGranted;
          _isRequesting = false;
        });

        if (!status.isGranted) {
          _handlePermissionDenied(status, 'Location',
              'Location permission is needed for Emergency Location');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _emergencyLocation = false;
          _isRequesting = false;
        });
        _showError('Error requesting location permission');
      }
    }
  }

  Future<void> _requestSensorPermission(bool value) async {
    if (_isRequesting) return;

    if (!value) {
      setState(() => _impactDetection = false);
      return;
    }

    setState(() => _isRequesting = true);

    try {
      final status = await Permission.sensors.request().timeout(
        const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _impactDetection = status.isGranted;
          _isRequesting = false;
        });

        if (!status.isGranted) {
          _handlePermissionDenied(
              status, 'Sensors', 'Sensor access is needed for Impact Detection');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _impactDetection = false;
          _isRequesting = false;
        });
        _showError('Error requesting sensor permission');
      }
    }
  }

  Future<void> _requestNotificationPermission(bool value) async {
    if (_isRequesting) return;

    if (!value) {
      setState(() => _safetyAlerts = false);
      return;
    }

    setState(() => _isRequesting = true);

    try {
      final status = await Permission.notification.request().timeout(
        const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _safetyAlerts = status.isGranted;
          _isRequesting = false;
        });

        if (!status.isGranted) {
          _handlePermissionDenied(status, 'Notifications',
              'Notification permission is needed for Safety Alerts');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _safetyAlerts = false;
          _isRequesting = false;
        });
        _showError('Error requesting notification permission');
      }
    }
  }

  Future<void> _requestBluetoothPermission(bool value) async {
    if (_isRequesting) return;

    if (!value) {
      setState(() => _rescueMesh = false);
      return;
    }

    setState(() => _isRequesting = true);

    try {
      // Check if bluetooth service is enabled
      final serviceStatus = await Permission.bluetooth.serviceStatus;

      if (!serviceStatus.isEnabled) {
        setState(() => _isRequesting = false);

        final result = await _showServiceDialog(
          icon: Icons.bluetooth,
          title: 'Enable Bluetooth',
          message:
              'Bluetooth is turned off. Please enable it in Settings to use Rescue Mesh for offline connectivity.',
        );

        if (result == true) {
          await openAppSettings();
        }
        return;
      }

      // Request permission
      final status = await Permission.bluetoothConnect.request().timeout(
        const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _rescueMesh = status.isGranted;
          _isRequesting = false;
        });

        if (!status.isGranted) {
          _handlePermissionDenied(
              status, 'Bluetooth', 'Bluetooth permission is needed for Rescue Mesh');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _rescueMesh = false;
          _isRequesting = false;
        });
        _showError('Error requesting bluetooth permission');
      }
    }
  }

  Future<bool?> _showServiceDialog({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF06D6A0), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06D6A0),
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePermissionDenied(
      PermissionStatus status, String name, String message) async {
    if (status.isPermanentlyDenied) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('$name Permission Required'),
          content: Text(
            '$message. This permission has been permanently denied. Please enable it in Settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06D6A0),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );

      if (result == true) {
        await openAppSettings();
      }
    } else {
      _showError(message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _allowAllPermissions() async {
    if (_isRequesting) return;

    setState(() => _isRequesting = true);

    try {
      await _requestLocationPermission(true);
      await Future.delayed(const Duration(milliseconds: 300));

      await _requestSensorPermission(true);
      await Future.delayed(const Duration(milliseconds: 300));

      await _requestNotificationPermission(true);
      await Future.delayed(const Duration(milliseconds: 300));

      await _requestBluetoothPermission(true);

      if (mounted && _emergencyLocation && _impactDetection && _safetyAlerts) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => EmergencyDashboardScreen()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F3),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Safety Permissions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF06D6A0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Stay Safe &\nConnected',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'To protect you in an emergency, we need\naccess to a few tools. Your data is encrypted\nand used only for your safety.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildPermissionCard(
                      icon: Icons.location_on,
                      title: 'Emergency Location',
                      description: 'To find you in emergencies',
                      value: _emergencyLocation,
                      onChanged: _requestLocationPermission,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionCard(
                      icon: Icons.medical_services_outlined,
                      title: 'Impact Detection',
                      description: 'To detect falls or accidents',
                      value: _impactDetection,
                      onChanged: _requestSensorPermission,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionCard(
                      icon: Icons.notifications_active_outlined,
                      title: 'Safety Alerts',
                      description: 'To receive urgent warnings',
                      value: _safetyAlerts,
                      onChanged: _requestNotificationPermission,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionCard(
                      icon: Icons.bluetooth,
                      title: 'Rescue Mesh',
                      description: 'To find others when offline',
                      value: _rescueMesh,
                      onChanged: _requestBluetoothPermission,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isRequesting ? null : _allowAllPermissions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06D6A0),
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          disabledBackgroundColor:
                              const Color(0xFF06D6A0).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isRequesting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black87,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Allow All',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => EmergencyDashboardScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                      ),
                      child: const Text(
                        'Ask Later',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text('Data Privacy'),
                            content: const Text(
                              'Your location and safety data is encrypted end-to-end and only used during emergencies. We never share your data with third parties.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Got it'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text(
                        'How we handle your data',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final iconColor =
        value ? const Color(0xFF06D6A0) : const Color(0xFF9CA3AF);
    final iconBgColor =
        value ? const Color(0xFFD1FAE5) : const Color(0xFFE5E7EB);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: _isRequesting ? null : onChanged,
              activeColor: const Color(0xFF06D6A0),
              activeTrackColor: const Color(0xFF06D6A0).withOpacity(0.5),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFE5E7EB),
            ),
          ),
        ],
      ),
    );
  }
}