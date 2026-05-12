import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/lab/providers/lab_provider.dart';
import 'package:taskquest/features/lab/models/lab_models.dart';

class LinearSearchVisualizerScreen extends ConsumerStatefulWidget {
  const LinearSearchVisualizerScreen({super.key});

  @override
  ConsumerState<LinearSearchVisualizerScreen> createState() =>
      _LinearSearchVisualizerScreenState();
}

class _LinearSearchVisualizerScreenState
    extends ConsumerState<LinearSearchVisualizerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(linearSearchLabProvider.notifier).initializeLab(
        [45, 12, 89, 34, 42, 67, 21, 55],
        42,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(linearSearchLabProvider);
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
          'LINEAR SEARCH',
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
            _buildVisualization(currentStep, colorScheme)
          else
            const Center(child: CircularProgressIndicator()),
          const Spacer(),
          _buildControlPanel(state, colorScheme),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(LinearSearchStep? step, ColorScheme colorScheme) {
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
              'STEP LOGIC',
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

  Widget _buildVisualization(LinearSearchStep step, ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: step.list.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;

          bool isCurrent = index == step.currentIndex;
          bool isFound = step.status == LabStatus.found && isCurrent;

          return _SearchCard(
            value: value,
            index: index,
            isCurrent: isCurrent,
            isFound: isFound,
            colorScheme: colorScheme,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildControlPanel(LinearSearchState state, ColorScheme colorScheme) {
    final notifier = ref.read(linearSearchLabProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP ${state.currentStepIndex + 1} / ${state.steps.length}',
                style: const TextStyle(fontFamily: 'DM Mono', fontSize: 10),
              ),
              Text(
                'TARGET: ${state.target}',
                style: const TextStyle(
                  fontFamily: 'DM Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
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
                  icon: state.canStepForward 
                      ? Icons.play_arrow_rounded 
                      : Icons.refresh_rounded,
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
}

class _SearchCard extends StatelessWidget {
  final int value;
  final int index;
  final bool isCurrent;
  final bool isFound;
  final ColorScheme colorScheme;

  const _SearchCard({
    required this.value,
    required this.index,
    required this.isCurrent,
    required this.isFound,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 60,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isFound 
            ? Colors.green 
            : (isCurrent ? colorScheme.primary : colorScheme.surface),
        border: Border.all(
          color: isCurrent ? colorScheme.primary : colorScheme.outline,
          width: isCurrent ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isCurrent ? [
          BoxShadow(
            color: (isFound ? Colors.green : colorScheme.primary).withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: (isCurrent || isFound) 
                  ? Colors.white 
                  : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (isCurrent || isFound) 
                  ? Colors.white.withValues(alpha: 0.2) 
                  : colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'idx: $index',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: (isCurrent || isFound) 
                    ? Colors.white 
                    : colorScheme.onSurfaceVariant,
              ),
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
