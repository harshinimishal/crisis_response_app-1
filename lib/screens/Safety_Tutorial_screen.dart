import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class SafetyTutorialsPage extends StatefulWidget {
  const SafetyTutorialsPage({Key? key}) : super(key: key);

  @override
  State<SafetyTutorialsPage> createState() => _SafetyTutorialsPageState();
}

class _SafetyTutorialsPageState extends State<SafetyTutorialsPage>
    with TickerProviderStateMixin {
  int _selectedCategory = 0;
  String _searchQuery = '';
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _rotateController;

  final List<String> _categories = ['All', 'Emergency', 'Prevention', 'Features'];

  final Map<String, bool> _expandedSections = {};

  final List<Map<String, dynamic>> _tutorials = [
    {
      'id': 'sos_alert',
      'title': 'Emergency SOS Alert',
      'category': 'emergency',
      'icon': Icons.sos_rounded,
      'gradient': [const Color(0xFFE74C3C), const Color(0xFFC0392B)],
      'duration': '3 min',
      'difficulty': 'Easy',
      'description': 'Learn how to quickly activate emergency SOS to alert your contacts and emergency services in critical situations.',
      'steps': [
        {
          'title': 'Press Power Button',
          'description': 'Press and hold the power button for 3 seconds until you feel a strong vibration and see the SOS screen.',
          'icon': Icons.power_settings_new_rounded,
          'color': const Color(0xFFE74C3C),
          'tip': 'Works even when phone is locked',
        },
        {
          'title': 'Confirm Emergency',
          'description': 'Slide the emergency SOS slider to the right to confirm. You can also cancel within 3 seconds if activated by mistake.',
          'icon': Icons.swipe_right_rounded,
          'color': const Color(0xFFF39C12),
          'tip': 'Quick swipe activates faster',
        },
        {
          'title': 'Alert Sent',
          'description': 'Your location and emergency alert are immediately sent to all emergency contacts. A countdown timer shows on screen.',
          'icon': Icons.send_rounded,
          'color': const Color(0xFF27AE60),
          'tip': 'Audio recording starts automatically',
        },
        {
          'title': 'Stay Connected',
          'description': 'Keep your phone unlocked. Emergency services can track your location in real-time and your contacts receive live updates.',
          'icon': Icons.location_on_rounded,
          'color': const Color(0xFF3498DB),
          'tip': 'Battery saver mode activates',
        },
      ],
    },
    {
      'id': 'crash_detection',
      'title': 'Crash Detection System',
      'category': 'emergency',
      'icon': Icons.car_crash_rounded,
      'gradient': [const Color(0xFFE67E22), const Color(0xFFD35400)],
      'duration': '4 min',
      'difficulty': 'Auto',
      'description': 'Understand how the automatic crash detection works and what happens when a severe impact is detected.',
      'steps': [
        {
          'title': 'Automatic Detection',
          'description': 'Advanced sensors detect sudden impacts, harsh braking, and collision patterns using accelerometer and gyroscope data.',
          'icon': Icons.sensors_rounded,
          'color': const Color(0xFFE67E22),
          'tip': 'Works in background 24/7',
        },
        {
          'title': 'Alert Countdown',
          'description': 'After detection, a 10-second countdown begins with loud alarm. You can cancel if it\'s a false alarm.',
          'icon': Icons.timer_rounded,
          'color': const Color(0xFFF39C12),
          'tip': 'Shake phone to cancel quickly',
        },
        {
          'title': 'Emergency Response',
          'description': 'If not cancelled, emergency services are automatically contacted and your exact location is shared with crash details.',
          'icon': Icons.emergency_rounded,
          'color': const Color(0xFFE74C3C),
          'tip': 'Voice call initiated automatically',
        },
        {
          'title': 'Contact Notification',
          'description': 'All emergency contacts receive crash alert with location, severity estimate, and real-time tracking link.',
          'icon': Icons.notifications_active_rounded,
          'color': const Color(0xFF9B59B6),
          'tip': 'Includes photo evidence if enabled',
        },
      ],
    },
    {
      'id': 'safe_zones',
      'title': 'Safe Zones & Geofencing',
      'category': 'prevention',
      'icon': Icons.place_rounded,
      'gradient': [const Color(0xFF3498DB), const Color(0xFF2980B9)],
      'duration': '5 min',
      'difficulty': 'Medium',
      'description': 'Set up safe zones and get notified when contacts enter or leave designated areas for enhanced safety monitoring.',
      'steps': [
        {
          'title': 'Create Safe Zone',
          'description': 'Tap the map to set a location, then adjust the radius (50m - 5km). Name it (Home, School, Work) for easy identification.',
          'icon': Icons.add_location_rounded,
          'color': const Color(0xFF3498DB),
          'tip': 'Create multiple zones for different people',
        },
        {
          'title': 'Assign Contacts',
          'description': 'Select which contacts to monitor in each zone. Set custom notification preferences for arrivals and departures.',
          'icon': Icons.person_add_rounded,
          'color': const Color(0xFF9B59B6),
          'tip': 'Different zones for different family members',
        },
        {
          'title': 'Set Schedules',
          'description': 'Configure time-based rules. Get alerts only during specific hours or days when monitoring is most important.',
          'icon': Icons.schedule_rounded,
          'color': const Color(0xFFF39C12),
          'tip': 'School hours monitoring for kids',
        },
        {
          'title': 'Receive Alerts',
          'description': 'Get instant notifications when contacts enter or exit safe zones, with timestamp and exact location details.',
          'icon': Icons.notifications_rounded,
          'color': const Color(0xFF27AE60),
          'tip': 'Customize alert sounds per zone',
        },
      ],
    },
    {
      'id': 'live_tracking',
      'title': 'Live Location Sharing',
      'category': 'features',
      'icon': Icons.my_location_rounded,
      'gradient': [const Color(0xFF27AE60), const Color(0xFF229954)],
      'duration': '3 min',
      'difficulty': 'Easy',
      'description': 'Share your real-time location with trusted contacts for temporary or continuous monitoring during travel.',
      'steps': [
        {
          'title': 'Enable Location',
          'description': 'Grant location permissions and ensure GPS is on. For best accuracy, enable high-accuracy mode in settings.',
          'icon': Icons.gps_fixed_rounded,
          'color': const Color(0xFF27AE60),
          'tip': 'Uses minimal battery in eco mode',
        },
        {
          'title': 'Choose Duration',
          'description': 'Select sharing period: 1 hour, 8 hours, 24 hours, or continuous. Set auto-stop when you reach a destination.',
          'icon': Icons.access_time_rounded,
          'color': const Color(0xFF3498DB),
          'tip': 'Continuous mode for long trips',
        },
        {
          'title': 'Select Recipients',
          'description': 'Pick trusted contacts to share with. They receive a secure link to view your location on a map in real-time.',
          'icon': Icons.share_location_rounded,
          'color': const Color(0xFF9B59B6),
          'tip': 'Share with multiple people at once',
        },
        {
          'title': 'Monitor Journey',
          'description': 'Your contacts see your live location, speed, battery level, and route history. They can send quick messages.',
          'icon': Icons.route_rounded,
          'color': const Color(0xFFF39C12),
          'tip': 'Shows estimated arrival time',
        },
      ],
    },
    {
      'id': 'silent_alert',
      'title': 'Silent Emergency Mode',
      'category': 'emergency',
      'icon': Icons.volume_off_rounded,
      'gradient': [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
      'duration': '2 min',
      'difficulty': 'Easy',
      'description': 'Activate discreet emergency alerts when you need help but cannot safely call or make noise.',
      'steps': [
        {
          'title': 'Activate Silently',
          'description': 'Triple-press volume down button or use the app widget. Phone stays silent with no visible indication to others.',
          'icon': Icons.volume_mute_rounded,
          'color': const Color(0xFF9B59B6),
          'tip': 'Practice the button sequence',
        },
        {
          'title': 'Background Alert',
          'description': 'Alert is sent to contacts with your location. App appears normal on screen to avoid suspicion if phone is grabbed.',
          'icon': Icons.shield_rounded,
          'color': const Color(0xFF34495E),
          'tip': 'Disguises as calculator app',
        },
        {
          'title': 'Continuous Updates',
          'description': 'Location updates sent every 30 seconds. Audio recording starts in background. Contacts receive stealth mode indicator.',
          'icon': Icons.update_rounded,
          'color': const Color(0xFF3498DB),
          'tip': 'Battery optimized for long duration',
        },
      ],
    },
    {
      'id': 'check_in',
      'title': 'Safety Check-In Timer',
      'category': 'prevention',
      'icon': Icons.timer_rounded,
      'gradient': [const Color(0xFFF39C12), const Color(0xFFE67E22)],
      'duration': '3 min',
      'difficulty': 'Easy',
      'description': 'Set automatic check-in timers for risky situations. Alert contacts if you don\'t check in on time.',
      'steps': [
        {
          'title': 'Set Timer Duration',
          'description': 'Choose check-in period based on activity: 15 min for walking alone, 1-2 hours for dates, 4-8 hours for hiking.',
          'icon': Icons.alarm_rounded,
          'color': const Color(0xFFF39C12),
          'tip': 'Extends automatically if in motion',
        },
        {
          'title': 'Add Context',
          'description': 'Optionally add what you\'re doing, where you\'re going, and when you expect to be done. Include meeting details.',
          'icon': Icons.edit_note_rounded,
          'color': const Color(0xFF3498DB),
          'tip': 'Take a photo for extra security',
        },
        {
          'title': 'Check In',
          'description': 'You\'ll get a reminder notification 5 minutes before deadline. Tap to confirm you\'re safe and extend if needed.',
          'icon': Icons.check_circle_rounded,
          'color': const Color(0xFF27AE60),
          'tip': 'Voice command: "I\'m safe"',
        },
        {
          'title': 'Missed Check-In',
          'description': 'If you don\'t respond, contacts get alert with last known location, activity details, and option to trigger full emergency.',
          'icon': Icons.warning_rounded,
          'color': const Color(0xFFE74C3C),
          'tip': 'Grace period before full alert',
        },
      ],
    },
    {
      'id': 'smart_home',
      'title': 'Smart Home Integration',
      'category': 'features',
      'icon': Icons.home_rounded,
      'gradient': [const Color(0xFF16A085), const Color(0xFF138D75)],
      'duration': '6 min',
      'difficulty': 'Medium',
      'description': 'Connect smart home devices to enhance security. Automate lights, locks, and cameras during emergencies.',
      'steps': [
        {
          'title': 'Connect Devices',
          'description': 'Link compatible smart lights, locks, cameras, and alarms. Supports Google Home, Alexa, HomeKit, and major brands.',
          'icon': Icons.devices_rounded,
          'color': const Color(0xFF16A085),
          'tip': 'Start with smart lights first',
        },
        {
          'title': 'Create Scenarios',
          'description': 'Set emergency actions: flash all lights, unlock doors for first responders, start camera recording, trigger alarm.',
          'icon': Icons.settings_suggest_rounded,
          'color': const Color(0xFF3498DB),
          'tip': 'Test scenarios during daytime',
        },
        {
          'title': 'Auto-Activation',
          'description': 'When emergency triggered, devices activate automatically. Lights flash red, doors unlock, cameras record to cloud.',
          'icon': Icons.flash_on_rounded,
          'color': const Color(0xFFF39C12),
          'tip': 'Neighbors see emergency lights',
        },
        {
          'title': 'Remote Control',
          'description': 'Emergency contacts can remotely control your smart home to help: unlock doors, check cameras, or sound alarms.',
          'icon': Icons.phonelink_rounded,
          'color': const Color(0xFF9B59B6),
          'tip': 'Requires emergency PIN code',
        },
      ],
    },
    {
      'id': 'fake_call',
      'title': 'Fake Call Exit Strategy',
      'category': 'prevention',
      'icon': Icons.call_rounded,
      'gradient': [const Color(0xFF8E44AD), const Color(0xFF71368A)],
      'duration': '2 min',
      'difficulty': 'Easy',
      'description': 'Schedule a fake incoming call to give yourself an excuse to leave uncomfortable or dangerous situations.',
      'steps': [
        {
          'title': 'Set Delay',
          'description': 'Schedule fake call from 30 seconds to 30 minutes. Quick activate from home screen widget for immediate situations.',
          'icon': Icons.phone_in_talk_rounded,
          'color': const Color(0xFF8E44AD),
          'tip': 'Preset 5-minute quick button',
        },
        {
          'title': 'Customize Caller',
          'description': 'Choose realistic caller (Mom, Boss, Friend). Set ringtone and even a voice message that plays when you "answer".',
          'icon': Icons.person_rounded,
          'color': const Color(0xFF3498DB),
          'tip': 'Record custom voice messages',
        },
        {
          'title': 'Realistic Response',
          'description': 'Phone rings with full screen caller display. You can "answer" and have a fake conversation to maintain authenticity.',
          'icon': Icons.phone_callback_rounded,
          'color': const Color(0xFF27AE60),
          'tip': 'Pre-scripted conversation prompts',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Initialize all sections as collapsed
    for (var tutorial in _tutorials) {
      _expandedSections[tutorial['id']] = false;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTutorials {
    List<Map<String, dynamic>> filtered = _tutorials;

    // Filter by category
    if (_selectedCategory != 0) {
      String categoryFilter = _categories[_selectedCategory].toLowerCase();
      filtered = filtered.where((t) => t['category'] == categoryFilter).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((tutorial) {
        final title = tutorial['title'].toLowerCase();
        final description = tutorial['description'].toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();
    }

    return filtered;
  }

  void _toggleSection(String id) {
    setState(() {
      _expandedSections[id] = !_expandedSections[id]!;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 1000));
                  HapticFeedback.mediumImpact();
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  children: [
                    _buildHeroSection(),
                    const SizedBox(height: 24),
                    _buildStatsBar(),
                    const SizedBox(height: 24),
                    _buildCategoryTabs(),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    ..._filteredTutorials
                        .asMap()
                        .entries
                        .map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildTutorialCard(entry.value, entry.key),
                            ))
                        .toList(),
                    if (_filteredTutorials.isEmpty) _buildEmptyState(),
                    const SizedBox(height: 24),
                    _buildEmergencyContactsCard(),
                    const SizedBox(height: 24),
                    _buildSupportSection(),
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
      child: Row(
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
                  'Safety Tutorials',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2C3E50),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Learn to protect yourself & others',
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
                  const Color(0xFFE74C3C).withOpacity(0.1),
                  const Color(0xFFF39C12).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: const Icon(Icons.emergency_rounded, color: Color(0xFFE74C3C)),
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showQuickEmergency();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated background pattern
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: CirclePatternPainter(_rotateController.value),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, math.sin(_floatController.value * 2 * math.pi) * 8),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Master Safety Features',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Step-by-step guides to keep you prepared',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final totalTutorials = _tutorials.length;
    final emergencyCount = _tutorials.where((t) => t['category'] == 'emergency').length;
    final totalMinutes = _tutorials.fold<int>(
      0,
      (sum, t) => sum + int.parse(t['duration'].toString().split(' ')[0]),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            Icons.menu_book_rounded,
            '$totalTutorials',
            'Tutorials',
            const Color(0xFF3498DB),
          ),
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFE8ECEF),
          ),
          const SizedBox(width: 8),
          _buildStatItem(
            Icons.emergency_rounded,
            '$emergencyCount',
            'Emergency',
            const Color(0xFFE74C3C),
          ),
          const SizedBox(width: 8),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFE8ECEF),
          ),
          const SizedBox(width: 8),
          _buildStatItem(
            Icons.schedule_rounded,
            '${totalMinutes}min',
            'Total Time',
            const Color(0xFF27AE60),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF7F8C8D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              margin: EdgeInsets.only(right: index < _categories.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
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
                          color: const Color(0xFF667EEA).withOpacity(0.3),
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          hintText: 'Search tutorials...',
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTutorialCard(Map<String, dynamic> tutorial, int index) {
    final isExpanded = _expandedSections[tutorial['id']]!;

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
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8ECEF)),
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
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                onTap: () => _toggleSection(tutorial['id']),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: tutorial['gradient']),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: (tutorial['gradient'][0] as Color).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(tutorial['icon'], color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tutorial['title'],
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2C3E50),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                _buildBadge(
                                  Icons.schedule_rounded,
                                  tutorial['duration'],
                                  const Color(0xFF3498DB),
                                ),
                                const SizedBox(width: 8),
                                _buildBadge(
                                  Icons.signal_cellular_alt_rounded,
                                  tutorial['difficulty'],
                                  const Color(0xFF27AE60),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: isExpanded ? 0.5 : 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey[600],
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Column(
                      children: [
                        Container(
                          height: 1,
                          color: const Color(0xFFE8ECEF),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tutorial['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: tutorial['gradient'],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.list_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'STEP-BY-STEP GUIDE',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF7F8C8D),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (tutorial['gradient'][0] as Color)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${(tutorial['steps'] as List).length} Steps',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: tutorial['gradient'][0],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...(tutorial['steps'] as List<Map<String, dynamic>>)
                                  .asMap()
                                  .entries
                                  .map((entry) => Padding(
                                        padding: EdgeInsets.only(
                                          bottom: entry.key <
                                                  (tutorial['steps'] as List).length - 1
                                              ? 20
                                              : 0,
                                        ),
                                        child: _buildTutorialStep(
                                          step: entry.value,
                                          stepNumber: entry.key + 1,
                                          totalSteps: (tutorial['steps'] as List).length,
                                        ),
                                      ))
                                  .toList(),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: tutorial['gradient'],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (tutorial['gradient'][0] as Color)
                                          .withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      HapticFeedback.mediumImpact();
                                      _showVideoTutorial(tutorial);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.play_circle_filled_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Watch Video Tutorial',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.3,
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
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialStep({
    required Map<String, dynamic> step,
    required int stepNumber,
    required int totalSteps,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [step['color'], step['color'].withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: step['color'].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(step['icon'], color: Colors.white, size: 20),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3E50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '$stepNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (stepNumber < totalSteps)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      step['color'],
                      step['color'].withOpacity(0.2),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                step['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2C3E50),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                step['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFF39C12).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.tips_and_updates_rounded,
                      size: 14,
                      color: Color(0xFFF39C12),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Tip: ${step['tip']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE67E22),
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
              color: const Color(0xFF3498DB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Color(0xFF3498DB),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Tutorials Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
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

  Widget _buildEmergencyContactsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE74C3C).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.contact_phone_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Contacts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Quick dial in emergencies',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildEmergencyContactRow('Police', '911', Icons.local_police_rounded),
          const SizedBox(height: 12),
          _buildEmergencyContactRow('Fire Dept', '911', Icons.local_fire_department_rounded),
          const SizedBox(height: 12),
          _buildEmergencyContactRow('Ambulance', '911', Icons.medical_services_rounded),
          const SizedBox(height: 12),
          _buildEmergencyContactRow('Poison Control', '1-800-222-1222', Icons.medication_rounded),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactRow(String name, String number, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFE74C3C), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.call_rounded, color: Color(0xFFE74C3C)),
              onPressed: () {
                HapticFeedback.mediumImpact();
                // Make call
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F7FA), Color(0xFFE8ECEF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8ECEF), width: 2),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, math.sin(_floatController.value * 2 * math.pi) * 6),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Need Personalized Help?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Our safety experts are available 24/7\nto guide you through any feature',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8ECEF), width: 2),
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
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        HapticFeedback.lightImpact();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.chat_rounded,
                              color: const Color(0xFF3498DB),
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Live Chat',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.phone_in_talk_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Call Now',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showVideoTutorial(Map<String, dynamic> tutorial) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
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
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: tutorial['gradient']),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(tutorial['icon'], color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Video Tutorial',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7F8C8D),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              tutorial['title'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: tutorial['gradient']),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.play_circle_filled_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  tutorial['duration'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'What You\'ll Learn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...(tutorial['steps'] as List<Map<String, dynamic>>)
                      .asMap()
                      .entries
                      .map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: tutorial['gradient'],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value['title'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: tutorial['gradient']),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (tutorial['gradient'][0] as Color).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        // Play video
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Start Tutorial',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
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
    );
  }

  void _showQuickEmergency() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.emergency_rounded, color: Color(0xFFE74C3C)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Quick Emergency',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: const Text(
          'In a real emergency, this would activate your emergency protocol and alert your contacts immediately.',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.heavyImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Activate SOS'),
          ),
        ],
      ),
    );
  }
}

// Custom painter for animated background pattern
class CirclePatternPainter extends CustomPainter {
  final double animation;

  CirclePatternPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < 3; i++) {
      final radius = (20.0 + (i * 30)) + (animation * 20);
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        paint,
      );
    }

    // Draw small circles around
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + (animation * 2 * math.pi);
      final x = centerX + math.cos(angle) * 60;
      final y = centerY + math.sin(angle) * 60;
      canvas.drawCircle(Offset(x, y), 4, paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(CirclePatternPainter oldDelegate) => true;
}