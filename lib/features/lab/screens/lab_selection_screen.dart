import 'package:flutter/material.dart';
import 'package:taskquest/features/lab/screens/binary_search_visualizer_screen.dart';
import 'package:taskquest/features/lab/screens/quick_sort_visualizer_screen.dart';
import 'package:taskquest/features/lab/screens/knapsack_visualizer_screen.dart';
import 'package:taskquest/features/lab/screens/linear_search_visualizer_screen.dart';

class LabSelectionScreen extends StatelessWidget {
  const LabSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'HOW ALGORITHMS WORK',
          style: TextStyle(
            fontFamily: 'DM Mono',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code in\nMotion.',
              style: TextStyle(
                fontFamily: 'Syne',
                fontWeight: FontWeight.w800,
                fontSize: 42,
                height: 0.9,
                letterSpacing: -1.5,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Select an algorithm to visualize its step-by-step logic.',
              style: TextStyle(
                fontFamily: 'DM Mono',
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),

            _LabCard(
              title: 'Binary Search',
              description: 'Divide and conquer a sorted list to find a target.',
              complexity: 'O(log N)',
              icon: Icons.unfold_more_double_rounded,
              color: colorScheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BinarySearchVisualizerScreen()),
              ),
            ),
            const SizedBox(height: 20),

            _LabCard(
              title: 'Linear Search',
              description: 'Scan an unsorted list one-by-one to find a target.',
              complexity: 'O(N)',
              icon: Icons.search_rounded,
              color: Colors.blueAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LinearSearchVisualizerScreen()),
              ),
            ),
            const SizedBox(height: 20),

            _LabCard(
              title: 'Quick Sort',
              description: 'Recursive partitioning for high-performance sorting.',
              complexity: 'O(N log N)',
              icon: Icons.sort_rounded,
              color: Colors.orangeAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuickSortVisualizerScreen()),
              ),
            ),
            const SizedBox(height: 20),

            _LabCard(
              title: '0/1 Knapsack',
              description: 'Dynamic programming for resource optimization.',
              complexity: 'O(N * W)',
              icon: Icons.inventory_2_rounded,
              color: Colors.purpleAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KnapsackVisualizerScreen()),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _LabCard extends StatelessWidget {
  final String title;
  final String description;
  final String complexity;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LabCard({
    required this.title,
    required this.description,
    required this.complexity,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Syne',
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.onSurface.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          complexity,
                          style: TextStyle(
                            fontFamily: 'DM Mono',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
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
          ],
        ),
      ),
    );
  }
}
