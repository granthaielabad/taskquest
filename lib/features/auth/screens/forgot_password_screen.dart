import 'package:flutter/material.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  bool _isLoading = false;
  bool _isSuccess = false;

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
    if (_emailController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
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
              const SizedBox(height: 16),
              
              // Back button
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
              const SizedBox(height: 36),

              // Heading
              Text(
                'Reset\nPassword.',
                style: AppTheme.headingXL.copyWith(
                  fontSize: 34,
                  height: 1.05,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter the email associated with your account and we’ll send an email with instructions to reset your password.',
                style: AppTheme.bodyMono.copyWith(height: 1.5),
              ),
              const SizedBox(height: 32),

              if (_isSuccess) ...[
                // Success state
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.mark_email_read_rounded,
                        color: Color(0xFF2E7D32),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Check your email',
                        style: AppTheme.headingM.copyWith(
                          color: const Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We have sent a password recover instructions to your email.',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyMono.copyWith(
                          color: const Color(0xFF388E3C),
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
                  suffixIcon: const Icon(
                    Icons.mail_outline_rounded,
                    size: 16,
                    color: AppTheme.muted,
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
