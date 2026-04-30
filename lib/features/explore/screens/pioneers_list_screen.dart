// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/explore/providers/explore_provider.dart';
import 'package:taskquest/features/explore/screens/wiki_detail_screen.dart';

class PioneersListScreen extends ConsumerStatefulWidget {
  const PioneersListScreen({super.key});

  @override
  ConsumerState<PioneersListScreen> createState() => _PioneersListScreenState();
}

class _PioneersListScreenState extends ConsumerState<PioneersListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  final List<Map<String, String>> _filterCategories = [
    {'label': 'All', 'tag': 'Category:Computer_scientists'},
    {'label': 'Pioneers', 'tag': 'Category:Pioneers_of_computing'},
    {'label': 'Women', 'tag': 'Category:Women_computer_scientists'},
    {'label': 'AI', 'tag': 'Category:Artificial_intelligence_researchers'},
    {'label': 'Software', 'tag': 'Category:Software_engineers'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(pioneersProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pioneersAsync = ref.watch(pioneersProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'TECH PIONEERS',
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 12,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Search & Filters ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      ref.read(pioneersProvider.notifier).setSearchQuery(value);
                    },
                    style: const TextStyle(fontFamily: 'DM Mono', fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Search pioneers...',
                      hintStyle: TextStyle(
                        fontFamily: 'DM Mono',
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(pioneersProvider.notifier)
                                    .setSearchQuery('');
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: _filterCategories.map((cat) {
                final isSelected = pioneersAsync.value?.category == cat['tag'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      cat['label']!,
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 10,
                        color: isSelected
                            ? colorScheme.surface
                            : colorScheme.onSurface,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _searchController.clear();
                        ref
                            .read(pioneersProvider.notifier)
                            .setCategory(cat['tag']!);
                        setState(() {});
                      }
                    },
                    selectedColor: colorScheme.onSurface,
                    backgroundColor: colorScheme.surface,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? colorScheme.onSurface
                            : colorScheme.outline,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // ── Grid List ─────────────────────────────────────────────
          Expanded(
            child: pioneersAsync.when(
              data: (state) {
                final pioneers = state.pioneers;

                if (pioneers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No pioneers found.',
                      style: TextStyle(fontFamily: 'DM Mono'),
                    ),
                  );
                }

                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: pioneers.length + (state.isLoadingMore ? 2 : 0),
                  itemBuilder: (context, index) {
                    if (index >= pioneers.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _PioneerGridCard(title: pioneers[index]);
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
}

class _PioneerGridCard extends ConsumerWidget {
  final String title;

  const _PioneerGridCard({required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(wikiSummaryProvider(title));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WikiDetailScreen(title: title),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(24),
        ),
        child: summaryAsync.when(
          data: (summary) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: theme.scaffoldBackgroundColor,
                backgroundImage: summary?.thumbnailUrl != null
                    ? CachedNetworkImageProvider(summary!.thumbnailUrl!)
                    : null,
                child: summary?.thumbnailUrl == null
                    ? Icon(
                        Icons.person_rounded,
                        size: 40,
                        color: colorScheme.outline,
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const Icon(Icons.error_outline),
        ),
      ),
    );
  }
}
