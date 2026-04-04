import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/shared/widgets/main_scaffold.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _obscurePass = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() => setState(() {}));
    _emailFocus.addListener(() => setState(() {}));
    _passFocus.addListener(() => setState(() {}));
    _passController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  int get _passwordStrength {
    final p = _passController.text;
    if (p.isEmpty) return 0;
    int score = 0;
    if (p.length >= 8) score++;
    if (p.contains(RegExp(r'[A-Z]')) && p.contains(RegExp(r'[a-z]'))) score++;
    if (p.contains(RegExp(r'[0-9]')) && p.contains(RegExp(r'[^A-Za-z0-9]'))) score++;
    return score;
  }

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 1: return 'Weak password';
      case 2: return 'Medium password';
      case 3: return 'Strong password';
      default: return '';
    }
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
      case 1: return const Color(0xFFE55555);
      case 2: return const Color(0xFFE5A000);
      case 3: return AppTheme.black;
      default: return AppTheme.border;
    }
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

  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signUpWithEmail(
            _emailController.text.trim(),
            _passController.text.trim(),
          );
      if (mounted) _navigateToHome();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _registerWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      if (user != null && mounted) {
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-up Failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showTermsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LegalModal(
        title: 'Terms of Service',
        content: '1. Introduction\nWelcome to TaskQuest. By using our app, you agree to these terms.\n\n2. User Accounts\nYou are responsible for maintaining the security of your account.\n\n3. Acceptable Use\nYou must not use the Service for any illegal purpose.',
      ),
    );
  }

  void _showPrivacyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LegalModal(
        title: 'Privacy Policy',
        content: '1. Data Collection\nWe collect information you provide directly to us.\n\n2. Use of Data\nWe use the information to improve our services.',
      ),
    );
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
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chevron_left_rounded, size: 18, color: AppTheme.black),
                    const SizedBox(width: 2),
                    Text('Back', style: AppTheme.bodyMono.copyWith(color: AppTheme.black, letterSpacing: 0.3)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text('Create your\naccount.', style: AppTheme.headingXL.copyWith(fontSize: 34, height: 1.05, letterSpacing: -1.0)),
              const SizedBox(height: 12),
              Text('Start your CS learning journey today.', style: AppTheme.bodyMono),
              const SizedBox(height: 32),
              const FieldLabel('Full Name'),
              const SizedBox(height: 6),
              TQInputField(
                controller: _nameController,
                focusNode: _nameFocus,
                hintText: 'Charlie',
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                suffixIcon: const Icon(Icons.person_outline_rounded, size: 16, color: AppTheme.muted),
              ),
              const SizedBox(height: 16),
              const FieldLabel('Email'),
              const SizedBox(height: 6),
              TQInputField(
                controller: _emailController,
                focusNode: _emailFocus,
                hintText: 'example@gmail.com',
                keyboardType: TextInputType.emailAddress,
                suffixIcon: const Icon(Icons.mail_outline_rounded, size: 16, color: AppTheme.muted),
              ),
              const SizedBox(height: 16),
              const FieldLabel('Password'),
              const SizedBox(height: 6),
              TQInputField(
                controller: _passController,
                focusNode: _passFocus,
                hintText: 'Str0ng#Pass',
                obscureText: _obscurePass,
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscurePass = !_obscurePass),
                  child: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16, color: AppTheme.muted),
                ),
              ),
              if (_passController.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: List.generate(3, (i) {
                    final filled = i < _passwordStrength;
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                        decoration: BoxDecoration(color: filled ? _strengthColor : AppTheme.border, borderRadius: BorderRadius.circular(2)),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Text(_strengthLabel, style: AppTheme.labelMono.copyWith(color: _strengthColor, letterSpacing: 0.3)),
              ],
              const SizedBox(height: 24),
              TQButton(label: 'Create Account', isLoading: _isLoading, onTap: _register),
              const SizedBox(height: 20),
              const OrDivider(label: 'OR SIGN UP WITH'),
              const SizedBox(height: 20),
              GoogleButton(onTap: _registerWithGoogle, label: 'Sign up with Google'),
              const SizedBox(height: 24),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTheme.bodyMono.copyWith(fontSize: 11, height: 1.6),
                    children: [
                      const TextSpan(text: 'By creating an account, you agree to our\n'),
                      TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(color: AppTheme.black, decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()..onTap = _showTermsModal,
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(color: AppTheme.black, decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()..onTap = _showPrivacyModal,
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Already have an account? ', style: AppTheme.bodyMono),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Log In', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.black, decoration: TextDecoration.underline)),
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

class _LegalModal extends StatelessWidget {
  final String title;
  final String content;
  const _LegalModal({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.dimmed, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Text(title, style: AppTheme.headingL),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(content, style: AppTheme.bodyMono.copyWith(height: 1.6)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: TQButton(label: 'Got it', isLoading: false, onTap: () => Navigator.pop(context)),
          ),
        ],
      ),
    );
  }
}
