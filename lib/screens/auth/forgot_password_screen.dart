import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  int _currentStep = 1; // 1 = Request Email, 2 = Verify Code & Set Password
  bool _isLoading = false;
  bool _isFromLink = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  int _resendCountdown = 60;
  Timer? _timer;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.trim().isNotEmpty) {
      _emailController.text = widget.initialEmail!.trim();
    }
    _listenToAuthRecovery();
  }

  void _listenToAuthRecovery() {
    try {
      final supa = SupabaseService.client;
      if (supa == null) return;
      _authSubscription = supa.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.passwordRecovery) {
          if (mounted) {
            setState(() {
              _currentStep = 2;
              _isFromLink = true;
              _errorMessage = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recovery verified via link! Enter your new password.'),
                backgroundColor: AppColors.lightSecondary,
              ),
            );
          }
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _resendCountdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleSendResetCode() async {
    if (!_emailFormKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await SupabaseService.sendPasswordReset(email);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset code sent to your email. Please check your inbox.'),
          backgroundColor: AppColors.lightSecondary,
        ),
      );

      setState(() {
        _currentStep = 2;
      });
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().toLowerCase();
      String userError;
      if (msg.contains('socket') || msg.contains('network') || msg.contains('failed host')) {
        userError = 'Network error. Please check your internet connection.';
      } else {
        userError = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      }
      setState(() {
        _errorMessage = userError;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _passwordController.text;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isFromLink) {
        final supa = SupabaseService.client;
        if (supa == null) throw Exception('Supabase client is not initialized.');
        await supa.auth.updateUser(UserAttributes(password: newPassword));
        await supa.auth.signOut();
      } else {
        await SupabaseService.resetPasswordWithOtp(
          email: email,
          token: otp,
          newPassword: newPassword,
        );
      }

      if (!mounted) return;

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle_rounded, color: AppColors.lightSecondary, size: 48),
          title: const Text('Password Reset Successful', textAlign: TextAlign.center),
          content: const Text(
            'Your password has been reset successfully.\nYou can now sign in with your new password.',
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  Navigator.pop(context, email); // Return to login with updated email
                },
                child: const Text('Go to Sign In'),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().toLowerCase();
      String userError;
      if (msg.contains('token has expired') || msg.contains('expired')) {
        userError = 'The verification code has expired. Please request a new code.';
      } else if (msg.contains('invalid') || msg.contains('token')) {
        userError = 'Invalid verification code. Please check your email and try again.';
      } else {
        userError = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      }
      setState(() {
        _errorMessage = userError;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Password Recovery'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                if (_currentStep == 2) {
                  setState(() {
                    _currentStep = 1;
                    _errorMessage = null;
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.arrow_back_rounded, color: AppColors.onSurface, size: 19),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _emailFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                size: 38,
                color: AppColors.primaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'پاس ورڈ بحال کریں',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Enter your registered email address below. We will send you a verification code to securely reset your password.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Email Input
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Registered Email Address',
              hintText: 'student@example.com',
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter your email address';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          if (_errorMessage != null) ...[
            _buildErrorBox(_errorMessage!),
            const SizedBox(height: 16),
          ],

          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _isLoading ? null : _handleSendResetCode,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Send Recovery Code',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _resetFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_read_rounded,
                size: 38,
                color: AppColors.primaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Create New Password',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'نیا پاس ورڈ درج کریں',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.4),
              children: [
                const TextSpan(text: 'Enter the verification code sent to\n'),
                TextSpan(
                  text: _emailController.text.trim(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Verified via Link Banner OR OTP Code Input
          if (_isFromLink) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: AppColors.secondary, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Email verified via recovery link! Enter your new password below.',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // OTP Code Input
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 8,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, letterSpacing: 6, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Verification Code (OTP)',
                hintText: '123456',
                counterText: '',
                prefixIcon: const Icon(Icons.pin_outlined),
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              validator: (val) {
                if (_isFromLink) return null;
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter the verification code';
                }
                if (val.trim().length < 6) {
                  return 'Code must be at least 6 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
          ],

          // New Password Input
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'New Password',
              hintText: 'Minimum 6 characters',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please enter your new password';
              }
              if (val.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Confirm New Password Input
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: const Icon(Icons.lock_reset_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            validator: (val) {
              if (val != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          if (_errorMessage != null) ...[
            _buildErrorBox(_errorMessage!),
            const SizedBox(height: 14),
          ],

          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Reset Password & Proceed',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Resend Code
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't receive code? ",
                style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              TextButton(
                onPressed: _resendCountdown > 0 ? null : _handleSendResetCode,
                child: Text(
                  _resendCountdown > 0 ? 'Resend in ${_resendCountdown}s' : 'Resend Code',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBox(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppColors.error, fontSize: 12, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
