import 'package:flutter/material.dart';

class EmergencyProfileScreen extends StatefulWidget {
  const EmergencyProfileScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyProfileScreen> createState() => _EmergencyProfileScreenState();
}

class _EmergencyProfileScreenState extends State<EmergencyProfileScreen> {
  bool showOnLockScreen = true;
  bool respondersOnly = true;
  bool locationSharing = false;

  final List<Map<String, dynamic>> emergencyContacts = [
    {
      'name': 'Jane Doe',
      'role': 'Spouse',
      'type': 'Primary',
      'icon': Icons.person,
    },
    {
      'name': 'Dr. Michael Smith',
      'role': 'Primary Physician',
      'type': '',
      'icon': Icons.medical_services,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2D2D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2D2D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Emergency Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Profile Avatar and Info
            _buildProfileHeader(),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medical ID Section
                  _buildMedicalIDSection(),
                  const SizedBox(height: 32),

                  // Emergency Contacts Section
                  _buildEmergencyContactsSection(),
                  const SizedBox(height: 32),

                  // Privacy Settings Section
                  _buildPrivacySettingsSection(),
                  const SizedBox(height: 24),

                  // Export Button
                  _buildExportButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00E5CC), width: 3),
              ),
              child: ClipOval(
                child: Container(
                  color: const Color(0xFF5A7F7F),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5CC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'VERIFIED',
                  style: TextStyle(
                    color: Color(0xFF0D2D2D),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'John Doe',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '34 years old • Male',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF143838),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.circle, color: Color(0xFF00E5CC), size: 8),
              SizedBox(width: 8),
              Text(
                'Profile Active',
                style: TextStyle(
                  color: Color(0xFF00E5CC),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalIDSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF143838),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F4D4D), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.local_hospital, color: Color(0xFF00E5CC), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Medical ID',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: Color(0xFF00E5CC),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F4D4D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: const [
                    Text(
                      'BLOOD',
                      style: TextStyle(
                        color: Color(0xFF00E5CC),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'O+',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ALLERGIES',
                      style: TextStyle(
                        color: Color(0xFF00E5CC),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Penicillin, Peanuts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'MEDICAL CONDITIONS',
                      style: TextStyle(
                        color: Color(0xFF00E5CC),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'None Reported',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.white38, size: 16),
              SizedBox(width: 8),
              Text(
                'Last updated on Oct 24, 2023',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.contacts, color: Color(0xFF00E5CC), size: 20),
                SizedBox(width: 8),
                Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Manage',
                style: TextStyle(
                  color: Color(0xFF00E5CC),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...emergencyContacts.map((contact) => _buildContactCard(contact)),
      ],
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF143838),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F4D4D), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF1F4D4D),
              shape: BoxShape.circle,
            ),
            child: Icon(
              contact['icon'],
              color: const Color(0xFF00E5CC),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${contact['role']}${contact['type'].isNotEmpty ? ' • ${contact['type']}' : ''}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF00E5CC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone,
              color: Color(0xFF0D2D2D),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.remove_red_eye, color: Color(0xFF00E5CC), size: 20),
            SizedBox(width: 8),
            Text(
              'Privacy Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPrivacyToggle(
          title: 'Show on Lock Screen',
          subtitle: 'Allow access without unlocking',
          value: showOnLockScreen,
          onChanged: (value) {
            setState(() {
              showOnLockScreen = value;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildPrivacyToggle(
          title: 'Responders Only',
          subtitle: 'Only verified first responders can see info',
          value: respondersOnly,
          onChanged: (value) {
            setState(() {
              respondersOnly = value;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildPrivacyToggle(
          title: 'Location Sharing',
          subtitle: 'Share current coordinates during SOS',
          value: locationSharing,
          onChanged: (value) {
            setState(() {
              locationSharing = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPrivacyToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF143838),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F4D4D), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00E5CC),
            activeTrackColor: const Color(0xFF1F4D4D),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.file_download, size: 20),
        label: const Text(
          'Export for Emergency',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5CC),
          foregroundColor: const Color(0xFF0D2D2D),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}