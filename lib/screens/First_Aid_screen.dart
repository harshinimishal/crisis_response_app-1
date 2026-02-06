import 'package:flutter/material.dart';
import 'dart:math' as math;

// Model Classes
class FirstAidGuide {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String category;
  final bool isOffline;
  final String size;
  final List<String> steps;
  final String estimatedTime;

  FirstAidGuide({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.category,
    required this.isOffline,
    required this.size,
    required this.steps,
    required this.estimatedTime,
  });
}

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
  String _searchQuery = '';

  final List<String> _categories = [
    'All Guides',
    'Life Threatening',
    'Minor Injury',
  ];

  // Comprehensive Dummy Data
  final List<FirstAidGuide> _allGuides = [
    // Critical/Life Threatening
    FirstAidGuide(
      id: '1',
      title: 'CPR',
      subtitle: 'Chest compressions\nand rescue breaths',
      description: 'Cardiopulmonary resuscitation for cardiac arrest',
      icon: Icons.favorite,
      iconColor: const Color(0xFFEF4444),
      iconBgColor: const Color(0xFFFFE5E5),
      category: 'Life Threatening',
      isOffline: true,
      size: '2.1MB',
      estimatedTime: '2-5 min',
      steps: [
        'Check for responsiveness and breathing',
        'Call emergency services (911/112)',
        'Place person on firm, flat surface',
        'Position hands in center of chest',
        'Give 30 chest compressions (100-120 per minute)',
        'Give 2 rescue breaths',
        'Continue cycles of 30:2 until help arrives',
      ],
    ),
    FirstAidGuide(
      id: '2',
      title: 'Choking',
      subtitle: 'Abdominal thrusts\n(Heimlich)',
      description: 'Emergency response for airway obstruction',
      icon: Icons.air,
      iconColor: const Color(0xFFF59E0B),
      iconBgColor: const Color(0xFFFEF3C7),
      category: 'Life Threatening',
      isOffline: true,
      size: '1.5MB',
      estimatedTime: '1-3 min',
      steps: [
        'Ask "Are you choking?" to confirm',
        'Stand behind the person',
        'Make a fist above navel',
        'Grasp fist with other hand',
        'Give quick upward thrusts',
        'Repeat until object dislodges',
        'Call emergency if unsuccessful',
      ],
    ),
    FirstAidGuide(
      id: '3',
      title: 'Severe Bleeding',
      subtitle: 'Tourniquet and pressure\napplication',
      description: 'Control severe hemorrhage and prevent shock',
      icon: Icons.bloodtype,
      iconColor: const Color(0xFFEF4444),
      iconBgColor: const Color(0xFFFFE5E5),
      category: 'Life Threatening',
      isOffline: true,
      size: '1.2MB',
      estimatedTime: '3-5 min',
      steps: [
        'Apply direct pressure with clean cloth',
        'Elevate the injured area above heart',
        'Apply pressure bandage if available',
        'If bleeding doesn\'t stop, apply tourniquet',
        'Note the time tourniquet was applied',
        'Call emergency services immediately',
        'Monitor for signs of shock',
      ],
    ),
    FirstAidGuide(
      id: '4',
      title: 'Heart Attack',
      subtitle: 'Recognize and respond\nto cardiac emergency',
      description: 'Immediate response to myocardial infarction',
      icon: Icons.monitor_heart,
      iconColor: const Color(0xFFDC2626),
      iconBgColor: const Color(0xFFFEE2E2),
      category: 'Life Threatening',
      isOffline: false,
      size: '1.8MB',
      estimatedTime: '2-4 min',
      steps: [
        'Call emergency services immediately',
        'Help person sit or lie down comfortably',
        'Loosen tight clothing',
        'Give aspirin if not allergic (chew slowly)',
        'Monitor breathing and pulse',
        'Be prepared to perform CPR',
        'Stay calm and reassure the person',
      ],
    ),
    FirstAidGuide(
      id: '5',
      title: 'Stroke',
      subtitle: 'FAST assessment\nand response',
      description: 'Recognize stroke symptoms and act quickly',
      icon: Icons.psychology,
      iconColor: const Color(0xFF7C3AED),
      iconBgColor: const Color(0xFFF3E8FF),
      category: 'Life Threatening',
      isOffline: false,
      size: '1.4MB',
      estimatedTime: '1-2 min',
      steps: [
        'Check Face: Ask to smile (drooping?)',
        'Check Arms: Raise both arms (drift down?)',
        'Check Speech: Repeat phrase (slurred?)',
        'Time: Note when symptoms started',
        'Call emergency services immediately',
        'Keep person comfortable and calm',
        'Do not give food or drink',
      ],
    ),

    // Urgent Care
    FirstAidGuide(
      id: '6',
      title: 'Burns',
      subtitle: 'Thermal, chemical,\nand electrical',
      description: 'Treatment for all types of burn injuries',
      icon: Icons.local_fire_department,
      iconColor: const Color(0xFFF97316),
      iconBgColor: const Color(0xFFFFEDD5),
      category: 'Life Threatening',
      isOffline: false,
      size: '0.8MB',
      estimatedTime: '5-10 min',
      steps: [
        'Remove person from heat source',
        'Cool burn with running water (10-20 minutes)',
        'Remove jewelry and tight clothing',
        'Cover with sterile, non-stick bandage',
        'Do NOT apply ice, butter, or ointments',
        'Take over-the-counter pain reliever',
        'Seek medical help for severe burns',
      ],
    ),
    FirstAidGuide(
      id: '7',
      title: 'Poisoning',
      subtitle: 'Ingestion and chemical\nexposure',
      description: 'Emergency response to toxic substance exposure',
      icon: Icons.science_outlined,
      iconColor: const Color(0xFF8B5CF6),
      iconBgColor: const Color(0xFFEDE9FE),
      category: 'Life Threatening',
      isOffline: false,
      size: '0.6MB',
      estimatedTime: '2-5 min',
      steps: [
        'Call Poison Control immediately',
        'Identify the substance if possible',
        'Do NOT induce vomiting unless told',
        'If on skin, brush off and rinse with water',
        'If in eyes, flush with water for 15 minutes',
        'Save container for emergency responders',
        'Monitor breathing and consciousness',
      ],
    ),
    FirstAidGuide(
      id: '8',
      title: 'Fractures',
      subtitle: 'Broken bone\nimmobilization',
      description: 'Stabilize and support suspected fractures',
      icon: Icons.healing,
      iconColor: const Color(0xFF0891B2),
      iconBgColor: const Color(0xFFCFFAFE),
      category: 'Life Threatening',
      isOffline: false,
      size: '1.1MB',
      estimatedTime: '5-8 min',
      steps: [
        'Do NOT move the injured area',
        'Immobilize the joint above and below',
        'Apply ice pack (wrapped in cloth)',
        'Create splint with rigid material',
        'Secure splint with bandages',
        'Elevate if possible to reduce swelling',
        'Seek immediate medical attention',
      ],
    ),
    FirstAidGuide(
      id: '9',
      title: 'Allergic Reaction',
      subtitle: 'Anaphylaxis\nemergency response',
      description: 'Severe allergic reaction treatment',
      icon: Icons.medical_information,
      iconColor: const Color(0xFFEC4899),
      iconBgColor: const Color(0xFFFCE7F3),
      category: 'Life Threatening',
      isOffline: false,
      size: '0.9MB',
      estimatedTime: '1-3 min',
      steps: [
        'Call emergency services immediately',
        'Use epinephrine auto-injector if available',
        'Inject into outer thigh muscle',
        'Have person lie down with legs elevated',
        'Loosen tight clothing',
        'Monitor breathing and pulse',
        'Be prepared to perform CPR',
      ],
    ),

    // Minor Injuries
    FirstAidGuide(
      id: '10',
      title: 'Cuts & Scrapes',
      subtitle: 'Minor wound\ncare and cleaning',
      description: 'Proper wound cleaning and bandaging',
      icon: Icons.medical_services_outlined,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0xFFD1FAE5),
      category: 'Minor Injury',
      isOffline: true,
      size: '0.4MB',
      estimatedTime: '3-5 min',
      steps: [
        'Wash your hands thoroughly',
        'Stop bleeding with gentle pressure',
        'Clean wound with clean water',
        'Apply antibiotic ointment',
        'Cover with sterile bandage',
        'Change bandage daily',
        'Watch for signs of infection',
      ],
    ),
    FirstAidGuide(
      id: '11',
      title: 'Sprains',
      subtitle: 'R.I.C.E. method\nfor joint injuries',
      description: 'Treatment for twisted or overstretched ligaments',
      icon: Icons.self_improvement,
      iconColor: const Color(0xFF3B82F6),
      iconBgColor: const Color(0xFFDBEAFE),
      category: 'Minor Injury',
      isOffline: true,
      size: '0.7MB',
      estimatedTime: '5-10 min',
      steps: [
        'Rest: Stop activity immediately',
        'Ice: Apply ice pack for 20 minutes',
        'Compression: Wrap with elastic bandage',
        'Elevation: Raise above heart level',
        'Take anti-inflammatory medication',
        'Avoid heat for first 48 hours',
        'Seek medical help if severe pain',
      ],
    ),
    FirstAidGuide(
      id: '12',
      title: 'Nosebleeds',
      subtitle: 'Stop bleeding and\nprevent recurrence',
      description: 'Effective nosebleed management',
      icon: Icons.face,
      iconColor: const Color(0xFFEF4444),
      iconBgColor: const Color(0xFFFEE2E2),
      category: 'Minor Injury',
      isOffline: true,
      size: '0.3MB',
      estimatedTime: '10-15 min',
      steps: [
        'Sit upright and lean slightly forward',
        'Pinch soft part of nose firmly',
        'Hold for 10-15 minutes continuously',
        'Breathe through your mouth',
        'Apply cold compress to nose bridge',
        'Do NOT tilt head back',
        'Seek help if bleeding doesn\'t stop',
      ],
    ),
    FirstAidGuide(
      id: '13',
      title: 'Bee Stings',
      subtitle: 'Remove stinger and\nreduce swelling',
      description: 'Treatment for insect stings and bites',
      icon: Icons.pest_control,
      iconColor: const Color(0xFFF59E0B),
      iconBgColor: const Color(0xFFFEF3C7),
      category: 'Minor Injury',
      isOffline: true,
      size: '0.5MB',
      estimatedTime: '5-8 min',
      steps: [
        'Remove stinger by scraping (don\'t pinch)',
        'Wash area with soap and water',
        'Apply ice pack to reduce swelling',
        'Take antihistamine for itching',
        'Apply hydrocortisone cream',
        'Monitor for allergic reactions',
        'Seek emergency help if severe reaction',
      ],
    ),
    FirstAidGuide(
      id: '14',
      title: 'Minor Burns',
      subtitle: 'First-degree burn\ntreatment',
      description: 'Care for superficial burns',
      icon: Icons.whatshot,
      iconColor: const Color(0xFFF97316),
      iconBgColor: const Color(0xFFFFEDD5),
      category: 'Minor Injury',
      isOffline: true,
      size: '0.4MB',
      estimatedTime: '10-15 min',
      steps: [
        'Cool burn under running water (10 minutes)',
        'Remove rings or tight items',
        'Apply aloe vera or burn gel',
        'Cover with sterile gauze loosely',
        'Take pain reliever if needed',
        'Keep burn clean and dry',
        'Do NOT pop blisters',
      ],
    ),
    FirstAidGuide(
      id: '15',
      title: 'Bruises',
      subtitle: 'Reduce swelling\nand discoloration',
      description: 'Treatment for contusions and impact injuries',
      icon: Icons.colorize,
      iconColor: const Color(0xFF8B5CF6),
      iconBgColor: const Color(0xFFEDE9FE),
      category: 'Minor Injury',
      isOffline: true,
      size: '0.3MB',
      estimatedTime: '5-10 min',
      steps: [
        'Apply ice pack immediately (20 minutes)',
        'Elevate injured area if possible',
        'Rest and avoid further injury',
        'Take over-the-counter pain reliever',
        'After 48 hours, apply warm compress',
        'Gently massage area after 2 days',
        'Seek help if bruise is very large',
      ],
    ),
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

  List<FirstAidGuide> get _filteredGuides {
    List<FirstAidGuide> guides = _allGuides;

    // Filter by category
    if (_selectedCategoryIndex == 1) {
      guides = guides.where((g) => g.category == 'Life Threatening').toList();
    } else if (_selectedCategoryIndex == 2) {
      guides = guides.where((g) => g.category == 'Minor Injury').toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      guides = guides.where((g) {
        return g.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            g.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            g.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return guides;
  }

  List<FirstAidGuide> get _criticalGuides {
    return _filteredGuides
        .where((g) => g.isOffline && g.category == 'Life Threatening')
        .take(2)
        .toList();
  }

  List<FirstAidGuide> get _urgentGuides {
    return _filteredGuides
        .where((g) => !_criticalGuides.contains(g))
        .toList();
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
                                      _searchQuery = '';
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
                          setState(() {
                            _searchQuery = value;
                          });
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
                                      color: isSelected ? null : Colors.white,
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
              child: _searchQuery.isNotEmpty
                  ? _buildSearchResults()
                  : _buildMainContent(),
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
              onTap: () {
                _showEmergencyDialog();
              },
            ),
            const SizedBox(height: 12),
            _buildFabOption(
              icon: Icons.download,
              label: 'Download All',
              color: const Color(0xFF1B9B8E),
              onTap: () {
                _showDownloadDialog();
              },
            ),
            const SizedBox(height: 12),
            _buildFabOption(
              icon: Icons.share,
              label: 'Share Guide',
              color: const Color(0xFF3B82F6),
              onTap: () {
                _showShareDialog();
              },
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
    );
  }

  Widget _buildMainContent() {
    final criticalGuides = _criticalGuides;
    final urgentGuides = _urgentGuides;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // CRITICAL RESPONSE Section
        if (criticalGuides.isNotEmpty) ...[
          _buildSectionHeader(
            'CRITICAL RESPONSE',
            Icons.emergency,
            const Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          if (criticalGuides.length >= 2)
            Row(
              children: [
                Expanded(
                  child: _buildCriticalCard(criticalGuides[0]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCriticalCard(criticalGuides[1]),
                ),
              ],
            )
          else
            ...criticalGuides.map((guide) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCriticalCard(guide),
                )),
          const SizedBox(height: 32),
        ],

        // URGENT CARE Section
        if (urgentGuides.isNotEmpty) ...[
          _buildSectionHeader(
            'URGENT CARE',
            Icons.local_hospital,
            const Color(0xFF1B9B8E),
          ),
          const SizedBox(height: 16),
          ...urgentGuides.map((guide) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildUrgentCareCard(guide),
              )),
          const SizedBox(height: 32),
        ],

        if (criticalGuides.isEmpty && urgentGuides.isEmpty)
          _buildEmptyState(),

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
    );
  }

  Widget _buildSearchResults() {
    final results = _filteredGuides;

    if (results.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '${results.length} result${results.length != 1 ? 's' : ''} found',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 16),
        ...results.map((guide) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildUrgentCareCard(guide),
            )),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 64,
                color: Color(0xFF1B9B8E),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No guides found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
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

  Widget _buildCriticalCard(FirstAidGuide guide) {
    return GestureDetector(
      onTap: () => _showGuideDetails(guide),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: guide.iconColor.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: guide.iconColor.withOpacity(0.15),
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
                    color: guide.iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    guide.icon,
                    color: guide.iconColor,
                    size: 28,
                  ),
                ),
                if (guide.isOffline)
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
              guide.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              guide.subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgentCareCard(FirstAidGuide guide) {
    return GestureDetector(
      onTap: () => _showGuideDetails(guide),
      child: Container(
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
                color: guide.iconBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                guide.icon,
                color: guide.iconColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    guide.subtitle.replaceAll('\n', ' '),
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
                if (guide.isOffline)
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
                  guide.size,
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
              color:
                  isActive ? const Color(0xFF1B9B8E) : const Color(0xFF9CA3AF),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? const Color(0xFF1B9B8E)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGuideDetails(FirstAidGuide guide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
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
                            color: guide.iconBgColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            guide.icon,
                            color: guide.iconColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                guide.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                guide.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Info Pills
                    Row(
                      children: [
                        _buildInfoPill(
                          Icons.timer,
                          guide.estimatedTime,
                          const Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 12),
                        _buildInfoPill(
                          guide.isOffline
                              ? Icons.offline_pin
                              : Icons.cloud_download,
                          guide.isOffline ? 'Offline' : guide.size,
                          guide.isOffline
                              ? const Color(0xFF10B981)
                              : const Color(0xFF1B9B8E),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Steps
                    const Text(
                      'Step-by-Step Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      guide.steps.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    guide.iconColor,
                                    guide.iconColor.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  guide.steps[index],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    if (!guide.isOffline)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showDownloadDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B9B8E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.download),
                            SizedBox(width: 8),
                            Text(
                              'Download for Offline Use',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.call, color: Color(0xFFEF4444)),
            SizedBox(width: 12),
            Text('Emergency Call'),
          ],
        ),
        content: const Text(
          'Call emergency services?\n\n🚨 911 (US)\n🚨 112 (Europe)\n🚨 999 (UK)',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Call Now'),
          ),
        ],
      ),
    );
  }

  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.download, color: Color(0xFF1B9B8E)),
            SizedBox(width: 12),
            Text('Download All Guides'),
          ],
        ),
        content: const Text(
          'Download all first aid guides for offline access?\n\nTotal size: ~15MB',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B9B8E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.share, color: Color(0xFF3B82F6)),
            SizedBox(width: 12),
            Text('Share Guide'),
          ],
        ),
        content: const Text(
          'Share this first aid guide with friends and family to help them stay prepared.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}