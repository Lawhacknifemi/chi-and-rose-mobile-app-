import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_app/composition_root/data_sources/shared_preference_data_source.dart';

import 'package:flutter_app/configuration/api_configuration.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  final apiConfiguration = ref.watch(apiConfigurationProvider);
  return AuthRepository(sharedPreferences, apiConfiguration);
}

class AuthRepository {
  AuthRepository(this._sharedPreferences, this._apiConfiguration);
  final SharedPreferences _sharedPreferences;
  final ApiConfiguration _apiConfiguration;

  String get _baseUrl => _apiConfiguration.baseUrl;

  Future<void> signInWithGoogle() async {
    debugPrint('AuthRepository: signInWithGoogle called');
    await _signInWithProvider('google');
  }

  Future<void> signInWithApple() async {
    debugPrint('AuthRepository: signInWithApple called');
    
    // Native Apple Sign In is only available on iOS and macOS
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      try {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        debugPrint('Apple Credential Obtained: identityToken length: ${credential.identityToken?.length}');

        if (credential.identityToken == null) {
          throw Exception('Apple Identity Token is null');
        }

        // Exchange identityToken for a session on the server
        final url = Uri.parse('$_baseUrl/api/auth/sign-in/social');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'provider': 'apple',
            'idToken': credential.identityToken,
          }),
        );

        debugPrint('Apple Token Exchange Response: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // Handle both top-level token or nested session token
          final token = data['token'] ?? data['session']?['token'];
          
          if (token != null) {
            await saveToken(token);
            debugPrint('Apple Native Sign In Successful & Token Saved');
          } else {
             throw Exception('Token not found in server response');
          }
        } else {
          throw Exception('Apple Token Exchange failed: ${response.body}');
        }
      } catch (e) {
        debugPrint('Error during Native Apple Sign In: $e');
        // Handle cancellation or other errors
        if (e is SignInWithAppleAuthorizationException && e.code == AuthorizationErrorCode.canceled) {
           debugPrint('Apple Sign In canceled by user');
           return;
        }
        rethrow;
      }
    } else {
      // Fallback to browser-based flow on other platforms
      await _signInWithProvider('apple');
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    debugPrint('AuthRepository: signInWithEmailAndPassword called');
    try {
      final url = Uri.parse('$_baseUrl/api/auth/sign-in/email');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      debugPrint('Sign In Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Better-Auth typically returns { session: { token: ... }, user: ... }
        // Adjust extraction based on actual response structure if needed.
        final token = data['token'] ?? data['session']?['token'];
        
        if (token != null) {
          await saveToken(token);
          debugPrint('Email Sign In Successful & Token Saved');
        } else {
             throw Exception('Token not found in response');
        }
      } else {
        throw Exception('Sign in failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error signing in with email: $e');
      rethrow;
    }
  }

  Future<bool> signUpWithEmailAndPassword(String email, String password, String name) async {
    debugPrint('AuthRepository: signUpWithEmailAndPassword called');
    try {
      final url = Uri.parse('$_baseUrl/api/auth/sign-up/email');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      debugPrint('Sign Up Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] ?? data['session']?['token'];
        
        if (token != null) {
          await saveToken(token);
          debugPrint('Sign Up Successful & Token Saved');
          return true; // Auto-login success
        } else {
             // Verification required (OTP sent)
             debugPrint('Sign Up Successful: Verification Required');
             return false; // User needs to verify
        }
      } else {
        String errorMessage = 'Sign up failed';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error']?['message'] ?? response.body;
        } catch (_) {
          errorMessage = response.body;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error signing up: $e');
      if (e is Exception) rethrow;
      throw Exception(e.toString());
    }
  }

  Future<void> sendEmailOtp(String email) async {
    debugPrint('AuthRepository: sendEmailOtp called');
    try {
      final url = Uri.parse('$_baseUrl/api/auth/email-otp/send-verification-otp');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'type': 'email-verification',
        }),
      );

      debugPrint('Send OTP Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('OTP Resent Successfully');
      } else {
         throw Exception('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      rethrow;
    }
  }

  Future<void> verifyEmailOtp(String email, String otp) async {
    debugPrint('AuthRepository: verifyEmailOtp called');
    try {
      final url = Uri.parse('$_baseUrl/api/auth/email-otp/verify-email');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      debugPrint('Verify Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] ?? data['session']?['token'];
        if (token != null) {
          await saveToken(token);
        } else {
           // If plugin doesn't return token, try manual sign-in or check cookie
           debugPrint('Verification success but no token returned. Attempting silent sign-in or checking headers?');
           // For now assume success means verified.
        }
      } else {
         String errorMessage = 'Verification failed';
         try {
            final error = jsonDecode(response.body);
            errorMessage = error['message'] ?? error['body']?['message'] ?? response.body;
         } catch (_) {}
         throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      rethrow;
    }
  }

  Future<void> _signInWithProvider(String provider) async {
    final callbackUrl = Uri.encodeComponent('chiandrose://app/auth/callback');
    // Point to our cleanup shim that handles the POST + Cookie logic in the browser
    final urlString = '$_baseUrl/login/$provider?callbackURL=$callbackUrl';
    
    debugPrint('AuthRepository: Attempting to launch URL via Shim: $urlString');
    final uri = Uri.parse(urlString);
    
    try {
       // We MUST use externalApplication so the Browser (Chrome) holds the cookie, not a temporary WebView
       // (Though platformDefault/CustomTabs often shares cookies, external is safest for debugging state mismatch)
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
           // Fallback
           await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
    } catch (e) {
      debugPrint('Error launching OAuth URL: $e');
      rethrow;
    }
  }

  Future<void> handleDeepLink(Uri uri) async {
    // Expected format: chiandrose://auth/callback?token=... or code=...
    // Adjust based on actual server response.
    // For Better-Auth, we might get a cookie set response, but in external browser.
    // If the server redirects with ?token=xyz, we capture it here.
    
    debugPrint('Received Deep Link: $uri');
    final token = uri.queryParameters['token'];
    
    if (token != null) {
      await _saveToken(token);
      debugPrint('Token captured and saved: $token');
      // Navigate to home or next step (handled by router redirect if auth state changes)
    } else {
      debugPrint('No token found in deep link.');
    }
  }

  Future<void> updateUserName(String name) async {
    debugPrint('AuthRepository: updateUserName called');
    final token = _sharedPreferences.getString('auth_token');
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final url = Uri.parse('$_baseUrl/api/auth/user/update');
      // Better-Auth update user endpoint might be /api/auth/update-user or /api/auth/user/update depending on version?
      // Documentation says: client.updateUser({ name: "..." }) -> POST /update-user
      // Let's try /api/auth/update-user first.
      
      final updateUrl = Uri.parse('$_baseUrl/api/auth/update-user');
      
      final response = await http.post(
        updateUrl,
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
        }),
      );

      debugPrint('Update User Name Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('User Name Updated Successfully');
      } else {
          // If 404, maybe path is wrong.
         throw Exception('Failed to update user name: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating user name: $e');
      rethrow;
    }
  }

  Future<void> saveToken(String token) async {
    await _sharedPreferences.setString('auth_token', token);
    debugPrint('AuthRepository: Token saved to SharedPreferences');
  }

  Future<void> _saveToken(String token) => saveToken(token);
}
