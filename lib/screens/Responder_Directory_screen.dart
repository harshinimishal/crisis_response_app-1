import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class ResponderDirectoryPage extends StatefulWidget {
  const ResponderDirectoryPage({Key? key}) : super(key: key);

  @override
  State<ResponderDirectoryPage> createState() => _ResponderDirectoryPageState();
}

class _ResponderDirectoryPageState extends State<ResponderDirectoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  int _selectedCategory = 0;
  Timer? _simulationTimer;
  int _sosCountdown = 0;
  bool _isSOSActive = false;
  final Random _random = Random();

  final List<Map<String, dynamic>> _responders = [
    // Medical
    {
      'name': 'City General Hospital',
      'distance': '0.8 mi',
      'eta': '3 min',
      'status': 'Open 24/7',
      'type': 'medical',
      'icon': Icons.local_hospital,
      'available': true,
      'phone': '+1 (555) 123-4567',
      'beds': '234 beds available',
      'rating': 4.8,
      'responseTime': '2-4 min',
    },
    {
      'name': 'Metropolitan Urgent Care',
      'distance': '2.5 mi',
      'eta': '8 min',
      'status': 'Opens at 8:00 AM',
      'type': 'medical',
      'icon': Icons.medical_services,
      'available': false,
      'phone': '+1 (555) 234-5678',
      'beds': 'Closed',
      'rating': 4.5,
      'responseTime': 'N/A',
    },
    {
      'name': 'Eastside Medical Center',
      'distance': '3.1 mi',
      'eta': '10 min',
      'status': 'Open 24/7',
      'type': 'medical',
      'icon': Icons.local_hospital,
      'available': true,
      'phone': '+1 (555) 345-6789',
      'beds': '89 beds available',
      'rating': 4.7,
      'responseTime': '5-7 min',
    },
    {
      'name': 'St. Mary\'s Emergency',
      'distance': '4.2 mi',
      'eta': '12 min',
      'status': 'Open 24/7',
      'type': 'medical',
      'icon': Icons.emergency,
      'available': true,
      'phone': '+1 (555) 456-7890',
      'beds': '156 beds available',
      'rating': 4.9,
      'responseTime': '3-5 min',
    },
    // Police
    {
      'name': 'District Police Station',
      'distance': '1.2 mi',
      'eta': '4 min',
      'status': 'Emergency Services Open',
      'type': 'police',
      'icon': Icons.local_police,
      'available': true,
      'phone': '911',
      'beds': '12 officers on duty',
      'rating': 4.6,
      'responseTime': '3-6 min',
    },
    {
      'name': 'Central Command Unit',
      'distance': '2.8 mi',
      'eta': '9 min',
      'status': 'Active Patrol',
      'type': 'police',
      'icon': Icons.shield,
      'available': true,
      'phone': '911',
      'beds': '8 units available',
      'rating': 4.7,
      'responseTime': '4-7 min',
    },
    {
      'name': 'Highway Patrol',
      'distance': '5.5 mi',
      'eta': '15 min',
      'status': 'On Highway 101',
      'type': 'police',
      'icon': Icons.local_police,
      'available': true,
      'phone': '911',
      'beds': '5 units patrolling',
      'rating': 4.5,
      'responseTime': '8-12 min',
    },
    // Fire
    {
      'name': 'Central Fire Department',
      'distance': '1.8 mi',
      'eta': '5 min',
      'status': 'Open 24/7',
      'type': 'fire',
      'icon': Icons.fire_truck,
      'available': true,
      'phone': '911',
      'beds': '3 trucks ready',
      'rating': 4.9,
      'responseTime': '2-4 min',
    },
    {
      'name': 'Eastside Fire Station',
      'distance': '3.7 mi',
      'eta': '11 min',
      'status': 'Active Response',
      'type': 'fire',
      'icon': Icons.fire_extinguisher,
      'available': true,
      'phone': '911',
      'beds': '2 trucks available',
      'rating': 4.8,
      'responseTime': '5-8 min',
    },
    {
      'name': 'Rescue Squad Alpha',
      'distance': '2.3 mi',
      'eta': '7 min',
      'status': 'Standby Mode',
      'type': 'fire',
      'icon': Icons.emergency_share,
      'available': true,
      'phone': '911',
      'beds': 'Full crew ready',
      'rating': 4.9,
      'responseTime': '3-5 min',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = _tabController.index;
      });
    });
    _startSimulation();
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          // Randomly update some responder statuses
          if (_random.nextDouble() > 0.7) {
            final index = _random.nextInt(_responders.length);
            _responders[index]['available'] = _random.nextBool();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _simulationTimer?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredResponders {
    List<Map<String, dynamic>> filtered = _responders;

    // Filter by category
    if (_selectedCategory == 1) {
      filtered = filtered.where((r) => r['type'] == 'medical').toList();
    } else if (_selectedCategory == 2) {
      filtered = filtered.where((r) => r['type'] == 'police').toList();
    } else if (_selectedCategory == 3) {
      filtered = filtered.where((r) => r['type'] == 'fire').toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((r) => r['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Sort by distance
    filtered.sort((a, b) {
      double distA = double.parse(a['distance'].replaceAll(RegExp(r'[^0-9.]'), ''));
      double distB = double.parse(b['distance'].replaceAll(RegExp(r'[^0-9.]'), ''));
      return distA.compareTo(distB);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildQuickStats(),
            _buildSearchBar(),
            _buildCategoryTabs(),
            Expanded(
              child: _buildResponderList(),
            ),
            if (_isSOSActive) _buildSOSActiveBar(),
            _buildSOSButton(),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emergency Directory',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00FF88),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Live Status',
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
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4A9EFF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF4A9EFF).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF4A9EFF),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_filteredResponders.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A9EFF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Average ETA',
              '4.2 min',
              Icons.schedule,
              const Color(0xFF4A9EFF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Available',
              '${_responders.where((r) => r['available']).length}/${_responders.length}',
              Icons.check_circle,
              const Color(0xFF00FF88),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Nearest',
              _filteredResponders.isNotEmpty ? _filteredResponders.first['distance'] : 'N/A',
              Icons.near_me,
              const Color(0xFFFF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF666666),
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search responders...',
          hintStyle: const TextStyle(color: Color(0xFF666666)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF4A9EFF), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF666666), size: 20),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
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
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF666666),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.grid_view, size: 18),
            text: 'ALL',
          ),
          Tab(
            icon: Icon(Icons.local_hospital, size: 18),
            text: 'MEDICAL',
          ),
          Tab(
            icon: Icon(Icons.local_police, size: 18),
            text: 'POLICE',
          ),
          Tab(
            icon: Icon(Icons.fire_truck, size: 18),
            text: 'FIRE',
          ),
        ],
      ),
    );
  }

  Widget _buildResponderList() {
    if (_filteredResponders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No responders found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredResponders.length,
      itemBuilder: (context, index) {
        return _buildResponderCard(_filteredResponders[index], index);
      },
    );
  }

  Widget _buildResponderCard(Map<String, dynamic> responder, int index) {
    final isAvailable = responder['available'];
    final statusColor = isAvailable ? const Color(0xFF00FF88) : const Color(0xFFFF4444);

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAvailable
                ? const Color(0xFF00FF88).withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.lightImpact();
              _showResponderDetails(responder);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _getTypeColor(responder['type']).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getTypeColor(responder['type']).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          responder['icon'],
                          color: _getTypeColor(responder['type']),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              responder['name'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${responder['distance']} • ETA ${responder['eta']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  responder['status'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFAA00).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFFFAA00).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Color(0xFFFFAA00),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  responder['rating'].toString(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFAA00),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Call',
                          Icons.phone,
                          const Color(0xFF00FF88),
                          () {
                            HapticFeedback.mediumImpact();
                            _simulateCall(responder);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          'Directions',
                          Icons.directions,
                          const Color(0xFF4A9EFF),
                          () {
                            HapticFeedback.lightImpact();
                            _simulateDirections(responder);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          'Info',
                          Icons.info_outline,
                          const Color(0xFF666666),
                          () {
                            HapticFeedback.lightImpact();
                            _showResponderDetails(responder);
                          },
                        ),
                      ),
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

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'medical':
        return const Color(0xFF00FF88);
      case 'police':
        return const Color(0xFF4A9EFF);
      case 'fire':
        return const Color(0xFFFF4444);
      default:
        return const Color(0xFF666666);
    }
  }

  Widget _buildSOSActiveBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4444),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4444).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 500),
            tween: Tween<double>(begin: 0.8, end: 1.2),
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: const Icon(
              Icons.emergency,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SOS ACTIVE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Emergency services notified',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isSOSActive = false;
              });
            },
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4444), Color(0xFFCC0000)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4444).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _isSOSActive ? null : () {
              HapticFeedback.heavyImpact();
              _showSOSDialog();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  _sosCountdown > 0
                      ? 'SENDING SOS IN $_sosCountdown...'
                      : 'SOS EMERGENCY',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFFFF4444).withOpacity(0.3),
            width: 1,
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Color(0xFFFF4444), size: 28),
            SizedBox(width: 12),
            Text(
              'Emergency SOS',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          'This will immediately notify all nearby emergency services and send your location. Use only in real emergencies.',
          style: TextStyle(fontSize: 14, color: Color(0xFF999999), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF4444), Color(0xFFCC0000)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _activateSOS();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Send SOS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _activateSOS() {
    setState(() {
      _sosCountdown = 3;
      _isSOSActive = false;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sosCountdown > 0) {
        setState(() {
          _sosCountdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isSOSActive = true;
        });
        _showSOSConfirmation();
      }
    });
  }

  void _showSOSConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFF00FF88).withOpacity(0.3),
            width: 1,
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF00FF88), size: 28),
            SizedBox(width: 12),
            Text(
              'SOS Sent',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency services have been notified:',
              style: TextStyle(color: Color(0xFF999999)),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check, color: Color(0xFF00FF88), size: 16),
                SizedBox(width: 8),
                Text('Police - ETA 4 min', style: TextStyle(color: Colors.white)),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.check, color: Color(0xFF00FF88), size: 16),
                SizedBox(width: 8),
                Text('Medical - ETA 3 min', style: TextStyle(color: Colors.white)),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.check, color: Color(0xFF00FF88), size: 16),
                SizedBox(width: 8),
                Text('Fire - ETA 5 min', style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _simulateCall(Map<String, dynamic> responder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: const Color(0xFF00FF88).withOpacity(0.3),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.phone, color: Color(0xFF00FF88), size: 24),
            const SizedBox(width: 12),
            const Text(
              'Calling...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              responder['name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              responder['phone'],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A9EFF),
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              color: Color(0xFF00FF88),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFFF4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _simulateDirections(Map<String, dynamic> responder) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.directions, color: Color(0xFF4A9EFF)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Opening directions to ${responder['name']}...',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showResponderDetails(Map<String, dynamic> responder) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _getTypeColor(responder['type']).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getTypeColor(responder['type']).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          responder['icon'],
                          color: _getTypeColor(responder['type']),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              responder['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              responder['type'].toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getTypeColor(responder['type']),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDetailRow('Distance', responder['distance'], Icons.location_on),
                  _buildDetailRow('ETA', responder['eta'], Icons.schedule),
                  _buildDetailRow('Status', responder['status'], Icons.info_outline),
                  _buildDetailRow('Phone', responder['phone'], Icons.phone),
                  _buildDetailRow('Capacity', responder['beds'], Icons.airline_seat_flat),
                  _buildDetailRow('Response Time', responder['responseTime'], Icons.timer),
                  _buildDetailRow('Rating', '${responder['rating']} / 5.0', Icons.star),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLargeActionButton(
                          'Call Now',
                          Icons.phone,
                          const Color(0xFF00FF88),
                          () {
                            Navigator.pop(context);
                            _simulateCall(responder);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLargeActionButton(
                          'Directions',
                          Icons.directions,
                          const Color(0xFF4A9EFF),
                          () {
                            Navigator.pop(context);
                            _simulateDirections(responder);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF4A9EFF),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}