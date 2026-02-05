import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class AccidentDetectedScreen extends StatefulWidget {
  const AccidentDetectedScreen({Key? key}) : super(key: key);

  @override
  State<AccidentDetectedScreen> createState() => _AccidentDetectedScreenState();
}

class _AccidentDetectedScreenState extends State<AccidentDetectedScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  int countdown = 10;
  late Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
        // SOS would be sent automatically here
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
            _buildCriticalAlertHeader(),
            const SizedBox(height: 30),
            _buildAccidentTitle(),
            const SizedBox(height: 40),
            Expanded(
              child: _buildCountdownTimer(),
            ),
            const SizedBox(height: 30),
            _buildSendingStatus(),
            const SizedBox(height: 30),
            _buildLocationSection(),
            const SizedBox(height: 30),
            _buildCancelInfo(),
            const SizedBox(height: 20),
            _buildSafeButton(),
            const SizedBox(height: 16),
            _buildCallButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalAlertHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF5252),
            Color(0xFFFF6B6B),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.warning,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(width: 12),
          Text(
            'CRITICAL ALERT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccidentTitle() {
    return Column(
      children: const [
        Text(
          'POSSIBLE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            height: 1.1,
          ),
        ),
        Text(
          'ACCIDENT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            height: 1.1,
          ),
        ),
        Text(
          'DETECTED',
          style: TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownTimer() {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_progressController, _pulseController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing background glow
              Container(
                width: 280 + (math.sin(_pulseController.value * 2 * math.pi) * 20),
                height: 280 + (math.sin(_pulseController.value * 2 * math.pi) * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFF5252).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Progress ring
              SizedBox(
                width: 240,
                height: 240,
                child: Transform.rotate(
                  angle: -math.pi / 2,
                  child: CircularProgressIndicator(
                    value: _progressController.value,
                    strokeWidth: 10,
                    backgroundColor: const Color(0xFF2A1A1A),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)),
                  ),
                ),
              ),
              // Dark background circle
              Container(
                width: 210,
                height: 210,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1A0A0A),
                ),
              ),
              // Countdown number
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    countdown.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 90,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'SECONDS',
                    style: TextStyle(
                      color: Color(0xFF808080),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSendingStatus() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1A1A),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF5252),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFF5252),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Sending SOS via SMS in ${countdown}s...',
            style: const TextStyle(
              color: Color(0xFF808080),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'LOCATION OF EVENT',
            style: TextStyle(
              color: Color(0xFF808080),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Map placeholder
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFD0D0D0),
                        Color(0xFFE8E8E8),
                      ],
                    ),
                  ),
                ),
                // Placeholder dimensions text
                const Center(
                  child: Text(
                    '300×300',
                    style: TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 24,
                    ),
                  ),
                ),
                // Location marker
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF5252).withOpacity(0.2),
                    ),
                    child: Center(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF5252),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '37.7749° N, 122.4194° W',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Accuracy: 5m',
                style: TextStyle(
                  color: Color(0xFF808080),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCancelInfo() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Tap if you are uninjured to cancel emergency\nprotocols',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF808080),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSafeButton() {
    return GestureDetector(
      onTap: () {
        // Cancel the emergency and go back
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF5252),
              Color(0xFFFF6B6B),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5252).withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text(
              'I AM SAFE / CANCEL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton() {
    return GestureDetector(
      onTap: () {
        // Trigger manual call to 911
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF3A3A3A), width: 1),
        ),
        child: const Center(
          child: Text(
            'MANUALLY CALL 911',
            style: TextStyle(
              color: Color(0xFF808080),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}