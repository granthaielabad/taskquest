import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/lab/models/lab_models.dart';

// ─── BINARY SEARCH PROVIDER ───────────────────────────────────────────

class BinarySearchNotifier extends Notifier<BinarySearchState> {
  @override
  BinarySearchState build() {
    return BinarySearchState(
      list: [12, 18, 25, 34, 42, 55, 67, 72, 89, 95],
      target: 42,
    );
  }

  void initializeLab(List<int> list, int target) {
    final sortedList = List<int>.from(list)..sort();
    final steps = _generateSteps(sortedList, target);
    state = BinarySearchState(
      list: sortedList,
      target: target,
      steps: steps,
      currentStepIndex: 0,
      status: LabStatus.searching,
    );
  }

  List<BinarySearchStep> _generateSteps(List<int> list, int target) {
    List<BinarySearchStep> steps = [];
    int low = 0;
    int high = list.length - 1;

    steps.add(BinarySearchStep(
      list: list,
      low: low,
      high: high,
      mid: -1,
      target: target,
      message: "Starting search for $target in sorted list.",
      status: LabStatus.searching,
    ));

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      final currentVal = list[mid];

      String stepMsg = "Step: Calculate mid index.\n\n"
                       "• Range: Index $low to $high\n"
                       "• Mid: ($low + $high) / 2 = $mid\n"
                       "• Value at mid: $currentVal\n\n";

      if (currentVal == target) {
        steps.add(BinarySearchStep(
          list: list,
          low: low,
          high: high,
          mid: mid,
          target: target,
          message: "$stepMsg -> MATCH! $currentVal == $target. Search finished.",
          status: LabStatus.found,
        ));
        return steps;
      }

      String decision = currentVal < target 
          ? "$currentVal < $target (Target is higher). Discarding left half."
          : "$currentVal > $target (Target is lower). Discarding right half.";

      steps.add(BinarySearchStep(
        list: list,
        low: low,
        high: high,
        mid: mid,
        target: target,
        message: "$stepMsg -> $decision",
        status: LabStatus.searching,
      ));

      if (currentVal < target) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    steps.add(BinarySearchStep(
      list: list,
      low: low,
      high: high,
      mid: -1,
      target: target,
      message: "Target $target not found.",
      status: LabStatus.notFound,
    ));

    return steps;
  }

  void nextStep() => state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
  void previousStep() => state = state.copyWith(currentStepIndex: state.currentStepIndex - 1);
  void reset() => state = state.copyWith(currentStepIndex: 0);
}

final binarySearchLabProvider = NotifierProvider<BinarySearchNotifier, BinarySearchState>(() => BinarySearchNotifier());

// ─── QUICK SORT PROVIDER ──────────────────────────────────────────────

class QuickSortNotifier extends Notifier<QuickSortState> {
  @override
  QuickSortState build() => QuickSortState(initialList: [65, 20, 80, 10, 45, 30, 95, 50]);

  void initializeLab(List<int> list) {
    List<QuickSortStep> steps = [];
    List<int> workingList = List<int>.from(list);
    
    steps.add(QuickSortStep(
      list: List<int>.from(workingList),
      pivotIndex: -1,
      low: 0,
      high: workingList.length - 1,
      i: -1,
      j: -1,
      message: "Step: Starting Quick Sort.\n\n"
               "• Initial List: $list\n"
               "• Goal: Use 'Divide and Conquer' to sort elements efficiently.",
    ));

    _sort(workingList, 0, workingList.length - 1, steps);

    steps.add(QuickSortStep(
      list: List<int>.from(workingList),
      pivotIndex: -1,
      low: 0, high: workingList.length - 1, i: -1, j: -1,
      message: "SORT COMPLETE! 🎉\n\n"
               "All elements have been partitioned and sorted recursively.",
    ));

    state = QuickSortState(initialList: list, steps: steps, currentStepIndex: 0);
  }

  void _sort(List<int> A, int low, int high, List<QuickSortStep> steps) {
    if (low < high) {
      int p = _partition(A, low, high, steps);
      
      steps.add(QuickSortStep(
        list: List<int>.from(A),
        pivotIndex: p,
        low: low, high: high, i: -1, j: -1,
        message: "Recursion: Pivot $p is fixed. Now sorting the LEFT side [$low to ${p-1}]...",
      ));
      _sort(A, low, p - 1, steps);

      steps.add(QuickSortStep(
        list: List<int>.from(A),
        pivotIndex: p,
        low: low, high: high, i: -1, j: -1,
        message: "Recursion: Left side done. Now sorting the RIGHT side [${p+1} to $high]...",
      ));
      _sort(A, p + 1, high, steps);
    }
  }

  int _partition(List<int> A, int low, int high, List<QuickSortStep> steps) {
    int pivot = A[high];
    int i = low - 1;

    steps.add(QuickSortStep(
      list: List<int>.from(A),
      pivotIndex: high,
      low: low,
      high: high,
      i: i,
      j: low,
      message: "Step: Partitioning sub-array [$low to $high].\n\n"
               "• Chosen Pivot: $pivot (last element)\n"
               "• Goal: Move all elements ≤ $pivot behind the 'Wall' (i).",
    ));

    for (int j = low; j < high; j++) {
      int valJ = A[j];
      bool isLessOrEqual = valJ <= pivot;
      
      String comparison = "$valJ ≤ $pivot is ${isLessOrEqual.toString().toUpperCase()}";
      String action = isLessOrEqual 
          ? "Element is smaller or equal. Move 'Wall' (i) and swap into place." 
          : "Element is larger. No swap needed, just move 'Scanner' (j).";

      steps.add(QuickSortStep(
        list: List<int>.from(A),
        pivotIndex: high,
        low: low,
        high: high,
        i: i,
        j: j,
        message: "Step: Scanner (j) is at index $j.\n\n"
                 "• Comparison: $comparison\n"
                 "• Action: $action",
      ));

      if (isLessOrEqual) {
        i++;
        int temp = A[i];
        A[i] = A[j];
        A[j] = temp;
        
        String swapMsg = i == j 
            ? "Step: Element $valJ is already in a 'Smaller' position. Just advancing Wall (i)."
            : "Step: Swapping A[$i] and A[$j].\n\n"
              "• Moved $valJ behind the Wall (i).\n"
              "• Wall (i) is now at index $i.";

        steps.add(QuickSortStep(
          list: List<int>.from(A),
          pivotIndex: high,
          low: low,
          high: high,
          i: i,
          j: j,
          message: swapMsg,
          isSwap: true,
        ));
      }
    }

    int temp = A[i + 1];
    A[i + 1] = A[high];
    A[high] = temp;

    steps.add(QuickSortStep(
      list: List<int>.from(A),
      pivotIndex: i + 1,
      low: low,
      high: high,
      i: i + 1,
      j: high,
      message: "Step: Final Partition Swap.\n\n"
               "Place pivot $pivot in its correct final spot (index ${i+1}).",
      isSwap: true,
    ));

    return i + 1;
  }

  void nextStep() => state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
  void previousStep() => state = state.copyWith(currentStepIndex: state.currentStepIndex - 1);
  void reset() => state = state.copyWith(currentStepIndex: 0);
}

final quickSortLabProvider = NotifierProvider<QuickSortNotifier, QuickSortState>(() => QuickSortNotifier());

// ─── KNAPSACK PROVIDER ────────────────────────────────────────────────

class KnapsackNotifier extends Notifier<KnapsackState> {
  @override
  KnapsackState build() => KnapsackState(items: [], capacity: 0);

  void initializeLab(List<KnapsackItem> items, int capacity) {
    List<KnapsackStep> steps = [];
    int n = items.length;
    
    // 1. Initialize empty matrix
    List<List<int>> matrix = List.generate(n + 1, (_) => List.filled(capacity + 1, 0));
    
    steps.add(KnapsackStep(
      matrix: _cloneMatrix(matrix),
      currentRow: 0,
      currentCol: 0,
      message: "Starting 0/1 Knapsack. Initializing DP Table with zeros.",
      status: LabStatus.calculating,
    ));

    // 2. Build Table
    for (int i = 1; i <= n; i++) {
      final item = items[i - 1];
      for (int w = 1; w <= capacity; w++) {
        if (item.weight <= w) {
          int remainderVal = matrix[i - 1][w - item.weight];
          int include = item.value + remainderVal;
          int exclude = matrix[i - 1][w];
          
          String decision = include > exclude ? "INCLUDE" : "EXCLUDE";
          int winner = include > exclude ? include : exclude;

          steps.add(KnapsackStep(
            matrix: _cloneMatrix(matrix),
            currentRow: i,
            currentCol: w,
            message: "Step: Check '${item.name}' (${item.weight}m, ${item.value}XP) at ${w}m limit.\n\n"
                     "• Option A (Include): Take item (+${item.value}XP) + Best XP for remaining ${w - item.weight}m above ($remainderVal XP) = $include XP\n"
                     "• Option B (Exclude): Take best XP directly above ($exclude XP)\n\n"
                     "Decision: $decision ($winner XP is higher)",
            status: LabStatus.calculating,
            isComparison: true,
            excludeRow: i - 1,
            excludeCol: w,
            includeRow: i - 1,
            includeCol: w - item.weight,
          ));

          matrix[i][w] = winner;
        } else {
          int valueAbove = matrix[i - 1][w];
          steps.add(KnapsackStep(
            matrix: _cloneMatrix(matrix),
            currentRow: i,
            currentCol: w,
            message: "Step: Check '${item.name}' (${item.weight}m) at ${w}m limit.\n\n"
                     "Item too heavy! (${item.weight}m > ${w}m limit). "
                     "Just copying the best XP from above ($valueAbove XP).",
            status: LabStatus.calculating,
          ));
          matrix[i][w] = valueAbove;
        }
      }
    }

    // 3. Final Calculation State
    steps.add(KnapsackStep(
      matrix: _cloneMatrix(matrix),
      currentRow: n,
      currentCol: capacity,
      message: "Table Complete! Maximum XP found: ${matrix[n][capacity]}.",
      status: LabStatus.backtracking,
    ));

    // 4. Backtrack
    List<int> selected = [];
    int res = matrix[n][capacity];
    int w = capacity;
    for (int i = n; i > 0 && res > 0; i--) {
      if (res != matrix[i - 1][w]) {
        selected.add(i - 1);
        res -= items[i - 1].value;
        w -= items[i - 1].weight;
        
        steps.add(KnapsackStep(
          matrix: _cloneMatrix(matrix),
          currentRow: i,
          currentCol: w + items[i - 1].weight,
          message: "Backtrack: Value changed! Item '${items[i - 1].name}' was selected.",
          status: LabStatus.backtracking,
          selectedIndices: List<int>.from(selected),
        ));
      }
    }

    steps.add(KnapsackStep(
      matrix: _cloneMatrix(matrix),
      currentRow: -1,
      currentCol: -1,
      message: "Final solution found. ${selected.length} items optimized.",
      status: LabStatus.finished,
      selectedIndices: selected,
    ));

    state = KnapsackState(items: items, capacity: capacity, steps: steps, currentStepIndex: 0);
  }

  List<List<int>> _cloneMatrix(List<List<int>> m) => m.map((row) => List<int>.from(row)).toList();

  void nextStep() => state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
  void previousStep() => state = state.copyWith(currentStepIndex: state.currentStepIndex - 1);
  void reset() => state = state.copyWith(currentStepIndex: 0);
}

final knapsackLabProvider = NotifierProvider<KnapsackNotifier, KnapsackState>(() => KnapsackNotifier());

// ─── LINEAR SEARCH PROVIDER ───────────────────────────────────────────

class LinearSearchNotifier extends Notifier<LinearSearchState> {
  @override
  LinearSearchState build() {
    return LinearSearchState(
      list: [45, 12, 89, 34, 42, 67, 21, 55],
      target: 42,
    );
  }

  void initializeLab(List<int> list, int target) {
    final steps = _generateSteps(list, target);
    state = LinearSearchState(
      list: list,
      target: target,
      steps: steps,
      currentStepIndex: 0,
    );
  }

  List<LinearSearchStep> _generateSteps(List<int> list, int target) {
    List<LinearSearchStep> steps = [];

    steps.add(LinearSearchStep(
      list: list,
      currentIndex: -1,
      target: target,
      message: "Step: Starting Linear Search.\n\n"
               "• Unsorted List: $list\n"
               "• Goal: Scan one-by-one until $target is found.",
      status: LabStatus.searching,
    ));

    for (int i = 0; i < list.length; i++) {
      final currentVal = list[i];
      final isMatch = currentVal == target;

      String stepMsg = "Step: Checking index $i.\n\n"
                       "• Value at index: $currentVal\n"
                       "• Target: $target\n\n";

      if (isMatch) {
        steps.add(LinearSearchStep(
          list: list,
          currentIndex: i,
          target: target,
          message: "$stepMsg -> MATCH FOUND! 🎉\n$currentVal == $target.",
          status: LabStatus.found,
        ));
        return steps;
      } else {
        steps.add(LinearSearchStep(
          list: list,
          currentIndex: i,
          target: target,
          message: "$stepMsg -> No match. Moving to next element.",
          status: LabStatus.searching,
        ));
      }
    }

    steps.add(LinearSearchStep(
      list: list,
      currentIndex: -1,
      target: target,
      message: "Search Complete.\n\nTarget $target was not found in the list.",
      status: LabStatus.notFound,
    ));

    return steps;
  }

  void nextStep() => state = state.copyWith(currentStepIndex: state.currentStepIndex + 1);
  void previousStep() => state = state.copyWith(currentStepIndex: state.currentStepIndex - 1);
  void reset() => state = state.copyWith(currentStepIndex: 0);
}

final linearSearchLabProvider = NotifierProvider<LinearSearchNotifier, LinearSearchState>(() => LinearSearchNotifier());
