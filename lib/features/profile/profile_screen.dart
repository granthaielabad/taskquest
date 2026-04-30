import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';
import 'package:taskquest/core/utils/xp_utils.dart';
import 'package:taskquest/features/profile/editprofile_screen.dart';
import 'package:taskquest/features/settings/screens/appearance_screen.dart';
import 'package:taskquest/features/settings/screens/notifications_screen.dart';
import 'package:taskquest/features/settings/screens/guide_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showInfoModal(BuildContext context, String title, Widget content) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(title, style: theme.textTheme.displayMedium),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    content,
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: TQButton(
                label: 'Close',
                isLoading: false,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Logout',
          style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Are you sure you want to exit your quest?',
          style: TextStyle(fontFamily: 'DM Mono', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: TextStyle(fontFamily: 'DM Mono', color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authServiceProvider).signOut();
            },
            child: const Text(
              'LOGOUT',
              style: TextStyle(
                fontFamily: 'DM Mono',
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: userAsync.when(
        data: (user) => _buildProfileContent(context, ref, user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, UserModel? user) {
    if (user == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final levelData = XpUtils.getLevelProgress(user.xp);
    final currentLevel = levelData['level'] as int;
    final nextLevelXp = levelData['nextLevelXpThreshold'] as int;
    final progress = (levelData['progress'] as double).clamp(0.0, 1.0);

    final initials = user.displayName.isNotEmpty
        ? user.displayName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'S';

    final bgHex = user.photoBackground.replaceFirst('#', '0xFF');
    final avatarColor = Color(int.parse(bgHex));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),

          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: avatarColor.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _buildAvatarImage(user, initials),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user.displayName.isNotEmpty ? user.displayName : 'Scholar',
                  style: theme.textTheme.displayMedium?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 12,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (user.course.isNotEmpty || user.school.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${user.course}${user.school.isNotEmpty ? " @ ${user.school}" : ""}',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    'LEVEL $currentLevel · ${XpUtils.getRankTitle(currentLevel).toUpperCase()}',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatTile(label: 'TOTAL XP', value: '${user.xp}', icon: Icons.bolt_rounded),
                _StatTile(label: 'STREAK', value: '${user.streak}d', icon: Icons.local_fire_department_rounded),
                _StatTile(label: 'BADGES', value: '${user.unlockedBadges.length}', icon: Icons.stars_rounded),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LEVEL $currentLevel',
                    style: const TextStyle(fontFamily: 'DM Mono', fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'LEVEL ${currentLevel + 1}',
                    style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: colorScheme.outline.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${nextLevelXp - user.xp} XP remaining for next level',
                  style: TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          _buildGroupHeader('ACCOUNT'),
          _buildSettingsGroup([
            _SettingsTile(
              icon: Icons.person_outline_rounded,
              title: 'Edit Profile',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
            ),
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AppearanceScreen())),
            ),
            _SettingsTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
            ),
          ]),

          const SizedBox(height: 24),
          _buildGroupHeader('SUPPORT & LEGAL'),
          _buildSettingsGroup([
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'How to use TaskQuest',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GuideScreen())),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => _showPrivacyPolicy(context),
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () => _showTermsOfService(context),
            ),
          ]),

          const SizedBox(height: 24),
          _buildGroupHeader('DANGER ZONE'),
          _buildSettingsGroup([
            _SettingsTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              iconColor: Colors.redAccent,
              onTap: () => _showLogoutConfirmation(context, ref),
            ),
          ]),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    final theme = Theme.of(context);
    _showInfoModal(
      context, 
      'Privacy Policy', 
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Last Updated: April 27, 2026', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('Data Privacy Act Compliance Statement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'In compliance with the Data Privacy Act of 2012 (Republic Act No. 10173) of the Philippines, TaskQuest is committed to protecting your personal data. By using this Android-based gamified learning application, you consent to the collection, processing, and storage of your name, email address, learning progress (quiz scores, puzzle completion, timed challenges), digital badges, and device information solely to provide adaptive difficulty, progress tracking, instant feedback, and improve educational support. We do not sell your data. Your data is stored securely, and in case of a breach, we will notify the National Privacy Commission and affected users within 72 hours. You have the right to access, correct, or delete your data by contacting us. Continued use of the app constitutes your acceptance of this policy.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 24),
          _policySection('1. Information We Collect', 'We collect your name, email address, learning progress (quizzes, puzzles, challenges), digital badges, and device information.', theme),
          _policySection('2. How We Use Your Data', 'We use your data to deliver gamified learning, track progress, adjust difficulty, provide feedback, award badges, and improve the app.', theme),
          _policySection('3. Data Sharing', 'We do not sell your data. We may share anonymized progress reports with educational institutions for research purposes.', theme),
          _policySection('4. Data Security', 'We use encryption and restricted access to protect your data. Only authorized researchers and developers can view records.', theme),
          _policySection('5. Your Rights', 'Under the Data Privacy Act, you have the right to access, correct, erase, object, withdraw consent, and request a copy of your data.', theme),
          _policySection('6. Data Retention', 'We keep your data only as long as needed for this study. You may request deletion of your account at any time.', theme),
          _policySection('7. Contact Us', 'For privacy concerns or to exercise your rights, email us at: taskquest.support@gmail.com', theme),
          const SizedBox(height: 40),
        ],
      )
    );
  }

  void _showTermsOfService(BuildContext context) {
    final theme = Theme.of(context);
    _showInfoModal(
      context, 
      'Terms of Service', 
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Last Updated: April 27, 2026', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text('Terms of Service Statement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'By downloading, installing, or using TaskQuest: A Gamified Learning Application for Android-Based Educational Support, you agree to be bound by these Terms of Service. TaskQuest is a gamified learning tool designed to improve student engagement through quizzes, puzzles, timed challenges, digital badges, progress tracking, and adaptive difficulty. You agree to use the application solely for lawful educational purposes, to provide accurate information during account creation, and to not attempt to hack, reverse-engineer, or disrupt the app\'s functionality. The developers and researchers behind TaskQuest are not liable for any device damage, data loss, or academic outcomes resulting from use of the application. We reserve the right to suspend or terminate accounts that violate these terms or engage in cheating, harassment, or misuse of the gamified system. Continued use of TaskQuest constitutes your acceptance of these terms.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 24),
          _policySection('1. Account Registration', 'You must provide a valid name and email address to create an account. You are responsible for keeping your login credentials confidential.', theme),
          _policySection('2. Acceptable Use', 'You agree to use TaskQuest only for legitimate learning activities. You may not:\n- Cheat or exploit the gamified system (e.g., fake score manipulation).\n- Share your account with others who are not authorized users.\n- Attempt to hack, decompile, or reverse-engineer the application.\n- Use the app for any illegal or unethical purpose.', theme),
          _policySection('3. Intellectual Property', 'All content within TaskQuest—including quizzes, puzzles, badges, graphics, and code—is owned by the developers and researchers of this study. You may not copy, distribute, or reproduce any part of the app without written permission.', theme),
          _policySection('4. Account Termination', 'We reserve the right to suspend or permanently delete your account if you violate these terms. You may also delete your own account at any time by contacting us.', theme),
          _policySection('5. Disclaimer of Warranties', 'TaskQuest is provided "as is" without any warranties of merchantability, fitness for a particular purpose, or uninterrupted operation. We do not guarantee specific academic improvements.', theme),
          _policySection('6. Limitation of Liability', 'To the fullest extent permitted by Philippine law, TaskQuest and its developers shall not be liable for any indirect, incidental, or consequential damages arising from your use of the application, including device issues or academic performance.', theme),
          _policySection('7. Changes to These Terms', 'We may update these Terms of Service from time to time. Continued use of the app after changes constitutes your acceptance of the updated terms.', theme),
          _policySection('8. Governing Law', 'These Terms shall be governed by and construed in accordance with the laws of the Republic of the Philippines. Any disputes shall be resolved exclusively by the proper courts of the Philippines.', theme),
          _policySection('9. Contact Us', 'For questions or concerns regarding these Terms of Service, contact us at: taskquest.support@gmail.com', theme),
          const SizedBox(height: 40),
        ],
      )
    );
  }

  Widget _policySection(String title, String content, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(content, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(UserModel user, String initials) {
    if (user.photoUrl.isEmpty) return _buildInitials(initials);
    if (user.photoUrl.startsWith('data:image')) {
      try {
        final base64Part = user.photoUrl.split(',').last;
        return Image.memory(base64Decode(base64Part), fit: BoxFit.cover);
      } catch (e) { return _buildInitials(initials); }
    }
    return CachedNetworkImage(imageUrl: user.photoUrl, fit: BoxFit.cover, errorWidget: (context, url, error) => _buildInitials(initials));
  }

  Widget _buildInitials(String initials) {
    return Center(child: Text(initials, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 32, color: Colors.white)));
  }

  Widget _buildGroupHeader(String title) {
    return Padding(padding: const EdgeInsets.only(left: 12, bottom: 8), child: Text(title, style: const TextStyle(fontFamily: 'DM Mono', fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.bold)));
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Builder(builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      return Container(decoration: BoxDecoration(color: colorScheme.surface, border: Border.all(color: colorScheme.outline), borderRadius: BorderRadius.circular(24)), child: Column(children: children));
    });
  }
}

class _StatTile extends StatelessWidget {
  final String label; final String value; final IconData icon;
  const _StatTile({required this.label, required this.value, required this.icon});
  @override Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(children: [Icon(icon, color: colorScheme.primary, size: 20), const SizedBox(height: 8), Text(value, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 18)), const SizedBox(height: 2), Text(label, style: TextStyle(fontFamily: 'DM Mono', fontSize: 8, color: colorScheme.onSurfaceVariant))]);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback onTap; final Color? iconColor;
  const _SettingsTile({required this.icon, required this.title, required this.onTap, this.iconColor});
  @override Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), child: Row(children: [Icon(icon, size: 20, color: iconColor ?? theme.colorScheme.onSurface), const SizedBox(width: 16), Expanded(child: Text(title, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w600, fontSize: 14))), Icon(Icons.chevron_right_rounded, size: 18, color: theme.colorScheme.outline)])));
  }
}
