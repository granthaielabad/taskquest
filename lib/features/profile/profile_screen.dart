import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';
import 'package:taskquest/core/services/database_seed_service.dart';
import 'package:taskquest/core/utils/xp_utils.dart';
import 'package:taskquest/features/profile/editprofile_screen.dart';
import 'package:taskquest/features/settings/appearance_screen.dart';
import 'package:taskquest/features/settings/notifications_screen.dart';
import 'package:taskquest/features/settings/switchaccount_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showInfoModal(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(title, style: AppTheme.headingL),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  content,
                  style: AppTheme.bodyMono.copyWith(height: 1.6),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundLight,
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
            child: const Text(
              'CANCEL',
              style: TextStyle(fontFamily: 'DM Mono', color: AppTheme.muted),
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
                color: Colors.red,
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: userAsync.when(
          data: (user) => _buildProfileContent(context, ref, user),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    UserModel? user,
  ) {
    if (user == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading your profile...',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 12,
                color: AppTheme.muted,
              ),
            ),
          ],
        ),
      );
    }

    final displayName = user.displayName.isNotEmpty
        ? user.displayName
        : 'Scholar';
    final totalXp = user.xp;
    final levelData = XpUtils.getLevelProgress(totalXp);
    final initials = displayName.isNotEmpty
        ? displayName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'S';

    final currentLevel = levelData['level'] as int;
    final nextLevelXp = levelData['nextLevelXpThreshold'] as int;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  letterSpacing: -0.8,
                  color: AppTheme.black,
                ),
              ),
              _HeaderButton(
                icon: Icons.edit_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // User Info Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: AppTheme.black,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF262626),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF333333)),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                          if (user.school.isNotEmpty == true ||
                              user.course.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${user.course}${user.school.isNotEmpty == true ? ' · ' : ''}${user.school}',
                              style: const TextStyle(
                                fontFamily: 'DM Mono',
                                fontSize: 10,
                                color: Color(0x99FFFFFF),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF333333),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.white,
                                  size: 10,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'LEVEL ${user.level} · ${XpUtils.getRankTitle(user.level).toUpperCase()}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'DM Mono',
                                      fontSize: 9,
                                      letterSpacing: 0.5,
                                      color: Color(0x99FFFFFF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFF262626), height: 1),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _StatItem(label: 'TOTAL XP', value: '${user.xp}'),
                    ),
                    Expanded(
                      child: _StatItem(
                        label: 'DAY STREAK',
                        value: '${user.streak}',
                      ),
                    ),
                    Expanded(
                      child: _StatItem(
                        label: 'BADGES',
                        value: '${user.unlockedBadges.length}',
                      ),
                    ),
                    Expanded(
                      child: const _StatItem(label: 'RANK', value: '---'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Level Progress Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(color: AppTheme.borderLight),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LEVEL PROGRESS',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: AppTheme.muted,
                      ),
                    ),
                    Text(
                      'Next Level',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 10,
                        color: AppTheme.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${user.xp}',
                            style: const TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              color: AppTheme.black,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '/ $nextLevelXp XP',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'DM Mono',
                                fontSize: 12,
                                color: AppTheme.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Level ${currentLevel + 1}',
                          style: const TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppTheme.black,
                          ),
                        ),
                        Text(
                          '${nextLevelXp - totalXp} XP to go',
                          style: const TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 10,
                            color: AppTheme.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (levelData['progress'] as double).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AppTheme.backgroundLight,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Settings Section
          _buildSectionHeader('Account'),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(color: AppTheme.borderLight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  Icons.person_outline_rounded,
                  'Edit Profile',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  ),
                ),
                const Divider(color: AppTheme.borderLight, height: 1),
                _buildMenuItem(
                  Icons.palette_outlined,
                  'Appearance',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppearanceScreen(),
                    ),
                  ),
                ),
                const Divider(color: AppTheme.borderLight, height: 1),
                _buildMenuItem(
                  Icons.notifications_none_rounded,
                  'Notifications',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  ),
                ),
                const Divider(color: AppTheme.borderLight, height: 1),
                _buildMenuItem(
                  Icons.switch_account_outlined,
                  'Switch Account',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SwitchAccountScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Support & Legal'),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(color: AppTheme.borderLight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildMenuItem(
                  Icons.description_outlined,
                  'Privacy Policy',
                  onTap: () => _showInfoModal(
                    context,
                    'Privacy Policy',
                    'TaskQuest values your privacy. We collect minimal data to provide a gamified learning experience...',
                  ),
                ),
                const Divider(color: AppTheme.borderLight, height: 1),
                _buildMenuItem(
                  Icons.gavel_outlined,
                  'Terms of Service',
                  onTap: () => _showInfoModal(
                    context,
                    'Terms of Service',
                    'By using TaskQuest, you agree to follow our acceptable use policy and academic integrity guidelines...',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Development'),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(color: AppTheme.borderLight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildMenuItem(
              Icons.storage_rounded,
              'Seed Database',
              onTap: () async {
                await DatabaseSeedService().seedAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Database seeded successfully!'),
                    ),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 32),
          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TQButton(
              label: 'Logout',
              isLoading: false,
              onTap: () => _showLogoutConfirmation(context, ref),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 10,
          letterSpacing: 1.8,
          color: AppTheme.muted,
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.black),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.black,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppTheme.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _HeaderButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppTheme.white,
          border: Border.all(color: AppTheme.borderLight),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.black, size: 18),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: const TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 8,
            letterSpacing: 0.5,
            color: Color(0x66FFFFFF),
          ),
        ),
      ],
    );
  }
}
