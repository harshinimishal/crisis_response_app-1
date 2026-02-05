import 'package:flutter/material.dart';

class ConnectivityStatusScreen extends StatefulWidget {
  const ConnectivityStatusScreen({Key? key}) : super(key: key);

  @override
  State<ConnectivityStatusScreen> createState() =>
      _ConnectivityStatusScreenState();
}

class _ConnectivityStatusScreenState extends State<ConnectivityStatusScreen> {
  final List<Map<String, dynamic>> queuedEvents = [
    {
      'title': 'Alert: Medical Assistance',
      'subtitle': 'Waiting for next SMS hop...',
      'time': '2m ago',
      'icon': Icons.warning_amber,
      'iconColor': Colors.red,
      'bgColor': Color(0xFF3D1F1F),
    },
    {
      'title': 'Status Update: Safe',
      'subtitle': 'In DTN transmission queue',
      'time': '5m ago',
      'icon': Icons.check_circle,
      'iconColor': Color(0xFF00E5CC),
      'bgColor': Color(0xFF1F3D3D),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2D2D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2D2D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Connectivity Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connectivity Health',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Connectivity Status Grid
            _buildConnectivityGrid(),
            const SizedBox(height: 32),

            // Queued Events Section
            const Text(
              'Queued Events',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...queuedEvents.map((event) => _buildEventCard(event)),
            const SizedBox(height: 32),

            // Nearby Peer Devices
            const Text(
              'Nearby Peer Devices',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...nearbyDevices.map((device) => _buildDeviceCard(device)),
            const SizedBox(height: 24),

            // Retry Button
            _buildRetryButton(),
            const SizedBox(height: 16),

            // Last Checked
            Center(
              child: Text(
                'LAST CHECKED: 14:02:45',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Low Power Mode Link
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Enable Low Power Mode',
                  style: TextStyle(
                    color: Color(0xFFFFAA00),
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
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
      childAspectRatio: 1.3,
      children: [
        _buildConnectivityCard(
          icon: Icons.cloud_off,
          title: 'Internet',
          status: 'Offline',
          isActive: false,
        ),
        _buildConnectivityCard(
          icon: Icons.sms,
          title: 'SMS',
          status: 'Active Gateway',
          isActive: true,
        ),
        _buildConnectivityCard(
          icon: Icons.hub_outlined,
          title: 'DTN',
          status: 'Standby',
          isActive: false,
          statusColor: Colors.blue,
        ),
        _buildConnectivityCard(
          icon: Icons.bluetooth,
          title: 'BLE',
          status: 'Mesh Active',
          isActive: true,
        ),
      ],
    );
  }

  Widget _buildConnectivityCard({
    required IconData icon,
    required String title,
    required String status,
    required bool isActive,
    Color? statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF143838) : const Color(0xFF1F2D2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF00E5CC) : const Color(0xFF1F4D4D),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF00E5CC) : Colors.white30,
            size: 32,
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              color: statusColor ?? (isActive ? const Color(0xFF00E5CC) : Colors.white38),
              fontSize: 13,
            ),
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
        color: const Color(0xFF143838),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F4D4D), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: event['bgColor'],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              event['icon'],
              color: event['iconColor'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event['subtitle'],
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
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
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                Icons.refresh,
                color: const Color(0xFF00E5CC),
                size: 20,
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
        color: const Color(0xFF143838),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F4D4D), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF1F4D4D),
              shape: BoxShape.circle,
            ),
            child: Icon(
              device['icon'],
              color: const Color(0xFF00E5CC),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Signal: ${device['signal']} • ${device['distance']}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.signal_cellular_alt,
            color: Color(0xFF00E5CC),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Retry logic
        },
        icon: const Icon(Icons.refresh, size: 20),
        label: const Text(
          'Retry All Transmissions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5CC),
          foregroundColor: const Color(0xFF0D2D2D),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}