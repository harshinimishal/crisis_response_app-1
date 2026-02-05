import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  final List<Map<String, dynamic>> _responders = [
    {
      'name': 'City General Hospital',
      'distance': '0.8 miles away',
      'status': 'Open 24/7',
      'type': 'medical',
      'icon': Icons.local_hospital,
      'color': const Color(0xFF4ECDC4),
      'available': true,
    },
    {
      'name': 'District Police Station',
      'distance': '1.2 miles away',
      'status': 'Emergency Services Open',
      'type': 'police',
      'icon': Icons.local_police,
      'color': const Color(0xFF4A90E2),
      'available': true,
    },
    {
      'name': 'Metropolitan Urgent Care',
      'distance': '2.5 miles away',
      'status': 'Opens at 8:00 AM',
      'type': 'medical',
      'icon': Icons.medical_services,
      'color': const Color(0xFFFF6B6B),
      'available': false,
    },
    {
      'name': 'Central Fire Department',
      'distance': '1.8 miles away',
      'status': 'Open 24/7',
      'type': 'fire',
      'icon': Icons.fire_truck,
      'color': const Color(0xFFFF8C42),
      'available': true,
    },
    {
      'name': 'Eastside Medical Center',
      'distance': '3.1 miles away',
      'status': 'Open 24/7',
      'type': 'medical',
      'icon': Icons.local_hospital,
      'color': const Color(0xFF4ECDC4),
      'available': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredResponders {
    List<Map<String, dynamic>> filtered = _responders;

    // Filter by category
    if (_selectedCategory == 0) {
      filtered = filtered.where((r) => r['type'] == 'medical').toList();
    } else if (_selectedCategory == 1) {
      filtered = filtered.where((r) => r['type'] == 'police').toList();
    } else if (_selectedCategory == 2) {
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

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildMap(),
            _buildSearchBar(),
            _buildCategoryTabs(),
            Expanded(
              child: _buildResponderList(),
            ),
            _buildSOSButton(),
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
          const Text(
            'Responder Directory',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Placeholder for map - replace with actual map widget
            Container(
              color: const Color(0xFFE8F4F8),
              child: const Center(
                child: Icon(
                  Icons.map,
                  size: 80,
                  color: Color(0xFF4A90E2),
                ),
              ),
            ),
            // Location marker
            Positioned(
              top: 80,
              left: MediaQuery.of(context).size.width / 2 - 40,
              child: const Icon(
                Icons.location_on,
                size: 50,
                color: Color(0xFFFF6B6B),
              ),
            ),
          ],
        ),
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
          hintText: 'Search responders...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF4A90E2)),
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

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF4ECDC4)],
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF636E72),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: [
          _buildTab('MEDICAL', Icons.local_hospital),
          _buildTab('POLICE', Icons.local_police),
          _buildTab('FIRE', Icons.fire_truck),
        ],
      ),
    );
  }

  Widget _buildTab(String label, IconData icon) {
    return Tab(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponderList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredResponders.length,
      itemBuilder: (context, index) {
        return _buildResponderCard(_filteredResponders[index], index);
      },
    );
  }

  Widget _buildResponderCard(Map<String, dynamic> responder, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: responder['color'].withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              HapticFeedback.lightImpact();
              // Handle tap
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          responder['color'],
                          responder['color'].withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      responder['icon'],
                      color: Colors.white,
                      size: 30,
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          responder['distance'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: responder['available']
                                    ? const Color(0xFF00D9A5)
                                    : const Color(0xFFFF6B6B),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              responder['status'],
                              style: TextStyle(
                                fontSize: 12,
                                color: responder['available']
                                    ? const Color(0xFF00D9A5)
                                    : const Color(0xFFFF6B6B),
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
                        width: 100,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4ECDC4),
                              const Color(0xFF4ECDC4).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              // Handle call
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone, color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'Call',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.directions, size: 20),
                          color: const Color(0xFF4A90E2),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            // Handle directions
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

  Widget _buildSOSButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B6B).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              HapticFeedback.heavyImpact();
              // Handle SOS
              _showSOSDialog();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_rounded, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'SOS EMERGENCY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Color(0xFFFF6B6B), size: 28),
            SizedBox(width: 12),
            Text('Emergency SOS'),
          ],
        ),
        content: const Text(
          'Are you sure you want to send an emergency SOS alert? This will notify all nearby emergency services.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle SOS confirmation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }
}