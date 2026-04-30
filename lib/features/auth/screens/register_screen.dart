import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/screens/login_screen.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_agreeToTerms) {
      setState(() => _errorMessage = 'Please agree to the Terms & Privacy');
      return;
    }

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
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
          .signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_seen_onboarding', true);
        ref.read(authTransitionProvider.notifier).setTransitioning(true);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(
          () => _errorMessage =
              "Email already exists. You can log in or use Google to link this account.",
        );
      } else {
        setState(() => _errorMessage = e.message ?? "Registration failed");
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        Icon(
                          Icons.chevron_left_rounded,
                          color: colorScheme.onSurface,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 12,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 40,
                    height: 40,
                    colorFilter: ColorFilter.mode(
                      colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Heading
              Text(
                'Create\nAccount.',
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
                'Join thousands of CS students on their quest.',
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
              const FieldLabel('FULL NAME'),
              const SizedBox(height: 6),
              TQInputField(
                controller: _nameController,
                focusNode: _nameFocus,
                hintText: 'John Doe',
                suffixIcon: Icon(
                  Icons.person_outline_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

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
                hintText: 'min. 8 characters',
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

              const SizedBox(height: 24),

              // Terms & Privacy
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _agreeToTerms,
                      onChanged: (v) =>
                          setState(() => _agreeToTerms = v ?? false),
                      activeColor: colorScheme.onSurface,
                      checkColor: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Register Button
              TQButton(
                label: 'Sign Up',
                isLoading: _isLoading,
                onTap: _handleRegister,
              ),

              const SizedBox(height: 32),

              // Divider
              const OrDivider(label: 'OR CONTINUE WITH'),

              const SizedBox(height: 32),

              // Google Login
              GoogleButton(onTap: _handleGoogleSignIn, isLoading: _isLoading),

              const SizedBox(height: 48),

              // Login Link
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
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
                        const TextSpan(text: "Already have an account? "),
                        TextSpan(
                          text: 'Log In',
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
