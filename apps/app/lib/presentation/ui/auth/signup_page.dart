import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/ui/auth/widgets/auth_text_field.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_app/router/routes/auth_routes.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/composition_root/repositories/auth_repository.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  bool _isEmailMode = true; // Default to Email mode
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Gradient Overlay (optional match for AuthPage)
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
                    // Back Button (Moved inside)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios, size: 16, color: Color(0xFFC2185B)),
                        label: const Text(
                          'Back to login',
                          style: TextStyle(
                            color: Color(0xFFC2185B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF880E4F), // Maroon
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Social Buttons
                    _buildSocialButton(
                      asset: 'assets/apple_icon.svg',
                      text: 'Continue with Apple',
                      textColor: Colors.black,
                      onTap: () async {
                        print("UI: Tapped Apple Sign In");
                        await ref.read(authRepositoryProvider).signInWithApple();
                      },
                   ),
                    const SizedBox(height: 16),
                    _buildSocialButton(
                      asset: 'assets/google_icon.svg',
                      text: 'Continue with Google',
                      textColor: Colors.black,
                      onTap: () async {
                        print("UI: Tapped Google Sign In");
                        await ref.read(authRepositoryProvider).signInWithGoogle();
                      },
                    ),

                    const SizedBox(height: 32),
                    
                    // Divider
                    const Row(
                      children: [
                         Expanded(child: Divider(color: Color(0xFF880E4F), thickness: 0.5)),
                         Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Color(0xFF880E4F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                         Expanded(child: Divider(color: Color(0xFF880E4F), thickness: 0.5)),
                      ],
                    ),
                    
                    const SizedBox(height: 32),

                    // Input Field (Dynamic)
                    AuthTextField(
                      controller: _emailController,
                      hintText: _isEmailMode ? 'Enter email address' : 'Enter phone number',
                      prefixIcon: _isEmailMode ? Icons.email_outlined : Icons.phone,
                    ),
                    
                    const SizedBox(height: 32),

                    // Email Action Button
                     _buildActionButton(
                      text: 'Continue with Email',
                      icon: Icons.email_outlined,
                      color: _isEmailMode ? const Color(0xFF900759) : const Color(0xFFA69B97),
                      onTap: () {
                        if (_isEmailMode) {
                          if (_emailController.text.isNotEmpty) {
                            context.push(PasswordPageRoute.path, extra: _emailController.text);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter an email address')),
                            );
                          }
                        } else {
                          setState(() {
                            _isEmailMode = true;
                          });
                        }
                      },
                    ),
                     const SizedBox(height: 16),
                     
                    // Phone Action Button
                     _buildActionButton(
                      text: 'Continue with Phone',
                      icon: Icons.phone,
                      color: !_isEmailMode ? const Color(0xFF900759) : const Color(0xFFA69B97),
                      onTap: () {
                         if (!_isEmailMode) {
                           context.push(PasswordPageRoute.path);
                         } else {
                           setState(() {
                            _isEmailMode = false;
                          });
                         }
                      },
                    ),

                    const SizedBox(height: 48),

                    // Terms Footer
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(text: 'By signing up, you agree to our '),
                          TextSpan(
                            text: 'Terms of use',
                            style: TextStyle(
                              color: const Color(0xFFC2185B),
                              decoration: TextDecoration.underline,
                              decorationColor: const Color(0xFFC2185B),
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: const Color(0xFFC2185B),
                              decoration: TextDecoration.underline,
                               decorationColor: const Color(0xFFC2185B),
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Add extra space to push sheet up
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

  Widget _buildSocialButton({
    required String asset,
    required String text,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                asset,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
           borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
