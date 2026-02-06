import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:math' as math;

// Model Classes
class SafetyMarker {
  final String id;
  final LatLng position;
  final String type; // 'accident', 'flood', 'safe_zone', 'hospital', 'police'
  final String title;
  final String description;
  final DateTime timestamp;
  final String severity; // 'high', 'medium', 'low'

  SafetyMarker({
    required this.id,
    required this.position,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
  });
}

class EmergencyContact {
  final String name;
  final String phone;
  final String type;
  final IconData icon;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.type,
    required this.icon,
  });
}

class SafetyMapScreen extends StatefulWidget {
  const SafetyMapScreen({Key? key}) : super(key: key);

  @override
  State<SafetyMapScreen> createState() => _SafetyMapScreenState();
}

class _SafetyMapScreenState extends State<SafetyMapScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  String _selectedFilter = 'SAFE ROUTES';
  bool _isSOSPressed = false;
  late AnimationController _sosAnimationController;
  
  // Default location (Mumbai, India - adjust as needed)
  static const LatLng _defaultLocation = LatLng(19.0760, 72.8777);
  LatLng _currentLocation = _defaultLocation;
  
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Set<Circle> _circles = {};

  // Dummy Safety Data
  final List<SafetyMarker> _safetyMarkers = [
    // Accidents
    SafetyMarker(
      id: 'acc1',
      position: LatLng(19.0800, 72.8750),
      type: 'accident',
      title: 'Traffic Accident',
      description: 'Multi-vehicle collision reported. Road partially blocked.',
      timestamp: DateTime.now().subtract(Duration(minutes: 15)),
      severity: 'high',
    ),
    SafetyMarker(
      id: 'acc2',
      position: LatLng(19.0720, 72.8820),
      type: 'accident',
      title: 'Minor Accident',
      description: 'Vehicle breakdown causing traffic delay.',
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
      severity: 'medium',
    ),
    SafetyMarker(
      id: 'acc3',
      position: LatLng(19.0850, 72.8700),
      type: 'accident',
      title: 'Road Hazard',
      description: 'Debris on road, proceed with caution.',
      timestamp: DateTime.now().subtract(Duration(minutes: 30)),
      severity: 'medium',
    ),
    
    // Flood Warnings
    SafetyMarker(
      id: 'flood1',
      position: LatLng(19.0680, 72.8850),
      type: 'flood',
      title: 'Flood Warning',
      description: 'Heavy waterlogging reported. Avoid this area.',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      severity: 'high',
    ),
    SafetyMarker(
      id: 'flood2',
      position: LatLng(19.0900, 72.8650),
      type: 'flood',
      title: 'Water Accumulation',
      description: 'Minor flooding due to rain. Drive carefully.',
      timestamp: DateTime.now().subtract(Duration(minutes: 45)),
      severity: 'medium',
    ),
    
    // Safe Zones
    SafetyMarker(
      id: 'safe1',
      position: LatLng(19.0780, 72.8800),
      type: 'safe_zone',
      title: 'Safe Assembly Point',
      description: 'Designated safe zone with emergency services.',
      timestamp: DateTime.now(),
      severity: 'low',
    ),
    SafetyMarker(
      id: 'safe2',
      position: LatLng(19.0820, 72.8720),
      type: 'safe_zone',
      title: 'Community Center',
      description: 'Emergency shelter and first aid available.',
      timestamp: DateTime.now(),
      severity: 'low',
    ),
    
    // Hospitals
    SafetyMarker(
      id: 'hosp1',
      position: LatLng(19.0740, 72.8790),
      type: 'hospital',
      title: 'City General Hospital',
      description: '24/7 Emergency services available.',
      timestamp: DateTime.now(),
      severity: 'low',
    ),
    SafetyMarker(
      id: 'hosp2',
      position: LatLng(19.0880, 72.8680),
      type: 'hospital',
      title: 'Metro Medical Center',
      description: 'Trauma center with ICU facilities.',
      timestamp: DateTime.now(),
      severity: 'low',
    ),
    
    // Police Stations
    SafetyMarker(
      id: 'police1',
      position: LatLng(19.0790, 72.8760),
      type: 'police',
      title: 'Police Station',
      description: 'Local police station - 24/7 available.',
      timestamp: DateTime.now(),
      severity: 'low',
    ),
  ];

  final List<EmergencyContact> _emergencyContacts = [
    EmergencyContact(
      name: 'Police',
      phone: '100',
      type: 'police',
      icon: Icons.local_police,
    ),
    EmergencyContact(
      name: 'Ambulance',
      phone: '102',
      type: 'ambulance',
      icon: Icons.local_hospital,
    ),
    EmergencyContact(
      name: 'Fire',
      phone: '101',
      type: 'fire',
      icon: Icons.local_fire_department,
    ),
    EmergencyContact(
      name: 'Disaster',
      phone: '108',
      type: 'disaster',
      icon: Icons.warning,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _sosAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    _loadMarkers();
    _createSafeRoute();
  }

  @override
  void dispose() {
    _sosAnimationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _loadMarkers() {
    Set<Marker> markers = {};
    Set<Circle> circles = {};

    for (var safetyMarker in _safetyMarkers) {
      BitmapDescriptor icon;
      Color circleColor;

      switch (safetyMarker.type) {
        case 'accident':
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
          circleColor = Colors.red;
          // Add warning circles for accidents
          circles.add(
            Circle(
              circleId: CircleId('circle_${safetyMarker.id}'),
              center: safetyMarker.position,
              radius: 200,
              fillColor: Colors.red.withOpacity(0.2),
              strokeColor: Colors.red,
              strokeWidth: 2,
            ),
          );
          break;
        case 'flood':
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
          circleColor = Colors.orange;
          circles.add(
            Circle(
              circleId: CircleId('circle_${safetyMarker.id}'),
              center: safetyMarker.position,
              radius: 250,
              fillColor: Colors.orange.withOpacity(0.2),
              strokeColor: Colors.orange,
              strokeWidth: 2,
            ),
          );
          break;
        case 'safe_zone':
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
          circleColor = Colors.green;
          break;
        case 'hospital':
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
          circleColor = Colors.blue;
          break;
        case 'police':
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
          circleColor = Colors.indigo;
          break;
        default:
          icon = BitmapDescriptor.defaultMarker;
          circleColor = Colors.grey;
      }

      markers.add(
        Marker(
          markerId: MarkerId(safetyMarker.id),
          position: safetyMarker.position,
          icon: icon,
          infoWindow: InfoWindow(
            title: safetyMarker.title,
            snippet: safetyMarker.description,
          ),
          onTap: () => _showMarkerDetails(safetyMarker),
        ),
      );
    }

    // Add current location marker
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    setState(() {
      _markers = markers;
      _circles = circles;
    });
  }

  void _createSafeRoute() {
    // Create a sample safe route
    List<LatLng> safeRoutePoints = [
      _currentLocation,
      LatLng(19.0770, 72.8785),
      LatLng(19.0785, 72.8795),
      LatLng(19.0800, 72.8805),
      LatLng(19.0820, 72.8720),
    ];

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('safe_route'),
          points: safeRoutePoints,
          color: const Color(0xFF40C463),
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          geodesic: true,
        ),
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _recenterMap() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentLocation,
          zoom: 14.0,
        ),
      ),
    );
  }

  void _showMarkerDetails(SafetyMarker marker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMarkerDetailsSheet(marker),
    );
  }

  Widget _buildMarkerDetailsSheet(SafetyMarker marker) {
    Color headerColor;
    IconData headerIcon;

    switch (marker.type) {
      case 'accident':
        headerColor = const Color(0xFFEF4444);
        headerIcon = Icons.warning;
        break;
      case 'flood':
        headerColor = const Color(0xFFF97316);
        headerIcon = Icons.water_damage;
        break;
      case 'safe_zone':
        headerColor = const Color(0xFF10B981);
        headerIcon = Icons.shield;
        break;
      case 'hospital':
        headerColor = const Color(0xFF3B82F6);
        headerIcon = Icons.local_hospital;
        break;
      case 'police':
        headerColor = const Color(0xFF6366F1);
        headerIcon = Icons.local_police;
        break;
      default:
        headerColor = Colors.grey;
        headerIcon = Icons.place;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: headerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(headerIcon, color: headerColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      marker.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatTimestamp(marker.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getSeverityColor(marker.severity),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  marker.severity.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            marker.description,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDirections(marker.position);
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: headerColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _shareLocation(marker);
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: headerColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: headerColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF97316);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  void _showDirections(LatLng destination) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to location...'),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareLocation(SafetyMarker marker) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing location...'),
        backgroundColor: Color(0xFF3B82F6),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEmergencyContacts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Row(
              children: const [
                Icon(Icons.phone, color: Color(0xFFEF4444), size: 28),
                SizedBox(width: 12),
                Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Contacts
            ..._emergencyContacts.map((contact) => _buildContactCard(contact)),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    Color color;
    switch (contact.type) {
      case 'police':
        color = const Color(0xFF6366F1);
        break;
      case 'ambulance':
        color = const Color(0xFFEF4444);
        break;
      case 'fire':
        color = const Color(0xFFF97316);
        break;
      case 'disaster':
        color = const Color(0xFF8B5CF6);
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(contact.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  contact.phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _makeEmergencyCall(contact.phone);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _makeEmergencyCall(String phone) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.phone, color: Color(0xFFEF4444)),
            SizedBox(width: 12),
            Text('Emergency Call'),
          ],
        ),
        content: Text(
          'Calling $phone...',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _triggerSOS() {
    setState(() {
      _isSOSPressed = !_isSOSPressed;
    });

    if (_isSOSPressed) {
      _showSOSDialog();
    }
  }

  void _showSOSDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.emergency, color: Color(0xFFEF4444), size: 32),
            SizedBox(width: 12),
            Text('SOS ACTIVATED'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Emergency alert has been sent to:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('✓ Emergency Services'),
            Text('✓ Your Emergency Contacts'),
            Text('✓ Nearby Responders'),
            SizedBox(height: 16),
            Text(
              'Your location is being shared in real-time.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isSOSPressed = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Cancel Alert'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEmergencyContacts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Call Emergency'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: _polylines,
            circles: _circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            padding: const EdgeInsets.only(top: 280, bottom: 160),
          ),

          // Top Controls
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildFilterButtons(),
              ],
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  _buildZoomControls(),
                  const SizedBox(height: 16),
                  _buildRecenterButton(),
                  const SizedBox(height: 16),
                  _buildSOSButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ),
            const Text(
              'Safety Map',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    offset: Offset(1, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: _showEmergencyContacts,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.phone,
                  color: Color(0xFFEF4444),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: Color(0xFF1B9B8E),
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Search nearby locations...',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 16,
              ),
            ),
          ),
          const Icon(
            Icons.tune,
            color: Color(0xFF9CA3AF),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterButton('SAFE ROUTES', Icons.check_circle, const Color(0xFF10B981)),
          const SizedBox(width: 12),
          _buildFilterButton('ACCIDENTS', Icons.warning, const Color(0xFFEF4444)),
          const SizedBox(width: 12),
          _buildFilterButton('FLOODS', Icons.water_drop, const Color(0xFFF97316)),
          const SizedBox(width: 12),
          _buildFilterButton('HOSPITALS', Icons.local_hospital, const Color(0xFF3B82F6)),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, IconData icon, Color color) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
        _applyFilter(label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [color, color.withOpacity(0.8)])
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: color,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilter(String filter) {
    // Filter markers based on selection
    Set<Marker> filteredMarkers = {};
    Set<Circle> filteredCircles = {};
    Set<Polyline> filteredPolylines = {};

    // Always show current location
    filteredMarkers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    switch (filter) {
      case 'SAFE ROUTES':
        // Show safe route polyline
        filteredPolylines = _polylines;
        // Show safe zones
        for (var marker in _safetyMarkers) {
          if (marker.type == 'safe_zone') {
            filteredMarkers.add(
              Marker(
                markerId: MarkerId(marker.id),
                position: marker.position,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                infoWindow: InfoWindow(
                  title: marker.title,
                  snippet: marker.description,
                ),
                onTap: () => _showMarkerDetails(marker),
              ),
            );
          }
        }
        break;

      case 'ACCIDENTS':
        for (var marker in _safetyMarkers) {
          if (marker.type == 'accident') {
            filteredMarkers.add(
              Marker(
                markerId: MarkerId(marker.id),
                position: marker.position,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                infoWindow: InfoWindow(
                  title: marker.title,
                  snippet: marker.description,
                ),
                onTap: () => _showMarkerDetails(marker),
              ),
            );
            filteredCircles.add(
              Circle(
                circleId: CircleId('circle_${marker.id}'),
                center: marker.position,
                radius: 200,
                fillColor: Colors.red.withOpacity(0.2),
                strokeColor: Colors.red,
                strokeWidth: 2,
              ),
            );
          }
        }
        break;

      case 'FLOODS':
        for (var marker in _safetyMarkers) {
          if (marker.type == 'flood') {
            filteredMarkers.add(
              Marker(
                markerId: MarkerId(marker.id),
                position: marker.position,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                infoWindow: InfoWindow(
                  title: marker.title,
                  snippet: marker.description,
                ),
                onTap: () => _showMarkerDetails(marker),
              ),
            );
            filteredCircles.add(
              Circle(
                circleId: CircleId('circle_${marker.id}'),
                center: marker.position,
                radius: 250,
                fillColor: Colors.orange.withOpacity(0.2),
                strokeColor: Colors.orange,
                strokeWidth: 2,
              ),
            );
          }
        }
        break;

      case 'HOSPITALS':
        for (var marker in _safetyMarkers) {
          if (marker.type == 'hospital' || marker.type == 'police') {
            BitmapDescriptor icon = marker.type == 'hospital'
                ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
                : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
            filteredMarkers.add(
              Marker(
                markerId: MarkerId(marker.id),
                position: marker.position,
                icon: icon,
                infoWindow: InfoWindow(
                  title: marker.title,
                  snippet: marker.description,
                ),
                onTap: () => _showMarkerDetails(marker),
              ),
            );
          }
        }
        break;
    }

    setState(() {
      _markers = filteredMarkers;
      _circles = filteredCircles;
      _polylines = filteredPolylines;
    });
  }

  Widget _buildZoomControls() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF1B9B8E), size: 28),
              onPressed: () {
                _mapController?.animateCamera(CameraUpdate.zoomIn());
              },
              padding: const EdgeInsets.all(16),
            ),
            Container(
              height: 1,
              width: 40,
              color: const Color(0xFFE0E0E0),
            ),
            IconButton(
              icon: const Icon(Icons.remove, color: Color(0xFF1B9B8E), size: 28),
              onPressed: () {
                _mapController?.animateCamera(CameraUpdate.zoomOut());
              },
              padding: const EdgeInsets.all(16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecenterButton() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: _recenterMap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B9B8E), Color(0xFF16A085)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B9B8E).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.my_location,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Recenter Map',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSOSButton() {
    return AnimatedBuilder(
      animation: _sosAnimationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: _triggerSOS,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isSOSPressed
                    ? [
                        const Color(0xFFFF5252),
                        const Color(0xFFFF3333),
                      ]
                    : [
                        const Color(0xFFFF3333),
                        const Color(0xFFFF5252),
                      ],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF3333).withOpacity(
                    _isSOSPressed ? 0.6 : 0.4,
                  ),
                  blurRadius: _isSOSPressed ? 25 : 20,
                  spreadRadius: _isSOSPressed ? 3 : 2,
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSOSPressed)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 24,
                      height: 24,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  const Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isSOSPressed ? 'SOS ACTIVE' : 'EMERGENCY SOS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}