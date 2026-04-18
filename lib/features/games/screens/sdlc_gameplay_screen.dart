import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/games/widgets/game_timer.dart';

class SdlcPhase {
  final String title;
  final String desc;
  SdlcPhase({required this.title, required this.desc});
}

class SdlcGameplayScreen extends ConsumerStatefulWidget {
  const SdlcGameplayScreen({super.key});

  @override
  ConsumerState<SdlcGameplayScreen> createState() => _SdlcGameplayScreenState();
}

class _SdlcGameplayScreenState extends ConsumerState<SdlcGameplayScreen> {
  int _timeLeft = 33;
  int _totalTime = 45;
  Timer? _timer;
  
  final List<SdlcPhase> _correctOrder = [
    SdlcPhase(title: 'Planning', desc: 'Define scope & feasibility'),
    SdlcPhase(title: 'Analysis', desc: 'Gather & document requirements'),
    SdlcPhase(title: 'Design', desc: 'System architecture & UI design'),
    SdlcPhase(title: 'Implementation', desc: 'Write & build the actual code'),
    SdlcPhase(title: 'Testing', desc: 'QA, bug detection & fixes'),
    SdlcPhase(title: 'Maintenance', desc: 'Ongoing support & updates'),
  ];

  late List<SdlcPhase> _placedPhases;
  late List<SdlcPhase> _availablePhases;

  @override
  void initState() {
    super.initState();
    _placedPhases = [_correctOrder[0], _correctOrder[1]]; // Starting state in screenshot
    _availablePhases = [_correctOrder[3], _correctOrder[4], _correctOrder[2], _correctOrder[5]];
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) setState(() => _timeLeft--);
      else _timer?.cancel();
    });
  }

  void _onDrop(SdlcPhase phase) {
    if (phase.title == _correctOrder[_placedPhases.length].title) {
      HapticFeedback.lightImpact();
      setState(() {
        _placedPhases.add(phase);
        _availablePhases.remove(phase);
      });
      if (_placedPhases.length == _correctOrder.length) {
        _timer?.cancel();
        // Show Success
      }
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left_rounded), label: const Text('Exit', style: TextStyle(fontFamily: 'DM Mono'))),
                  Row(children: [
                    ...List.generate(5, (i) => Container(margin: const EdgeInsets.only(left: 4), width: 6, height: 6, decoration: BoxDecoration(color: i < 3 ? colorScheme.onSurface : colorScheme.outline.withValues(alpha: 0.3), shape: BoxShape.circle))),
                    const SizedBox(width: 12),
                    Text('Round 3 / 5', style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: colorScheme.onSurfaceVariant)),
                  ]),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GameTimer(timeLeft: _timeLeft, totalTime: _totalTime),
                    const SizedBox(height: 32),
                    Text('DRAG TO ARRANGE IN CORRECT ORDER →', style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, letterSpacing: 1.2, color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 16),

                    // Placed Phases
                    ..._placedPhases.asMap().entries.map((e) => _buildPlacedCard(context, e.key + 1, e.value)),

                    // Drop Target
                    if (_placedPhases.length < _correctOrder.length)
                      DragTarget<SdlcPhase>(
                        onAcceptWithDetails: (d) => _onDrop(d.data),
                        builder: (context, candidate, _) => Container(
                          width: double.infinity,
                          height: 72,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: colorScheme.onSurface, width: 1.5, style: BorderStyle.solid),
                          ),
                          child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Container(width: 32, height: 32, decoration: BoxDecoration(color: colorScheme.onSurface.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.question_mark_rounded, size: 14, color: Colors.black12)),
                            const SizedBox(width: 12),
                            const Text('Drop phase here...', style: TextStyle(fontFamily: 'DM Mono', fontSize: 12, color: Colors.black12)),
                          ])),
                        ),
                      ),

                    // Available
                    ..._availablePhases.map((p) => Draggable<SdlcPhase>(
                      data: p,
                      feedback: Material(color: Colors.transparent, child: SizedBox(width: MediaQuery.of(context).size.width - 48, child: _buildDraggableCard(context, p, isDragging: true))),
                      childWhenDragging: Opacity(opacity: 0.3, child: _buildDraggableCard(context, p)),
                      child: _buildDraggableCard(context, p),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacedCard(BuildContext context, int index, SdlcPhase p) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colorScheme.onSurface, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: colorScheme.surface.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Center(child: Text('$index', style: const TextStyle(color: Colors.white, fontFamily: 'Syne', fontWeight: FontWeight.bold)))),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.title, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white)),
          Text(p.desc, style: const TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: Colors.white38)),
        ]),
        const Spacer(),
        const Icon(Icons.check_rounded, color: Colors.white38, size: 18),
      ]),
    );
  }

  Widget _buildDraggableCard(BuildContext context, SdlcPhase p, {bool isDragging = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDragging ? [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))] : null,
      ),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: colorScheme.onSurface.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.square_rounded, color: Colors.black12, size: 14)),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.title, style: const TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.w800, fontSize: 15)),
          Text(p.desc, style: TextStyle(fontFamily: 'DM Mono', fontSize: 10, color: colorScheme.onSurfaceVariant)),
        ]),
      ]),
    );
  }
}
