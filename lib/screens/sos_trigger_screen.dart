import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'accident_detected_screen.dart';

class SOSTriggeredScreen extends StatefulWidget {
  const SOSTriggeredScreen({Key? key}) : super(key: key);

  @override
  State<SOSTriggeredScreen> createState() => _SOSTriggeredScreenState();
}

class _SOSTriggeredScreenState extends State<SOSTriggeredScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  int countdown = 8;
  late Timer _countdownTimer;

  final List<Map<String, dynamic>> contacts = [
    {'name': 'Dad', 'image': Icons.people},
    {'name': 'Dr. Sarah', 'image': Icons.medical_services},
    {'name': 'Marcus', 'image': Icons.person},
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
        // Navigate to accident detected screen after countdown
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AccidentDetectedScreen(),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _countdownTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildMapSection(),
            const SizedBox(height: 30),
            _buildConnectionStatus(),
            const SizedBox(height: 40),
            Expanded(
              child: _buildSOSButton(),
            ),
            const SizedBox(height: 30),
            _buildCountdownText(),
            const SizedBox(height: 20),
            _buildContactsSection(),
            const SizedBox(height: 30),
            _buildCancelButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Emergency SOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manual Trigger Active',
                style: TextStyle(
                  color: Color(0xFF808080),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFFFF5252),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3A7A8A),
                    Color(0xFF5A9AAA),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    'CURRENT LOCATION: MARKET ST, SF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildStatusCard('INTERNET', 'Active', Icons.wifi, true)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatusCard('SMS', 'Backup', Icons.sms, true)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatusCard('BLE', 'Searching...', Icons.bluetooth, false)),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String status, IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF40916C) : const Color(0xFF808080),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF808080),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF808080),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_progressController, _pulseController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing outer glow
              Container(
                width: 300 + (math.sin(_pulseController.value * 2 * math.pi) * 15),
                height: 300 + (math.sin(_pulseController.value * 2 * math.pi) * 15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFF6B6B).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Progress ring
              SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: _progressController.value,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFF2A1A1A),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)),
                ),
              ),
              // Dark background
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2A1A1A),
                ),
              ),
              // Main SOS button
              Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFFFF7B7B),
                      Color(0xFFFF5252),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFF5252),
                      blurRadius: 30,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'TRIGGERED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCountdownText() {
    return Column(
      children: [
        Text(
          'SENDING IN 0${countdown}s',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Emergency services and your contacts will\nbe notified automatically.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF808080),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'CONTACTS TO NOTIFY',
            style: TextStyle(
              color: Color(0xFF808080),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ...contacts.map((contact) => _buildContactAvatar(
                    contact['name'],
                    contact['image'],
                  )),
              _buildAddContactButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactAvatar(String name, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2A2A),
              border: Border.all(color: const Color(0xFFFF5252), width: 3),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddContactButton() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF2A2A2A),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: const Icon(
            Icons.add,
            color: Color(0xFF808080),
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '',
          style: TextStyle(color: Colors.transparent, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.close, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              'CANCEL SOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}