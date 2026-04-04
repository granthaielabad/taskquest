import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/auth/widgets/auth_widgets.dart';
import 'package:taskquest/core/services/database_seed_service.dart';
import 'package:taskquest/core/utils/xp_utils.dart';

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

  void _showEditProfile(BuildContext context, WidgetRef ref, UserModel? user) {
    final nameController = TextEditingController(text: user?.displayName);
    final focusNode = FocusNode();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Edit Profile', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FieldLabel('Display Name'),
            const SizedBox(height: 8),
            TQInputField(
              controller: nameController,
              focusNode: focusNode,
              hintText: 'Your name',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(fontFamily: 'DM Mono', color: AppTheme.muted)),
          ),
          TextButton(
            onPressed: () async {
              if (user != null && nameController.text.trim().isNotEmpty) {
                await ref.read(userServiceProvider).updateDisplayName(user.uid, nameController.text.trim());
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('SAVE', style: TextStyle(fontFamily: 'DM Mono', color: AppTheme.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
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
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        // ── Profile Header ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _showEditProfile(context, ref, user),
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppTheme.black, width: 2),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, size: 50, color: AppTheme.black),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.black,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? 'Scholar',
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.44,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'LEVEL ${user?.level ?? 1} · COMPUTER SCIENCE',
                style: AppTheme.labelMono.copyWith(letterSpacing: 1.2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // ── Your Progress ─────────────────────────────────────────
        _buildSectionHeader('Your Progress'),
        _buildProgressCard(user),
        
        const SizedBox(height: 32),

        // ── Stats Grid ────────────────────────────────────────────
        _buildSectionHeader('Stats'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildStatCard('🔥', '${user?.streak ?? 0}', 'Day Streak'),
              const SizedBox(width: 12),
              _buildStatCard('🏆', '${user?.unlockedBadges.length ?? 0}', 'Badges'),
              const SizedBox(width: 12),
              _buildStatCard('⚡', '42', 'Quests'),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // ── Menu Options ──────────────────────────────────────────
        _buildSectionHeader('Account'),
        _buildMenuItem(Icons.person_outline_rounded, 'Edit Profile', onTap: () => _showEditProfile(context, ref, user)),
        _buildMenuItem(Icons.lock_outline_rounded, 'Change Password'),
        _buildMenuItem(Icons.notifications_none_rounded, 'Notifications'),
        
        const SizedBox(height: 20),
        _buildSectionHeader('Support & Legal'),
        _buildMenuItem(Icons.help_outline_rounded, 'Help Center'),
        _buildMenuItem(Icons.description_outlined, 'Privacy Policy', onTap: () {
          _showInfoModal(context, 'Privacy Policy', 'TaskQuest values your privacy. We collect minimal data to provide a gamified learning experience...');
        }),
        _buildMenuItem(Icons.gavel_outlined, 'Terms of Service', onTap: () {
          _showInfoModal(context, 'Terms of Service', 'By using TaskQuest, you agree to follow our acceptable use policy and academic integrity guidelines...');
        }),

        const SizedBox(height: 24),
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

        const SizedBox(height: 32),
        // Logout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TQButton(
            label: 'Logout',
            isLoading: false,
            onTap: () => ref.read(authServiceProvider).signOut(),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildProgressCard(UserModel? user) {
    final totalXp = user?.xp ?? 0;
    final levelData = XpUtils.getLevelProgress(totalXp);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total XP',
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  letterSpacing: 1.0,
                  color: Color(0x66FFFFFF),
                ),
              ),
              Text(
                'Next Level: ${levelData['nextLevelXpThreshold']} XP',
                style: const TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 9,
                  color: Color(0x66FFFFFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$totalXp XP',
            style: const TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (levelData['progress'] as double).clamp(0.0, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
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

  Widget _buildStatCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppTheme.black,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 8,
                color: AppTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
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
