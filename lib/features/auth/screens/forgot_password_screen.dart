import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).sendPasswordReset(email);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
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
              const SizedBox(height: 16),

              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 18,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 12,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Heading
              Text(
                'Reset\nPassword.',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 34,
                  height: 1.05,
                  letterSpacing: -1.0,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the email associated with your account and we’ll send an email with instructions to reset your password.',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 12,
                  height: 1.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
                const SizedBox(height: 16),
              ],

              if (_isSuccess) ...[
                // Success state
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.mark_email_read_rounded,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Check your email',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We have sent a password recover instructions to your email.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 11,
                          color: Colors.green.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                TQButton(
                  label: 'Back to Login',
                  isLoading: false,
                  onTap: () => Navigator.pop(context),
                ),
              ] else ...[
                // Form state
                const FieldLabel('Email Address'),
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
                const SizedBox(height: 32),

                // Send button
                TQButton(
                  label: 'Send Instructions',
                  isLoading: _isLoading,
                  onTap: _sendResetLink,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
