enum LabStatus { idle, searching, found, notFound, sorting, calculating, backtracking, finished }

// ─── BINARY SEARCH MODELS ──────────────────────────────────────────────

class BinarySearchStep {
  final List<int> list;
  final int low;
  final int high;
  final int mid;
  final int target;
  final String message;
  final LabStatus status;

  BinarySearchStep({
    required this.list,
    required this.low,
    required this.high,
    required this.mid,
    required this.target,
    required this.message,
    required this.status,
  });
}

class BinarySearchState {
  final List<int> list;
  final int target;
  final List<BinarySearchStep> steps;
  final int currentStepIndex;
  final LabStatus status;

  BinarySearchState({
    required this.list,
    required this.target,
    this.steps = const [],
    this.currentStepIndex = -1,
    this.status = LabStatus.idle,
  });

  BinarySearchStep? get currentStep => 
      (currentStepIndex >= 0 && currentStepIndex < steps.length) 
      ? steps[currentStepIndex] 
      : null;

  bool get canStepForward => currentStepIndex < steps.length - 1;
  bool get canStepBackward => currentStepIndex > 0;

  BinarySearchState copyWith({
    List<int>? list,
    int? target,
    List<BinarySearchStep>? steps,
    int? currentStepIndex,
    LabStatus? status,
  }) {
    return BinarySearchState(
      list: list ?? this.list,
      target: target ?? this.target,
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      status: status ?? this.status,
    );
  }
}

// ─── QUICK SORT MODELS ─────────────────────────────────────────────────

class QuickSortStep {
  final List<int> list;
  final int pivotIndex;
  final int low;
  final int high;
  final int i; // "Wall" pointer
  final int j; // "Scanner" pointer
  final String message;
  final bool isSwap;

  QuickSortStep({
    required this.list,
    required this.pivotIndex,
    required this.low,
    required this.high,
    required this.i,
    required this.j,
    required this.message,
    this.isSwap = false,
  });
}

class QuickSortState {
  final List<int> initialList;
  final List<QuickSortStep> steps;
  final int currentStepIndex;

  QuickSortState({
    required this.initialList,
    this.steps = const [],
    this.currentStepIndex = -1,
  });

  QuickSortStep? get currentStep => 
      (currentStepIndex >= 0 && currentStepIndex < steps.length) 
      ? steps[currentStepIndex] 
      : null;

  bool get canStepForward => currentStepIndex < steps.length - 1;
  bool get canStepBackward => currentStepIndex > 0;

  QuickSortState copyWith({
    List<int>? initialList,
    List<QuickSortStep>? steps,
    int? currentStepIndex,
  }) {
    return QuickSortState(
      initialList: initialList ?? this.initialList,
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    );
  }
}

// ─── KNAPSACK MODELS ───────────────────────────────────────────────────

class KnapsackItem {
  final String name;
  final int weight;
  final int value;

  KnapsackItem({required this.name, required this.weight, required this.value});
}

class KnapsackStep {
  final List<List<int>> matrix;
  final int currentRow;
  final int currentCol;
  final String message;
  final LabStatus status;
  final List<int> selectedIndices;
  final bool isComparison;
  final int? excludeRow;
  final int? excludeCol;
  final int? includeRow;
  final int? includeCol;

  KnapsackStep({
    required this.matrix,
    required this.currentRow,
    required this.currentCol,
    required this.message,
    required this.status,
    this.selectedIndices = const [],
    this.isComparison = false,
    this.excludeRow,
    this.excludeCol,
    this.includeRow,
    this.includeCol,
  });
}

class KnapsackState {
  final List<KnapsackItem> items;
  final int capacity;
  final List<KnapsackStep> steps;
  final int currentStepIndex;

  KnapsackState({
    required this.items,
    required this.capacity,
    this.steps = const [],
    this.currentStepIndex = -1,
  });

  KnapsackStep? get currentStep => 
      (currentStepIndex >= 0 && currentStepIndex < steps.length) 
      ? steps[currentStepIndex] 
      : null;

  bool get canStepForward => currentStepIndex < steps.length - 1;
  bool get canStepBackward => currentStepIndex > 0;

  KnapsackState copyWith({
    List<KnapsackItem>? items,
    int? capacity,
    List<KnapsackStep>? steps,
    int? currentStepIndex,
  }) {
    return KnapsackState(
      items: items ?? this.items,
      capacity: capacity ?? this.capacity,
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    );
  }
}

// ─── LINEAR SEARCH MODELS ─────────────────────────────────────────────

class LinearSearchStep {
  final List<int> list;
  final int currentIndex;
  final int target;
  final String message;
  final LabStatus status;

  LinearSearchStep({
    required this.list,
    required this.currentIndex,
    required this.target,
    required this.message,
    required this.status,
  });
}

class LinearSearchState {
  final List<int> list;
  final int target;
  final List<LinearSearchStep> steps;
  final int currentStepIndex;

  LinearSearchState({
    required this.list,
    required this.target,
    this.steps = const [],
    this.currentStepIndex = -1,
  });

  LinearSearchStep? get currentStep => 
      (currentStepIndex >= 0 && currentStepIndex < steps.length) 
      ? steps[currentStepIndex] 
      : null;

  bool get canStepForward => currentStepIndex < steps.length - 1;
  bool get canStepBackward => currentStepIndex > 0;

  LinearSearchState copyWith({
    List<int>? list,
    int? target,
    List<LinearSearchStep>? steps,
    int? currentStepIndex,
  }) {
    return LinearSearchState(
      list: list ?? this.list,
      target: target ?? this.target,
      steps: steps ?? this.steps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    );
  }
}
