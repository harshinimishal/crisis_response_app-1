import 'package:flutter/material.dart';

class EventHistoryScreen extends StatefulWidget {
  const EventHistoryScreen({Key? key}) : super(key: key);

  @override
  State<EventHistoryScreen> createState() => _EventHistoryScreenState();
}

class _EventHistoryScreenState extends State<EventHistoryScreen> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterTabs(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildManualSOSEvent(),
                  const SizedBox(height: 16),
                  _buildAccidentDetectedEvent(),
                  const SizedBox(height: 16),
                  _buildSafetyCheckInEvent(),
                  const SizedBox(height: 16),
                  _buildLowBatteryEvent(),
                  const SizedBox(height: 30),
                  _buildArchiveSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF3A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
          const Text(
            'Event History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF3A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.share,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterTab('All', true),
          const SizedBox(width: 12),
          _buildFilterTab('SOS', false, icon: Icons.sos),
          const SizedBox(width: 12),
          _buildFilterTab('Warnings', false, icon: Icons.warning),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, bool isSelected, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFF3333) : const Color(0xFF3A2A2A),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualSOSEvent() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF3333), width: 2),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3333),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Manual SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Today • 14:20',
                        style: TextStyle(
                          color: Color(0xFF808080),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D5F2D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF40C463),
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'SENT',
                        style: TextStyle(
                          color: Color(0xFF40C463),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.expand_more,
                  color: Color(0xFF808080),
                  size: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccidentDetectedEvent() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFA726), width: 2),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA726),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.car_crash,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Accident Detected',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Oct 24, 2023 • 12:05',
                        style: TextStyle(
                          color: Color(0xFF808080),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A4A1A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.access_time,
                        color: Color(0xFFFFA726),
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'PENDING',
                        style: TextStyle(
                          color: Color(0xFFFFA726),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.expand_less,
                  color: Color(0xFF808080),
                  size: 24,
                ),
              ],
            ),
          ),
          // Expanded content
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(
                  'https://api.mapbox.com/styles/v1/mapbox/light-v10/static/-122.4194,37.7749,12,0/600x400?access_token=YOUR_TOKEN',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3333),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LOCATION',
                  style: TextStyle(
                    color: Color(0xFF808080),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '37.7749° N, 122.4194° W',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3333),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Retry Signal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildSafetyCheckInEvent() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A90E2), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Safety Check-In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Oct 23, 2023 • 09:15',
                    style: TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2A3A5A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.message,
                    color: Color(0xFF4A90E2),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'RELAYED VIA SMS',
                    style: TextStyle(
                      color: Color(0xFF4A90E2),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.expand_more,
              color: Color(0xFF808080),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowBatteryEvent() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF808080), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.battery_alert,
                color: Color(0xFF808080),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Low Battery Warning',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Oct 22, 2023 • 22:45',
                    style: TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2A3A2A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.check_circle,
                    color: Color(0xFF808080),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'SENT',
                    style: TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.expand_more,
              color: Color(0xFF808080),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveSection() {
    return Column(
      children: [
        const Icon(
          Icons.archive,
          color: Color(0xFF808080),
          size: 48,
        ),
        const SizedBox(height: 12),
        const Text(
          'Older events are archived',
          style: TextStyle(
            color: Color(0xFF808080),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF3A2A2A),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Text(
            'LOAD ARCHIVE',
            style: TextStyle(
              color: Color(0xFF808080),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: const Color(0xFF3A3A3A), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', false),
          _buildNavItem(Icons.security, 'SafeZone', false),
          _buildNavItem(Icons.history, 'History', true),
          _buildNavItem(Icons.settings, 'Settings', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFFFF3333) : const Color(0xFF808080),
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFFF3333) : const Color(0xFF808080),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}