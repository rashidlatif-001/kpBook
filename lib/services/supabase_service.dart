import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://tsqypxgfaajwqcgtfdkq.supabase.co';
  static const String publishableKey =
      'sb_publishable_RQ8BvygKqcRAxmndpRt_OQ_PMtfMF6x';

  /// Initializes the Supabase client.
  static Future<void> initialize() async {
    // Skip remote initialization during automated widget/unit test runs
    final bool isTestEnv =
        !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (isTestEnv) {
      debugPrint('Running under FLUTTER_TEST: Supabase init skipped for tests.');
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: publishableKey,
      );
      debugPrint('Supabase initialized successfully for KPK Books.');
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
    }
  }

  /// Returns the global Supabase client instance if initialized.
  static SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // AUTHENTICATION HELPERS
  // ==========================================

  /// Check whether a user is currently logged in with a valid session
  static bool get isAuthenticated {
    final supa = client;
    if (supa == null) return false;
    return supa.auth.currentSession != null;
  }

  /// Current logged-in user
  static User? get currentUser => client?.auth.currentUser;

  /// Current user's email
  static String? get userEmail => currentUser?.email;

  /// Current user's full name from metadata
  static String get userName {
    final user = currentUser;
    if (user == null) return 'Student';
    final metadata = user.userMetadata;
    if (metadata != null && metadata.containsKey('full_name')) {
      final name = metadata['full_name'] as String?;
      if (name != null && name.trim().isNotEmpty) return name;
    }
    return user.email?.split('@').first ?? 'Student';
  }

  /// Register new user with email and password, sending an OTP verification
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final supa = client;
    if (supa == null) {
      throw Exception('Supabase client is not initialized.');
    }
    return await supa.auth.signUp(
      email: email.trim(),
      password: password,
      data: fullName != null ? {'full_name': fullName.trim()} : null,
    );
  }

  /// Verify signup OTP / email confirmation token
  static Future<AuthResponse> verifySignupOtp({
    required String email,
    required String token,
  }) async {
    final supa = client;
    if (supa == null) {
      throw Exception('Supabase client is not initialized.');
    }
    return await supa.auth.verifyOTP(
      email: email.trim(),
      token: token.trim(),
      type: OtpType.signup,
    );
  }

  /// Resend signup confirmation OTP
  static Future<void> resendSignupOtp(String email) async {
    final supa = client;
    if (supa == null) {
      throw Exception('Supabase client is not initialized.');
    }
    await supa.auth.resend(
      email: email.trim(),
      type: OtpType.signup,
    );
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final supa = client;
    if (supa == null) {
      throw Exception('Supabase client is not initialized.');
    }
    return await supa.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Send password reset email
  static Future<void> sendPasswordReset(String email) async {
    final supa = client;
    if (supa == null) {
      throw Exception('Supabase client is not initialized.');
    }
    await supa.auth.resetPasswordForEmail(email.trim());
  }

  /// Sign out current user
  static Future<void> signOut() async {
    final supa = client;
    if (supa == null) return;
    await supa.auth.signOut();
  }

  // ==========================================
  // STORAGE HELPERS
  // ==========================================

  /// Helper to get public URL for a textbook PDF from Supabase Storage bucket 'books'.
  static String? getBookPdfUrl(String fileName, {String bucket = 'books'}) {
    try {
      final supaClient = client;
      if (supaClient == null) return null;
      return supaClient.storage.from(bucket).getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Error getting book public URL: $e');
      return null;
    }
  }
}
