import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'Login_screen.dart';
import 'Signup_screen.dart';


=======
import '../routes/app_routes.dart';
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b

class GuardianScreen extends StatelessWidget {
  const GuardianScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Top Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4E8E6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B9B8E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Guardian',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              const Text(
                'Your Emergency Helper',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Center Shield Icon
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4E8E6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.shield_outlined,
                    size: 80,
                    color: const Color(0xFF1B9B8E).withOpacity(0.3),
                  ),
                ),
              ),
              
              const Spacer(flex: 3),
              
              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
<<<<<<< HEAD
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
=======
                    Navigator.pushNamed(context, AppRoutes.signup);
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B9B8E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
<<<<<<< HEAD
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
=======
                    Navigator.pushNamed(context, AppRoutes.login);
>>>>>>> 390b985e4f3e5b9de5e4bbcd381a0766918cde3b
                  },

                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1B9B8E),
                    side: const BorderSide(
                      color: Color(0xFF1B9B8E),
                      width: 2,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Learn More Link
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Learn more about Guardian',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1B9B8E),
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Bottom Indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFB0BEC5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}