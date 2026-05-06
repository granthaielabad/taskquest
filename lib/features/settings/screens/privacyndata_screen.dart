import 'package:flutter/material.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';

class PrivacyAndDataScreen extends StatefulWidget {
  const PrivacyAndDataScreen({super.key});

  @override
  State<PrivacyAndDataScreen> createState() => _PrivacyAndDataScreenState();
}

class _PrivacyAndDataScreenState extends State<PrivacyAndDataScreen> {
  bool analytics = true;
  bool personalization = true;
  bool crashReports = true;

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            const Text('Privacy Policy', style: TextStyle(fontFamily: 'Syne', fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.white, fontFamily: 'DM Mono', fontSize: 13, height: 1.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Last Updated: April 27, 2026', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      const Text('Data Privacy Act Compliance Statement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      const SizedBox(height: 8),
                      const Text('In compliance with the Data Privacy Act of 2012 (Republic Act No. 10173) of the Philippines, TaskQuest is committed to protecting your personal data. By using this Android-based gamified learning application, you consent to the collection, processing, and storage of your name, email address, learning progress (quiz scores, puzzle completion, timed challenges), digital badges, and device information solely to provide adaptive difficulty, progress tracking, instant feedback, and improve educational support. We do not sell your data. Your data is stored securely, and in case of a breach, we will notify the National Privacy Commission and affected users within 72 hours. You have the right to access, correct, or delete your data by contacting us. Continued use of the app constitutes your acceptance of this policy.', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 24),
                      _section('1. Information We Collect', 'We collect your name, email address, learning progress (quizzes, puzzles, challenges), digital badges, and device information.'),
                      _section('2. How We Use Your Data', 'We use your data to deliver gamified learning, track progress, adjust difficulty, provide feedback, award badges, and improve the app.'),
                      _section('3. Data Sharing', 'We do not sell your data. We may share anonymized progress reports with educational institutions for research purposes.'),
                      _section('4. Data Security', 'We use encryption and restricted access to protect your data. Only authorized researchers and developers can view records.'),
                      _section('5. Your Rights', 'Under the Data Privacy Act, you have the right to access, correct, erase, object, withdraw consent, and request a copy of your data.'),
                      _section('6. Data Retention', 'We keep your data only as long as needed for this study. You may request deletion of your account at any time.'),
                      _section('7. Contact Us', 'For privacy concerns or to exercise your rights, email us at: taskquest.support@gmail.com'),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: TQButton(label: 'Close', isLoading: false, onTap: () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : AppTheme.white,
                        border: Border.all(color: isDark ? Colors.white10 : AppTheme.borderLight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.chevron_left_rounded, color: isDark ? Colors.white : AppTheme.black),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text('Privacy & Data', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 24, color: isDark ? Colors.white : AppTheme.black)),
                  ),
                ],
              ),
            ),
            Divider(color: isDark ? Colors.white10 : AppTheme.borderLight, height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : AppTheme.black,
                        borderRadius: BorderRadius.circular(24),
                        border: isDark ? Border.all(color: Colors.white10) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.shield_outlined, color: Colors.white, size: 24),
                          const SizedBox(height: 20),
                          const Text('Your data stays private', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white)),
                          const SizedBox(height: 12),
                          Text('TaskQuest never sells your personal information. You have full control over what we collect.', style: TextStyle(fontFamily: 'DM Mono', fontSize: 12, height: 1.6, color: Colors.white.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _SectionLabel(label: 'DATA CONTROLS', isDark: isDark),
                    _SettingsGroup(
                      isDark: isDark,
                      children: [
                        _ControlTile(isDark: isDark, icon: Icons.person_outline_rounded, iconBg: const Color(0xFFE8F0FF), iconColor: const Color(0xFF4A8BFF), title: 'Analytics', subtitle: 'Help improve app with usage data', value: analytics, onChanged: (v) => setState(() => analytics = v)),
                        _ControlTile(isDark: isDark, icon: Icons.grid_view_rounded, iconBg: const Color(0xFFF3EBFF), iconColor: const Color(0xFF7C4DFF), title: 'Personalization', subtitle: 'Tailor content to your learning style', value: personalization, onChanged: (v) => setState(() => personalization = v)),
                        _ControlTile(isDark: isDark, icon: Icons.cloud_done_outlined, iconBg: const Color(0xFFE6F9F0), iconColor: const Color(0xFF00C853), title: 'Crash Reports', subtitle: 'Send error logs to help fix bugs', value: crashReports, onChanged: (v) => setState(() => crashReports = v), isLast: true),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _SectionLabel(label: 'DATA MANAGEMENT', isDark: isDark),
                    _SettingsGroup(
                      isDark: isDark,
                      children: [
                        _ManagementTile(isDark: isDark, icon: Icons.download_outlined, title: 'Download My Data', subtitle: 'Export all your activity and progress'),
                        _ManagementTile(isDark: isDark, icon: Icons.history_rounded, title: 'Clear Learning History', subtitle: 'Remove past session records'),
                        _ManagementTile(isDark: isDark, icon: Icons.description_outlined, title: 'Privacy Policy', subtitle: 'Read our full policy', isLast: true, onTap: () => _showPrivacyPolicy(context)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: isDark ? Colors.red.withValues(alpha: 0.05) : const Color(0xFFFFF5F5), border: Border.all(color: isDark ? Colors.red.withValues(alpha: 0.1) : const Color(0xFFFFE0E0)), borderRadius: BorderRadius.circular(16)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 18), const SizedBox(width: 8), Text('Delete All My Data', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14, color: Colors.red.shade400))]),
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
  final String label; final bool isDark;
  const _SectionLabel({required this.label, this.isDark = false});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(label, style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, letterSpacing: 1.2, color: isDark ? Colors.white38 : AppTheme.muted)));
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children; final bool isDark;
  const _SettingsGroup({required this.children, this.isDark = false});
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: isDark ? const Color(0xFF1A1A1A) : AppTheme.white, border: Border.all(color: isDark ? Colors.white10 : AppTheme.borderLight), borderRadius: BorderRadius.circular(20)), child: Column(children: children));
}

class _ControlTile extends StatelessWidget {
  final IconData icon; final Color iconBg; final Color iconColor; final String title; final String subtitle; final bool value; final ValueChanged<bool> onChanged; final bool isLast; final bool isDark;
  const _ControlTile({required this.icon, required this.iconBg, required this.iconColor, required this.title, required this.subtitle, required this.value, required this.onChanged, this.isLast = false, this.isDark = false});
  @override Widget build(BuildContext context) => Column(children: [Padding(padding: const EdgeInsets.all(16), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: iconBg.withValues(alpha: isDark ? 0.1 : 1.0), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 18)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : AppTheme.black)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: isDark ? Colors.white38 : AppTheme.muted))])), Switch(value: value, onChanged: onChanged, activeThumbColor: Colors.white, activeTrackColor: iconColor)])), if (!isLast) Divider(color: isDark ? Colors.white10 : AppTheme.borderLight, height: 1, indent: 72)]);
}

class _ManagementTile extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final bool isLast; final VoidCallback? onTap; final bool isDark;
  const _ManagementTile({required this.icon, required this.title, required this.subtitle, this.isLast = false, this.onTap, this.isDark = false});
  @override Widget build(BuildContext context) => Column(children: [InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Icon(icon, size: 20, color: isDark ? Colors.white70 : AppTheme.black), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : AppTheme.black)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: isDark ? Colors.white38 : AppTheme.muted))])), Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white10 : AppTheme.borderLight, size: 20)]))), if (!isLast) Divider(color: isDark ? Colors.white10 : AppTheme.borderLight, height: 1, indent: 52)]);
}
