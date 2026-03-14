import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Top nav
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('GOOD MORNING',
                          style: TextStyle(fontFamily: 'DM Mono', fontSize: 10,
                              letterSpacing: 1.4, color: AppTheme.muted)),
                      SizedBox(height: 2),
                      Text('User 👋',
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
                      child: const Icon(Icons.notifications_none_rounded,
                          color: AppTheme.black, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(child: Text('U',
                          style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800,
                              fontSize: 13, color: Colors.white))),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: 16),

              // Streak banner
              Container(
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
              const SizedBox(height: 20),
              const Text('DAILY QUEST',
                  style: TextStyle(fontFamily: 'DM Mono', fontSize: 10,
                      letterSpacing: 1.8, color: AppTheme.muted)),
              const SizedBox(height: 10),
              // Daily Quest card
              Container(
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
                    _QuestItem(done: true, title: 'Flashcard Review',
                        sub: '10 cards · Python Basics', xp: 120),
                    _QuestItem(done: true, title: 'SDLC Sequence',
                        sub: 'Arrange 6 phases · Timed', xp: 80),
                    _QuestItem(done: false, title: 'Code Block Challenge',
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
                      child: LinearProgressIndicator(
                        value: 200 / 350,
                        minHeight: 4,
                        backgroundColor: AppTheme.border,
                        valueColor: AlwaysStoppedAnimation(AppTheme.black),
                      ),
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
          child: done ? const Icon(Icons.check, color: Colors.white, size: 11) : null,
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