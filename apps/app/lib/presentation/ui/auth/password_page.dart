import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/ui/auth/widgets/auth_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_app/router/routes/auth_routes.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/composition_root/repositories/auth_repository.dart';
import 'package:flutter_app/router/routes/auth_routes.dart'; // Ensure correct import for UserInfoPageRoute

class PasswordPage extends ConsumerStatefulWidget {
  const PasswordPage({super.key, this.email});
  final String? email;

  @override
  ConsumerState<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends ConsumerState<PasswordPage> {
  bool _obscureText = true;
  bool _obscureConfirmText = true;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _showError = false;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validatePassword() {
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Reset error
    _errorMessage = null;

    // At least 8 characters
    if (password.length < 8) {
       _errorMessage = 'Password must contain at least 8 characters.';
       return false;
    }
    // At least one number
    if (!password.contains(RegExp(r'[0-9]'))) {
       _errorMessage = 'Password must contain at least one number.';
       return false;
    }
    // At least one special character
    if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
       _errorMessage = 'Password must contain at least one special character.';
       return false;
    }
    
    // Check match
    if (password != confirmPassword) {
      _errorMessage = 'Passwords do not match.';
      return false;
    }

    return true;
  }

  Future<void> _handleNext() async {
    if (_validatePassword()) {
       if (widget.email == null || widget.email!.isEmpty) {
          setState(() {
             _errorMessage = "Email is missing. Go back and try again.";
             _showError = true;
          });
          return;
       }

       setState(() => _isLoading = true);
       try {
          // Hardcoded name for now, or could be collected in UserInfo page later.
          // BetterAuth usually allows updating user info.
          final success = await ref.read(authRepositoryProvider).signUpWithEmailAndPassword(
             widget.email!,
             _passwordController.text,
             "New User", 
          );
          
          if (mounted) {
             if (success) {
                 // Auto-login success
                 context.go(UserInfoPageRoute.path);
             } else {
                 // Verification required
                 context.push(OtpPageRoute.path, extra: widget.email);
             }
          }
       } catch (e) {
          if (mounted) {
             setState(() {
                _errorMessage = "Sign up failed: ${e.toString()}";
                _showError = true;
                _isLoading = false;
             });
          }
       }
    } else {
      setState(() {
        _showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
             // ... existing background
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          // Bottom Sheet (Scrollable)
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDF0F6), // Pale Pink Background
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFFC2185B)),
                        label: const Text(
                          'Back',
                          style: TextStyle(
                            color: Color(0xFFC2185B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // ... style
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Create a Password',
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF880E4F), // Maroon
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Password Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _showError ? Colors.red : Colors.black12,
                          width: _showError ? 1.5 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        onChanged: (value) {
                             if (_showError) setState(() => _showError = false);
                        },
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                            onPressed: () => setState(() => _obscureText = !_obscureText),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    // Confirm Password Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _showError ? Colors.red : Colors.black12,
                          width: _showError ? 1.5 : 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmText,
                        onChanged: (value) {
                            if (_showError) setState(() => _showError = false);
                        },
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                            onPressed: () => setState(() => _obscureConfirmText = !_obscureConfirmText),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Info Row
                    Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: _showError ? Colors.red : Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _showError && _errorMessage != null 
                              ? _errorMessage! 
                              : 'Password must contain at least 8 characters, including a number and a special character.',
                            style: TextStyle(
                              color: _showError ? Colors.red : Colors.grey[600],
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF880E4F), // Maroon
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading 
                           ? const CircularProgressIndicator(color: Colors.white)
                           : const Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                    ),
                     // Add extra space to push sheet up (consistent with Signup)
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
