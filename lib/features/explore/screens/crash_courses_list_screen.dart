// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/explore/providers/explore_provider.dart';
import 'package:taskquest/features/explore/providers/tutorial_completion_provider.dart';
import 'package:taskquest/features/explore/screens/tutorial_detail_screen.dart';
import 'package:taskquest/features/explore/services/explore_api_service.dart';

class CrashCoursesListScreen extends ConsumerStatefulWidget {
  const CrashCoursesListScreen({super.key});

  @override
  ConsumerState<CrashCoursesListScreen> createState() =>
      _CrashCoursesListScreenState();
}

class _CrashCoursesListScreenState
    extends ConsumerState<CrashCoursesListScreen> {
  String _selectedFilter = 'ALL';
  final List<String> _filters = ['ALL', 'UNREAD', 'COMPLETED'];

  @override
  Widget build(BuildContext context) {
    final tutorialsAsync = ref.watch(crashCoursesProvider);
    final completedIds = ref.watch(tutorialCompletionProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CRASH COURSES',
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 12,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildFilters(context),
          const SizedBox(height: 24),
          Expanded(
            child: tutorialsAsync.when(
              data: (tutorials) {
                final filteredList = tutorials.where((t) {
                  final isDone = completedIds.contains(t.id);
                  if (_selectedFilter == 'UNREAD') return !isDone;
                  if (_selectedFilter == 'COMPLETED') return isDone;
                  return true;
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_stories_rounded,
                          size: 48,
                          color: colorScheme.outline.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No courses found in this category.',
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final t = filteredList[index];
                    final isDone = completedIds.contains(t.id);
                    return _buildCourseTile(context, t, isDone);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.surface
                      : colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedFilter = filter);
              },
              selectedColor: colorScheme.onSurface,
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.outline,
                ),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCourseTile(BuildContext context, TutorialCourse t, bool isDone) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TutorialDetailScreen(tutorial: t),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(
            color: isDone
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          t.topic,
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t.difficulty.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'DM Mono',
                          fontSize: 8,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.title,
                    style: const TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'DM Mono',
                      fontSize: 10,
                      height: 1.4,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (isDone)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.outline,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
