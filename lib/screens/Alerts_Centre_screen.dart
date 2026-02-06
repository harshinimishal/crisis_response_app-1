import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class AlertsCenterPage extends StatefulWidget {
  const AlertsCenterPage({Key? key}) : super(key: key);

  @override
  State<AlertsCenterPage> createState() => _AlertsCenterPageState();
}

class _AlertsCenterPageState extends State<AlertsCenterPage>
    with TickerProviderStateMixin {
  int _selectedCategory = 0;
  String _searchQuery = '';
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  bool _showFilters = false;
  String _sortBy = 'recent'; // recent, priority, distance

  final List<String> _categories = ['All', 'Emergency', 'Community', 'Weather', 'Traffic'];

  final List<Map<String, dynamic>> _alerts = [
    {
      'id': 1,
      'title': 'Wildfire Warning: Northern Hills',
      'time': DateTime.now().subtract(const Duration(minutes: 2)),
      'description':
          'Immediate evacuation ordered for zone A-12. Public shelters are open at Lincoln High School and Community Center. Winds are shifting north-northeast at 25mph. Updates every 30 minutes.',
      'type': 'emergency',
      'severity': 'critical',
      'icon': Icons.local_fire_department_rounded,
      'color': const Color(0xFFE74C3C),
      'action': 'Evacuation Order',
      'actionIcon': Icons.directions_run_rounded,
      'active': true,
      'distance': '2.3 mi',
      'affectedAreas': ['Zone A-12', 'Zone B-7', 'Hillside District'],
      'updates': 3,
      'source': 'Fire Department',
    },
    {
      'id': 2,
      'title': 'Hazardous Gas Leak: Downtown',
      'time': DateTime.now().subtract(const Duration(minutes: 15)),
      'description':
          'Major gas leak reported at 5th Avenue and Oak Street intersection. Emergency crews on site. Road closures: 5th Ave (3rd-7th St), Oak St (4th-6th Ave). Avoid area. Expected clearance in 2-3 hours.',
      'type': 'emergency',
      'severity': 'high',
      'icon': Icons.warning_amber_rounded,
      'color': const Color(0xFFF39C12),
      'action': 'Area Restricted',
      'actionIcon': Icons.do_not_disturb_on_rounded,
      'active': true,
      'distance': '0.8 mi',
      'affectedAreas': ['Downtown Core', '5th Avenue District'],
      'updates': 5,
      'source': 'Utility Services',
    },
    {
      'id': 3,
      'title': 'Flash Flood Watch Issued',
      'time': DateTime.now().subtract(const Duration(hours: 1)),
      'description':
          'National Weather Service issued flash flood watch effective until 11:00 PM tonight. Heavy rainfall expected 2-4 inches. Low-lying areas at risk. Avoid creek crossings and move to higher ground if needed.',
      'type': 'weather',
      'severity': 'moderate',
      'icon': Icons.water_drop_rounded,
      'color': const Color(0xFF3498DB),
      'action': 'Weather Alert',
      'actionIcon': Icons.cloud_rounded,
      'active': true,
      'distance': 'Region-wide',
      'affectedAreas': ['Riverside', 'Creek Valley', 'Lowlands'],
      'updates': 2,
      'source': 'Weather Service',
    },
    {
      'id': 4,
      'title': 'Major Traffic Incident: I-95 North',
      'time': DateTime.now().subtract(const Duration(minutes: 45)),
      'description':
          'Multi-vehicle collision blocking 3 lanes on I-95 North near Exit 42. Delays up to 60 minutes. Use alternate routes: Route 1 or Highway 301. Emergency services on scene.',
      'type': 'traffic',
      'severity': 'moderate',
      'icon': Icons.traffic_rounded,
      'color': const Color(0xFFE67E22),
      'action': 'Traffic Update',
      'actionIcon': Icons.directions_car_rounded,
      'active': false,
      'distance': '5.1 mi',
      'affectedAreas': ['I-95 North', 'Exit 42 Area'],
      'updates': 4,
      'source': 'Traffic Control',
    },
    {
      'id': 5,
      'title': 'Community: Missing Person Alert',
      'time': DateTime.now().subtract(const Duration(hours: 3)),
      'description':
          'Silver Alert issued for elderly person last seen near Central Park at 2:00 PM. White male, 75 years old, wearing blue jacket. Contact police immediately if seen: (555) 123-4567.',
      'type': 'community',
      'severity': 'high',
      'icon': Icons.person_search_rounded,
      'color': const Color(0xFF9B59B6),
      'action': 'Community Alert',
      'actionIcon': Icons.groups_rounded,
      'active': false,
      'distance': '1.2 mi',
      'affectedAreas': ['Central Park', 'Downtown'],
      'updates': 2,
      'source': 'Police Department',
    },
    {
      'id': 6,
      'title': 'Power Outage: Westside Area',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'description':
          'Approximately 1,200 customers without power in Westside district due to equipment failure. Crews working to restore service. Estimated restoration: 6:00 PM today. Stay away from downed power lines.',
      'type': 'emergency',
      'severity': 'moderate',
      'icon': Icons.power_off_rounded,
      'color': const Color(0xFFF39C12),
      'action': 'Utility Alert',
      'actionIcon': Icons.bolt_rounded,
      'active': false,
      'distance': '3.7 mi',
      'affectedAreas': ['Westside', 'Maple Street', 'Oak Avenue'],
      'updates': 3,
      'source': 'Power Company',
    },
    {
      'id': 7,
      'title': 'Air Quality Advisory',
      'time': DateTime.now().subtract(const Duration(hours: 4)),
      'description':
          'Poor air quality expected today due to wildfire smoke. AQI levels 150-175. Sensitive groups should limit outdoor activities. Keep windows closed. Use air filters if available.',
      'type': 'weather',
      'severity': 'moderate',
      'icon': Icons.air_rounded,
      'color': const Color(0xFF95A5A6),
      'action': 'Health Advisory',
      'actionIcon': Icons.masks_rounded,
      'active': false,
      'distance': 'Region-wide',
      'affectedAreas': ['Entire City'],
      'updates': 1,
      'source': 'Environmental Agency',
    },
    {
      'id': 8,
      'title': 'Emergency System Test Complete',
      'time': DateTime.now().subtract(const Duration(hours: 6)),
      'description':
          'Monthly test of emergency warning sirens completed successfully at 12:00 PM. All 47 sirens operational. Next test scheduled for first Wednesday of next month.',
      'type': 'community',
      'severity': 'low',
      'icon': Icons.check_circle_rounded,
      'color': const Color(0xFF27AE60),
      'action': 'System Status',
      'actionIcon': Icons.shield_rounded,
      'active': false,
      'distance': 'City-wide',
      'affectedAreas': ['All Districts'],
      'updates': 0,
      'source': 'Emergency Services',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAlerts {
    List<Map<String, dynamic>> filtered = _alerts;

    // Filter by category
    if (_selectedCategory != 0) {
      String categoryFilter = _categories[_selectedCategory].toLowerCase();
      filtered = filtered.where((alert) => alert['type'] == categoryFilter).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((alert) {
        final title = alert['title'].toLowerCase();
        final description = alert['description'].toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();
    }

    // Sort
    if (_sortBy == 'recent') {
      filtered.sort((a, b) => b['time'].compareTo(a['time']));
    } else if (_sortBy == 'priority') {
      final severityOrder = {'critical': 0, 'high': 1, 'moderate': 2, 'low': 3};
      filtered.sort((a, b) {
        final severityA = severityOrder[a['severity']] ?? 999;
        final severityB = severityOrder[b['severity']] ?? 999;
        return severityA.compareTo(severityB);
      });
    }

    return filtered;
  }

  List<Map<String, dynamic>> get _activeAlerts {
    return _filteredAlerts.where((alert) => alert['active'] == true).toList();
  }

  List<Map<String, dynamic>> get _recentAlerts {
    return _filteredAlerts.where((alert) => alert['active'] != true).toList();
  }

  String _getTimeAgo(DateTime time) {
    final duration = DateTime.now().difference(time);
    if (duration.inMinutes < 1) return 'Just now';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
    if (duration.inHours < 24) return '${duration.inHours}h ago';
    return '${duration.inDays}d ago';
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return const Color(0xFFE74C3C);
      case 'high':
        return const Color(0xFFF39C12);
      case 'moderate':
        return const Color(0xFF3498DB);
      default:
        return const Color(0xFF27AE60);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsBar(),
            _buildCategoryTabs(),
            _buildSearchAndFilter(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 1200));
                  HapticFeedback.mediumImpact();
                  setState(() {});
                },
                color: const Color(0xFF3498DB),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  children: [
                    const SizedBox(height: 16),
                    if (_activeAlerts.isNotEmpty) ...[
                      _buildSectionHeader(
                        'ACTIVE EMERGENCIES',
                        _activeAlerts.length,
                        Icons.warning_amber_rounded,
                        const Color(0xFFE74C3C),
                      ),
                      const SizedBox(height: 12),
                      ..._activeAlerts
                          .asMap()
                          .entries
                          .map((entry) => _buildAlertCard(entry.value, entry.key, true))
                          .toList(),
                      const SizedBox(height: 24),
                    ],
                    if (_recentAlerts.isNotEmpty) ...[
                      _buildSectionHeader(
                        'RECENT UPDATES',
                        _recentAlerts.length,
                        Icons.history_rounded,
                        const Color(0xFF7F8C8D),
                      ),
                      const SizedBox(height: 12),
                      ..._recentAlerts
                          .asMap()
                          .entries
                          .map((entry) => _buildAlertCard(entry.value, entry.key, false))
                          .toList(),
                    ],
                    if (_filteredAlerts.isEmpty) _buildEmptyState(),
                    const SizedBox(height: 24),
                    _buildIncidentMap(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 32),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFAFBFC)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8ECEF)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, 
                    color: Color(0xFF2C3E50), size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Center',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2C3E50),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Real-time alerts & updates',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7F8C8D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3498DB).withOpacity(0.1),
                      const Color(0xFF2ECC71).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded,
                      color: Color(0xFF3498DB)),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // Settings
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3498DB).withOpacity(0.1),
                      const Color(0xFF9B59B6).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  icon: const Icon(Icons.settings_outlined,
                      color: Color(0xFF9B59B6)),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showSettingsSheet();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final activeCount = _alerts.where((a) => a['active'] == true).length;
    final criticalCount = _alerts.where((a) => a['severity'] == 'critical').length;
    final totalUpdates = _alerts.fold<int>(0, (sum, a) => sum + (a['updates'] as int));

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            Icons.error_rounded,
            '$activeCount',
            'Active',
            Colors.white,
          ),
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(width: 8),
          _buildStatItem(
            Icons.local_fire_department_rounded,
            '$criticalCount',
            'Critical',
            Colors.white,
          ),
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(width: 8),
          _buildStatItem(
            Icons.update_rounded,
            '$totalUpdates',
            'Updates',
            Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = index);
              HapticFeedback.selectionClick();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.only(right: index < _categories.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF3498DB), Color(0xFF2ECC71)],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xFFE8ECEF),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3498DB).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF7F8C8D),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8ECEF)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search alerts...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFBDC3C7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF7F8C8D), size: 22),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              color: Color(0xFF7F8C8D), size: 20),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showFilterSheet();
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7F8C8D),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, int index, bool isActive) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 80)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isActive
              ? Border.all(
                  color: _getSeverityColor(alert['severity']).withOpacity(0.4),
                  width: 2,
                )
              : Border.all(color: const Color(0xFFE8ECEF), width: 1),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? _getSeverityColor(alert['severity']).withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isActive ? 20 : 12,
              offset: Offset(0, isActive ? 8 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              HapticFeedback.lightImpact();
              _showAlertDetails(alert);
            },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  alert['color'],
                                  alert['color'].withOpacity(0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: alert['color'].withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(alert['icon'], color: Colors.white, size: 28),
                          ),
                          if (isActive)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE74C3C),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFE74C3C)
                                              .withOpacity(0.6 * _pulseController.value),
                                          blurRadius: 12 * _pulseController.value,
                                          spreadRadius: 4 * _pulseController.value,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getSeverityColor(alert['severity'])
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    alert['severity'].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: _getSeverityColor(alert['severity']),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getTimeAgo(alert['time']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              alert['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2C3E50),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    alert['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: alert['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                alert['actionIcon'],
                                size: 16,
                                color: alert['color'],
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  alert['action'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: alert['color'],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: Color(0xFF7F8C8D),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              alert['distance'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7F8C8D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (alert['updates'] > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3498DB).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Badge(
                            label: Text('${alert['updates']}'),
                            backgroundColor: const Color(0xFF3498DB),
                            child: const Icon(
                              Icons.update_rounded,
                              size: 16,
                              color: Color(0xFF3498DB),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8ECEF)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 64,
              color: Color(0xFF27AE60),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'All Clear!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No alerts matching your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentMap() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8ECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3498DB), Color(0xFF2ECC71)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.map_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Incident Map',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Text(
                        'Real-time emergency tracking',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7F8C8D),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE74C3C),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE74C3C),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE8F4F8), Color(0xFFD4E9F3)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Stack(
              children: [
                // Animated background pattern
                AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: CustomPaint(
                        painter: MapGridPainter(_rotateController.value),
                      ),
                    );
                  },
                ),
                const Center(
                  child: Icon(
                    Icons.public_rounded,
                    size: 120,
                    color: Color(0xFFB8D4E0),
                  ),
                ),
                // Active markers
                Positioned(
                  top: 60,
                  left: 70,
                  child: _buildMapMarker(
                    color: const Color(0xFFE74C3C),
                    icon: Icons.local_fire_department_rounded,
                    label: 'Wildfire',
                  ),
                ),
                Positioned(
                  top: 140,
                  right: 90,
                  child: _buildMapMarker(
                    color: const Color(0xFFF39C12),
                    icon: Icons.warning_amber_rounded,
                    label: 'Gas Leak',
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: 110,
                  child: _buildMapMarker(
                    color: const Color(0xFF3498DB),
                    icon: Icons.water_drop_rounded,
                    label: 'Flood',
                  ),
                ),
                // Bottom control panel
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE74C3C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.error_rounded,
                            color: Color(0xFFE74C3C),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '3 Active Incidents',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              Text(
                                'Updated 2 min ago',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF7F8C8D),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                // Open full map
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.open_in_full_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Full View',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapMarker({
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 48 + (_pulseController.value * 16),
                  height: 48 + (_pulseController.value * 16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2 - (_pulseController.value * 0.15)),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.report_problem_rounded,
        'title': 'Report Issue',
        'color': const Color(0xFFE74C3C),
      },
      {
        'icon': Icons.medical_services_rounded,
        'title': 'Emergency',
        'color': const Color(0xFFE74C3C),
      },
      {
        'icon': Icons.notifications_active_rounded,
        'title': 'Subscribe',
        'color': const Color(0xFF3498DB),
      },
      {
        'icon': Icons.share_rounded,
        'title': 'Share',
        'color': const Color(0xFF9B59B6),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'QUICK ACTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7F8C8D),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return Container(
                width: 100,
                margin: EdgeInsets.only(right: index < actions.length - 1 ? 12 : 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8ECEF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      HapticFeedback.lightImpact();
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (action['color'] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            action['icon'] as IconData,
                            color: action['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          action['title'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C3E50),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAlertDetails(Map<String, dynamic> alert) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                alert['color'],
                                alert['color'].withOpacity(0.7)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: alert['color'].withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(alert['icon'], color: Colors.white, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _getSeverityColor(alert['severity'])
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  alert['severity'].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: _getSeverityColor(alert['severity']),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                alert['title'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2C3E50),
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getTimeAgo(alert['time']),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.source_rounded,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      alert['source'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Description
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        alert['description'],
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Affected Areas
                    const Text(
                      'AFFECTED AREAS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7F8C8D),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (alert['affectedAreas'] as List<String>)
                          .map((area) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: alert['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: alert['color'].withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: alert['color'],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      area,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: alert['color'],
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                            },
                            icon: const Icon(Icons.bookmark_border_rounded),
                            label: const Text('Save'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFFE8ECEF), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [alert['color'], alert['color'].withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: alert['color'].withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.map_rounded),
                              label: const Text('View on Map'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
            const Text(
              'Sort & Filter',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'SORT BY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7F8C8D),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            ...['recent', 'priority', 'distance'].map((sort) {
              final titles = {
                'recent': 'Most Recent',
                'priority': 'Priority Level',
                'distance': 'Distance',
              };
              final icons = {
                'recent': Icons.schedule_rounded,
                'priority': Icons.priority_high_rounded,
                'distance': Icons.near_me_rounded,
              };
              return RadioListTile<String>(
                value: sort,
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.pop(context);
                  HapticFeedback.selectionClick();
                },
                title: Row(
                  children: [
                    Icon(icons[sort], size: 20, color: const Color(0xFF3498DB)),
                    const SizedBox(width: 12),
                    Text(
                      titles[sort]!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
                activeColor: const Color(0xFF3498DB),
              );
            }),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
            const Text(
              'Alert Settings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 20),
            _buildSettingItem(
              Icons.notifications_active_rounded,
              'Push Notifications',
              'Receive instant alerts',
              true,
            ),
            _buildSettingItem(
              Icons.volume_up_rounded,
              'Alert Sounds',
              'Emergency sound notifications',
              true,
            ),
            _buildSettingItem(
              Icons.location_on_rounded,
              'Location Services',
              'Distance-based filtering',
              true,
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF3498DB), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {
              HapticFeedback.lightImpact();
            },
            activeColor: const Color(0xFF3498DB),
          ),
        ],
      ),
    );
  }
}

// Custom painter for animated map grid
class MapGridPainter extends CustomPainter {
  final double animation;

  MapGridPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8D4E0).withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSpacing = 40.0;
    final offset = animation * gridSpacing;

    // Draw vertical lines
    for (double i = -gridSpacing; i < size.width + gridSpacing; i += gridSpacing) {
      canvas.drawLine(
        Offset(i + offset, 0),
        Offset(i + offset, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double i = -gridSpacing; i < size.height + gridSpacing; i += gridSpacing) {
      canvas.drawLine(
        Offset(0, i + offset),
        Offset(size.width, i + offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(MapGridPainter oldDelegate) => true;
}