import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskquest/core/theme/app_theme.dart';
import '../services/notification_service.dart';

class NotificationSettings {
  final Map<String, bool> toggles;
  final int reminderHour;
  final int reminderMinute;

  NotificationSettings({
    required this.toggles,
    required this.reminderHour,
    required this.reminderMinute,
  });

  NotificationSettings copyWith({
    Map<String, bool>? toggles,
    int? reminderHour,
    int? reminderMinute,
  }) {
    return NotificationSettings(
      toggles: toggles ?? this.toggles,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
    );
  }
}

class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  static const String _prefKey = 'notification_settings_v3';
  static const String _hourKey = 'reminder_hour';
  static const String _minuteKey = 'reminder_minute';

  @override
  NotificationSettings build() {
    _loadSettings();
    return NotificationSettings(
      toggles: {
        'all': true,
        'daily': true,
        'streak': true,
        'quest': true,
        'xp': false,
        'social': false,
        'announcements': true,
        'quiet': true,
      },
      reminderHour: 9, // Default 9 AM
      reminderMinute: 0,
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList(_prefKey);
    final hour = prefs.getInt(_hourKey) ?? 9;
    final minute = prefs.getInt(_minuteKey) ?? 0;

    Map<String, bool> toggles = state.toggles;
    if (saved != null) {
      final Map<String, bool> loadedToggles = {};
      for (var item in saved) {
        final parts = item.split(':');
        if (parts.length == 2) {
          loadedToggles[parts[0]] = parts[1] == 'true';
        }
      }
      toggles = loadedToggles;
    }
    
    state = NotificationSettings(
      toggles: toggles,
      reminderHour: hour,
      reminderMinute: minute,
    );
  }

  Future<void> updateReminderTime(int hour, int minute) async {
    state = state.copyWith(reminderHour: hour, reminderMinute: minute);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey, hour);
    await prefs.setInt(_minuteKey, minute);

    // Re-schedule daily reminder with the new time if active
    if (state.toggles['all'] == true && state.toggles['daily'] == true) {
      await NotificationService().scheduleDailyReminder(
        hour, 
        minute,
        id: 1,
        title: 'Daily Quest! ⚔️',
        body: 'Your daily challenges are waiting.',
      );
    }
  }

  Future<void> toggle(String key, bool value) async {
    final newToggles = {...state.toggles, key: value};
    state = state.copyWith(toggles: newToggles);

    final prefs = await SharedPreferences.getInstance();
    final List<String> list = newToggles.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList(_prefKey, list);

    final service = NotificationService();
    
    if (key == 'all' && value == false) {
      await service.cancelAll();
    } else if (newToggles['all'] == true) {
      if (key == 'daily') {
        if (value) {
          // Now schedules for the user-selected time (default 9am)
          await service.scheduleDailyReminder(
            state.reminderHour, 
            state.reminderMinute,
            id: 1,
            title: 'Daily Quest! ⚔️',
            body: 'Your daily challenges are waiting.',
          );
        } else {
          // Optional: Cancel specifically ID 1 here if you want
        }
      } else if (value == true && key != 'quiet') {
        // Keeping other buttons as 30s test for now, or you can set them to their real logic
        _triggerTestNotif(key);
      }
    }
  }

  Future<void> _triggerTestNotif(String key) async {
    String title = 'Reminder';
    String body = 'Time to check TaskQuest!';
    int notificationId = 1;

    switch (key) {
      case 'streak':
        title = 'Streak at Risk! 🔥';
        body = 'Open the app now to keep your streak alive.';
        notificationId = 2;
        break;
      case 'quest':
        title = 'Quest Completed! ✅';
        body = 'Well done! Check your rewards.';
        notificationId = 3;
        break;
      case 'xp':
        title = 'XP Milestone! ⚡';
        body = 'You are close to a new level-up.';
        notificationId = 4;
        break;
      case 'social':
        title = 'Friend Activity! 👥';
        body = 'See what your friends are up to.';
        notificationId = 5;
        break;
      case 'announcements':
        title = 'New Announcement! 📢';
        body = 'Check out the latest updates.';
        notificationId = 6;
        break;
    }

    await NotificationService().scheduleTestNotification(
      30, 
      id: notificationId,
      title: title,
      body: body,
    );
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      NotificationSettingsNotifier.new,
    );

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _selectTime(BuildContext context, WidgetRef ref, int currentHour, int currentMinute) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.black,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      ref.read(notificationSettingsProvider.notifier).updateReminderTime(picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
                      child: Icon(Icons.chevron_left_rounded, color: colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        letterSpacing: -0.5,
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
                    const SizedBox(height: 20),
                    
                    // Master Switch
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? colorScheme.onSurface.withOpacity(0.1) : Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? colorScheme.surface : const Color(0xFF262626),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.notifications_none_rounded, color: isDark ? colorScheme.onSurface : Colors.white, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text('All Notifications',
                                      style: TextStyle(
                                        fontFamily: 'Syne', 
                                        fontWeight: FontWeight.w800, 
                                        fontSize: 16, 
                                        color: isDark ? colorScheme.onSurface : Colors.white
                                      )),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text('Master switch for all alerts',
                                      style: TextStyle(
                                        fontFamily: 'DM Mono', 
                                        fontSize: 10, 
                                        color: isDark ? colorScheme.onSurface.withOpacity(0.6) : Colors.white.withOpacity(0.4)
                                      )),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Switch(
                            value: settings.toggles['all'] ?? true,
                            onChanged: (v) => ref.read(notificationSettingsProvider.notifier).toggle('all', v),
                            activeColor: isDark ? colorScheme.primary : Colors.white,
                            activeTrackColor: isDark ? colorScheme.primary.withOpacity(0.3) : const Color(0xFF404040),
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
                          value: settings.toggles['daily'] ?? true,
                          onChanged: (v) => ref.read(notificationSettingsProvider.notifier).toggle('daily', v),
                        ),
                        if (settings.toggles['daily'] == true) ...[
                          Divider(color: colorScheme.outline, height: 1, indent: 72),
                          _TimeSelectionTile(
                            label: 'REMINDER TIME',
                            hour: settings.reminderHour,
                            minute: settings.reminderMinute,
                            onTap: () => _selectTime(context, ref, settings.reminderHour, settings.reminderMinute),
                          ),
                        ],
                        Divider(color: colorScheme.outline, height: 1, indent: 72),
                        _NotificationTile(
                          icon: Icons.star_outline_rounded,
                          iconBg: const Color(0xFFFFF7E6),
                          iconColor: const Color(0xFFFFAB00),
                          title: 'Streak Alert',
                          subtitle: 'Remind before streak breaks',
                          value: settings.toggles['streak'] ?? true,
                          onChanged: (v) => ref.read(notificationSettingsProvider.notifier).toggle('streak', v),
                        ),
                        Divider(color: colorScheme.outline, height: 1, indent: 72),
                        _NotificationTile(
                          icon: Icons.check_box_outlined,
                          iconBg: const Color(0xFFE6F9F0),
                          iconColor: const Color(0xFF00C853),
                          title: 'Quest Complete',
                          subtitle: 'When you finish a daily quest',
                          value: settings.toggles['quest'] ?? true,
                          onChanged: (v) => ref.read(notificationSettingsProvider.notifier).toggle('quest', v),
                        ),
                        Divider(color: colorScheme.outline, height: 1, indent: 72),
                        _NotificationTile(
                          icon: Icons.timeline_rounded,
                          iconBg: isDark ? colorScheme.onSurface.withOpacity(0.05) : const Color(0xFFF5F5F5),
                          iconColor: isDark ? colorScheme.onSurface.withOpacity(0.4) : const Color(0xFF9E9E9E),
                          title: 'XP Milestones',
                          subtitle: 'Level-up and XP threshold alerts',
                          value: settings.toggles['xp'] ?? false,
                          onChanged: (v) => ref.read(notificationSettingsProvider.notifier).toggle('xp', v),
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
                          iconBg: isDark ? colorScheme.onSurface.withOpacity(0.05) : const Color(0xFFF5F5F5),
                          iconColor: isDark ? colorScheme.onSurface.withOpacity(0.4) : const Color(0xFF9E9E9E),
                          title: 'Friend Activity',
                          subtitle: 'When friends earn badges or level up',
                          value: settings.toggles['social'] ?? false,
                          onChanged: (v) => ref.read(notificationSettingsProvider.notifier).toggle('social', v),
                        ),
                        Divider(color: colorScheme.outline, height: 1, indent: 72),
                        _NotificationTile(
                          icon: Icons.branding_watermark_outlined,
                          iconBg: isDark ? colorScheme.onSurface.withOpacity(0.05) : const Color(0xFFF5F5F5),
                          iconColor: isDark ? colorScheme.onSurface.withOpacity(0.4) : const Color(0xFF9E9E9E),
                          title: 'App Announcements',
                          subtitle: 'New content and feature updates',
                          value: settings.toggles['announcements'] ?? true,
                          onChanged: (v) => ref.read(notificationSettingsProvider.notifier).toggle('announcements', v),
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
                                        style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    const Text('Silence all alerts during set times',
                                        style: TextStyle(fontFamily: 'DM Mono', fontSize: 10)),
                                  ],
                                ),
                              ),
                              Switch(
                                value: settings.toggles['quiet'] ?? true,
                                onChanged: (v) => ref.read(notificationSettingsProvider.notifier).toggle('quiet', v),
                                activeColor: isDark ? colorScheme.onSurface : Colors.white,
                                activeTrackColor: isDark ? colorScheme.primary : AppTheme.black,
                              ),
                            ],
                          ),
                        ),
                        Divider(color: colorScheme.outline, height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('START',
                                      style: TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: colorScheme.onSurfaceVariant.withOpacity(0.5))),
                                  const SizedBox(height: 4),
                                  const Text('10:00 PM',
                                      style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 18)),
                                ],
                              ),
                              const Icon(Icons.chevron_right_rounded),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
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
                  child: Text(title,
                      style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(subtitle,
                      style: const TextStyle(fontFamily: 'DM Mono', fontSize: 9)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: iconColor,
          ),
        ],
      ),
    );
  }
}

class _TimeSelectionTile extends StatelessWidget {
  final String label;
  final int hour;
  final int minute;
  final VoidCallback onTap;

  const _TimeSelectionTile({
    required this.label,
    required this.hour,
    required this.minute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final time = TimeOfDay(hour: hour, minute: minute);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 52), // Align with text above
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: colorScheme.onSurfaceVariant.withOpacity(0.5))),
                  const SizedBox(height: 4),
                  Text(time.format(context),
                      style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 18)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
