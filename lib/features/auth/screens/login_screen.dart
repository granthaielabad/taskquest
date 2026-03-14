import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/main_scaffold.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'example@gmail.com');
  final _passController = TextEditingController(text: 'password123');
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _login() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScaffold()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // ── Logo ─────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppTheme.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bolt,
                        color: Colors.white, size: 18),
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

              // ── Heading ──────────────────────────────────────
              const Text(
                'Welcome\nback.',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  letterSpacing: -0.84,
                  color: AppTheme.black,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Log in to continue your learning quest.',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 12,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 32),

              // ── Email field ───────────────────────────────────
              _FieldLabel('Email'),
              const SizedBox(height: 5),
              _InputField(
                controller: _emailController,
                hintText: 'your@email.com',
                keyboardType: TextInputType.emailAddress,
                hasFocus: true,
                suffixIcon: const Icon(
                  Icons.mail_outline,
                  color: AppTheme.muted,
                  size: 16,
                ),
              ),
              const SizedBox(height: 12),

              // ── Password field ────────────────────────────────
              _FieldLabel('Password'),
              const SizedBox(height: 5),
              _InputField(
                controller: _passController,
                hintText: '••••••••',
                obscureText: _obscurePass,
                suffixIcon: GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePass = !_obscurePass),
                  child: Icon(
                    _obscurePass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppTheme.muted,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Forgot password ───────────────────────────────
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    color: AppTheme.muted,
                    decoration: TextDecoration.underline,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Log In button ─────────────────────────────────
              ElevatedButton(
                onPressed: _login,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Log In',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward,
                        color: Colors.white, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Divider ───────────────────────────────────────
              const Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR CONTINUE WITH',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: AppTheme.dimmed,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: AppTheme.border)),
                ],
              ),
              const SizedBox(height: 16),

              // ── Google button ─────────────────────────────────
              OutlinedButton(
                onPressed: _login,
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppTheme.white,
                  side: const BorderSide(color: AppTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.g_mobiledata_rounded,
                        color: AppTheme.black, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 12,
                        color: AppTheme.black,
                        letterSpacing: 0.48,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Sign up link ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 11,
                      color: AppTheme.muted,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppTheme.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable field label ──────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'DM Mono',
        fontSize: 10,
        letterSpacing: 1.4,
        color: AppTheme.muted,
      ),
    );
  }
}

// ── Reusable input field ──────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool hasFocus;

  const _InputField({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.hasFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(
          color: hasFocus ? AppTheme.black : AppTheme.border,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 13,
          color: AppTheme.black,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppTheme.dimmed),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 17, vertical: 16),
          suffixIcon: suffixIcon != null
              ? Padding(
            padding: const EdgeInsets.only(right: 14),
            child: suffixIcon,
          )
              : null,
          suffixIconConstraints:
          const BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    );
  }
}