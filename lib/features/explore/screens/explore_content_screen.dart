// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:flutter/material.dart';

class ExploreContentScreen extends StatelessWidget {
  const ExploreContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero banner
              SliverToBoxAdapter(
                child: Container(
                  height: 380,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface,
                    image: DecorationImage(
                      image: const NetworkImage(
                        'https://picsum.photos/seed/turing/800/600',
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        colorScheme.onSurface.withValues(alpha: 0.5),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 0, 26, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'NOTABLE PEOPLE',
                            style: TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.9,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Alan Turing: Father of Computer Science',
                          style: TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                            letterSpacing: -0.56,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'AT',
                                  style: TextStyle(
                                    fontFamily: 'Syne',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'Alan Turing · 1912–1954\n8 min read · CS History',
                                style: TextStyle(
                                  fontFamily: 'DM Mono',
                                  fontSize: 10,
                                  height: 1.4,
                                  color: Color(0xCCFFFFFF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Article Body
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(26, 32, 26, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      'Alan Mathison Turing was an English mathematician, computer scientist, and logician. Often regarded as the father of theoretical computer science and artificial intelligence, his contributions reshaped the entire trajectory of modern computing.',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 13,
                        height: 1.6,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Pull Quote
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border.all(color: colorScheme.outline),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"We can only see a short distance ahead, but we can see plenty there that needs to be done."',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '— Alan Turing, 1950',
                            style: TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 10,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Key Contributions',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 10,
                        letterSpacing: 1.8,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The Turing Machine',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'In 1936, Turing introduced the concept of a universal machine capable of computing any computable function — the theoretical foundation for all modern computers.',
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 12,
                        height: 1.6,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Key facts chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFactChip(context, 'Born: June 23, 1912'),
                        _buildFactChip(context, 'Nationality: British'),
                        _buildFactChip(context, 'Field: Mathematics, CS'),
                        _buildFactChip(
                          context,
                          'Turing Test · 1950',
                          isHighlight: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Breaking Enigma',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "During World War II, Turing led the team at Bletchley Park that cracked Nazi Germany's Enigma code — a breakthrough credited with shortening the war by an estimated two years.",
                      style: TextStyle(
                        fontFamily: 'DM Mono',
                        fontSize: 12,
                        height: 1.6,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Related quiz CTA
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Test your knowledge',
                                  style: TextStyle(
                                    fontFamily: 'DM Mono',
                                    fontSize: 10,
                                    letterSpacing: 1.0,
                                    color: colorScheme.surface.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Take the Turing Quiz',
                                  style: TextStyle(
                                    fontFamily: 'Syne',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: colorScheme.surface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: colorScheme.surface,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // Top Nav Overlays
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Multimedia',
                            style: TextStyle(
                              fontFamily: 'DM Mono',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: const Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactChip(
    BuildContext context,
    String text, {
    bool isHighlight = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isHighlight ? colorScheme.onSurface : Colors.transparent,
        border: Border.all(
          color: isHighlight ? colorScheme.onSurface : colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'DM Mono',
          fontSize: 10,
          color: isHighlight
              ? colorScheme.surface
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
