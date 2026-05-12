import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/lab/providers/lab_provider.dart';
import 'package:taskquest/features/lab/models/lab_models.dart';

class QuickSortVisualizerScreen extends ConsumerStatefulWidget {
  const QuickSortVisualizerScreen({super.key});

  @override
  ConsumerState<QuickSortVisualizerScreen> createState() =>
      _QuickSortVisualizerScreenState();
}

class _QuickSortVisualizerScreenState
    extends ConsumerState<QuickSortVisualizerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quickSortLabProvider.notifier).initializeLab(
        [65, 20, 80, 10, 45, 30, 95, 50, 15, 70],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quickSortLabProvider);
    final currentStep = state.currentStep;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'QUICK SORT',
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(currentStep, colorScheme),
          const Spacer(),
          if (currentStep != null)
            _buildVisualizer(currentStep, colorScheme)
          else
            const Center(child: CircularProgressIndicator()),
          const Spacer(),
          _buildControlPanel(state, colorScheme),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(QuickSortStep? step, ColorScheme colorScheme) {
    return Container(
      constraints: const BoxConstraints(minHeight: 160, maxHeight: 220),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PARTITIONING LOGIC',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: colorScheme.onInverseSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              step?.message ?? 'Initializing...',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                height: 1.5,
                color: colorScheme.onInverseSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizer(QuickSortStep step, ColorScheme colorScheme) {
    return Container(
      height: 300,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: step.list.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;

          Color barColor = colorScheme.outline.withValues(alpha: 0.3);
          bool isPivot = index == step.pivotIndex;
          bool isWall = index == step.i;
          bool isScanner = index == step.j;
          bool isInRange = index >= step.low && index <= step.high;

          if (isPivot) {
            barColor = Colors.orangeAccent;
          } else if (isScanner) {
            barColor = colorScheme.primary;
          } else if (isWall) {
            barColor = Colors.redAccent;
          } else if (isInRange) {
            barColor = colorScheme.onSurface.withValues(alpha: 0.6);
          }

          return _AnimatedBar(
            value: value,
            index: index,
            color: barColor,
            isPivot: isPivot,
            isScanner: isScanner,
            isWall: isWall,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildControlPanel(QuickSortState state, ColorScheme colorScheme) {
    final notifier = ref.read(quickSortLabProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Pivot', Colors.orangeAccent),
              const SizedBox(width: 16),
              _buildLegend('Scanner (j)', colorScheme.primary),
              const SizedBox(width: 16),
              _buildLegend('Wall (i)', Colors.redAccent),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP ${state.currentStepIndex + 1} / ${state.steps.length}',
                style: const TextStyle(fontFamily: 'DM Mono', fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ControlButton(
                  onTap: state.canStepBackward ? notifier.previousStep : null,
                  icon: Icons.skip_previous_rounded,
                  label: 'PREV',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ControlButton(
                  onTap: state.canStepForward ? notifier.nextStep : notifier.reset,
                  icon: state.canStepForward ? Icons.play_arrow_rounded : Icons.refresh_rounded,
                  label: state.canStepForward ? 'NEXT' : 'RESET',
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontFamily: 'DM Mono', fontSize: 8)),
      ],
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  final int value;
  final int index;
  final Color color;
  final bool isPivot;
  final bool isScanner;
  final bool isWall;

  const _AnimatedBar({
    required this.value,
    required this.index,
    required this.color,
    this.isPivot = false,
    this.isScanner = false,
    this.isWall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$value',
            style: const TextStyle(fontFamily: 'DM Mono', fontSize: 8, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: value * 2.0,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 12,
            child: isScanner 
              ? const Icon(Icons.arrow_drop_up_rounded, size: 16, color: Colors.blue)
              : (isWall ? const Icon(Icons.arrow_drop_up_rounded, size: 16, color: Colors.red) : null),
          ),
          const SizedBox(height: 4),
          Text(
            '$index',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final String label;
  final bool isPrimary;

  const _ControlButton({
    this.onTap,
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDisabled 
              ? colorScheme.outline.withValues(alpha: 0.1)
              : (isPrimary ? colorScheme.onSurface : colorScheme.surface),
          border: Border.all(
            color: isPrimary ? Colors.transparent : colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isDisabled 
                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                  : (isPrimary ? colorScheme.surface : colorScheme.onSurface),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isDisabled 
                    ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                    : (isPrimary ? colorScheme.surface : colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
