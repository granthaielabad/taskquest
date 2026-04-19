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
  static const String _prefKey = 'notification_settings_v5'; 
  static const String _hourKey = 'reminder_hour';
  static const String _minuteKey = 'reminder_minute';
  
  Map<String, bool> _previousState = {};

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
      reminderHour: 9, 
      reminderMinute: 0,
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList(_prefKey);
    final hour = prefs.getInt(_hourKey) ?? 9;
    final minute = prefs.getInt(_minuteKey) ?? 0;

    if (saved != null) {
      final Map<String, bool> loadedToggles = {};
      for (var item in saved) {
        final parts = item.split(':');
        if (parts.length == 2) {
          loadedToggles[parts[0]] = parts[1] == 'true';
        }
      }
      state = NotificationSettings(
        toggles: loadedToggles,
        reminderHour: hour,
        reminderMinute: minute,
      );
    }
  }

  Future<void> updateReminderTime(int hour, int minute) async {
    state = state.copyWith(reminderHour: hour, reminderMinute: minute);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey, hour);
    await prefs.setInt(_minuteKey, minute);

    if (state.toggles['all'] == true && state.toggles['daily'] == true) {
      await NotificationService().scheduleDailyReminder(hour, minute, id: 1, title: 'Daily Quest! ⚔️', body: 'Your daily challenges are waiting.');
    }
  }

  Future<void> toggle(String key, bool value) async {
    Map<String, bool> newToggles = {...state.toggles};

    if (key == 'all') {
      if (value == false) {
        _previousState = Map<String, bool>.from(newToggles);
        newToggles = newToggles.map((k, v) => MapEntry(k, false));
        await NotificationService().cancelAll();
      } else {
        if (_previousState.isNotEmpty) {
          newToggles = Map<String, bool>.from(_previousState);
        }
        newToggles['all'] = true;
        _retriggerActiveNotifications(newToggles);
      }
    } else {
      newToggles[key] = value;
      if (value == true && newToggles['all'] == true) {
        _triggerLogicForKey(key);
      }
    }

    state = state.copyWith(toggles: newToggles);

    final prefs = await SharedPreferences.getInstance();
    final List<String> list = newToggles.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList(_prefKey, list);
  }

  void _retriggerActiveNotifications(Map<String, bool> toggles) {
    if (toggles['daily'] == true) _triggerLogicForKey('daily');
    if (toggles['streak'] == true) _triggerLogicForKey('streak');
  }

  void _triggerLogicForKey(String key) {
    final service = NotificationService();
    switch (key) {
      case 'daily':
        service.scheduleDailyReminder(state.reminderHour, state.reminderMinute, id: 1, title: 'Daily Quest! ⚔️', body: 'Your daily challenges are waiting.');
        break;
      case 'streak':
        service.scheduleDailyReminder(21, 0, id: 2, title: 'Streak at Risk! 🔥', body: 'Open the app now to keep your streak alive.');
        break;
    }
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
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Colors.black,
              hourMinuteColor: WidgetStateColor.resolveWith((states) => 
                  states.contains(WidgetState.selected) ? Colors.blue.shade50 : Colors.grey.shade100),
              dayPeriodTextColor: Colors.black,
              dayPeriodColor: WidgetStateColor.resolveWith((states) => 
                  states.contains(WidgetState.selected) ? Colors.blue.shade50 : Colors.grey.shade100),
              dialBackgroundColor: Colors.grey.shade50,
              dialHandColor: Colors.blue.shade700,
              dialTextColor: Colors.black,
              entryModeIconColor: Colors.black,
              helpTextStyle: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold, color: Colors.black),
            ),
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700, // Background of circle and hand
              onPrimary: Colors.white, // Text color inside primary circle
              surface: Colors.white,
              onSurface: Colors.black,
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
    
    final bool masterEnabled = settings.toggles['all'] ?? true;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
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
                    child: Text('Notifications', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5)),
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
                                const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text('All Notifications', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text('Master switch for all alerts', style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: Colors.white.withOpacity(0.4))),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Switch(
                            value: masterEnabled,
                            onChanged: (v) => ref.read(notificationSettingsProvider.notifier).toggle('all', v),
                            activeColor: isDark ? colorScheme.primary : Colors.white,
                            activeTrackColor: isDark ? colorScheme.primary.withOpacity(0.3) : const Color(0xFF404040),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                    _SectionLabel(label: 'LEARNING', isEnabled: masterEnabled),
                    const SizedBox(height: 12),
                    _SettingsGroup(
                      isEnabled: masterEnabled,
                      children: [
                        _NotificationTile(
                          isEnabled: masterEnabled,
                          icon: Icons.access_time_rounded,
                          iconBg: const Color(0xFFE8F0FF),
                          iconColor: const Color(0xFF4A8BFF),
                          title: 'Daily Reminder',
                          subtitle: 'Nudge to complete daily quest',
                          value: settings.toggles['daily'] ?? true,
                          onChanged: (v) => ref.read(notificationSettingsProvider.notifier).toggle('daily', v),
                        ),
                        if (settings.toggles['daily'] == true && masterEnabled) ...[
                          Divider(color: colorScheme.outline, height: 1, indent: 72),
                          _TimeSelectionTile(
                            isEnabled: masterEnabled,
                            label: 'REMINDER TIME',
                            hour: settings.reminderHour,
                            minute: settings.reminderMinute,
                            onTap: () => _selectTime(context, ref, settings.reminderHour, settings.reminderMinute),
                          ),
                        ],
                        Divider(color: colorScheme.outline, height: 1, indent: 72),
                        _NotificationTile(
                          isEnabled: masterEnabled,
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
                          isEnabled: masterEnabled,
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
                          isEnabled: masterEnabled,
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
                    _SectionLabel(label: 'SOCIAL', isEnabled: masterEnabled),
                    const SizedBox(height: 12),
                    _SettingsGroup(
                      isEnabled: masterEnabled,
                      children: [
                        _NotificationTile(
                          isEnabled: masterEnabled,
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
                          isEnabled: masterEnabled,
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
  final bool isEnabled;
  const _SectionLabel({required this.label, this.isEnabled = true});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 10,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final bool isEnabled;
  const _SettingsGroup({required this.children, this.isEnabled = true});

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
  final bool isEnabled;

  const _NotificationTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
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
                    child: Text(title, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(subtitle, style: const TextStyle(fontFamily: 'DM Mono', fontSize: 9)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: isEnabled ? onChanged : null,
              activeColor: Colors.white,
              activeTrackColor: iconColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSelectionTile extends StatelessWidget {
  final String label;
  final int hour;
  final int minute;
  final VoidCallback onTap;
  final bool isEnabled;

  const _TimeSelectionTile({
    required this.label,
    required this.hour,
    required this.minute,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final time = TimeOfDay(hour: hour, minute: minute);
    
    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 52), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontFamily: 'DM Mono', fontSize: 9, color: colorScheme.onSurfaceVariant.withOpacity(0.5))),
                  const SizedBox(height: 4),
                  Text(time.format(context), style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 18)),
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
