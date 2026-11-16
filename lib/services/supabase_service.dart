import 'dart:io' show Platform, File;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/book_model.dart';
import '../models/chapter_model.dart';
import '../models/content_block_model.dart';

/// Exception thrown when a user attempts to log in with Google, but no account exists yet
class GoogleAuthAccountNotFoundException implements Exception {
  final String email;
  final String? displayName;
  const GoogleAuthAccountNotFoundException({required this.email, this.displayName});

  @override
  String toString() => 'No account found for $email. Please sign up first.';
}

/// Exception thrown when a user attempts to register with Google, but an account already exists
class GoogleAuthAccountAlreadyExistsException implements Exception {
  final String email;
  const GoogleAuthAccountAlreadyExistsException({required this.email});

  @override
  String toString() => 'Account already exists for $email. Please sign in.';
}

class SupabaseService {
  static const String supabaseUrl = 'https://tsqypxgfaajwqcgtfdkq.supabase.co';
  static const String publishableKey =
      'sb_publishable_RQ8BvygKqcRAxmndpRt_OQ_PMtfMF6x';
  static const String webClientId =
      '67778740795-in6rah0ub1tao7j17ge97oi7lfs85ehs.apps.googleusercontent.com';

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

  /// Check whether a user with the given email exists in the system (auth.users or profiles)
  static Future<bool> checkUserExists(String email) async {
    final supa = client;
    if (supa == null) return false;

    final trimmedEmail = email.trim().toLowerCase();
    try {
      final res = await supa.rpc('check_user_exists', params: {
        'lookup_email': trimmedEmail,
      });
      if (res is bool) return res;
      return res == true;
    } catch (e) {
      debugPrint('Error calling check_user_exists RPC, falling back to profiles: $e');
      try {
        final profile = await supa
            .from('profiles')
            .select('id')
            .ilike('email', trimmedEmail)
            .maybeSingle();
        return profile != null;
      } catch (e2) {
        debugPrint('Fallback checkUserExists profiles query error: $e2');
        rethrow;
      }
    }
  }

  /// Sign in or register with Google using native Google Sign-In and exchange ID token with Supabase.
  /// When [isRegisterMode] is false (Login mode):
  ///   Verifies that the account exists before creating a session. If not found,
  ///   throws [GoogleAuthAccountNotFoundException] so UI can prompt to register.
  /// When [isRegisterMode] is true (Register mode):
  ///   Verifies that the account does not already exist. If it already exists,
  ///   throws [GoogleAuthAccountAlreadyExistsException].
  static Future<AuthResponse?> signInWithGoogle({bool isRegisterMode = false}) async {
    final supa = client;
    if (supa == null) {
      throw Exception('Supabase client is not initialized.');
    }

    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
    );

    try {
      await googleSignIn.signOut();
    } catch (_) {}

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // User dismissed or canceled the account picker
      return null;
    }

    // Check if account already exists in Supabase
    final bool exists = await checkUserExists(googleUser.email);

    if (!isRegisterMode && !exists) {
      // User is on Login tab, but account does not exist yet!
      await googleSignIn.signOut();
      throw GoogleAuthAccountNotFoundException(
        email: googleUser.email,
        displayName: googleUser.displayName,
      );
    }

    if (isRegisterMode && exists) {
      // User is on Register tab, but account already exists!
      await googleSignIn.signOut();
      throw GoogleAuthAccountAlreadyExistsException(
        email: googleUser.email,
      );
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final String? idToken = googleAuth.idToken;
    final String? accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw Exception('No ID Token received from Google. Please try again.');
    }

    final response = await supa.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
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
    await supa.auth.resetPasswordForEmail(
      trimmed,
      redirectTo: kIsWeb ? null : 'io.supabase.flutter://reset-callback',
    );
  }

  /// Verify password recovery OTP and update password
  static Future<void> resetPasswordWithOtp({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    final supa = client;
    if (supa == null) {
      throw Exception('Supabase client is not initialized.');
    }
    if (newPassword.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    // 1. Verify the recovery token / OTP with OtpType.recovery
    final response = await supa.auth.verifyOTP(
      email: email.trim(),
      token: token.trim(),
      type: OtpType.recovery,
    );

    if (response.session == null && response.user == null) {
      throw Exception('Invalid or expired verification code.');
    }

    // 2. Set the new password
    await supa.auth.updateUser(
      UserAttributes(password: newPassword),
    );

    // 3. Sign out the recovery session so the user logs in fresh
    await supa.auth.signOut();
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

  /// Sign out current user from Supabase and Google
  static Future<void> signOut() async {
    final supa = client;
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (_) {}
    if (supa == null) return;
    await supa.auth.signOut();
  }

  // ==========================================
  // TEXTBOOK & CURRICULUM DATABASE METHODS
  // ==========================================

  /// Fetch all published educational books and guides from Supabase
  static Future<List<Book>> fetchPublishedBooks({int? classNumber}) async {
    final supa = client;
    if (supa == null) return [];

    try {
      var queryBuilder = supa
          .from('books')
          .select()
          .eq('publication_status', 'published');

      if (classNumber != null) {
        queryBuilder = queryBuilder.eq('class_number', classNumber);
      }

      final rows = await queryBuilder.order('class_number').order('created_at', ascending: false);
      final List<Book> books = [];

      for (final r in rows) {
        final bMap = Map<String, dynamic>.from(r);
        final bookId = bMap['id']?.toString() ?? '';

        // Fetch chapters for this book
        final chRows = await supa
            .from('chapters')
            .select()
            .eq('book_id', bookId)
            .order('chapter_number', ascending: true);

        final List<Chapter> chapters = [];
        for (final c in chRows) {
          chapters.add(Chapter.fromJson(Map<String, dynamic>.from(c)));
        }

        books.add(Book.fromJson(bMap, loadedChapters: chapters));
      }

      return books;
    } catch (e) {
      debugPrint('Error fetching published books from Supabase: $e');
      return [];
    }
  }

  /// Fetch rich content blocks for a specific chapter
  static Future<List<ContentBlock>> fetchChapterContentBlocks(String chapterId) async {
    final supa = client;
    if (supa == null) return [];

    try {
      // Find all topics in this chapter
      final topics = await supa
          .from('topics')
          .select('id')
          .eq('chapter_id', chapterId)
          .order('display_order', ascending: true);

      final List<String> topicIds = topics.map((t) => t['id'].toString()).toList();
      if (topicIds.isEmpty) return [];

      final blocks = await supa
          .from('content_blocks')
          .select()
          .inFilter('topic_id', topicIds)
          .order('display_order', ascending: true);

      return blocks.map((b) => ContentBlock.fromJson(Map<String, dynamic>.from(b))).toList();
    } catch (e) {
      debugPrint('Error fetching chapter content blocks: $e');
      return [];
    }
  }

  /// Sync reading progress to user account in database
  static Future<void> syncReadingProgress({
    required String bookId,
    required int pageNumber,
    String? chapterId,
  }) async {
    final supa = client;
    final user = currentUser;
    if (supa == null || user == null) return;

    try {
      await supa.from('reading_progress').upsert({
        'user_id': user.id,
        'book_id': bookId,
        'last_read_page': pageNumber,
        'last_read_chapter_id': chapterId,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id,book_id');
    } catch (e) {
      debugPrint('Note syncing reading progress: $e');
    }
  }

  /// Sync bookmark to user account in database
  static Future<void> syncBookmark({
    required String bookId,
    required int pageNumber,
    required bool isBookmarked,
    String? chapterId,
  }) async {
    final supa = client;
    final user = currentUser;
    if (supa == null || user == null) return;

    try {
      if (isBookmarked) {
        await supa.from('reading_bookmarks').upsert({
          'user_id': user.id,
          'book_id': bookId,
          'page_number': pageNumber,
          'chapter_id': chapterId,
        }, onConflict: 'user_id,book_id,page_number');
      } else {
        await supa
            .from('reading_bookmarks')
            .delete()
            .match({'user_id': user.id, 'book_id': bookId, 'page_number': pageNumber});
      }
    } catch (e) {
      debugPrint('Note syncing bookmark: $e');
    }
  }
}
