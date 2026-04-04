import 'package:flutter/material.dart';
import 'package:taskquest/core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool allNotifications = true;
  bool dailyReminder = true;
  bool streakAlert = true;
  bool questComplete = true;
  bool xpMilestones = false;
  bool friendActivity = false;
  bool appAnnouncements = true;
  bool quietHours = true;

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
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      letterSpacing: -0.5,
                      color: AppTheme.black,
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
                    const SizedBox(height: 20),
                    
                    // Master Switch Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF262626),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('All Notifications',
                                    style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                                Text('Master switch for all alerts',
                                    style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: Colors.white.withOpacity(0.4))),
                              ],
                            ),
                          ),
                          Switch(
                            value: allNotifications,
                            onChanged: (v) => setState(() => allNotifications = v),
                            activeColor: Colors.white,
                            activeTrackColor: const Color(0xFF404040),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'LEARNING'),
                    const SizedBox(height: 12),
                    _SettingsGroup(
                      children: [
                        _NotificationTile(
                          icon: Icons.access_time_rounded,
                          iconBg: const Color(0xFFE8F0FF),
                          iconColor: const Color(0xFF4A8BFF),
                          title: 'Daily Reminder',
                          subtitle: 'Nudge to complete daily quest',
                          value: dailyReminder,
                          onChanged: (v) => setState(() => dailyReminder = v),
                        ),
                        _NotificationTile(
                          icon: Icons.star_outline_rounded,
                          iconBg: const Color(0xFFFFF7E6),
                          iconColor: const Color(0xFFFFAB00),
                          title: 'Streak Alert',
                          subtitle: 'Remind before streak breaks',
                          value: streakAlert,
                          onChanged: (v) => setState(() => streakAlert = v),
                        ),
                        _NotificationTile(
                          icon: Icons.check_box_outlined,
                          iconBg: const Color(0xFFE6F9F0),
                          iconColor: const Color(0xFF00C853),
                          title: 'Quest Complete',
                          subtitle: 'When you finish a daily quest',
                          value: questComplete,
                          onChanged: (v) => setState(() => questComplete = v),
                        ),
                        _NotificationTile(
                          icon: Icons.timeline_rounded,
                          iconBg: const Color(0xFFF5F5F5),
                          iconColor: const Color(0xFF9E9E9E),
                          title: 'XP Milestones',
                          subtitle: 'Level-up and XP threshold alerts',
                          value: xpMilestones,
                          onChanged: (v) => setState(() => xpMilestones = v),
                          isLast: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'SOCIAL'),
                    const SizedBox(height: 12),
                    _SettingsGroup(
                      children: [
                        _NotificationTile(
                          icon: Icons.people_outline_rounded,
                          iconBg: const Color(0xFFF5F5F5),
                          iconColor: const Color(0xFF9E9E9E),
                          title: 'Friend Activity',
                          subtitle: 'When friends earn badges or level up',
                          value: friendActivity,
                          onChanged: (v) => setState(() => friendActivity = v),
                        ),
                        _NotificationTile(
                          icon: Icons.branding_watermark_outlined,
                          iconBg: const Color(0xFFF5F5F5),
                          iconColor: const Color(0xFF9E9E9E),
                          title: 'App Announcements',
                          subtitle: 'New content and feature updates',
                          value: appAnnouncements,
                          onChanged: (v) => setState(() => appAnnouncements = v),
                          isLast: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    const _SectionLabel(label: 'QUIET HOURS'),
                    const SizedBox(height: 12),
                    _SettingsGroup(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Enable Quiet Hours',
                                        style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.black)),
                                    const SizedBox(height: 4),
                                    const Text('Silence all alerts during set times',
                                        style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: AppTheme.muted)),
                                  ],
                                ),
                              ),
                              Switch(
                                value: quietHours,
                                onChanged: (v) => setState(() => quietHours = v),
                                activeColor: Colors.white,
                                activeTrackColor: AppTheme.black,
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: AppTheme.border, height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('START',
                                      style: TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: AppTheme.dimmed)),
                                  const SizedBox(height: 4),
                                  const Text('10:00 PM',
                                      style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.black)),
                                ],
                              ),
                              const Icon(Icons.chevron_right_rounded, color: AppTheme.border),
                            ],
                          ),
                        ),
                      ],
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

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _NotificationTile({
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
                activeColor: Colors.white,
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
