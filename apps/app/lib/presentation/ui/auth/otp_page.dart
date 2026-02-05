import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/router/routes/auth_routes.dart';
import 'package:flutter_app/composition_root/repositories/auth_repository.dart';

class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key, this.email});
  final String? email;

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  
  // Timer State
  Timer? _timer;
  int _start = 60; // 60 seconds countdown
  bool _isResendVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    setState(() {
      _start = 60;
      _isResendVisible = false;
    });
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _isResendVisible = true;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  String get timerText {
    final minutes = (_start / 60).floor().toString().padLeft(1, '0');
    final seconds = (_start % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return '*** ***';
    // Simple masking: s***@gmail.com
    final parts = email.split('@');
    if (parts.isEmpty) return email;
    final name = parts[0];
    if (name.length <= 2) return '$name***';
    return '${name.substring(0, 2)}***@${parts.length > 1 ? parts[1] : ""}';
  }

  Future<void> _handleVerify() async {
      if (pinController.text.length != 4) return;
      if (widget.email == null || widget.email!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Email address missing. Please go back."))
          );
          return;
      }

      setState(() => _isLoading = true);
      try {
          await ref.read(authRepositoryProvider).verifyEmailOtp(
              widget.email!,
              pinController.text
          );
          
          if (mounted) {
              context.go(UserInfoPageRoute.path);
          }
      } catch (e) {
          if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Verification failed: ${e.toString()}"))
              );
              pinController.clear();
          }
      } finally {
          if (mounted) setState(() => _isLoading = false);
      }
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color(0xFFC2185B); // Pinkish Maroon
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color(0xFFE0E0E0); // Light Grey

    final defaultPinTheme = PinTheme(
      width: 70, // Slightly larger boxes
      height: 70,
      textStyle: const TextStyle(
        fontSize: 24,
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        color: Colors.white,
      ),
    );

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
              color: Colors.black.withOpacity(0.35), // Slightly darker overlay
            ),
          ),

          // Bottom Sheet
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
                      'Verification code',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF880E4F), // Maroon
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We have sent the code verification to\n${_maskEmail(widget.email ?? "")}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Pinput
                    Pinput(
                      length: 4, // Reverted to 4 digits as per user request
                      controller: pinController,
                      focusNode: focusNode,
                      defaultPinTheme: defaultPinTheme,
                      separatorBuilder: (index) => const SizedBox(width: 16),
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(color: focusedBorderColor),
                        ),
                      ),
                      submittedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          color: fillColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: focusedBorderColor),
                        ),
                      ),
                      onCompleted: (pin) => _handleVerify(),
                    ),
                     const SizedBox(height: 24),
                     
                     // Resend Timer (Conditional)
                     if (!_isResendVisible)
                       Center(
                         child: RichText(
                           text: TextSpan(
                             style: TextStyle(
                               fontSize: 14,
                               color: Colors.grey[600],
                             ),
                             children: [
                               const TextSpan(text: 'Resend code after '),
                               TextSpan(
                                 text: timerText,
                                 style: const TextStyle(
                                   color: Color(0xFFC2185B),
                                   fontWeight: FontWeight.w600,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       )
                     else
                       const SizedBox(height: 20), // Placeholder to keep layout stable-ish
                    
                    const SizedBox(height: 48),

                    // Verify Button / Resend Button Row
                    Row(
                      children: [
                        if (_isResendVisible) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                startTimer();
                                try {
                                  await ref.read(authRepositoryProvider).sendEmailOtp(widget.email!);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Code resent successfully")),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Failed to resend: $e")),
                                  );
                                }
                              },
                               style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: Color(0xFFC2185B)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Resend', style: TextStyle(color: Color(0xFFC2185B))),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleVerify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF880E4F), // Maroon
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading 
                               ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                               : const Text(
                              'Confirm',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
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
