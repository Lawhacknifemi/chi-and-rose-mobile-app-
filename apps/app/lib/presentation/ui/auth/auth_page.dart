import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/ui/auth/widgets/login_form.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 75% of screen height for the sheet, or at least enough to fit content
    // We'll use a Stack where the sheet is pinned to bottom
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
          
          // Gradient Overlay if needed (optional)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

          // Header Text
          const Positioned(
            top: 100, // Adjust based on safe area
            left: 32,
            right: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello!',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome to Chi & Rose',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFEEDCF0),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Sheet (Scrollable)
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
               // To allow keyboard to push it up
              child: const LoginForm(),
            ),
          ),
        ],
      ),
    );
  }
}
