import 'package:flutter/material.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import 'package:taskquest/features/profile/editprofile_screen.dart';
import 'package:taskquest/features/settings/notifications_screen.dart';
import 'package:taskquest/features/settings/appearance_screen.dart';
import 'package:taskquest/features/settings/privacyndata_screen.dart';
import 'package:taskquest/features/settings/switchaccount_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
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
                          child: const Center(
                            child: Text('JD', style: TextStyle(fontFamily: 'Syne',
                                fontWeight: FontWeight.w800, fontSize: 24, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Juan dela Cruz', style: TextStyle(fontFamily: 'Syne',
                                  fontWeight: FontWeight.w800, fontSize: 22, color: Colors.white)),
                              const Text('[email protected]', style: TextStyle(fontFamily: 'DM Mono',
                                  fontSize: 12, color: Colors.blue)),
                              const SizedBox(height: 8),
                              // Badge with definitive overflow protection
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF333333)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded, color: Colors.white, size: 10),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'LEVEL 4 · APPRENTICE QUESTER', 
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _StatItem(label: 'TOTAL XP', value: '1,840')),
                        Expanded(child: _StatItem(label: 'DAY STREAK', value: '7')),
                        Expanded(child: _StatItem(label: 'BADGES', value: '8')),
                        Expanded(child: _StatItem(label: 'RANK', value: '6th')),
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
                            children: const [
                              Text('1,840', style: TextStyle(fontFamily: 'Syne',
                                  fontWeight: FontWeight.w800, fontSize: 24, color: AppTheme.black)),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text('/ 2,500 XP', overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontFamily: 'DM Mono',
                                    fontSize: 12, color: AppTheme.muted)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text('Level 5', style: TextStyle(fontFamily: 'Syne',
                                fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.black)),
                            Text('660 XP to go', style: TextStyle(fontFamily: 'DM Mono',
                                fontSize: 10, color: AppTheme.muted)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 1840 / 2500,
                        minHeight: 8,
                        backgroundColor: AppTheme.background,
                        valueColor: AlwaysStoppedAnimation(AppTheme.black),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Skill Breakdown Card
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
                    const Text('Skill Breakdown', style: TextStyle(fontFamily: 'Syne',
                        fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.black)),
                    const SizedBox(height: 20),
                    const _SkillItem(label: 'Programming Logic', progress: 0.82),
                    const _SkillItem(label: 'Syntax Knowledge', progress: 0.67),
                    const _SkillItem(label: 'SDLC Concepts', progress: 0.80),
                    const _SkillItem(label: 'Algorithm Solving', progress: 0.45),
                    const _SkillItem(label: 'Lang. Identification', progress: 0.70),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recent Badges Card
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Badges', style: TextStyle(fontFamily: 'Syne',
                            fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.black)),
                        Text('View all', style: TextStyle(fontFamily: 'DM Mono',
                            fontSize: 11, color: AppTheme.dimmed, decoration: TextDecoration.underline)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BadgeIcon(icon: Icons.star_rounded, color: AppTheme.black, isActive: true),
                        _BadgeIcon(icon: Icons.check_box_rounded, color: AppTheme.black, isActive: true),
                        _BadgeIcon(icon: Icons.access_time_filled_rounded, color: AppTheme.black, isActive: true),
                        _BadgeIcon(icon: Icons.lock_outline_rounded, color: AppTheme.border, isActive: false),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Spacing for bottom nav if needed
            ],
          ),
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

class _SkillItem extends StatelessWidget {
  final String label;
  final double progress;
  const _SkillItem({required this.label, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(label, 
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: 'DM Mono', fontSize: 11,
                    fontWeight: FontWeight.w500, color: AppTheme.black)),
              ),
              const SizedBox(width: 8),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(fontFamily: 'DM Mono',
                  fontSize: 10, color: AppTheme.muted)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppTheme.background,
              valueColor: const AlwaysStoppedAnimation(AppTheme.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isActive;
  const _BadgeIcon({required this.icon, required this.color, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        color: isActive ? color : AppTheme.white,
        border: isActive ? null : Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: isActive ? Colors.white : AppTheme.border, size: 22),
    );
  }
}
