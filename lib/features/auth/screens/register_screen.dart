import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/main_scaffold.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _register() {
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
          padding:
          const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
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
                'Create your\naccount.',
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
                'Start your quest. It only takes a minute.',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 12,
                  color: AppTheme.muted,
                ),
              ),
              const SizedBox(height: 32),

              // ── Form fields ───────────────────────────────────
              _buildField('Username', _nameController,
                  TextInputType.text),
              const SizedBox(height: 12),
              _buildField('Email', _emailController,
                  TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildField('Password', _passController,
                  TextInputType.visiblePassword,
                  obscure: true),
              const SizedBox(height: 20),

              // ── Create Account button ─────────────────────────
              ElevatedButton(
                onPressed: _register,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Create Account',
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
              const SizedBox(height: 24),

              // ── Login link ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 11,
                      color: AppTheme.muted,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Log In',
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

  Widget _buildField(
      String label,
      TextEditingController ctrl,
      TextInputType type, {
        bool obscure = false,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 10,
            letterSpacing: 1.4,
            color: AppTheme.muted,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: ctrl,
            obscureText: obscure,
            keyboardType: type,
            style: const TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 13,
              color: AppTheme.black,
            ),
            decoration: InputDecoration(
              hintText: label,
              hintStyle:
              const TextStyle(color: AppTheme.dimmed),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 17, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}