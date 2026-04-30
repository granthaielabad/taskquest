import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/home/providers/activity_provider.dart';

class AllActivityScreen extends ConsumerWidget {
  const AllActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(allActivitiesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Activity History',
          style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: activitiesAsync.when(
        data: (activities) {
          if (activities.isEmpty) {
            return const Center(
              child: Text(
                'No activity yet.',
                style: TextStyle(fontFamily: 'DM Mono'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              IconData icon = Icons.bolt_rounded;
              bool isDark = false;
              if (activity.type == ActivityType.scan) {
                icon = Icons.document_scanner_rounded;
              }
              if (activity.type == ActivityType.game) {
                icon = Icons.videogame_asset_rounded;
                isDark = true;
              }
              if (activity.type == ActivityType.study) {
                icon = Icons.menu_book_rounded;
              }

              final diff = DateTime.now().difference(activity.timestamp);
              String timeStr = 'Just now';
              if (diff.inMinutes > 0) timeStr = '${diff.inMinutes}m ago';
              if (diff.inHours > 0) timeStr = '${diff.inHours}h ago';
              if (diff.inDays > 0) timeStr = '${diff.inDays}d ago';

              return _ActivityListItem(
                icon: icon,
                title: activity.title,
                sub: activity.subtitle,
                xp: '+${activity.xpReward} XP',
                time: timeStr,
                isDarkIcon: isDark,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ActivityListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final String xp;
  final String time;
  final bool isDarkIcon;

  const _ActivityListItem({
    required this.icon,
    required this.title,
    required this.sub,
    required this.xp,
    required this.time,
    this.isDarkIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDarkIcon
                  ? colorScheme.onSurface
                  : theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDarkIcon ? colorScheme.surface : colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                xp,
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 8,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
