import 'package:flutter/material.dart';
import 'package:taskquest/core/theme/app_theme.dart';

class PrivacyAndDataScreen extends StatefulWidget {
  const PrivacyAndDataScreen({super.key});

  @override
  State<PrivacyAndDataScreen> createState() => _PrivacyAndDataScreenState();
}

class _PrivacyAndDataScreenState extends State<PrivacyAndDataScreen> {
  bool analytics = true;
  bool personalization = true;
  bool crashReports = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        border: Border.all(color: AppTheme.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.chevron_left_rounded, color: AppTheme.black),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Text(
                      'Privacy & Data',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        letterSpacing: -0.5,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.border, height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Privacy Hero Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.black,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF262626),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Your data stays private',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'TaskQuest never sells your personal information. You have full control over what we collect.',
                            style: TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 12,
                              height: 1.6,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'DATA CONTROLS'),
                    const SizedBox(height: 12),
                    _SettingsGroup(
                      children: [
                        _ControlTile(
                          icon: Icons.person_outline_rounded,
                          iconBg: const Color(0xFFE8F0FF),
                          iconColor: const Color(0xFF4A8BFF),
                          title: 'Analytics',
                          subtitle: 'Help improve app with usage data',
                          value: analytics,
                          onChanged: (v) => setState(() => analytics = v),
                        ),
                        _ControlTile(
                          icon: Icons.grid_view_rounded,
                          iconBg: const Color(0xFFF3EBFF),
                          iconColor: const Color(0xFF7C4DFF),
                          title: 'Personalization',
                          subtitle: 'Tailor content to your learning style',
                          value: personalization,
                          onChanged: (v) => setState(() => personalization = v),
                        ),
                        _ControlTile(
                          icon: Icons.cloud_done_outlined,
                          iconBg: const Color(0xFFE6F9F0),
                          iconColor: const Color(0xFF00C853),
                          title: 'Crash Reports',
                          subtitle: 'Send error logs to help fix bugs',
                          value: crashReports,
                          onChanged: (v) => setState(() => crashReports = v),
                          isLast: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'DATA MANAGEMENT'),
                    const SizedBox(height: 12),
                    _SettingsGroup(
                      children: [
                        const _ManagementTile(
                          icon: Icons.circle,
                          title: 'Download My Data',
                          subtitle: 'Export all your activity and progress',
                        ),
                        const _ManagementTile(
                          icon: Icons.circle,
                          title: 'Clear Learning History',
                          subtitle: 'Remove past session records',
                        ),
                        const _ManagementTile(
                          icon: Icons.circle,
                          title: 'Privacy Policy',
                          subtitle: 'Read our full policy',
                          isLast: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F5),
                        border: Border.all(color: const Color(0xFFFFE0E0)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Delete All My Data',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'DM Mono',
        fontSize: 10,
        letterSpacing: 1.2,
        color: AppTheme.muted,
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}

class _ControlTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ControlTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.black)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: AppTheme.muted)),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: iconColor,
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(color: AppTheme.border, height: 1, indent: 72),
      ],
    );
  }
}

class _ManagementTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLast;

  const _ManagementTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 8, color: AppTheme.black),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.black)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: AppTheme.muted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.border, size: 20),
            ],
          ),
        ),
        if (!isLast) const Divider(color: AppTheme.border, height: 1, indent: 40),
      ],
    );
  }
}
