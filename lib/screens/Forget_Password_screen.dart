import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'otp_screen.dart';

class RecoverAccessScreen extends StatefulWidget {
  const RecoverAccessScreen({Key? key}) : super(key: key);

  @override
  State<RecoverAccessScreen> createState() => _RecoverAccessScreenState();
}

class _RecoverAccessScreenState extends State<RecoverAccessScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _showError = false;
  bool _isLoading = false;
  String? _errorMessage;
  final AuthService _authService = AuthService();

  Future<void> _validateAndSend() async {
    setState(() {
      _isLoading = true;
      _showError = false;
      _errorMessage = null;
    });

    String email = _emailController.text.trim();

    // Validation
    if (email.isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = 'Please enter your email address';
        _isLoading = false;
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _showError = true;
        _errorMessage = 'Please enter a valid email address';
        _isLoading = false;
      });
      return;
    }

    // Send password reset email
    var result = await _authService.sendPasswordResetEmail(email: email);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to OTP screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OTPVerificationScreen(
              email: '',
              isPasswordReset: true,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _showError = true;
        _errorMessage = result['message'];
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Recover Access',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Key Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5F3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.vpn_key,
                            color: Color(0xFF1B9B8E),
                            size: 36,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description
                    const Text(
                      'Enter your registered email address.\nWe\'ll send you a password reset link\nto reset your account safely.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1B9B8E),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Email Label
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'EMAIL ADDRESS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Email Input Field
                    TextField(
                      controller: _emailController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        if (_showError) {
                          setState(() {
                            _showError = false;
                            _errorMessage = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'user@example.com',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: _showError
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Icon(
                                  Icons.error,
                                  color: Color(0xFFEF4444),
                                  size: 20,
                                ),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _showError
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFE0E0E0),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _showError
                                ? const Color(0xFFEF4444)
                                : const Color(0xFFE0E0E0),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: _showError
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF1B9B8E),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),

                    // Error Message
                    if (_showError && _errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Send Password Reset Email Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _validateAndSend,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B9B8E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Send Reset Link',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Contact Support Link
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                        children: [
                          const TextSpan(text: 'Need more help? '),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: _isLoading ? null : () {},
                              child: const Text(
                                'Contact Support',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1B9B8E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Secure Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.shield_outlined,
                          color: Color(0xFF9CA3AF),
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Secure Disaster Response System',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

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
          ],
        ),
      ),
    );
  }
}