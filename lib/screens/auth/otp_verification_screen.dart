import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_colors.dart';
import '../main_shell.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
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

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await SupabaseService.verifySignupOtp(
        email: widget.email,
        token: otp,
      );

      if (!mounted) return;

      if (response.session != null || response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification successful! Welcome to KPK E-Textbooks.'),
            backgroundColor: AppColors.secondary,
          ),
        );

        // Direct login to MainShell
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid code. Please check your email and try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0) return;

    setState(() => _isLoading = true);
    try {
      await SupabaseService.resendSignupOtp(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A new verification code has been sent to your email.'),
          backgroundColor: AppColors.secondary,
        ),
      );
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not resend: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Email Verification / تصدیق'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  size: 40,
                  color: AppColors.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verify Your Email Address',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'ای میل کی تصدیق کا کوڈ درج کریں',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryContainer,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit verification code to\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // OTP Input Field
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder, width: 1.2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 10,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    hintText: '• • • • • •',
                    hintStyle: TextStyle(
                      fontSize: 24,
                      letterSpacing: 8,
                      color: AppColors.outlineVariant,
                    ),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 28),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleVerify,
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Confirm & Enter App / تصدیق کریں',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Resend Option
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the code? ",
                    style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                  ),
                  TextButton(
                    onPressed: _resendCountdown > 0 ? null : _handleResend,
                    child: Text(
                      _resendCountdown > 0 ? 'Resend in ${_resendCountdown}s' : 'Resend Code',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _resendCountdown > 0 ? AppColors.outline : AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Alternative: Back to login if verified via link
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text(
                  'Clicked link in email? Go to Sign In / لاگ ان کریں',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

