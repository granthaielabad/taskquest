// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';
import 'package:taskquest/features/auth/providers/user_provider.dart';
import 'package:taskquest/features/explore/providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentUser = ref.watch(authStateProvider).value;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Global Ranking',
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: leaderboardAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No scholars found yet.'));
          }

          final top3 = users.take(3).toList();
          final others = users.skip(3).toList();

          return Column(
            children: [
              const SizedBox(height: 24),
              // ── Top 3 Podium ────────────────────────────────────────
              _buildPodium(context, top3),

              const SizedBox(height: 32),

              // ── Ranked List ─────────────────────────────────────────
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    itemCount: others.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = others[index];
                      final rank = index + 4;
                      final isCurrent = user.uid == currentUser?.uid;

                      return _buildLeaderboardTile(
                        context,
                        user,
                        rank,
                        isCurrent,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildPodium(BuildContext context, List<UserModel> top3) {
    if (top3.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 2nd Place
            if (top3.length > 1) _buildPodiumItem(context, top3[1], 2, 70),
            const SizedBox(width: 12),
            // 1st Place
            _buildPodiumItem(context, top3[0], 1, 90),
            const SizedBox(width: 12),
            // 3rd Place
            if (top3.length > 2) _buildPodiumItem(context, top3[2], 3, 60),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumItem(
    BuildContext context,
    UserModel user,
    int rank,
    double size,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      Colors.amber,
      const Color(0xFFC0C0C0),
      Colors.orange.shade300,
    ];
    final color = colors[rank - 1];

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: colorScheme.onSurface,
                borderRadius: BorderRadius.circular(size * 0.3),
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(
                  user.displayName[0].toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w800,
                    fontSize: size * 0.4,
                    color: colorScheme.surface,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.surface, width: 2),
                ),
                child: Text(
                  rank == 1
                      ? '1ST'
                      : rank == 2
                      ? '2ND'
                      : '3RD',
                  style: const TextStyle(
                    fontFamily: 'DM Mono',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          user.displayName.split(' ').first,
          style: TextStyle(
            fontFamily: 'Syne',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          '${user.streak} day streak',
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(
    BuildContext context,
    UserModel user,
    int rank,
    bool isCurrent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent
            ? colorScheme.onSurface.withValues(alpha: 0.05)
            : Colors.transparent,
        border: Border.all(
          color: isCurrent ? colorScheme.onSurface : colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.onSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                user.displayName[0].toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Syne',
                  color: colorScheme.surface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              user.displayName,
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            '${user.streak} days',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
