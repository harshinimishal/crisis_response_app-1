import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntegratedSettingsPage extends StatefulWidget {
  const IntegratedSettingsPage({Key? key}) : super(key: key);

  @override
  State<IntegratedSettingsPage> createState() => _IntegratedSettingsPageState();
}

class _IntegratedSettingsPageState extends State<IntegratedSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sensor Settings
  double _detectionSensitivity = 0.5;
  bool _ultraLowPowerMode = false;
  bool _enhancedBLEBeacon = false;
  bool _periodicLogUploads = false;

  // Connectivity Data
  final List<Map<String, dynamic>> queuedEvents = [
    {
      'title': 'Alert: Medical Assistance',
      'subtitle': 'Waiting for next SMS hop...',
      'time': '2m ago',
      'icon': Icons.warning_amber,
      'iconColor': Color(0xFFFF4444),
      'bgColor': Color(0xFF2D1F1F),
    },
    {
      'title': 'Status Update: Safe',
      'subtitle': 'In DTN transmission queue',
      'time': '5m ago',
      'icon': Icons.check_circle,
      'iconColor': Color(0xFF00FF88),
      'bgColor': Color(0xFF1F2D1F),
    },
  ];

  final List<Map<String, dynamic>> nearbyDevices = [
    {
      'name': 'Node-882-Alpha',
      'signal': 'Strong',
      'distance': '4m away',
      'icon': Icons.router,
    },
    {
      'name': 'Phone-User-01',
      'signal': 'Medium',
      'distance': '12m away',
      'icon': Icons.phone_android,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSensorsTab(),
                  _buildConnectivityTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Advanced Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'System Configuration',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF4A9EFF).withOpacity(0.3),
            width: 1,
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF666666),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.sensors, size: 20),
            text: 'SENSORS',
          ),
          Tab(
            icon: Icon(Icons.wifi_tethering, size: 20),
            text: 'CONNECTIVITY',
          ),
        ],
      ),
    );
  }

  // ==================== SENSORS TAB ====================

  Widget _buildSensorsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetectionSettings(),
            const SizedBox(height: 16),
            _buildPowerManagement(),
            const SizedBox(height: 16),
            _buildSynchronization(),
            const SizedBox(height: 16),
            _buildCalibrationWarning(),
            const SizedBox(height: 16),
            _buildRestoreButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A9EFF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF4A9EFF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.sensors,
                  color: Color(0xFF4A9EFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Detection Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getSensitivityColor().withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getSensitivityColor().withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getSensitivityLabel().toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getSensitivityColor(),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'LOW',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                      elevation: 2,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 20,
                    ),
                    activeTrackColor: _getSensitivityColor(),
                    inactiveTrackColor: const Color(0xFF2A2A2A),
                    thumbColor: _getSensitivityColor(),
                    overlayColor: _getSensitivityColor().withOpacity(0.2),
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
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white.withOpacity(0.4),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Higher sensitivity improves response time but may increase false alerts.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
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

  Color _getSensitivityColor() {
    if (_detectionSensitivity < 0.33) {
      return const Color(0xFF00FF88); // Green for low/safe
    } else if (_detectionSensitivity < 0.66) {
      return const Color(0xFF4A9EFF); // Blue for medium/normal
    } else {
      return const Color(0xFFFF4444); // Red for high/alert
    }
  }

  Widget _buildPowerManagement() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF88).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF00FF88).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.battery_charging_full,
                  color: Color(0xFF00FF88),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Power Management',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
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
            iconColor: const Color(0xFF00FF88),
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
            iconColor: const Color(0xFF4A9EFF),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A9EFF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF4A9EFF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.sync,
                  color: Color(0xFF4A9EFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Synchronization',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
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
            iconColor: const Color(0xFF4A9EFF),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? iconColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: iconColor,
              activeTrackColor: iconColor.withOpacity(0.4),
              inactiveThumbColor: const Color(0xFF666666),
              inactiveTrackColor: const Color(0xFF2A2A2A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF4444).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4444).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFFF4444).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Color(0xFFFF4444),
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'CALIBRATION REQUIRED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF4444),
                        letterSpacing: 1,
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
    return Material(
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
              color: const Color(0xFF4A9EFF).withOpacity(0.5),
              width: 1.5,
            ),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF4A9EFF).withOpacity(0.1),
                const Color(0xFF4A9EFF).withOpacity(0.05),
              ],
            ),
          ),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restart_alt,
                  color: Color(0xFF4A9EFF),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'RESTORE DEFAULT PROTOCOLS',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A9EFF),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
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
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        title: const Text(
          'Restore Default Settings?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will reset all advanced sensor settings to their default values.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF666666)),
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
              HapticFeedback.mediumImpact();
            },
            child: const Text(
              'Restore',
              style: TextStyle(
                color: Color(0xFF4A9EFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CONNECTIVITY TAB ====================

  Widget _buildConnectivityTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connectivity Health',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 16),
            _buildConnectivityGrid(),
            const SizedBox(height: 24),
            const Text(
              'Queued Events',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 16),
            ...queuedEvents.map((event) => _buildEventCard(event)),
            const SizedBox(height: 24),
            const Text(
              'Nearby Peer Devices',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 16),
            ...nearbyDevices.map((device) => _buildDeviceCard(device)),
            const SizedBox(height: 20),
            _buildRetryButton(),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'LAST CHECKED: ${TimeOfDay.now().format(context)}',
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                icon: const Icon(
                  Icons.power_settings_new,
                  size: 16,
                  color: Color(0xFFFFAA00),
                ),
                label: const Text(
                  'Enable Low Power Mode',
                  style: TextStyle(
                    color: Color(0xFFFFAA00),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectivityGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildConnectivityCard(
          icon: Icons.cloud_off,
          title: 'Internet',
          status: 'Offline',
          isActive: false,
          statusColor: const Color(0xFFFF4444),
        ),
        _buildConnectivityCard(
          icon: Icons.sms,
          title: 'SMS',
          status: 'Active Gateway',
          isActive: true,
          statusColor: const Color(0xFF00FF88),
        ),
        _buildConnectivityCard(
          icon: Icons.hub_outlined,
          title: 'DTN',
          status: 'Standby',
          isActive: false,
          statusColor: const Color(0xFF4A9EFF),
        ),
        _buildConnectivityCard(
          icon: Icons.bluetooth,
          title: 'BLE Mesh',
          status: 'Active',
          isActive: true,
          statusColor: const Color(0xFF00FF88),
        ),
      ],
    );
  }

  Widget _buildConnectivityCard({
    required IconData icon,
    required String title,
    required String status,
    required bool isActive,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? statusColor.withOpacity(0.5)
              : Colors.white.withOpacity(0.05),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? statusColor.withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isActive ? statusColor : const Color(0xFF666666),
              size: 28,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF999999),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: event['iconColor'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: event['bgColor'],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: event['iconColor'].withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              event['icon'],
              color: event['iconColor'],
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event['subtitle'],
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                event['time'],
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Icon(
                Icons.refresh,
                color: event['iconColor'],
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00FF88).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF00FF88).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF00FF88).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              device['icon'],
              color: const Color(0xFF00FF88),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Signal: ${device['signal']} • ${device['distance']}',
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.signal_cellular_alt,
            color: Color(0xFF00FF88),
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00FF88),
            Color(0xFF00CC6E),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF88).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
        },
        icon: const Icon(Icons.refresh, size: 20),
        label: const Text(
          'RETRY ALL TRANSMISSIONS',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF0A0A0A),
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}