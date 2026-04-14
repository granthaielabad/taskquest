import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';
import 'package:taskquest/core/utils/xp_utils.dart';
import 'package:taskquest/features/profile/editprofile_screen.dart';
import 'package:taskquest/features/settings/appearance_screen.dart';
import 'package:taskquest/features/settings/notifications_screen.dart';

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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // ── Centered Header ─────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                        color: colorScheme.onPrimary,
                      ),
                    ),
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
                _StatTile(label: 'TOTAL XP', value: '${user.xp}', icon: Icons.bolt_rounded),
                _StatTile(label: 'STREAK', value: '${user.streak}d', icon: Icons.local_fire_department_rounded),
                _StatTile(label: 'BADGES', value: '${user.unlockedBadges.length}', icon: Icons.stars_rounded),
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

          // ── Settings Groups ─────────────────────────────────────
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
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () => _showInfoModal(context, 'Privacy Policy', 'TaskQuest values your privacy...'),
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () => _showInfoModal(context, 'Terms of Service', 'By using TaskQuest...'),
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

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontFamily: 'DM Mono', fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Builder(builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(children: children),
      );
    });
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontFamily: 'DM Mono', fontSize: 8, color: colorScheme.onSurfaceVariant),
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
            Icon(icon, size: 20, color: iconColor ?? theme.colorScheme.onSurface),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
