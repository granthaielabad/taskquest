import 'package:flutter/material.dart';
import 'package:taskquest/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              
              // Top Nav
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('GOOD MORNING',
                            style: TextStyle(fontFamily: 'DM Mono', fontSize: 10,
                                letterSpacing: 1.4, color: AppTheme.muted)),
                        SizedBox(height: 2),
                        Text('Juan 👋',
                            style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800,
                                fontSize: 20, letterSpacing: -0.4, color: AppTheme.black)),
                      ],
                    ),
                    Row(children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          border: Border.all(color: AppTheme.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            const Center(child: Icon(Icons.notifications_none_rounded,
                                color: AppTheme.black, size: 16)),
                            Positioned(
                              top: 8, right: 8,
                              child: Container(
                                width: 6, height: 6,
                                decoration: BoxDecoration(
                                  color: AppTheme.black,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.white, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Text('JD',
                            style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800,
                                fontSize: 13, color: Colors.white))),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Streak Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.black,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CURRENT STREAK',
                              style: TextStyle(fontFamily: 'DM Mono', fontSize: 9,
                                  letterSpacing: 1.44, color: Color(0x66FFFFFF))),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: const [
                              Text('7', style: TextStyle(fontFamily: 'Syne',
                                  fontWeight: FontWeight.w800, fontSize: 26,
                                  color: Colors.white, letterSpacing: -0.78)),
                              SizedBox(width: 4),
                              Text('days', style: TextStyle(fontFamily: 'Syne',
                                  fontWeight: FontWeight.w600, fontSize: 13,
                                  color: Color(0x66FFFFFF))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Day circles
                          Row(
                            children: ['M','T','W','T','F','S','S'].asMap().entries.map((e) {
                              final isToday = e.key == 5;
                              final isFuture = e.key == 6;
                              return Container(
                                width: 26, height: 26, margin: const EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                  color: isToday ? Colors.white
                                      : isFuture ? const Color(0x14FFFFFF)
                                      : const Color(0x2EFFFFFF),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Center(child: Text(e.value,
                                    style: TextStyle(fontFamily: 'DM Mono', fontSize: 9,
                                        color: isToday ? AppTheme.black
                                            : isFuture ? const Color(0x4DFFFFFF)
                                            : const Color(0xCCFFFFFF)))),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('Lvl 4', style: TextStyle(fontFamily: 'Syne',
                              fontWeight: FontWeight.w800, fontSize: 16,
                              color: Colors.white, letterSpacing: -0.32)),
                          SizedBox(height: 2),
                          Text('1,840 XP', style: TextStyle(fontFamily: 'DM Mono', fontSize: 9,
                              letterSpacing: 0.9, color: Color(0x59FFFFFF))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Daily Quest
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('DAILY QUEST',
                    style: TextStyle(fontFamily: 'DM Mono', fontSize: 10,
                        letterSpacing: 1.8, color: AppTheme.muted)),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text("Today's Challenges",
                            style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800,
                                fontSize: 15, letterSpacing: -0.3, color: AppTheme.black)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            border: Border.all(color: AppTheme.border),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('2 / 3 done',
                              style: TextStyle(fontFamily: 'DM Mono', fontSize: 9,
                                  letterSpacing: 0.9, color: AppTheme.muted)),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      const _QuestItem(done: true, title: 'Flashcard Review',
                          sub: '10 cards · Python Basics', xp: 120),
                      const _QuestItem(done: true, title: 'SDLC Sequence',
                          sub: 'Arrange 6 phases · Timed', xp: 80),
                      const _QuestItem(done: false, title: 'Code Block Challenge',
                          sub: 'Fill missing syntax · JS', xp: 150),
                      const SizedBox(height: 14),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                        Text('DAILY PROGRESS', style: TextStyle(fontFamily: 'DM Mono',
                            fontSize: 9, letterSpacing: 0.9, color: AppTheme.muted)),
                        Text('200 / 350 XP', style: TextStyle(fontFamily: 'DM Mono',
                            fontSize: 9, fontWeight: FontWeight.w500, color: AppTheme.black)),
                      ]),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: const LinearProgressIndicator(
                          value: 200 / 350,
                          minHeight: 4,
                          backgroundColor: AppTheme.border,
                          valueColor: AlwaysStoppedAnimation(AppTheme.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Game Modes
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('GAME MODES',
                    style: TextStyle(fontFamily: 'DM Mono', fontSize: 10,
                        letterSpacing: 1.8, color: AppTheme.muted)),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _GamePill(
                      title: 'Flashcards',
                      desc: 'Manual or AI-generated',
                      tag: 'AI ✦ Featured',
                      icon: Icons.style,
                      isFeatured: true,
                    ),
                    SizedBox(width: 10),
                    _GamePill(
                      title: 'Code Blocks',
                      desc: 'Drag & drop syntax',
                      tag: 'Interactive',
                      icon: Icons.code,
                    ),
                    SizedBox(width: 10),
                    _GamePill(
                      title: 'Which Lang?',
                      desc: 'Identify from clues',
                      tag: 'Quiz',
                      icon: Icons.question_mark_rounded,
                    ),
                    SizedBox(width: 10),
                    _GamePill(
                      title: 'SDLC Sequence',
                      desc: 'Arrange dev phases',
                      tag: 'Puzzle',
                      icon: Icons.segment,
                    ),
                    SizedBox(width: 10),
                    _GamePill(
                      title: 'Algorithm',
                      desc: 'Pseudocode solving',
                      tag: 'Logic',
                      icon: Icons.lightbulb_outline,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recent Activity
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('RECENT ACTIVITY',
                        style: TextStyle(fontFamily: 'DM Mono', fontSize: 10,
                            letterSpacing: 1.8, color: AppTheme.muted)),
                    Text('SEE ALL',
                        style: TextStyle(fontFamily: 'DM Mono', fontSize: 9,
                            letterSpacing: 1.0, color: AppTheme.dimmed,
                            decoration: TextDecoration.underline)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: const [
                    _ActivityItem(
                      icon: Icons.lightbulb_outline,
                      title: 'Solve an Algorithm',
                      sub: '12 correct · Level 3',
                      xp: '+340 XP',
                      time: '2h ago',
                      isDarkIcon: true,
                    ),
                    SizedBox(height: 8),
                    _ActivityItem(
                      icon: Icons.style,
                      title: 'Flashcards — Python',
                      sub: '20 cards reviewed · 85%',
                      xp: '+210 XP',
                      time: 'Yesterday',
                    ),
                    SizedBox(height: 8),
                    _ActivityItem(
                      icon: Icons.question_mark_rounded,
                      title: 'Which Lang?',
                      sub: '8 / 10 correct · 180s',
                      xp: '+160 XP',
                      time: 'Yesterday',
                    ),
                    SizedBox(height: 8),
                    _ActivityItem(
                      icon: Icons.code,
                      title: 'Code Blocks — JS',
                      sub: '5 / 6 blocks correct',
                      xp: '+190 XP',
                      time: '2 days ago',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper Widgets

class _QuestItem extends StatelessWidget {
  final bool done;
  final String title;
  final String sub;
  final int xp;
  const _QuestItem({required this.done, required this.title,
    required this.sub, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            color: done ? AppTheme.black : Colors.transparent,
            border: Border.all(color: done ? AppTheme.black : AppTheme.dimmed),
            borderRadius: BorderRadius.circular(6),
          ),
          child: done ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(
            fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 13,
            color: done ? AppTheme.dimmed : AppTheme.black,
            decoration: done ? TextDecoration.lineThrough : null,
          )),
          Text(sub, style: const TextStyle(fontFamily: 'DM Mono',
              fontSize: 10, color: AppTheme.muted)),
        ])),
        Text('+$xp XP', style: TextStyle(fontFamily: 'DM Mono', fontSize: 10,
            letterSpacing: 0.6, color: done ? AppTheme.muted : AppTheme.black,
            fontWeight: done ? FontWeight.w400 : FontWeight.w500)),
      ]),
    );
  }
}

class _GamePill extends StatelessWidget {
  final String title;
  final String desc;
  final String tag;
  final IconData icon;
  final bool isFeatured;

  const _GamePill({
    required this.title,
    required this.desc,
    required this.tag,
    required this.icon,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFeatured ? 150 : 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFeatured ? AppTheme.black : AppTheme.white,
        border: Border.all(color: isFeatured ? AppTheme.black : AppTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: isFeatured ? Colors.white.withValues(alpha: 0.1) : AppTheme.background,
              border: isFeatured ? null : Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: isFeatured ? Colors.white : AppTheme.black),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(
            fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 12,
            color: isFeatured ? Colors.white : AppTheme.black,
          )),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(
            fontFamily: 'DM Mono', fontSize: 9, height: 1.4,
            color: isFeatured ? Colors.white.withValues(alpha: 0.4) : AppTheme.muted,
          )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isFeatured ? Colors.white.withValues(alpha: 0.1) : AppTheme.background,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(tag.toUpperCase(), style: TextStyle(
              fontFamily: 'DM Mono', fontSize: 8, letterSpacing: 0.08,
              color: isFeatured ? Colors.white.withValues(alpha: 0.6) : AppTheme.muted,
            )),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final String xp;
  final String time;
  final bool isDarkIcon;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.sub,
    required this.xp,
    required this.time,
    this.isDarkIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isDarkIcon ? AppTheme.black : AppTheme.background,
              border: Border.all(color: isDarkIcon ? AppTheme.black : AppTheme.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: isDarkIcon ? Colors.white : AppTheme.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                  fontFamily: 'Syne', fontWeight: FontWeight.w700, fontSize: 12,
                  color: AppTheme.black,
                )),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(
                  fontFamily: 'DM Mono', fontSize: 10, color: AppTheme.muted,
                )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(xp, style: const TextStyle(
                fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 13,
                color: AppTheme.black,
              )),
              const SizedBox(height: 3),
              Text(time, style: const TextStyle(
                fontFamily: 'DM Mono', fontSize: 9, color: AppTheme.dimmed,
              )),
            ],
          ),
        ],
      ),
    );
  }
}
