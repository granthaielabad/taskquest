import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/auth/screens/register_screen.dart';
import 'package:taskquest/features/shared/widgets/main_scaffold.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';

import 'package:taskquest/features/auth/screens/forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _obscurePass = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Rebuild on focus change so active border updates
    _emailFocus.addListener(() => setState(() {}));
    _passFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => const MainScaffold(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithEmail(
            _emailController.text.trim(),
            _passController.text.trim(),
          );
      if (mounted) _navigateToHome();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      if (user != null && mounted) {
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Login Failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Logo
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 34,
                    height: 34,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'TaskQuest',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: -0.36,
                      color: AppTheme.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Heading
              Text(
                'Welcome\nback.',
                style: AppTheme.headingXL.copyWith(
                  fontSize: 34,
                  height: 1.05,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Log in to continue your learning quest.',
                style: AppTheme.bodyMono,
              ),
              const SizedBox(height: 32),

              const FieldLabel('Email'),
              const SizedBox(height: 6),
              TQInputField(
                controller: _emailController,
                focusNode: _emailFocus,
                hintText: 'example@gmail.com',
                keyboardType: TextInputType.emailAddress,
                suffixIcon: const Icon(
                  Icons.mail_outline_rounded,
                  size: 16,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 16),

              const FieldLabel('Password'),
              const SizedBox(height: 6),
              TQInputField(
                controller: _passController,
                focusNode: _passFocus,
                hintText: 'password123',
                obscureText: _obscurePass,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscurePass = !_obscurePass),
                  child: Icon(
                    _obscurePass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 16,
                    color: AppTheme.muted,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                    );
                  },
                  child: Text(
                    'Forgot password?',
                    style: AppTheme.bodyMono.copyWith(
                      fontSize: 11,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.muted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              TQButton(
                label: 'Log In',
                isLoading: _isLoading,
                onTap: _login,
              ),
              const SizedBox(height: 20),

              const OrDivider(label: 'OR CONTINUE WITH'),
              const SizedBox(height: 20),

              GoogleButton(onTap: _loginWithGoogle),
              const SizedBox(height: 40),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTheme.bodyMono,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, animation, _) =>
                              const RegisterScreen(),
                          transitionsBuilder:
                              (_, animation, _, child) =>
                                  FadeTransition(
                                      opacity: animation, child: child),
                          transitionDuration:
                              const Duration(milliseconds: 300),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.black,
                          decoration: TextDecoration.underline,
                          decorationColor: AppTheme.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
