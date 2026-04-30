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
import 'package:taskquest/core/providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showInfoModal(BuildContext context, String title, String content) {
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
                child: Text(
                  content,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
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
    bool isLoggingOut = false;

    showDialog(
      context: context,
      barrierDismissible: !isLoggingOut,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800),
          ),
          content: isLoggingOut
              ? SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                )
              : const Text(
                  'Are you sure you want to exit your quest?',
                  style: TextStyle(fontFamily: 'DM Mono', fontSize: 13),
                ),
          actions: isLoggingOut
              ? []
              : [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'CANCEL',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      setState(() => isLoggingOut = true);
                      ref.read(navigationIndexProvider.notifier).setIndex(0);
                      await ref.read(authServiceProvider).signOut();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
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
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // ── Optimized Selectors ────────────────────────────────────
    final displayName = ref.watch(
      userProfileProvider.select((u) => u.value?.displayName ?? 'Scholar'),
    );
    final email = ref.watch(
      userProfileProvider.select((u) => u.value?.email ?? ''),
    );
    final xp = ref.watch(userProfileProvider.select((u) => u.value?.xp ?? 0));
    final streak = ref.watch(
      userProfileProvider.select((u) => u.value?.streak ?? 0),
    );
    final unlockedCount = ref.watch(
      userProfileProvider.select((u) => u.value?.unlockedBadges.length ?? 0),
    );
    final photoUrl = ref.watch(
      userProfileProvider.select((u) => u.value?.photoUrl ?? ''),
    );
    final photoBg = ref.watch(
      userProfileProvider.select((u) => u.value?.photoBackground ?? '#1A1A1A'),
    );
    final course = ref.watch(
      userProfileProvider.select((u) => u.value?.course ?? ''),
    );
    final school = ref.watch(
      userProfileProvider.select((u) => u.value?.school ?? ''),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _buildProfileContent(
              context,
              ref,
              displayName,
              email,
              xp,
              streak,
              unlockedCount,
              photoUrl,
              photoBg,
              course,
              school,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    String displayName,
    String email,
    int xp,
    int streak,
    int unlockedCount,
    String photoUrl,
    String photoBackground,
    String course,
    String school,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final levelData = XpUtils.getLevelProgress(xp);
    final currentLevel = levelData['level'] as int;
    final nextLevelXp = levelData['nextLevelXpThreshold'] as int;
    final progress = (levelData['progress'] as double).clamp(0.0, 1.0);

    final initials = displayName.isNotEmpty
        ? displayName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'S';

    final bgHex = photoBackground.replaceFirst('#', '0xFF');
    final avatarColor = Color(int.parse(bgHex));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // ── Centered Header ─────────────────────────────────────
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
                    child: _buildAvatarImage(photoUrl, initials),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  displayName.isNotEmpty ? displayName : 'Scholar',
                  style: theme.textTheme.displayMedium?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 12,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (course.isNotEmpty || school.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$course${school.isNotEmpty ? " @ $school" : ""}',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
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

          // ── Stats Row ──────────────────────────────────────────
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
                _StatTile(
                  label: 'TOTAL XP',
                  value: '$xp',
                  icon: Icons.bolt_rounded,
                ),
                _StatTile(
                  label: 'STREAK',
                  value: '${streak}d',
                  icon: Icons.local_fire_department_rounded,
                ),
                _StatTile(
                  label: 'BADGES',
                  value: '$unlockedCount',
                  icon: Icons.stars_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Level Progress ──────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LEVEL $currentLevel',
                    style: const TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'LEVEL ${currentLevel + 1}',
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
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
                  '${nextLevelXp - xp} XP remaining for next level',
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 9,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // ── Settings Groups ─────────────────────────────────────
          _buildGroupHeader('ACCOUNT'),
          _buildSettingsGroup([
            _SettingsTile(
              icon: Icons.person_outline_rounded,
              title: 'Edit Profile',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              ),
            ),
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppearanceScreen(),
                ),
              ),
            ),
            _SettingsTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 24),
          _buildGroupHeader('SUPPORT & LEGAL'),
          _buildSettingsGroup([
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              title: 'How to use TaskQuest',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GuideScreen()),
              ),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => _showInfoModal(
                context,
                'Privacy Policy',
                '''1. Data Collection
We collect minimal data (email, display name) strictly for account creation and saving your learning progress.

2. Data Usage
Your data is used to track XP, level, and badge progress. We do not sell your personal information.

3. Analytics
We collect anonymous crash reports to improve app stability. You can opt-out in Data Controls.

4. Deletion
You can request account and data deletion at any time via the Danger Zone.''',
              ),
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () => _showInfoModal(
                context,
                'Terms of Service',
                '''By using TaskQuest, you agree to:

1. Educational Use
Use the platform for its intended educational and gamified learning purposes.

2. Fair Play
Maintain the integrity of the leaderboard. Any attempts to manipulate XP or scores via exploits is prohibited.

3. Account Responsibility
Maintain the security of your account. TaskQuest is not responsible for unauthorized access.

4. Content Ownership
All learning content remains the property of TaskQuest and its contributors.''',
              ),
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

  Widget _buildAvatarImage(String photoUrl, String initials) {
    if (photoUrl.isEmpty) {
      return _buildInitials(initials);
    }

    if (photoUrl.startsWith('data:image')) {
      try {
        final base64Part = photoUrl.split(',').last;
        return Image.memory(base64Decode(base64Part), fit: BoxFit.cover);
      } catch (e) {
        return _buildInitials(initials);
      }
    }

    return CachedNetworkImage(
      imageUrl: photoUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ),
      errorWidget: (context, url, error) => _buildInitials(initials),
    );
  }

  Widget _buildInitials(String initials) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontFamily: 'Syne',
          fontWeight: FontWeight.w800,
          fontSize: 32,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 9,
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.outline),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(children: children),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 8,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
