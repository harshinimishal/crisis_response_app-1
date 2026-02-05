import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdvancedSensorsPage extends StatefulWidget {
  const AdvancedSensorsPage({Key? key}) : super(key: key);

  @override
  State<AdvancedSensorsPage> createState() => _AdvancedSensorsPageState();
}

class _AdvancedSensorsPageState extends State<AdvancedSensorsPage> {
  double _detectionSensitivity = 0.5; // Medium = 0.5
  bool _ultraLowPowerMode = false;
  bool _enhancedBLEBeacon = false;
  bool _periodicLogUploads = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F2E),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildDetectionSettings(),
                    const SizedBox(height: 24),
                    _buildPowerManagement(),
                    const SizedBox(height: 24),
                    _buildSynchronization(),
                    const SizedBox(height: 24),
                    _buildCalibrationWarning(),
                    const SizedBox(height: 16),
                    _buildRestoreButton(),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Advanced Sensors',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF252B3D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.sensors,
                  color: Color(0xFF6C5CE7),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Detection Settings',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Auto-Detection Sensitivity',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              Text(
                _getSensitivityLabel(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4ECDC4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'LOW',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
                    activeTrackColor: const Color(0xFF4ECDC4),
                    inactiveTrackColor: const Color(0xFF3A4052),
                    thumbColor: const Color(0xFF4ECDC4),
                    overlayColor: const Color(0xFF4ECDC4).withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _detectionSensitivity,
                    onChanged: (value) {
                      setState(() {
                        _detectionSensitivity = value;
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),
              ),
              const Text(
                'HIGH',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Higher sensitivity may increase false alerts but significantly improves response time during real motion events.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getSensitivityLabel() {
    if (_detectionSensitivity < 0.33) {
      return 'Low';
    } else if (_detectionSensitivity < 0.66) {
      return 'Medium';
    } else {
      return 'High';
    }
  }

  Widget _buildPowerManagement() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF252B3D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.battery_charging_full,
                  color: Color(0xFF4A90E2),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Power Management',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildToggleItem(
            title: 'Ultra-Low-Power Mode',
            description:
                'Disable non-essential background pings to extend battery life up to 15x-20x.',
            value: _ultraLowPowerMode,
            icon: Icons.power_settings_new,
            iconColor: const Color(0xFF4A90E2),
            onChanged: (value) {
              setState(() {
                _ultraLowPowerMode = value;
              });
              HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(height: 16),
          _buildToggleItem(
            title: 'Enhanced BLE Beacon',
            description:
                'Increases signal strength for precision indoor tracking. Recommended for high-density buildings.',
            value: _enhancedBLEBeacon,
            icon: Icons.bluetooth,
            iconColor: const Color(0xFF4ECDC4),
            onChanged: (value) {
              setState(() {
                _enhancedBLEBeacon = value;
              });
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSynchronization() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF252B3D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.sync,
                  color: Color(0xFF4ECDC4),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Synchronization',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildToggleItem(
            title: 'Periodic Log Uploads',
            description:
                'Automatically syncs sensor logs to the cloud every 15 minutes while on Wi-Fi.',
            value: _periodicLogUploads,
            icon: Icons.cloud_upload,
            iconColor: const Color(0xFF4A90E2),
            onChanged: (value) {
              setState(() {
                _periodicLogUploads = value;
              });
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    required String description,
    required bool value,
    required IconData icon,
    required Color iconColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Transform.scale(
          scale: 0.85,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4ECDC4),
            activeTrackColor: const Color(0xFF4ECDC4).withOpacity(0.5),
            inactiveThumbColor: const Color(0xFF6B7280),
            inactiveTrackColor: const Color(0xFF3A4052),
          ),
        ),
      ],
    );
  }

  Widget _buildCalibrationWarning() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2420),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFA726).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA726).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Color(0xFFFFA726),
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'CALIBRATION REQUIRED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFA726),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Changing these values affects the core emergency response logic. Please consult the system administrator before modifying device-level protocols.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _showRestoreDialog();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4A90E2).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Text(
                'Restore Default Protocols',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A90E2),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252B3D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Restore Default Settings?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will reset all advanced sensor settings to their default values.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _detectionSensitivity = 0.5;
                _ultraLowPowerMode = false;
                _enhancedBLEBeacon = false;
                _periodicLogUploads = false;
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Restore',
              style: TextStyle(color: Color(0xFF4A90E2)),
            ),
          ),
        ],
      ),
    );
  }
}