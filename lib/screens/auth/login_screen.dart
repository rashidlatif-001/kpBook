import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

import '../../theme/app_colors.dart';
import '../main_shell.dart';
import 'forgot_password_screen.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoginMode = true; // true = Login, false = Register
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLoginMode) {
        // Sign In
        final response = await SupabaseService.signIn(
          email: email,
          password: password,
        );

        if (!mounted) return;

        if (response.session != null || response.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome back! خوش آمدید'),
              backgroundColor: AppColors.lightSecondary,
            ),
          );

          // Direct persistent login to MainShell
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainShell()),
          );
        }
      } else {
        // Sign Up / Register
        final fullName = _nameController.text.trim();
        final response = await SupabaseService.signUp(
          email: email,
          password: password,
          fullName: fullName.isNotEmpty ? fullName : null,
        );

        if (!mounted) return;

        // If email confirmation is required, navigate to OTP screen
        if (response.session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification code sent! Please check your email.'),
              backgroundColor: AppColors.lightSecondary,
            ),
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(email: email),
            ),
          );
        } else {
          // If auto-confirmed by Supabase
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created! Welcome to KPK E-Textbooks.'),
              backgroundColor: AppColors.lightSecondary,
            ),
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainShell()),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().toLowerCase();
      String userFriendlyError;
      if (msg.contains('socket') || msg.contains('failed host lookup') || msg.contains('network') || msg.contains('clientexception')) {
        userFriendlyError = 'Internet connection error. Please check your data or Wi-Fi.\nانٹرنیٹ کنکشن چیک کریں۔';
      } else if (msg.contains('already registered') || msg.contains('user already exists')) {
        userFriendlyError = 'This email is already registered. Please Sign In.\nیہ ای میل پہلے سے رجسٹرڈ ہے، براہ کرم لاگ ان کریں۔';
      } else if (msg.contains('invalid login credentials') || msg.contains('invalid credentials')) {
        userFriendlyError = 'Incorrect email or password. Please check your credentials.\nغلط ای میل یا پاس ورڈ۔';
      } else {
        userFriendlyError = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      }
      setState(() {
        _errorMessage = userFriendlyError;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await SupabaseService.signInWithGoogle(
        isRegisterMode: !_isLoginMode,
      );
      if (!mounted) return;

      if (response == null) {
        // User dismissed the account selection dialog
        return;
      }

      if (response.session != null || response.user != null) {
        final successMessage = _isLoginMode
            ? 'Welcome back! Google Sign-In successful. خوش آمدید'
            : 'Account created with Google! Welcome to KPK E-Textbooks.\nگوگل سے نیا اکاؤنٹ بن گیا ہے۔ خوش آمدید';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: AppColors.secondary,
          ),
        );

        // Direct persistent navigation to MainShell Dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    } on GoogleAuthAccountNotFoundException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoginMode = false; // Switch to Register mode
        if (_nameController.text.isEmpty && e.displayName != null) {
          _nameController.text = e.displayName!;
        }
        if (_emailController.text.isEmpty) {
          _emailController.text = e.email;
        }
        _errorMessage =
            'No account found with this Google email. Please Sign Up first.\nاس گوگل ای میل سے کوئی اکاؤنٹ نہیں ملا۔ براہ کرم پہلے سائن اپ کریں۔';
      });
    } on GoogleAuthAccountAlreadyExistsException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoginMode = true; // Switch to Sign In mode
        if (_emailController.text.isEmpty) {
          _emailController.text = e.email;
        }
        _errorMessage =
            'This Google email is already registered. Please Sign In.\nیہ گوگل ای میل پہلے سے رجسٹرڈ ہے۔ براہ کرم لاگ ان کریں۔';
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().toLowerCase();
      String userFriendlyError;
      if (msg.contains('socket') ||
          msg.contains('failed host lookup') ||
          msg.contains('network') ||
          msg.contains('clientexception')) {
        userFriendlyError =
            'Internet connection error. Please check your data or Wi-Fi.\nانٹرنیٹ کنکشن چیک کریں۔';
      } else if (msg.contains('canceled') ||
          msg.contains('cancelled') ||
          msg.contains('sign_in_canceled')) {
        userFriendlyError = 'Google Sign-In was cancelled.';
      } else {
        userFriendlyError =
            e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      }
      setState(() {
        _errorMessage = userFriendlyError;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
          _isLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordDialog() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(
          initialEmail: _emailController.text.trim(),
        ),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _emailController.text = result;
        _isLoginMode = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight > 48 ? constraints.maxHeight - 48 : constraints.maxHeight,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // KPK App Logo
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.18),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                border: Border.all(color: AppColors.cardBorder, width: 1.5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  'assets/images/app_logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Title
                          Text(
                            'KPK E-Textbooks',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: AppColors.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'خیبر پختونخوا ای-ٹیکسٹ بکس پورٹل',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryContainer,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          // Mode Toggle (Login vs Register)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.cardBorder, width: 1),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isLoginMode = true;
                                        _errorMessage = null;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _isLoginMode ? AppColors.surfaceContainerLowest : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: _isLoginMode
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.05),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        'Sign In (لاگ ان)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: _isLoginMode ? FontWeight.bold : FontWeight.w500,
                                          color: _isLoginMode ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isLoginMode = false;
                                        _errorMessage = null;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: !_isLoginMode ? AppColors.surfaceContainerLowest : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: !_isLoginMode
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.05),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        'Register (نیا اکاؤنٹ)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: !_isLoginMode ? FontWeight.bold : FontWeight.w500,
                                          color: !_isLoginMode ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Full Name (Only in Register Mode)
                          if (!_isLoginMode) ...[
                            TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: 'Full Name / نام',
                                hintText: 'e.g. Ahmad Khan',
                                prefixIcon: const Icon(Icons.person_outline),
                                filled: true,
                                fillColor: AppColors.surfaceContainerLowest,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              validator: (val) {
                                if (!_isLoginMode && (val == null || val.trim().isEmpty)) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                          ],

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Address / ای میل',
                              hintText: 'student@example.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: AppColors.surfaceContainerLowest,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val.trim())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Password',
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
                                return 'Please enter your password';
                              }
                              if (val.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          // Confirm Password (Only in Register Mode) with matching validation
                          if (!_isLoginMode) ...[
                            const SizedBox(height: 14),
                            Builder(builder: (context) {
                              final bool isMismatch = _confirmPasswordController.text.isNotEmpty &&
                                  _confirmPasswordController.text != _passwordController.text;
                              return TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: const Icon(Icons.lock_reset_outlined),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    ),
                                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surfaceContainerLowest,
                                  enabledBorder: isMismatch
                                      ? const UnderlineInputBorder(
                                          borderSide: BorderSide(color: AppColors.lightError, width: 2.2),
                                        )
                                      : OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                  focusedBorder: isMismatch
                                      ? const UnderlineInputBorder(
                                          borderSide: BorderSide(color: AppColors.lightError, width: 2.5),
                                        )
                                      : OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(color: AppColors.primaryContainer, width: 1.5),
                                        ),
                                  helperText: isMismatch ? 'Passwords do not match yet' : null,
                                  helperStyle: TextStyle(color: AppColors.error, fontSize: 11),
                                ),
                                validator: (val) {
                                  if (!_isLoginMode && val != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              );
                            }),
                          ],

                          // Forgot Password Link (Only in Login Mode)
                          if (_isLoginMode) ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryContainer,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 18),
                          ],

                          // Error Message Banner
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(color: AppColors.error, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Action Button
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primaryContainer,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: (_isLoading && !_isGoogleLoading)
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      _isLoginMode ? 'Sign In' : 'Register & Get OTP',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Divider with "OR / یا"
                          Row(
                            children: [
                              Expanded(child: Divider(color: AppColors.cardBorder, thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'OR / یا',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: AppColors.cardBorder, thickness: 1)),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // Continue with Google Button (Available in both Login and Register modes)
                          SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _handleGoogleSignIn,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.surfaceContainerLowest,
                                side: BorderSide(color: AppColors.cardBorder, width: 1.2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: _isGoogleLoading
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryContainer,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildGoogleLogo(),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          child: Text(
                                            _isLoginMode
                                                ? 'Continue with Google'
                                                : 'Sign Up with Google',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGoogleLogo() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

/// Pixel-perfect 4-color Google "G" vector painter
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double r = w / 2;
    final double strokeWidth = w * 0.22;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r - strokeWidth / 2);

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Red arc (Top)
    canvas.drawArc(rect, -2.356, 1.57, false, redPaint);
    // Yellow arc (Left)
    canvas.drawArc(rect, -3.927, 1.57, false, yellowPaint);
    // Green arc (Bottom)
    canvas.drawArc(rect, 0.785, 1.57, false, greenPaint);
    // Blue arc (Right)
    canvas.drawArc(rect, -0.785, 1.57, false, bluePaint);

    // Blue horizontal crossbar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final barRect = Rect.fromLTWH(cx - w * 0.05, cy - strokeWidth / 2, w * 0.55, strokeWidth);
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
