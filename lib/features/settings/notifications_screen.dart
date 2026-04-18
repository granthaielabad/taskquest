import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Use Notifier instead of StateProvider for better compatibility
class NotificationSettingsNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    return {
      'all': true,
      'daily': true,
      'streak': true,
      'quest': true,
      'xp': false,
      'social': false,
      'announcements': true,
      'quiet': true,
    };
  }

  void toggle(String key, bool value) {
    state = {...state, key: value};
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, Map<String, bool>>(
      NotificationSettingsNotifier.new,
    );

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                        color: colorScheme.surface,
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      'Notifications',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.5,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: colorScheme.outline, height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Master Switch Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              color: colorScheme.surface,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'All Notifications',
                                  style: TextStyle(
                                    fontFamily: 'Syne',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: colorScheme.surface,
                                  ),
                                ),
                                Text(
                                  'Master switch for all alerts',
                                  style: TextStyle(
                                    fontFamily: 'DM Mono',
                                    fontSize: 10,
                                    color: colorScheme.surface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Switch(
                            value: settings['all'] ?? true,
                            onChanged: (v) => ref
                                .read(notificationSettingsProvider.notifier)
                                .toggle('all', v),
                            activeThumbColor: colorScheme.surface,
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
                          value: settings['daily'] ?? true,
                          onChanged: (v) => ref
                              .read(notificationSettingsProvider.notifier)
                              .toggle('daily', v),
                        ),
                        _NotificationTile(
                          icon: Icons.star_outline_rounded,
                          iconBg: const Color(0xFFFFF7E6),
                          iconColor: const Color(0xFFFFAB00),
                          title: 'Streak Alert',
                          subtitle: 'Remind before streak breaks',
                          value: settings['streak'] ?? true,
                          onChanged: (v) => ref
                              .read(notificationSettingsProvider.notifier)
                              .toggle('streak', v),
                        ),
                        _NotificationTile(
                          icon: Icons.check_box_outlined,
                          iconBg: const Color(0xFFE6F9F0),
                          iconColor: const Color(0xFF00C853),
                          title: 'Quest Complete',
                          subtitle: 'When you finish a daily quest',
                          value: settings['quest'] ?? true,
                          onChanged: (v) => ref
                              .read(notificationSettingsProvider.notifier)
                              .toggle('quest', v),
                        ),
                        _NotificationTile(
                          icon: Icons.timeline_rounded,
                          iconBg: colorScheme.outline.withValues(alpha: 0.2),
                          iconColor: colorScheme.onSurfaceVariant,
                          title: 'XP Milestones',
                          subtitle: 'Level-up and XP threshold alerts',
                          value: settings['xp'] ?? false,
                          onChanged: (v) => ref
                              .read(notificationSettingsProvider.notifier)
                              .toggle('xp', v),
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
                          iconBg: colorScheme.outline.withValues(alpha: 0.2),
                          iconColor: colorScheme.onSurfaceVariant,
                          title: 'Friend Activity',
                          subtitle: 'When friends earn badges or level up',
                          value: settings['social'] ?? false,
                          onChanged: (v) => ref
                              .read(notificationSettingsProvider.notifier)
                              .toggle('social', v),
                        ),
                        _NotificationTile(
                          icon: Icons.branding_watermark_outlined,
                          iconBg: colorScheme.outline.withValues(alpha: 0.2),
                          iconColor: colorScheme.onSurfaceVariant,
                          title: 'App Announcements',
                          subtitle: 'New content and feature updates',
                          value: settings['announcements'] ?? true,
                          onChanged: (v) => ref
                              .read(notificationSettingsProvider.notifier)
                              .toggle('announcements', v),
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
                                    Text(
                                      'Enable Quiet Hours',
                                      style: TextStyle(
                                        fontFamily: 'Syne',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Silence all alerts during set times',
                                      style: TextStyle(
                                        fontFamily: 'DM Mono',
                                        fontSize: 10,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: settings['quiet'] ?? true,
                                onChanged: (v) => ref
                                    .read(notificationSettingsProvider.notifier)
                                    .toggle('quiet', v),
                                activeThumbColor: colorScheme.onSurface,
                              ),
                            ],
                          ),
                        ),
                        Divider(color: colorScheme.outline, height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'START',
                                    style: TextStyle(
                                      fontFamily: 'DM Mono',
                                      fontSize: 9,
                                      color: colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '10:00 PM',
                                    style: TextStyle(
                                      fontFamily: 'Syne',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: colorScheme.outline,
                              ),
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
      style: TextStyle(
        fontFamily: 'DM Mono',
        fontSize: 10,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 9,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: iconColor,
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: colorScheme.outline, height: 1, indent: 72),
      ],
    );
  }
}
