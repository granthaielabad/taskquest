import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/screens/register_screen.dart';
import 'package:taskquest/features/auth/screens/forgot_password_screen.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authServiceProvider)
          .signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_seen_onboarding', true);
        ref.read(authTransitionProvider.notifier).setTransitioning(true);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        setState(
          () => _errorMessage =
              "Invalid credentials. If you've signed in with Google before, try that!",
        );
      } else if (e.code == 'account-exists-with-different-credential') {
        setState(
          () => _errorMessage =
              "This email is associated with a different sign-in method. Please use Google.",
        );
      } else {
        setState(() => _errorMessage = e.message ?? "Login failed");
      }
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final credential = await ref.read(authServiceProvider).signInWithGoogle();
      if (credential != null && mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_seen_onboarding', true);
        ref.read(authTransitionProvider.notifier).setTransitioning(true);
      }
    } catch (e) {
      debugPrint('DEBUG: Google Sign-In error: $e');
      setState(() => _errorMessage = 'Google Sign-In failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header Logo (Fixed: No border, larger size)
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 40,
                    height: 40,
                    colorFilter: ColorFilter.mode(
                      colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'TaskQuest',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.5,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // Heading
              Text(
                'Welcome\nback.',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 42,
                  height: 0.9,
                  letterSpacing: -1.5,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Log in to continue your learning quest.',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: colorScheme.error,
                      fontFamily: 'DM Mono',
                      fontSize: 11,
                    ),
                  ),
                ),

              // Form
              const FieldLabel('EMAIL'),
              const SizedBox(height: 6),
              TQInputField(
                controller: _emailController,
                focusNode: _emailFocus,
                hintText: 'example@gmail.com',
                keyboardType: TextInputType.emailAddress,
                suffixIcon: Icon(
                  Icons.mail_outline_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              const FieldLabel('PASSWORD'),
              const SizedBox(height: 6),
              TQInputField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                hintText: 'password123',
                obscureText: _obscurePassword,
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  child: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 11,
                      decoration: TextDecoration.underline,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Login Button
              TQButton(
                label: 'Log In',
                isLoading: _isLoading,
                onTap: _handleLogin,
              ),

              const SizedBox(height: 32),

              // Divider
              const OrDivider(label: 'OR CONTINUE WITH'),

              const SizedBox(height: 32),

              // Google Login
              GoogleButton(onTap: _handleGoogleSignIn, isLoading: _isLoading),

              const SizedBox(height: 48),

              // Sign Up Link
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
