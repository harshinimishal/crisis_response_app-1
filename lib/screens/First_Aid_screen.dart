import 'package:flutter/material.dart';
import 'dart:math' as math;



class FirstAidGuideScreen extends StatefulWidget {
  const FirstAidGuideScreen({Key? key}) : super(key: key);

  @override
  State<FirstAidGuideScreen> createState() => _FirstAidGuideScreenState();
}

class _FirstAidGuideScreenState extends State<FirstAidGuideScreen>
    with TickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fabController;
  bool _isFabExpanded = false;

  final List<String> _categories = [
    'All Guides',
    'Life Threatening',
    'Minor Injury',
  ];

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
    _searchController.dispose();
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                            Icons.medical_services,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'First Aid Guide',
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
                            Icons.info_outline,
                            color: Color(0xFF1B9B8E),
                            size: 22,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Enhanced Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1B9B8E).withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for an injury or symptom...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF1B9B8E),
                            size: 22,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Category Pills
                    SizedBox(
                      height: 42,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedCategoryIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryIndex = index;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? const LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFF1B9B8E),
                                                Color(0xFF16A085),
                                              ],
                                            )
                                          : null,
                                      color: isSelected
                                          ? null
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : const Color(0xFFE0E0E0),
                                        width: 1.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF1B9B8E)
                                                    .withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      _categories[index],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // CRITICAL RESPONSE Section
                  _buildSectionHeader(
                    'CRITICAL RESPONSE',
                    Icons.emergency,
                    const Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCriticalCard(
                          icon: Icons.favorite,
                          iconColor: const Color(0xFFEF4444),
                          iconBgColor: const Color(0xFFFFE5E5),
                          title: 'CPR',
                          subtitle: 'Chest compressions\nand rescue breaths',
                          isOffline: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCriticalCard(
                          icon: Icons.air,
                          iconColor: const Color(0xFFF59E0B),
                          iconBgColor: const Color(0xFFFEF3C7),
                          title: 'Choking',
                          subtitle: 'Abdominal thrusts\n(Heimlich)',
                          isOffline: true,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // URGENT CARE Section
                  _buildSectionHeader(
                    'URGENT CARE',
                    Icons.local_hospital,
                    const Color(0xFF1B9B8E),
                  ),
                  const SizedBox(height: 16),

                  _buildUrgentCareCard(
                    icon: Icons.bloodtype,
                    iconColor: const Color(0xFFEF4444),
                    iconBgColor: const Color(0xFFFFE5E5),
                    title: 'Severe Bleeding',
                    subtitle: 'Tourniquet and pressure application',
                    size: '1.2MB',
                    isDownloaded: true,
                  ),

                  const SizedBox(height: 12),

                  _buildUrgentCareCard(
                    icon: Icons.local_fire_department,
                    iconColor: const Color(0xFFF97316),
                    iconBgColor: const Color(0xFFFFEDD5),
                    title: 'Burns',
                    subtitle: 'Thermal, chemical, and electrical',
                    size: '0.8MB',
                    isDownloaded: false,
                  ),

                  const SizedBox(height: 12),

                  _buildUrgentCareCard(
                    icon: Icons.science_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    iconBgColor: const Color(0xFFEDE9FE),
                    title: 'Poisoning',
                    subtitle: 'Ingestion and chemical exposure',
                    size: '0.6MB',
                    isDownloaded: false,
                  ),

                  const SizedBox(height: 32),

                  // Library Version Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_done,
                          color: Color(0xFF1B9B8E),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'LIBRARY VERSION 2.4',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5F3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '42MB SAVED',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B9B8E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),

      // Enhanced FAB with menu
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isFabExpanded) ...[
            _buildFabOption(
              icon: Icons.call,
              label: 'Emergency Call',
              color: const Color(0xFFEF4444),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildFabOption(
              icon: Icons.download,
              label: 'Download All',
              color: const Color(0xFF1B9B8E),
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildFabOption(
              icon: Icons.share,
              label: 'Share Guide',
              color: const Color(0xFF3B82F6),
              onTap: () {},
            ),
            const SizedBox(height: 16),
          ],
          Container(
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
                setState(() {
                  _isFabExpanded = !_isFabExpanded;
                  if (_isFabExpanded) {
                    _fabController.forward();
                  } else {
                    _fabController.reverse();
                  }
                });
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: AnimatedRotation(
                turns: _isFabExpanded ? 0.125 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Bottom Navigation
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
                _buildNavItem(Icons.library_books, 'Library', true),
                _buildNavItem(Icons.local_hospital, 'Hospitals', false),
                _buildNavItem(Icons.person_outline, 'Profile', false),
                _buildNavItem(Icons.settings_outlined, 'Settings', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCriticalCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool isOffline,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              if (isOffline)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.offline_pin,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'OFFLINE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentCareCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String size,
    required bool isDownloaded,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isDownloaded)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B9B8E).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.download,
                    color: Color(0xFF1B9B8E),
                    size: 20,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                size,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFabOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return InkWell(
      onTap: () {},
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
}