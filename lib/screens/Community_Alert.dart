import 'package:flutter/material.dart';
import 'dart:math' as math;


class CommunityAlertsScreen extends StatefulWidget {
  const CommunityAlertsScreen({Key? key}) : super(key: key);

  @override
  State<CommunityAlertsScreen> createState() => _CommunityAlertsScreenState();
}

class _CommunityAlertsScreenState extends State<CommunityAlertsScreen>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  int _selectedNavIndex = 0;
  late AnimationController _fabController;

  final List<String> _tabs = ['All Alerts', 'Urgent', 'Near Me'];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    const Color(0xFFE8F5F3).withOpacity(0.5),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  children: [
                    // Title Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1B9B8E),
                                Color(0xFF16A085),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1B9B8E).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.campaign,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Community Alerts',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5F3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: Color(0xFF1B9B8E),
                            size: 22,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Enhanced Tab Pills
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: List.generate(_tabs.length, (index) {
                          final isSelected = _selectedTab == index;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTab = index;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF1B9B8E),
                                            Color(0xFF16A085),
                                          ],
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF1B9B8E)
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  _tabs[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Critical Alert - Flooded Road
                  _buildAlertCard(
                    severity: 'CRITICAL',
                    severityColor: const Color(0xFFEF4444),
                    title: 'Flooded Road',
                    description: 'Water level is dangerously high. Avoid the area.',
                    timeAgo: 'Reported 2 mins ago',
                    distance: '0.5 mi',
                    likes: 42,
                    comments: 8,
                    imageUrl: 'assets/flood.jpg',
                    hasImage: true,
                    verified: false,
                  ),

                  const SizedBox(height: 16),

                  // Caution Alert - Large Pothole
                  _buildAlertCard(
                    severity: 'CAUTION',
                    severityColor: const Color(0xFFF59E0B),
                    title: 'Large Pothole',
                    description: 'Right lane obstructed by deep pothole.',
                    timeAgo: 'Reported 15 mins ago',
                    distance: '1.2 mi',
                    likes: 18,
                    comments: 3,
                    imageUrl: 'assets/pothole.jpg',
                    hasImage: true,
                    verified: false,
                  ),

                  const SizedBox(height: 16),

                  // Critical Alert - Downed Power Line
                  _buildAlertCard(
                    severity: 'CRITICAL',
                    severityColor: const Color(0xFFEF4444),
                    title: 'Downed Power Line',
                    description: 'Live wires on 5th Ave. Fire dept notified.',
                    timeAgo: '3.0 miles away',
                    distance: '3.0 mi',
                    likes: 0,
                    comments: 0,
                    hasImage: false,
                    verified: true,
                    verifiedBy: '112 others',
                    icon: Icons.electric_bolt,
                  ),

                  const SizedBox(height: 16),

                  // Info Alert - Road Construction
                  _buildAlertCard(
                    severity: 'INFO',
                    severityColor: const Color(0xFF3B82F6),
                    title: 'Road Construction',
                    description: 'Main St closed until 6 PM. Use detour.',
                    timeAgo: 'Reported 1 hour ago',
                    distance: '2.8 mi',
                    likes: 25,
                    comments: 5,
                    hasImage: false,
                    verified: true,
                    verifiedBy: '45 others',
                    icon: Icons.construction,
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),

      // Enhanced FAB
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF06D6A0),
              Color(0xFF1B9B8E),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B9B8E).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            _showReportDialog(context);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),

      // Enhanced Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.campaign, 'Alerts', 0),
                _buildNavItem(Icons.map_outlined, 'Map', 1),
                const SizedBox(width: 40), // Space for FAB
                _buildNavItem(Icons.notifications_outlined, 'Notify', 2),
                _buildNavItem(Icons.person_outline, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAlertCard({
    required String severity,
    required Color severityColor,
    required String title,
    required String description,
    required String timeAgo,
    required String distance,
    required int likes,
    required int comments,
    String? imageUrl,
    bool hasImage = false,
    bool verified = false,
    String? verifiedBy,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: severityColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: severityColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image if available
          if (hasImage)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      severityColor.withOpacity(0.2),
                      severityColor.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.image,
                        size: 60,
                        color: severityColor.withOpacity(0.3),
                      ),
                    ),
                    // Distance Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Color(0xFF1B9B8E),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distance,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B9B8E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Severity Badge and Icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        severity,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: severityColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (!hasImage)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: severityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon ?? Icons.warning,
                          color: severityColor,
                          size: 24,
                        ),
                      ),
                    if (!hasImage)
                      const SizedBox(width: 8),
                    if (!hasImage)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5F3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Color(0xFF1B9B8E),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              distance,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B9B8E),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 8),

                // Time Ago
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),

                // Verified Badge
                if (verified && verifiedBy != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Verified by $verifiedBy',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Actions Row
                Row(
                  children: [
                    // Like Button
                    _buildActionButton(
                      icon: Icons.thumb_up_outlined,
                      label: likes > 0 ? likes.toString() : '',
                      color: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 12),
                    // Comment Button
                    _buildActionButton(
                      icon: Icons.chat_bubble_outline,
                      label: comments > 0 ? comments.toString() : '',
                      color: const Color(0xFF8B5CF6),
                    ),
                    const Spacer(),
                    // Verify Button
                    if (!verified)
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B9B8E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.bookmark_border, size: 18),
                        label: const Text(
                          'I Saw It!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedNavIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF1B9B8E) : const Color(0xFF9CA3AF),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? const Color(0xFF1B9B8E) : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Report New Alert',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            _buildReportOption(
              icon: Icons.warning,
              title: 'Road Hazard',
              color: const Color(0xFFF59E0B),
            ),
            const SizedBox(height: 12),
            _buildReportOption(
              icon: Icons.emergency,
              title: 'Emergency',
              color: const Color(0xFFEF4444),
            ),
            const SizedBox(height: 12),
            _buildReportOption(
              icon: Icons.info,
              title: 'General Info',
              color: const Color(0xFF3B82F6),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOption({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}