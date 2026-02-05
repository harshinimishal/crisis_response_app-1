import 'package:flutter/material.dart';
import 'dart:math' as math;

class SafetyMapScreen extends StatefulWidget {
  const SafetyMapScreen({Key? key}) : super(key: key);

  @override
  State<SafetyMapScreen> createState() => _SafetyMapScreenState();
}

class _SafetyMapScreenState extends State<SafetyMapScreen> {
  String selectedFilter = 'SAFE ROUTES';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5C4A42),
      body: SafeArea(
        child: Stack(
          children: [
            // Map area
            _buildMapArea(),
            
            // Top header and controls
            Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildFilterButtons(),
              ],
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
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
          ],
        ),
      ),
    );
  }

  Widget _buildMapArea() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: MapPainter(),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF3A2A24),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
          const Text(
            'Safety Map',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF3A2A24),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3A34).withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF6A5A54), width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: Color(0xFFB0A0A0),
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Nearby Responders',
              style: TextStyle(
                color: Color(0xFFB0A0A0),
                fontSize: 18,
              ),
            ),
          ),
          const Icon(
            Icons.tune,
            color: Color(0xFFB0A0A0),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterButton('SAFE ROUTES', Icons.check_circle, const Color(0xFF2D7A4F)),
          const SizedBox(width: 12),
          _buildFilterButton('ACCIDENTS', Icons.warning, const Color(0xFFB83232)),
          const SizedBox(width: 12),
          _buildFilterButton('FLO', Icons.water_drop, const Color(0xFFD4A04C)),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, IconData icon, Color color) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF3A2A24),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 28),
              onPressed: () {},
              padding: const EdgeInsets.all(16),
            ),
            Container(
              height: 1,
              width: 40,
              color: const Color(0xFF5A4A44),
            ),
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.white, size: 28),
              onPressed: () {},
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.my_location,
              color: Colors.black,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              'Recenter Map',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSOSButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF3333),
            Color(0xFFFF5252),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3333).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'SOS  EMERGENCY SOS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()..color = const Color(0xFF7A6A62);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw safe route (green curved path)
    final greenPath = Path();
    greenPath.moveTo(80, size.height * 0.45);
    greenPath.quadraticBezierTo(
      size.width * 0.3, size.height * 0.6,
      size.width * 0.5, size.height * 0.55,
    );
    greenPath.lineTo(size.width - 20, size.height * 0.5);

    final greenPaint = Paint()
      ..color = const Color(0xFF40C463)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(greenPath, greenPaint);

    // User location (blue dot)
    final userPaint = Paint()..color = const Color(0xFF4A90E2);
    canvas.drawCircle(
      Offset(80, size.height * 0.45),
      12,
      userPaint,
    );
    final userBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(
      Offset(80, size.height * 0.45),
      12,
      userBorderPaint,
    );

    // Accident markers (red circles)
    _drawAccidentMarker(canvas, size.width * 0.35, size.height * 0.35);
    _drawAccidentMarker(canvas, size.width * 0.75, size.height * 0.65);

    // Flood warning icon
    _drawFloodIcon(canvas, size.width * 0.75, size.height * 0.25);

    // Home icon
    _drawHomeIcon(canvas, size.width * 0.85, size.height * 0.58);
  }

  void _drawAccidentMarker(Canvas canvas, double x, double y) {
    // Outer circle
    final outerPaint = Paint()
      ..color = const Color(0xFFFF3333).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 50, outerPaint);

    // Middle circle
    final middlePaint = Paint()
      ..color = const Color(0xFFFF3333).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 35, middlePaint);

    // Inner circle
    final innerPaint = Paint()
      ..color = const Color(0xFFFF3333)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), 20, innerPaint);

    // Car icon (simplified)
    final carPaint = Paint()
      ..color = const Color(0xFFBB0000)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: 20, height: 12),
        const Radius.circular(2),
      ),
      carPaint,
    );
  }

  void _drawFloodIcon(Canvas canvas, double x, double y) {
    final floodPaint = Paint()..color = const Color(0xFFFDB736);
    
    // House shape
    final housePath = Path();
    housePath.moveTo(x, y - 15);
    housePath.lineTo(x - 15, y);
    housePath.lineTo(x - 15, y + 15);
    housePath.lineTo(x + 15, y + 15);
    housePath.lineTo(x + 15, y);
    housePath.close();
    canvas.drawPath(housePath, floodPaint);

    // Water waves
    final wavePaint = Paint()
      ..color = const Color(0xFFFDB736)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 3; i++) {
      final wavePath = Path();
      wavePath.moveTo(x - 20, y + 20 + (i * 5));
      wavePath.lineTo(x + 20, y + 20 + (i * 5));
      canvas.drawPath(wavePath, wavePaint);
    }
  }

  void _drawHomeIcon(Canvas canvas, double x, double y) {
    final homePaint = Paint()..color = const Color(0xFFFDB736);
    
    // House shape
    final housePath = Path();
    housePath.moveTo(x, y - 12);
    housePath.lineTo(x - 12, y);
    housePath.lineTo(x - 12, y + 12);
    housePath.lineTo(x + 12, y + 12);
    housePath.lineTo(x + 12, y);
    housePath.close();
    canvas.drawPath(housePath, homePaint);

    // Door
    final doorPaint = Paint()..color = const Color(0xFFD49020);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(x, y + 6), width: 6, height: 10),
      doorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}