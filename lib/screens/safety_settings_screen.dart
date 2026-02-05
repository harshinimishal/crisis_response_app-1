import 'package:flutter/material.dart';

class SafetySettingsScreen extends StatefulWidget {
  const SafetySettingsScreen({Key? key}) : super(key: key);

  @override
  State<SafetySettingsScreen> createState() => _SafetySettingsScreenState();
}

class _SafetySettingsScreenState extends State<SafetySettingsScreen> {
  bool criticalAlerts = true;
  bool autoDetection = true;
  double sensitivity = 0.8; // 0.0 to 1.0 (Low to Precise)
  bool ultraLowPower = false;
  bool bleBeacon = true;

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
          'Safety Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF143838),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.circle, color: Color(0xFF00E5CC), size: 8),
                SizedBox(width: 6),
                Text(
                  'ACTIVE OPS',
                  style: TextStyle(
                    color: Color(0xFF00E5CC),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure emergency protocols & hardware',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // Responder Alerts Section
            _buildSectionHeader('RESPONDER ALERTS'),
            const SizedBox(height: 16),
            _buildAlertCard(
              icon: Icons.campaign,
              iconColor: Colors.red,
              title: 'Critical Alerts',
              subtitle: 'Override silent/DND mode',
              value: criticalAlerts,
              onChanged: (value) {
                setState(() {
                  criticalAlerts = value;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildAutoDetectionCard(),
            const SizedBox(height: 32),

            // Power & Device Section
            _buildSectionHeader('POWER & DEVICE'),
            const SizedBox(height: 16),
            _buildPowerCard(
              icon: Icons.battery_charging_full,
              iconColor: Colors.orange,
              title: 'Ultra-Low-Power',
              subtitle: 'Extend battery life during shifts',
              value: ultraLowPower,
              onChanged: (value) {
                setState(() {
                  ultraLowPower = value;
                });
              },
            ),
            const SizedBox(height: 12),
            _buildAlertCard(
              icon: Icons.bluetooth,
              iconColor: const Color(0xFF00E5CC),
              title: 'BLE Beacon',
              subtitle: 'Proximity tracking for teams',
              value: bleBeacon,
              onChanged: (value) {
                setState(() {
                  bleBeacon = value;
                });
              },
            ),
            const SizedBox(height: 32),

            // General Preferences Section
            _buildSectionHeader('GENERAL PREFERENCES'),
            const SizedBox(height: 16),
            _buildPreferenceCard(
              icon: Icons.shield,
              title: 'Privacy & Sharing',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildPreferenceCard(
              icon: Icons.language,
              title: 'Language & Accessibility',
              onTap: () {},
            ),
            const SizedBox(height: 32),

            // Footer
            _buildFooter(),
            const SizedBox(height: 24),

            // Save Button
            _buildSaveButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F3D4D), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2D3D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
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

  Widget _buildAutoDetectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F3D4D), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2D3D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.sensors,
                  color: Color(0xFF00E5CC),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Auto-Detection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Fall & collision impact triggers',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: autoDetection,
                onChanged: (value) {
                  setState(() {
                    autoDetection = value;
                  });
                },
                activeColor: const Color(0xFF00E5CC),
                activeTrackColor: const Color(0xFF1F4D4D),
              ),
            ],
          ),
          if (autoDetection) ...[
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'SENSITIVITY',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'HIGH',
                      style: TextStyle(
                        color: Color(0xFF00E5CC),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFF00E5CC),
                    inactiveTrackColor: const Color(0xFF1F4D4D),
                    thumbColor: const Color(0xFF00E5CC),
                    overlayColor: const Color(0xFF00E5CC).withOpacity(0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: sensitivity,
                    onChanged: (value) {
                      setState(() {
                        sensitivity = value;
                      });
                    },
                    min: 0.0,
                    max: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Low',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Medium',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Precise',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPowerCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1F2D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F3D4D), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2D3D),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
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

  Widget _buildPreferenceCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1F2D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1F3D4D), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1F2D3D),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF00E5CC),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'SENTINEL SAFETY PROTOCOL V4.2.1',
          style: TextStyle(
            color: Colors.white24,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'LAST SYNCED: TODAY AT 08:42 AM',
          style: TextStyle(
            color: Colors.white24,
            fontSize: 11,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Save settings
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5CC),
          foregroundColor: const Color(0xFF0D2D2D),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Save All Changes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}