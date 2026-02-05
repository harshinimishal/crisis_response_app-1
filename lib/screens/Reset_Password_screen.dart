import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import 'auth_service.dart';
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  double _passwordStrength = 0.0;
  bool _isLoading = false;
  String? _errorMessage;
  final AuthService _authService = AuthService();

  String _getStrengthText() {
    if (_passwordStrength < 0.4) return 'Weak';
    if (_passwordStrength < 0.7) return 'Medium';
    return 'Strong';
  }

  Color _getStrengthColor() {
    if (_passwordStrength < 0.4) return Colors.red;
    if (_passwordStrength < 0.7) return Colors.orange;
    return const Color(0xFF1B9B8E);
  }

  void _updatePasswordStrength(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordStrength = 0.0;
      } else if (value.length < 6) {
        _passwordStrength = 0.3;
      } else if (value.length < 10) {
        _passwordStrength = 0.6;
      } else if (value.length >= 10 &&
          value.contains(RegExp(r'[A-Z]')) &&
          value.contains(RegExp(r'[0-9]')) &&
          value.contains(RegExp(r'[!@#$%^&*]'))) {
        _passwordStrength = 0.95;
      } else {
        _passwordStrength = 0.85;
      }
    });
  }

  Future<void> _handleResetPassword() async {
  final newPassword = _newPasswordController.text.trim();
  final confirmPassword = _confirmPasswordController.text.trim();

  // Validation
  if (newPassword.isEmpty || confirmPassword.isEmpty) {
    setState(() => _errorMessage = 'Please fill in all fields');
    return;
  }
  if (newPassword.length < 8) {
    setState(() => _errorMessage = 'Password must be at least 8 characters long');
    return;
  }
  if (newPassword != confirmPassword) {
    setState(() => _errorMessage = 'Passwords do not match');
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  final result = await _authService.resetPassword(newPassword: newPassword);

  if (!mounted) return;

  setState(() => _isLoading = false);

  if (result['success']) {
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  } else {
    setState(() => _errorMessage = result['message']);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_errorMessage ?? 'Password reset failed'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F3),
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
                        'Reset Password',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Title
                    const Text(
                      'Create Secure Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description
                    const Text(
                      'Create a new password that is at least 8\ncharacters long and includes a mix of letters,\nnumbers, and symbols.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Secure Connection Badge
                    const Row(
                      children: [
                        Icon(
                          Icons.verified_user,
                          color: Color(0xFF1B9B8E),
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'SECURE CONNECTION',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF1B9B8E),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Error Message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          border: Border.all(color: const Color(0xFFEF4444)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // New Password Label
                    const Text(
                      'New Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // New Password Input
                    TextField(
                      controller: _newPasswordController,
                      enabled: !_isLoading,
                      obscureText: !_isNewPasswordVisible,
                      onChanged: (value) {
                        _updatePasswordStrength(value);
                        if (_errorMessage != null) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: '••••••••••••',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 20,
                          letterSpacing: 2,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1B9B8E),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNewPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF1B9B8E),
                          ),
                          onPressed: () {
                            setState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Password Strength Section
                    if (_newPasswordController.text.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Password Strength',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '${_getStrengthText()} (${(_passwordStrength * 100).toInt()}/100)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _getStrengthColor(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _passwordStrength,
                              backgroundColor: const Color(0xFFD1FAE5),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getStrengthColor(),
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _passwordStrength >= 0.7
                                ? 'Great! This password is hard to guess.'
                                : 'Add more characters for a stronger password.',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getStrengthColor(),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),

                    const SizedBox(height: 24),

                    // Confirm New Password Label
                    const Text(
                      'Confirm New Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Confirm Password Input
                    TextField(
                      controller: _confirmPasswordController,
                      enabled: !_isLoading,
                      obscureText: !_isConfirmPasswordVisible,
                      onChanged: (value) {
                        if (_errorMessage != null) {
                          setState(() {
                            _errorMessage = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: '••••••••••••',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 20,
                          letterSpacing: 2,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1B9B8E),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF1B9B8E),
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Reset Password Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleResetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF06D6A0),
                          foregroundColor: Colors.black87,
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
                                    Colors.black87,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Reset Password',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.refresh,
                                    color: Colors.black87,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Contact Support Link
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                          children: [
                            const TextSpan(text: 'Need help? '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  'Contact Support',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1B9B8E),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
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