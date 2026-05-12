import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/lab/providers/lab_provider.dart';
import 'package:taskquest/features/lab/models/lab_models.dart';

class KnapsackVisualizerScreen extends ConsumerStatefulWidget {
  const KnapsackVisualizerScreen({super.key});

  @override
  ConsumerState<KnapsackVisualizerScreen> createState() =>
      _KnapsackVisualizerScreenState();
}

class _KnapsackVisualizerScreenState
    extends ConsumerState<KnapsackVisualizerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(knapsackLabProvider.notifier).initializeLab(
        [
          KnapsackItem(name: 'Quest A', weight: 2, value: 30),
          KnapsackItem(name: 'Quest B', weight: 3, value: 40),
          KnapsackItem(name: 'Quest C', weight: 4, value: 50),
          KnapsackItem(name: 'Quest D', weight: 5, value: 60),
        ],
        8, // Max capacity
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(knapsackLabProvider);
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
          '0/1 KNAPSACK (DP)',
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
          const SizedBox(height: 20),
          if (currentStep != null)
            Expanded(
              child: _buildMatrix(currentStep, state, colorScheme),
            )
          else
            const Expanded(child: Center(child: CircularProgressIndicator())),
          _buildControlPanel(state, colorScheme),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(KnapsackStep? step, ColorScheme colorScheme) {
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
              'OPTIMIZATION LOGIC',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: colorScheme.onInverseSurface.withValues(alpha: 0.5),
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

  Widget _buildMatrix(KnapsackStep step, KnapsackState state, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Items Summary Table
          _buildItemsTable(state, step, colorScheme),
          const SizedBox(height: 24),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Exclude path', Colors.redAccent),
              const SizedBox(width: 16),
              _buildLegend('Include path', Colors.blueAccent),
            ],
          ),
          const SizedBox(height: 16),
          
          // The DP Grid
          Text(
            'DP TABLE [QUESTS][MINUTES]',
            style: TextStyle(
              fontFamily: 'DM Mono',
              fontSize: 10,
              letterSpacing: 1.2,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Table(
                defaultColumnWidth: const FixedColumnWidth(32),
                border: TableBorder.all(color: colorScheme.outline, width: 0.5),
                children: [
                  // Header Row
                  TableRow(
                    children: [
                      _buildHeaderCell(''),
                      ...List.generate(state.capacity + 1, (index) => _buildHeaderCell('${index}m')),
                    ],
                  ),
                  // Data Rows
                  ...step.matrix.asMap().entries.map((rowEntry) {
                    final rowIndex = rowEntry.key;
                    final row = rowEntry.value;

                    String rowLabel = 'Ø';
                    if (rowIndex > 0) {
                      rowLabel = String.fromCharCode(64 + rowIndex);
                    }

                    return TableRow(
                      children: [
                        _buildHeaderCell(rowLabel),
                        ...row.asMap().entries.map((colEntry) {
                          final colIndex = colEntry.key;
                          final value = colEntry.value;
                          
                          bool isCurrent = rowIndex == step.currentRow && colIndex == step.currentCol;
                          bool isAbove = rowIndex == step.currentRow - 1 && colIndex == step.currentCol;
                          bool isRemainder = step.isComparison && 
                                           rowIndex == step.currentRow - 1 && 
                                           colIndex == step.currentCol - state.items[step.currentRow - 1].weight;
                          
                          bool isBacktracked = step.status == LabStatus.finished && 
                                             step.selectedIndices.contains(rowIndex - 1);

                          Color cellColor = Colors.transparent;
                          Color borderColor = Colors.transparent;
                          double borderWidth = 0;

                          if (isCurrent) cellColor = colorScheme.primary.withValues(alpha: 0.2);
                          if (isBacktracked) cellColor = Colors.green.withValues(alpha: 0.1);
                          
                          if (isAbove) {
                            borderColor = Colors.redAccent;
                            borderWidth = 2.0;
                          } else if (isRemainder) {
                            borderColor = Colors.blueAccent;
                            borderWidth = 2.0;
                          }

                          return Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: cellColor,
                              border: borderWidth > 0 
                                ? Border.all(color: borderColor, width: borderWidth)
                                : null,
                            ),
                            child: Center(
                              child: Text(
                                '$value',
                                style: TextStyle(
                                  fontFamily: 'DM Mono',
                                  fontSize: 10,
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  color: isCurrent 
                                    ? colorScheme.onPrimary 
                                    : (isBacktracked ? Colors.green : colorScheme.onSurface),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }),
                ],
              ),
              // Arrow Overlay
              if (step.isComparison)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _KnapsackArrowPainter(
                        currentRow: step.currentRow,
                        currentCol: step.currentCol,
                        excludeRow: step.excludeRow,
                        excludeCol: step.excludeCol,
                        includeRow: step.includeRow,
                        includeCol: step.includeCol,
                        cellWidth: 32,
                        cellHeight: 32,
                        totalCols: state.capacity + 2, // +1 for labels, +1 for 0..cap
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      height: 32,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
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

  Widget _buildItemsTable(KnapsackState state, KnapsackStep step, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: state.items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final isSelected = step.selectedIndices.contains(idx);
          final isProcessing = step.currentRow - 1 == idx;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isProcessing ? colorScheme.primary.withValues(alpha: 0.05) : null,
              border: idx < state.items.length - 1 
                ? Border(bottom: BorderSide(color: colorScheme.outline, width: 0.5))
                : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.inventory_2_outlined,
                  size: 16,
                  color: isSelected ? Colors.green : (isProcessing ? colorScheme.primary : colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontWeight: isProcessing ? FontWeight.bold : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  '${item.weight}m | ${item.value}XP',
                  style: const TextStyle(fontFamily: 'DM Mono', fontSize: 10),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildControlPanel(KnapsackState state, ColorScheme colorScheme) {
    final notifier = ref.read(knapsackLabProvider.notifier);

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
                'CAPACITY: ${state.capacity}m',
                style: const TextStyle(fontFamily: 'DM Mono', fontSize: 10, fontWeight: FontWeight.bold),
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
}

class _KnapsackArrowPainter extends CustomPainter {
  final int currentRow;
  final int currentCol;
  final int? excludeRow;
  final int? excludeCol;
  final int? includeRow;
  final int? includeCol;
  final double cellWidth;
  final double cellHeight;
  final int totalCols;

  _KnapsackArrowPainter({
    required this.currentRow,
    required this.currentCol,
    this.excludeRow,
    this.excludeCol,
    this.includeRow,
    this.includeCol,
    required this.cellWidth,
    required this.cellHeight,
    required this.totalCols,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset getCellCenter(int r, int c) {
      // Row r+1, Col c+1 (to skip headers/labels)
      return Offset(
        (c + 1) * cellWidth + cellWidth / 2,
        (r + 1) * cellHeight + cellHeight / 2,
      );
    }

    final currentCenter = getCellCenter(currentRow, currentCol);

    if (excludeRow != null && excludeCol != null) {
      final excludeCenter = getCellCenter(excludeRow!, excludeCol!);
      _drawArrow(canvas, currentCenter, excludeCenter, Colors.redAccent);
    }

    if (includeRow != null && includeCol != null) {
      final includeCenter = getCellCenter(includeRow!, includeCol!);
      _drawArrow(canvas, currentCenter, includeCenter, Colors.blueAccent);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Color color) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(start.dx, start.dy);
    
    if (start.dx != end.dx) {
      final controlPoint = Offset(end.dx, start.dy);
      path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);
    } else {
      path.lineTo(end.dx, end.dy);
    }

    canvas.drawPath(path, paint);

    final headPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(end, 4, headPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
