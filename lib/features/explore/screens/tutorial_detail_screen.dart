// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:taskquest/features/explore/providers/tutorial_completion_provider.dart';
import 'package:taskquest/features/explore/services/explore_api_service.dart';

import 'package:flutter/services.dart';

class TutorialDetailScreen extends ConsumerStatefulWidget {
  final TutorialCourse tutorial;

  const TutorialDetailScreen({super.key, required this.tutorial});

  @override
  ConsumerState<TutorialDetailScreen> createState() =>
      _TutorialDetailScreenState();
}

class _TutorialDetailScreenState extends ConsumerState<TutorialDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final completedIds = ref.watch(tutorialCompletionProvider);
    final isCompleted = completedIds.contains(widget.tutorial.id);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                widget.tutorial.topic,
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tutorial.title,
                    style: const TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoTag(
                        widget.tutorial.difficulty,
                        colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(width: 12),
                        _buildInfoTag(
                          'COMPLETED',
                          colorScheme.primary.withValues(alpha: 0.1),
                          textColor: colorScheme.primary,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 32),
                  MarkdownBody(
                    data: widget.tutorial.contentMarkdown,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 14,
                        height: 1.6,
                        color: colorScheme.onSurface.withValues(alpha: 0.85),
                      ),
                      // Fixed the assertion error: fontSize must be > 0
                      h1: const TextStyle(
                        fontSize: 1,
                        color: Colors.transparent,
                      ),
                      h2: const TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        height: 1.4,
                      ),
                      code: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outline),
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: colorScheme.outline)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isCompleted ? null : _markAsRead,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted
                        ? Colors.blueGrey.withValues(alpha: 0.2)
                        : colorScheme.onSurface,
                    foregroundColor: isCompleted
                        ? colorScheme.onSurfaceVariant
                        : theme.scaffoldBackgroundColor,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isCompleted ? 'KNOWLEDGE SECURED ✓' : 'FINISH READING',
                    style: const TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markAsRead() {
    ref
        .read(tutorialCompletionProvider.notifier)
        .completeTutorial(widget.tutorial.id);
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Nicely done! You have successfully completed this lesson.',
        ),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  Widget _buildInfoTag(String label, Color bgColor, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: textColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
