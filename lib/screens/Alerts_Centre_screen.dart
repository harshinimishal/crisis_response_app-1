import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlertsCenterPage extends StatefulWidget {
  const AlertsCenterPage({Key? key}) : super(key: key);

  @override
  State<AlertsCenterPage> createState() => _AlertsCenterPageState();
}

class _AlertsCenterPageState extends State<AlertsCenterPage>
    with SingleTickerProviderStateMixin {
  int _selectedCategory = 0;
  String _searchQuery = '';
  late AnimationController _pulseController;

  final List<String> _categories = ['Emergency', 'Community', 'Preventive'];

  final List<Map<String, dynamic>> _alerts = [
    {
      'title': 'Wildfire Warning: Northern Hills',
      'time': '2m ago',
      'description':
          'Immediate evacuation ordered for zone A-12. Public shelters are...',
      'type': 'emergency',
      'icon': Icons.local_fire_department_rounded,
      'color': const Color(0xFFFF6B6B),
      'action': 'View on Map',
      'actionIcon': Icons.map_rounded,
      'active': true,
    },
    {
      'title': 'Hazard: Gas Leak at Downtown',
      'time': '15m ago',
      'description':
          'Gas leak reported near 5th Avenue and Oak Street. Avoid the area until further...',
      'type': 'emergency',
      'icon': Icons.warning_rounded,
      'color': const Color(0xFFFFA726),
      'action': 'User Report',
      'actionIcon': Icons.person_rounded,
      'active': true,
    },
    {
      'title': 'Severe Thunderstorm Watch',
      'time': '1h ago',
      'description':
          'Expected heavy rainfall and high winds. Secure loose outdoor items...',
      'type': 'preventive',
      'icon': Icons.thunderstorm_rounded,
      'color': const Color(0xFF4A90E2),
      'action': 'System Alert',
      'actionIcon': Icons.notification_important_rounded,
      'active': false,
    },
    {
      'title': 'System Maintenance Complete',
      'time': '4h ago',
      'description':
          'Emergency sirens were tested successfully in the Downtown area.',
      'type': 'preventive',
      'icon': Icons.check_circle_rounded,
      'color': const Color(0xFF00D9A5),
      'action': 'Preventive',
      'actionIcon': Icons.shield_rounded,
      'active': false,
    },
    {
      'title': 'Road Blockage: Main St',
      'time': '4h ago',
      'description':
          'Tree fell on power lines. Crews are on site. Traffic diverted to 2nd Street.',
      'type': 'community',
      'icon': Icons.block_rounded,
      'color': const Color(0xFFFF8C42),
      'action': 'Community',
      'actionIcon': Icons.groups_rounded,
      'active': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAlerts {
    List<Map<String, dynamic>> filtered = _alerts;

    // Filter by category
    String categoryFilter = _categories[_selectedCategory].toLowerCase();
    if (categoryFilter != 'emergency') {
      filtered = filtered.where((alert) => alert['type'] == categoryFilter).toList();
    } else {
      filtered = filtered.where((alert) => alert['type'] == 'emergency').toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((alert) =>
              alert['title'].toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  List<Map<String, dynamic>> get _recentAlerts {
    return _alerts.where((alert) => alert['active'] != true).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryTabs(),
            _buildSearchBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                  HapticFeedback.mediumImpact();
                },
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 8),
                    _buildRecentNotifications(),
                    if (_recentAlerts.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildEarlierToday(),
                    ],
                    const SizedBox(height: 24),
                    _buildIncidentMap(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3436)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Alerts Center',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.check_circle_outline,
                  color: Color(0xFF4A90E2)),
              onPressed: () {
                HapticFeedback.lightImpact();
                // Mark all as read
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_categories.length, (index) {
          final isSelected = _selectedCategory == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = index;
                });
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF4A90E2), Color(0xFF4ECDC4)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _categories[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF636E72),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search history...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildRecentNotifications() {
    final activeAlerts = _filteredAlerts.where((a) => a['active'] == true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'RECENT NOTIFICATIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF636E72),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              if (activeAlerts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${activeAlerts.length}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...activeAlerts
            .asMap()
            .entries
            .map((entry) => _buildAlertCard(entry.value, entry.key, true))
            .toList(),
      ],
    );
  }

  Widget _buildEarlierToday() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'EARLIER TODAY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF636E72),
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._recentAlerts
            .asMap()
            .entries
            .map((entry) => _buildAlertCard(entry.value, entry.key, false))
            .toList(),
      ],
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, int index, bool isActive) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(
                  color: alert['color'].withOpacity(0.3),
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? alert['color'].withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isActive ? 15 : 10,
              offset: Offset(0, isActive ? 6 : 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              HapticFeedback.lightImpact();
              _showAlertDetails(alert);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              alert['color'],
                              alert['color'].withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          alert['icon'],
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      if (isActive)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_pulseController.value * 0.3),
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B6B),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF6B6B)
                                            .withOpacity(0.6),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                alert['title'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D3436),
                                ),
                              ),
                            ),
                            Text(
                              alert['time'],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          alert['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: alert['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                alert['actionIcon'],
                                size: 14,
                                color: alert['color'],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                alert['action'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: alert['color'],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncidentMap() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.map_rounded, color: Color(0xFF4A90E2), size: 20),
                SizedBox(width: 8),
                Text(
                  'Recent Incident Map',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 220,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F4F8),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.map_outlined,
                    size: 80,
                    color: Color(0xFFB8D4E0),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 60,
                  child: _buildMapMarker(
                    color: const Color(0xFFFF6B6B),
                    icon: Icons.local_fire_department_rounded,
                  ),
                ),
                Positioned(
                  top: 120,
                  right: 80,
                  child: _buildMapMarker(
                    color: const Color(0xFFFFA726),
                    icon: Icons.warning_rounded,
                  ),
                ),
                Positioned(
                  bottom: 70,
                  left: 100,
                  child: _buildMapMarker(
                    color: const Color(0xFFFF8C42),
                    icon: Icons.block_rounded,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_rounded,
                              color: Color(0xFFFF6B6B),
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '3 Active Emergency',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4A90E2), Color(0xFF4ECDC4)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4A90E2).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              // Open full map
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Live View',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapMarker({required Color color, required IconData icon}) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40 + (_pulseController.value * 20),
              height: 40 + (_pulseController.value * 20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2 - (_pulseController.value * 0.15)),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
          ],
        );
      },
    );
  }

  void _showAlertDetails(Map<String, dynamic> alert) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [alert['color'], alert['color'].withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(alert['icon'], color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      Text(
                        alert['time'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              alert['description'],
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to map
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: alert['color'],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}