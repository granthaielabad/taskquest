import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';
import 'package:taskquest/core/services/database_seed_service.dart';
import 'package:taskquest/core/utils/xp_utils.dart';
import 'package:taskquest/features/profile/editprofile_screen.dart';
import 'package:taskquest/features/settings/notifications_screen.dart';
import 'package:taskquest/features/settings/appearance_screen.dart';
import 'package:taskquest/features/settings/privacyndata_screen.dart';
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
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
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

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 16),
              _SettingsTile(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.palette_outlined,
                label: 'Appearance',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppearanceScreen()),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.security_rounded,
                label: 'Privacy & Data',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PrivacyAndDataScreen()),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.switch_account_outlined,
                label: 'Switch Account',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SwitchAccountScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: userAsync.when(
          data: (user) => _buildProfileContent(context, ref, user),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, UserModel? user) {
    final displayName = user?.displayName ?? 'Scholar';
    final totalXp = user?.xp ?? 0;
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
              const Text('Profile',
                  style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800,
                      fontSize: 28, letterSpacing: -0.8, color: AppTheme.black)),
              Row(
                children: [
                  const _HeaderButton(icon: Icons.wb_sunny_outlined),
                  const SizedBox(width: 8),
                  _HeaderButton(
                    icon: Icons.edit_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _HeaderButton(
                    icon: Icons.menu_rounded,
                    onTap: () => _showSettingsMenu(context),
                  ),
                ],
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
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF262626),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF333333)),
                      ),
                      child: Center(
                        child: Text(initials, style: const TextStyle(fontFamily: 'Syne',
                            fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayName, style: const TextStyle(fontFamily: 'Syne',
                              fontWeight: FontWeight.w800, fontSize: 22, color: Colors.white)),
                          Text(user?.email ?? '', style: const TextStyle(fontFamily: 'DM Mono',
                              fontSize: 12, color: Colors.blue)),
                          const SizedBox(height: 8),
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF333333)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.white, size: 10),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'LEVEL ${user?.level ?? 1} · ${XpUtils.getRankTitle(user?.level ?? 1).toUpperCase()}', 
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontFamily: 'DM Mono', fontSize: 9,
                                        letterSpacing: 0.5, color: Color(0x99FFFFFF)),
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
                    Expanded(child: _StatItem(label: 'TOTAL XP', value: '$totalXp')),
                    Expanded(child: _StatItem(label: 'DAY STREAK', value: '${user?.streak ?? 0}')),
                    Expanded(child: _StatItem(label: 'BADGES', value: '${user?.unlockedBadges.length ?? 0}')),
                    Expanded(child: const _StatItem(label: 'RANK', value: '---')),
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
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('LEVEL PROGRESS', style: TextStyle(fontFamily: 'DM Mono',
                        fontSize: 10, letterSpacing: 1.2, color: AppTheme.muted)),
                    Text('Next Level', style: TextStyle(fontFamily: 'DM Mono',
                        fontSize: 10, color: AppTheme.muted)),
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
                          Text('$totalXp', style: const TextStyle(fontFamily: 'Syne',
                              fontWeight: FontWeight.w800, fontSize: 24, color: AppTheme.black)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text('/ $nextLevelXp XP', overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontFamily: 'DM Mono',
                                fontSize: 12, color: AppTheme.muted)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Level ${currentLevel + 1}', style: const TextStyle(fontFamily: 'Syne',
                            fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.black)),
                        Text('${nextLevelXp - totalXp} XP to go', style: const TextStyle(fontFamily: 'DM Mono',
                            fontSize: 10, color: AppTheme.muted)),
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
                    backgroundColor: AppTheme.background,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Developer Tools Section
          _buildSectionHeader('Developer Tools'),
          _buildMenuItem(
            Icons.storage_rounded, 
            'Seed Database', 
            onTap: () async {
              await DatabaseSeedService().seedAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Database seeded successfully!'))
                );
              }
            }
          ),
          _buildMenuItem(Icons.description_outlined, 'Privacy Policy', onTap: () {
            _showInfoModal(context, 'Privacy Policy', 'TaskQuest values your privacy. We collect minimal data to provide a gamified learning experience...');
          }),
          _buildMenuItem(Icons.gavel_outlined, 'Terms of Service', onTap: () {
            _showInfoModal(context, 'Terms of Service', 'By using TaskQuest, you agree to follow our acceptable use policy and academic integrity guidelines...');
          }),

          const SizedBox(height: 24),
          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TQButton(
              label: 'Logout',
              isLoading: false,
              onTap: () => ref.read(authServiceProvider).signOut(),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.muted),
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
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.black, size: 18),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.black),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Syne',
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppTheme.black,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.dimmed),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
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
          child: Text(value, 
              style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800,
              fontSize: 20, color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(label, 
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: const TextStyle(fontFamily: 'DM Mono', fontSize: 8,
            letterSpacing: 0.5, color: Color(0x66FFFFFF))),
      ],
    );
  }
}
