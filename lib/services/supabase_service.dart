import 'dart:io' show Platform, File;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://tsqypxgfaajwqcgtfdkq.supabase.co';
  static const String publishableKey =
      'sb_publishable_RQ8BvygKqcRAxmndpRt_OQ_PMtfMF6x';

  /// Initializes the Supabase client.
  static Future<void> initialize() async {
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

  /// Current user's avatar URL from user metadata
  static String? get userAvatarUrl {
    final user = currentUser;
    if (user == null) return null;
    final metadata = user.userMetadata;
    return metadata?['avatar_url'] as String?;
  }

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
    final response = await supa.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    if (response.session != null || response.user != null) {
      recordLoginActivity();
    }

    return response;
  }

  /// Record mobile login activity session in database for Admin Dashboard
  static Future<void> recordLoginActivity({String status = 'success'}) async {
    try {
      final supa = client;
      final user = currentUser;
      if (supa == null || user == null) return;

      String device = 'Mobile App';
      try {
        if (!kIsWeb) {
          device = '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
        } else {
          device = 'Web Client';
        }
      } catch (_) {}

      await supa.from('login_activity').insert({
        'user_id': user.id,
        'user_email': user.email ?? '',
        'user_name': userName,
        'device_info': device,
        'status': status,
      });
    } catch (e) {
      debugPrint('Notice: login_activity recording: $e');
    }
  }

  /// Update user full name in Supabase auth and profiles table
  static Future<void> updateUserName(String newName) async {
    final supa = client;
    final user = currentUser;
    if (supa == null || user == null) {
      throw Exception('User is not signed in.');
    }

    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw Exception('Name cannot be empty.');
    }

    // 1. Update Auth user metadata
    await supa.auth.updateUser(
      UserAttributes(data: {'full_name': trimmed}),
    );

    // 2. Update profiles table
    try {
      await supa.from('profiles').update({'full_name': trimmed}).eq('id', user.id);
    } catch (e) {
      debugPrint('Profile table update note: $e');
    }
  }

  /// Update user password
  static Future<void> updatePassword(String newPassword) async {
    final supa = client;
    if (supa == null || currentUser == null) {
      throw Exception('User is not signed in.');
    }

    if (newPassword.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    await supa.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Send password reset email
  static Future<void> sendPasswordReset(String email) async {
    final supa = client;
    if (supa == null) {
      throw Exception('Supabase client is not initialized.');
    }
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      throw Exception('Please enter an email address.');
    }
    await supa.auth.resetPasswordForEmail(trimmed);
  }

  /// Upload or update profile avatar image
  static Future<String?> uploadProfileImage(File imageFile) async {
    final supa = client;
    final user = currentUser;
    if (supa == null || user == null) return null;

    try {
      final ext = imageFile.path.split('.').last;
      final fileName = '${user.id}_avatar.$ext';
      final storagePath = 'avatars/$fileName';

      // Upload file to Supabase storage bucket
      await supa.storage.from('avatars').upload(
            storagePath,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = supa.storage.from('avatars').getPublicUrl(storagePath);

      // Save public URL in user metadata
      await supa.auth.updateUser(
        UserAttributes(data: {'avatar_url': publicUrl}),
      );

      return publicUrl;
    } catch (e) {
      debugPrint('Avatar upload note (falling back to local): $e');
      return null;
    }
  }

  /// Fetch broadcast updates published from admin dashboard
  static Future<List<Map<String, dynamic>>> fetchAppUpdates() async {
    final supa = client;
    if (supa == null) return [];

    try {
      final data = await supa
          .from('app_updates')
          .select()
          .order('created_at', ascending: false)
          .limit(20);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Notice fetching updates: $e');
      return [];
    }
  }

  /// Sign out current user
  static Future<void> signOut() async {
    final supa = client;
    if (supa == null) return;
    await supa.auth.signOut();
  }
}
