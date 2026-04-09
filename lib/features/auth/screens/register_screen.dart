import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';

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
    if (p.contains(RegExp(r'[0-9]')) && p.contains(RegExp(r'[^A-Za-z0-9]'))) {
      score++;
    }
    return score;
  }

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 1:
        return 'Weak password';
      case 2:
        return 'Medium password';
      case 3:
        return 'Strong password';
      default:
        return '';
    }
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
      case 1:
        return const Color(0xFFE55555);
      case 2:
        return const Color(0xFFE5A000);
      case 3:
        return AppTheme.black;
      default:
        return AppTheme.borderLight;
    }
  }

  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    ref.read(authTransitionProvider.notifier).setTransitioning(true);
    try {
      final cred = await ref
          .read(authServiceProvider)
          .signUpWithEmail(
            _emailController.text.trim(),
            _passController.text.trim(),
          );

      if (cred.user != null) {
        debugPrint('RegisterScreen: Auth successful, updating display name...');
        // 1. Update Firebase Auth internal profile
        await cred.user!.updateDisplayName(_nameController.text.trim());

        // 2. Force a reload to ensure the local user object is updated
        await cred.user!.reload();

        debugPrint('RegisterScreen: Creating Firestore profile...');
        // 3. Create the Firestore document explicitly with the name from the controller
        await ref
            .read(userServiceProvider)
            .checkAndCreateProfile(
              cred.user!.uid,
              cred.user!.email!,
              _nameController.text.trim(),
            );
        debugPrint('RegisterScreen: Handshake complete.');
      }
    } catch (e) {
      if (mounted) {
        ref.read(authTransitionProvider.notifier).setTransitioning(false);
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
    ref.read(authTransitionProvider.notifier).setTransitioning(true);
    try {
      final cred = await ref.read(authServiceProvider).signInWithGoogle();
      if (cred?.user != null) {
        await ref
            .read(userServiceProvider)
            .checkAndCreateProfile(
              cred!.user!.uid,
              cred.user!.email!,
              cred.user!.displayName ?? 'Scholar',
            );
      } else {
        ref.read(authTransitionProvider.notifier).setTransitioning(false);
      }
    } catch (e) {
      if (mounted) {
        ref.read(authTransitionProvider.notifier).setTransitioning(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-up Failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
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
                    const Icon(
                      Icons.chevron_left_rounded,
                      size: 18,
                      color: AppTheme.black,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Back',
                      style: AppTheme.bodyMono.copyWith(
                        color: AppTheme.black,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Create your\naccount.',
                style: AppTheme.headingXL.copyWith(
                  fontSize: 34,
                  height: 1.05,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start your CS learning journey today.',
                style: AppTheme.bodyMono,
              ),
              const SizedBox(height: 32),
              const FieldLabel('Full Name'),
              const SizedBox(height: 6),
              TQInputField(
                controller: _nameController,
                focusNode: _nameFocus,
                hintText: 'Charlie',
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                suffixIcon: const Icon(
                  Icons.person_outline_rounded,
                  size: 16,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 16),
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
                hintText: 'Str0ng#Pass',
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
              if (_passController.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: List.generate(3, (i) {
                    final filled = i < _passwordStrength;
                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: filled ? _strengthColor : AppTheme.borderLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                Text(
                  _strengthLabel,
                  style: AppTheme.labelMono.copyWith(
                    color: _strengthColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              TQButton(
                label: 'Create Account',
                isLoading: _isLoading,
                onTap: _register,
              ),
              const SizedBox(height: 20),
              const OrDivider(label: 'OR SIGN UP WITH'),
              const SizedBox(height: 20),
              GoogleButton(
                onTap: _registerWithGoogle,
                label: 'Sign up with Google',
              ),
              const SizedBox(height: 40),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: AppTheme.bodyMono,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.black,
                          decoration: TextDecoration.underline,
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
