import 'package:flutter/material.dart';

class EmergencyBeaconScreen extends StatefulWidget {
  const EmergencyBeaconScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyBeaconScreen> createState() => _EmergencyBeaconScreenState();
}

class _EmergencyBeaconScreenState extends State<EmergencyBeaconScreen> {
  bool isBeaconActive = true;
  String privacyId = "4X92-LZ11";
  String timeRemaining = "02:45";

  final List<Map<String, dynamic>> nearbyPeers = [
    {
      'name': 'Node-771B',
      'distance': '~12m',
      'signal': -64,
      'status': 'STRONG',
      'color': Colors.green,
    },
    {
      'name': 'Relay-Alpha',
      'distance': '~45m',
      'signal': -88,
      'status': 'FADING',
      'color': Colors.amber,
    },
    {
      'name': 'Node-Z920',
      'distance': 'Last seen 2m ago',
      'signal': -98,
      'status': 'LOST',
      'color': Colors.grey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2D2D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2D2D),
        elevation: 0,
        leading: const Icon(Icons.bluetooth, color: Color(0xFF00E5CC)),
        title: const Text(
          'Emergency Beacon',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.signal_cellular_alt, color: Color(0xFF00E5CC)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Beacon Mode Card
            _buildBeaconModeCard(),
            const SizedBox(height: 16),

            // DTN Relay Status Card
            _buildDTNRelayCard(),
            const SizedBox(height: 16),

            // Security/Privacy ID Card
            _buildPrivacyIDCard(),
            const SizedBox(height: 24),

            // Nearby Peers Section
            _buildNearbyPeersSection(),
            const SizedBox(height: 16),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBeaconModeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF143838),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F4D4D), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Beacon Mode',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00E5CC),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Broadcasting...',
                style: TextStyle(
                  color: Color(0xFF00E5CC),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Switch(
            value: isBeaconActive,
            onChanged: (value) {
              setState(() {
                isBeaconActive = value;
              });
            },
            activeColor: const Color(0xFF00E5CC),
            activeTrackColor: const Color(0xFF1F4D4D),
          ),
        ],
      ),
    );
  }

  Widget _buildDTNRelayCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF143838),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F4D4D), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DTN Relay Status',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Icon(
                Icons.hub_outlined,
                color: const Color(0xFF00E5CC),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Active Hop',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'CONNECTED',
            style: TextStyle(
              color: Color(0xFF00CC88),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyIDCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF143838),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F4D4D), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SECURITY',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Rotating Privacy ID',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  privacyId,
                  style: const TextStyle(
                    color: Color(0xFF00E5CC),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Auto-rotates in $timeRemaining',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Regenerate ID logic
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Regenerate ID'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5CC),
                    foregroundColor: const Color(0xFF0D2D2D),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF1F4D4D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield,
              color: Color(0xFF00E5CC),
              size: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPeersSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nearby Peers Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1F4D4D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '6 ONLINE',
                style: TextStyle(
                  color: Color(0xFF00E5CC),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...nearbyPeers.map((peer) => _buildPeerCard(peer)),
      ],
    );
  }

  Widget _buildPeerCard(Map<String, dynamic> peer) {
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
              color: const Color(0xFF1F4D4D),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: peer['color'],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  peer['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  peer['distance'],
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
                '${peer['signal']} dBm',
                style: TextStyle(
                  color: peer['color'],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                peer['status'],
                style: TextStyle(
                  color: peer['color'],
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.signal_cellular_alt,
            color: peer['color'],
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_tethering,
            color: Color(0xFF00E5CC),
            size: 16,
          ),
          const SizedBox(width: 8),
          const Text(
            'DTN MESH ACTIVE',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 24),
          const Text(
            'V2.4.0-STABLE',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}