/// A utility class containing core algorithms.
class TaskQuestAlgorithms {
  // ─── 1. QUICK SORT (O(N log N)) ────────────────────────────────────────────

  /// Sorts a list using the Quick Sort algorithm.
  /// [compare] is a function that returns:
  ///   < 0 if a < b
  ///   == 0 if a == b
  ///   > 0 if a > b
  static void quickSort<T>(
    List<T> list,
    int low,
    int high,
    int Function(T a, T b) compare,
  ) {
    if (low < high) {
      int pivotIndex = _partition(list, low, high, compare);
      quickSort(list, low, pivotIndex - 1, compare);
      quickSort(list, pivotIndex + 1, high, compare);
    }
  }

  static int _partition<T>(
    List<T> list,
    int low,
    int high,
    int Function(T a, T b) compare,
  ) {
    T pivot = list[high];
    int i = low - 1;

    for (int j = low; j < high; j++) {
      if (compare(list[j], pivot) <= 0) {
        i++;
        _swap(list, i, j);
      }
    }
    _swap(list, i + 1, high);
    return i + 1;
  }

  static void _swap<T>(List<T> list, int i, int j) {
    T temp = list[i];
    list[i] = list[j];
    list[j] = temp;
  }

  // ─── 2. BINARY SEARCH (O(log N)) ───────────────────────────────────────────

  /// Performs a binary search on a sorted list.
  /// Returns the index of the item, or -1 if not found.
  static int binarySearch<T>(
    List<T> sortedList,
    T target,
    int Function(T a, T b) compare,
  ) {
    int low = 0;
    int high = sortedList.length - 1;

    while (low <= high) {
      int mid = low + (high - low) ~/ 2;
      int res = compare(sortedList[mid], target);

      if (res == 0) return mid;
      if (res < 0) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    return -1;
  }

  // ─── 3. 0/1 KNAPSACK - DYNAMIC PROGRAMMING (O(N * W)) ──────────────────────

  /// Solves the 0/1 Knapsack problem to find the optimal combination of items.
  /// [capacity] is the maximum "weight" (e.g., time) allowed.
  /// [weights] are the costs (e.g., minutes per quest).
  /// [values] are the rewards (e.g., XP per quest).
  /// Returns a list of indices representing the items included in the optimal solution.
  static List<int> knapsackDP(
    int capacity,
    List<int> weights,
    List<int> values,
  ) {
    int n = weights.length;
    List<List<int>> dp = List.generate(
      n + 1,
      (_) => List.filled(capacity + 1, 0),
    );

    // Build the DP table
    for (int i = 1; i <= n; i++) {
      for (int w = 1; w <= capacity; w++) {
        if (weights[i - 1] <= w) {
          // Max of (including the item, excluding the item)
          dp[i][w] = _max(
            values[i - 1] + dp[i - 1][w - weights[i - 1]],
            dp[i - 1][w],
          );
        } else {
          dp[i][w] = dp[i - 1][w];
        }
      }
    }

    // Backtrack to find which items were included
    List<int> selectedIndices = [];
    int res = dp[n][capacity];
    int w = capacity;
    for (int i = n; i > 0 && res > 0; i--) {
      if (res != dp[i - 1][w]) {
        selectedIndices.add(i - 1);
        res -= values[i - 1];
        w -= weights[i - 1];
      }
    }

    return selectedIndices;
  }

  static int _max(int a, int b) => (a > b) ? a : b;
}
