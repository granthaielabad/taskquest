// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:taskquest/features/games/models/game_models.dart';

final List<AlgorithmProblem> allAlgorithmProblems = [
  // Beginner (10 items)
  AlgorithmProblem(
    id: 'algo_beg_1',
    instruction: 'Analyze the array traversal algorithm.',
    pseudocode: '''function findMax(arr):
  max_val = arr[0]
  for i from 1 to arr.length - 1:
    if arr[i] > max_val:
      max_val = arr[i]
  return max_val''',
    question: 'What is the time complexity of this algorithm in the worst case?',
    correctAnswer: 'O(N)',
    options: ['O(1)', 'O(log N)', 'O(N)', 'O(N^2)'],
    explanation: 'The algorithm iterates through the array of size N exactly once, resulting in O(N) time complexity.',
    xpReward: 10,
  ),
  AlgorithmProblem(
    id: 'algo_beg_2',
    instruction: 'Analyze the string manipulation algorithm.',
    pseudocode: '''function isPalindrome(str):
  left = 0
  right = str.length - 1
  while left < right:
    if str[left] != str[right]:
      return false
    left = left + 1
    right = right - 1
  return true''',
    question: 'What does this algorithm check?',
    correctAnswer: 'If a string reads the same forwards and backwards',
    options: ['If a string has no duplicate characters', 'If a string reads the same forwards and backwards', 'If a string contains only letters', 'If a string is completely reversed'],
    explanation: 'The two pointers approach compares characters from the outside in to verify if the string is a palindrome.',
    xpReward: 10,
  ),
  AlgorithmProblem(
    id: 'algo_beg_3',
    instruction: 'Analyze the sorting algorithm.',
    pseudocode: '''function bubbleSort(arr):
  n = arr.length
  for i from 0 to n - 1:
    for j from 0 to n - i - 2:
      if arr[j] > arr[j + 1]:
        swap(arr[j], arr[j + 1])''',
    question: 'What is the best-case time complexity of standard Bubble Sort (as written above)?',
    correctAnswer: 'O(N^2)',
    options: ['O(1)', 'O(N)', 'O(N log N)', 'O(N^2)'],
    explanation: 'Without a boolean flag to check for swaps, standard Bubble Sort always performs O(N^2) comparisons even if the array is already sorted.',
    xpReward: 15,
  ),
  AlgorithmProblem(
    id: 'algo_beg_4',
    instruction: 'Analyze the string algorithm.',
    pseudocode: '''function isAnagram(str1, str2):
  if str1.length != str2.length: return false
  count = hash map
  for char in str1: count[char]++
  for char in str2: count[char]--
  for val in count.values():
    if val != 0: return false
  return true''',
    question: 'What is the space complexity of this approach?',
    correctAnswer: 'O(1) or O(K) where K is character set size',
    options: ['O(N)', 'O(N^2)', 'O(1) or O(K) where K is character set size', 'O(log N)'],
    explanation: 'The hash map stores at most the size of the character set (e.g., 26 for lowercase English letters), which is O(1) space complexity regardless of string length.',
    xpReward: 15,
  ),
  AlgorithmProblem(
    id: 'algo_beg_5',
    instruction: 'Analyze the string manipulation algorithm.',
    pseudocode: '''function countVowels(str):
  count = 0
  vowels = ['a', 'e', 'i', 'o', 'u']
  for char in str:
    if char in vowels:
      count++
  return count''',
    question: 'What is the primary purpose of this algorithm?',
    correctAnswer: 'To count the number of vowels in a given string',
    options: ['To reverse the vowels in a string', 'To remove all vowels from a string', 'To count the number of vowels in a given string', 'To find the first vowel in a string'],
    explanation: 'The algorithm iterates over the string and increments a counter each time a vowel is encountered.',
    xpReward: 10,
  ),
  AlgorithmProblem(
    id: 'algo_beg_6',
    instruction: 'Analyze the array sum algorithm.',
    pseudocode: '''function sumArray(arr):
  sum = 0
  for num in arr:
    sum = sum + num
  return sum''',
    question: 'What is the output if arr = [1, 2, 3, 4]?',
    correctAnswer: '10',
    options: ['4', '10', '24', '0'],
    explanation: 'The algorithm adds all elements: 1 + 2 + 3 + 4 = 10.',
    xpReward: 10,
  ),
  AlgorithmProblem(
    id: 'algo_beg_7',
    instruction: 'Analyze the sorting algorithm.',
    pseudocode: '''function insertionSort(arr):
  for i from 1 to arr.length - 1:
    key = arr[i]
    j = i - 1
    while j >= 0 and arr[j] > key:
      arr[j + 1] = arr[j]
      j = j - 1
    arr[j + 1] = key''',
    question: 'What is the worst-case time complexity of this algorithm?',
    correctAnswer: 'O(N^2)',
    options: ['O(N)', 'O(N log N)', 'O(N^2)', 'O(2^N)'],
    explanation: 'In the worst case (reverse sorted array), each element must be compared to all previously sorted elements, resulting in O(N^2) time complexity.',
    xpReward: 15,
  ),
  AlgorithmProblem(
    id: 'algo_beg_8',
    instruction: 'Analyze the array algorithm.',
    pseudocode: '''function linearSearch(arr, target):
  for i from 0 to arr.length - 1:
    if arr[i] == target:
      return i
  return -1''',
    question: 'What does this algorithm return if the target is NOT found?',
    correctAnswer: '-1',
    options: ['0', '-1', 'arr.length', 'null'],
    explanation: 'The algorithm returns -1 when the loop completes without finding the target element.',
    xpReward: 10,
  ),
  AlgorithmProblem(
    id: 'algo_beg_9',
    instruction: 'Analyze the array minimum algorithm.',
    pseudocode: '''function findMin(arr):
  min_val = arr[0]
  for i from 1 to arr.length - 1:
    if arr[i] < min_val:
      min_val = arr[i]
  return min_val''',
    question: 'What happens if the input array is empty?',
    correctAnswer: 'It will cause an out-of-bounds error',
    options: ['It returns 0', 'It returns -1', 'It will cause an out-of-bounds error', 'It returns null'],
    explanation: 'Since the algorithm blindly accesses arr[0] on the first line, an empty array will throw an index out-of-bounds error.',
    xpReward: 15,
  ),
  AlgorithmProblem(
    id: 'algo_beg_10',
    instruction: 'Analyze the string reversal algorithm.',
    pseudocode: '''function reverse(str):
  res = ""
  for i from str.length - 1 down to 0:
    res = res + str[i]
  return res''',
    question: 'What is the time complexity of building this string using simple concatenation in many languages?',
    correctAnswer: 'O(N^2)',
    options: ['O(1)', 'O(N)', 'O(N log N)', 'O(N^2)'],
    explanation: 'In languages where strings are immutable, simple concatenation creates a new string each time, leading to O(N^2) time complexity.',
    xpReward: 15,
  ),

  // Intermediate (10 items)
  AlgorithmProblem(
    id: 'algo_int_1',
    instruction: 'Analyze the binary search algorithm.',
    pseudocode: '''function binarySearch(arr, target):
  low = 0
  high = arr.length - 1
  while low <= high:
    mid = low + (high - low) / 2
    if arr[mid] == target: return mid
    if arr[mid] < target: low = mid + 1
    else: high = mid - 1
  return -1''',
    question: 'What is a necessary condition for binary search to work correctly?',
    correctAnswer: 'The array must be sorted',
    options: ['The array must contain only positive integers', 'The array must be sorted', 'The array length must be a power of 2', 'The array must not contain duplicates'],
    explanation: 'Binary search relies on the array being sorted to eliminate half of the remaining elements at each step.',
    xpReward: 20,
  ),
  AlgorithmProblem(
    id: 'algo_int_2',
    instruction: 'Analyze the Two Pointers approach for Two Sum.',
    pseudocode: '''function twoSumSorted(arr, target):
  left = 0
  right = arr.length - 1
  while left < right:
    sum = arr[left] + arr[right]
    if sum == target: return [left, right]
    if sum < target: left++
    else: right--
  return []''',
    question: 'What is the time complexity of this approach?',
    correctAnswer: 'O(N)',
    options: ['O(1)', 'O(log N)', 'O(N)', 'O(N^2)'],
    explanation: 'The two pointers only move towards each other, meaning each element is visited at most once, giving O(N) time complexity.',
    xpReward: 20,
  ),
  AlgorithmProblem(
    id: 'algo_int_3',
    instruction: 'Analyze the recursion algorithm.',
    pseudocode: '''function fib(n):
  if n <= 1: return n
  return fib(n-1) + fib(n-2)''',
    question: 'What is the time complexity of this naive recursive Fibonacci implementation?',
    correctAnswer: 'O(2^N)',
    options: ['O(N)', 'O(N log N)', 'O(N^2)', 'O(2^N)'],
    explanation: 'The naive recursive approach recalculates the same overlapping subproblems exponentially, resulting in O(2^N) time complexity.',
    xpReward: 20,
  ),
  AlgorithmProblem(
    id: 'algo_int_4',
    instruction: 'Analyze the recursion with memoization algorithm.',
    pseudocode: '''memo = {}
function fib(n):
  if n in memo: return memo[n]
  if n <= 1: return n
  memo[n] = fib(n-1) + fib(n-2)
  return memo[n]''',
    question: 'How does memoization affect the time complexity compared to naive recursion?',
    correctAnswer: 'Reduces it to O(N)',
    options: ['Reduces it to O(1)', 'Reduces it to O(log N)', 'Reduces it to O(N)', 'It stays O(2^N) but with a smaller constant factor'],
    explanation: 'Memoization caches previously computed values, so each Fibonacci number up to N is calculated exactly once, yielding O(N) time complexity.',
    xpReward: 20,
  ),
  AlgorithmProblem(
    id: 'algo_int_5',
    instruction: 'Analyze the Sliding Window algorithm.',
    pseudocode: '''function maxSumSubarray(arr, k):
  max_sum = 0, current_sum = 0
  for i from 0 to k - 1: current_sum += arr[i]
  max_sum = current_sum
  for i from k to arr.length - 1:
    current_sum += arr[i] - arr[i - k]
    if current_sum > max_sum: max_sum = current_sum
  return max_sum''',
    question: 'What problem does this algorithm solve?',
    correctAnswer: 'Finding the maximum sum of a contiguous subarray of size K',
    options: ['Finding the maximum element in the array', 'Finding the longest increasing subarray', 'Finding the maximum sum of a contiguous subarray of size K', 'Sorting the array in blocks of size K'],
    explanation: 'The sliding window maintains a running sum of size K, effectively finding the maximum sum subarray of that specific length.',
    xpReward: 25,
  ),
  AlgorithmProblem(
    id: 'algo_int_6',
    instruction: 'Analyze the fast exponentiation algorithm.',
    pseudocode: '''function power(x, n):
  if n == 0: return 1
  half = power(x, n / 2)
  if n % 2 == 0: return half * half
  else: return x * half * half''',
    question: 'What is the time complexity of this algorithm?',
    correctAnswer: 'O(log N)',
    options: ['O(1)', 'O(log N)', 'O(N)', 'O(N log N)'],
    explanation: 'By dividing the exponent in half at each step, the algorithm reduces the number of multiplications logarithmically.',
    xpReward: 25,
  ),
  AlgorithmProblem(
    id: 'algo_int_7',
    instruction: 'Analyze the merging of two sorted arrays.',
    pseudocode: '''function merge(arr1, arr2):
  i = 0, j = 0, res = []
  while i < arr1.length and j < arr2.length:
    if arr1[i] < arr2[j]: res.push(arr1[i++])
    else: res.push(arr2[j++])
  while i < arr1.length: res.push(arr1[i++])
  while j < arr2.length: res.push(arr2[j++])
  return res''',
    question: 'What is the space complexity of this merge operation?',
    correctAnswer: 'O(N + M)',
    options: ['O(1)', 'O(N)', 'O(N + M)', 'O(N * M)'],
    explanation: 'The resulting array `res` requires space proportional to the combined lengths of both input arrays (N and M).',
    xpReward: 20,
  ),
  AlgorithmProblem(
    id: 'algo_int_8',
    instruction: 'Analyze the selection sort algorithm.',
    pseudocode: '''function selectionSort(arr):
  n = arr.length
  for i from 0 to n - 1:
    min_idx = i
    for j from i + 1 to n - 1:
      if arr[j] < arr[min_idx]:
        min_idx = j
    swap(arr[i], arr[min_idx])''',
    question: 'How many swaps does Selection Sort perform in the worst case?',
    correctAnswer: 'O(N)',
    options: ['O(1)', 'O(N)', 'O(N log N)', 'O(N^2)'],
    explanation: 'Although Selection Sort has O(N^2) comparisons, it performs at most one swap per outer loop iteration, making it O(N) swaps.',
    xpReward: 20,
  ),
  AlgorithmProblem(
    id: 'algo_int_9',
    instruction: 'Analyze the Two Pointers (Valid Palindrome) algorithm.',
    pseudocode: '''function isPalindromeAlphaNum(str):
  left = 0, right = str.length - 1
  while left < right:
    if not isAlphaNum(str[left]): left++
    else if not isAlphaNum(str[right]): right--
    else if toLower(str[left]) != toLower(str[right]): return false
    else: left++; right--;
  return true''',
    question: 'What does this algorithm handle that a basic palindrome check does not?',
    correctAnswer: 'Non-alphanumeric characters and case insensitivity',
    options: ['Only numbers', 'Non-alphanumeric characters and case insensitivity', 'Spaces only', 'Unicode characters'],
    explanation: 'The algorithm explicitly skips non-alphanumeric characters and converts comparisons to lowercase.',
    xpReward: 20,
  ),
  AlgorithmProblem(
    id: 'algo_int_10',
    instruction: 'Analyze the Sliding Window algorithm.',
    pseudocode: '''function lengthOfLongestSubstring(str):
  charSet = set()
  left = 0, max_len = 0
  for right from 0 to str.length - 1:
    while str[right] in charSet:
      charSet.remove(str[left])
      left++
    charSet.add(str[right])
    max_len = max(max_len, right - left + 1)
  return max_len''',
    question: 'What is the time complexity of this algorithm?',
    correctAnswer: 'O(N)',
    options: ['O(1)', 'O(log N)', 'O(N)', 'O(N^2)'],
    explanation: 'Both the `left` and `right` pointers traverse the string at most once, making the overall time complexity O(N).',
    xpReward: 25,
  ),

  // Advanced (10 items)
  AlgorithmProblem(
    id: 'algo_adv_1',
    instruction: 'Analyze the 0/1 Knapsack problem (Dynamic Programming).',
    pseudocode: '''function knapsack(W, wt, val, n):
  dp = 2D array of size (n+1) x (W+1) initialized to 0
  for i from 1 to n:
    for w from 1 to W:
      if wt[i-1] <= w:
        dp[i][w] = max(val[i-1] + dp[i-1][w - wt[i-1]], dp[i-1][w])
      else:
        dp[i][w] = dp[i-1][w]
  return dp[n][W]''',
    question: 'What is the time complexity of this 0/1 Knapsack solution?',
    correctAnswer: 'O(n * W)',
    options: ['O(n^2)', 'O(W^2)', 'O(n * W)', 'O(2^n)'],
    explanation: 'The time complexity is pseudo-polynomial O(n * W), where n is the number of items and W is the knapsack capacity.',
    xpReward: 30,
  ),
  AlgorithmProblem(
    id: 'algo_adv_2',
    instruction: 'Analyze the Longest Increasing Subsequence (Dynamic Programming).',
    pseudocode: '''function LIS(arr):
  n = arr.length
  dp = array of size n initialized to 1
  for i from 1 to n - 1:
    for j from 0 to i - 1:
      if arr[i] > arr[j] and dp[i] < dp[j] + 1:
        dp[i] = dp[j] + 1
  return max(dp)''',
    question: 'What is the time complexity of this specific LIS implementation?',
    correctAnswer: 'O(N^2)',
    options: ['O(N)', 'O(N log N)', 'O(N^2)', 'O(N^3)'],
    explanation: 'The nested loops iterate over the array elements, leading to O(N^2) time complexity. (An O(N log N) solution exists using binary search).',
    xpReward: 30,
  ),
  AlgorithmProblem(
    id: 'algo_adv_3',
    instruction: 'Analyze the Graph Traversal (Breadth-First Search).',
    pseudocode: '''function BFS(graph, start):
  visited = set()
  queue = [start]
  visited.add(start)
  while queue is not empty:
    node = queue.dequeue()
    for neighbor in graph[node]:
      if neighbor not in visited:
        visited.add(neighbor)
        queue.enqueue(neighbor)''',
    question: 'Which data structure is essential for implementing BFS?',
    correctAnswer: 'Queue',
    options: ['Stack', 'Queue', 'Heap', 'Hash Map'],
    explanation: 'BFS explores nodes level by level, which requires a First-In-First-Out (FIFO) data structure like a Queue.',
    xpReward: 30,
  ),
  AlgorithmProblem(
    id: 'algo_adv_4',
    instruction: 'Analyze the Graph Traversal (Depth-First Search).',
    pseudocode: '''function DFS(graph, node, visited):
  if node in visited: return
  visited.add(node)
  for neighbor in graph[node]:
    DFS(graph, neighbor, visited)''',
    question: 'Which abstract data type does the call stack mimic in this recursive DFS?',
    correctAnswer: 'Stack',
    options: ['Queue', 'Stack', 'Linked List', 'Priority Queue'],
    explanation: 'Recursive implementations use the system call stack, mimicking the Last-In-First-Out (LIFO) behavior of a manual Stack.',
    xpReward: 30,
  ),
  AlgorithmProblem(
    id: 'algo_adv_5',
    instruction: 'Analyze Tree Operations (Lowest Common Ancestor).',
    pseudocode: '''function LCA(root, p, q):
  if root is null or root == p or root == q: return root
  left = LCA(root.left, p, q)
  right = LCA(root.right, p, q)
  if left is not null and right is not null: return root
  if left is not null: return left
  return right''',
    question: 'When does the algorithm return the current `root` as the LCA?',
    correctAnswer: 'When `p` and `q` are found in both the left and right subtrees',
    options: ['When `root` is a leaf node', 'When `p` and `q` are found in both the left and right subtrees', 'When both `left` and `right` recursive calls return null', 'When the tree is unbalanced'],
    explanation: 'If both the left and right subtrees return non-null values, it means p and q are on opposite sides of the current root, making it their Lowest Common Ancestor.',
    xpReward: 35,
  ),
  AlgorithmProblem(
    id: 'algo_adv_6',
    instruction: 'Analyze Tree Operations (Maximum Depth).',
    pseudocode: '''function maxDepth(root):
  if root is null: return 0
  leftDepth = maxDepth(root.left)
  rightDepth = maxDepth(root.right)
  return max(leftDepth, rightDepth) + 1''',
    question: 'What is the space complexity of this recursive algorithm in the worst case (a skewed tree)?',
    correctAnswer: 'O(N)',
    options: ['O(1)', 'O(log N)', 'O(N)', 'O(N^2)'],
    explanation: 'In the worst case of a completely skewed tree, the recursion depth will be N, requiring O(N) space on the call stack.',
    xpReward: 30,
  ),
  AlgorithmProblem(
    id: 'algo_adv_7',
    instruction: 'Analyze amortized time complexity of dynamic arrays.',
    pseudocode: '''function push_back(arr, element):
  if arr.size == arr.capacity:
    new_arr = allocate array of size (arr.capacity * 2)
    copy elements from arr to new_arr
    arr = new_arr
  arr[arr.size] = element
  arr.size++''',
    question: 'What is the amortized time complexity of appending an element?',
    correctAnswer: 'O(1)',
    options: ['O(1)', 'O(log N)', 'O(N)', 'O(N^2)'],
    explanation: 'Although resizing takes O(N) time, it happens infrequently enough (every N operations) that the average (amortized) cost per operation remains O(1).',
    xpReward: 35,
  ),
  AlgorithmProblem(
    id: 'algo_adv_8',
    instruction: 'Analyze Dijkstra\'s Algorithm.',
    pseudocode: '''function dijkstra(graph, start):
  distances = map with infinite values, distances[start] = 0
  pq = priority queue of (distance, node), pq.insert((0, start))
  while pq is not empty:
    dist, node = pq.extract_min()
    if dist > distances[node]: continue
    for neighbor, weight in graph[node]:
      new_dist = dist + weight
      if new_dist < distances[neighbor]:
        distances[neighbor] = new_dist
        pq.insert((new_dist, neighbor))''',
    question: 'What is a key requirement for the edge weights in standard Dijkstra\'s Algorithm?',
    correctAnswer: 'Edge weights must be non-negative',
    options: ['Edge weights must be positive integers only', 'Edge weights must be non-negative', 'Edge weights must be less than 100', 'The graph must be undirected'],
    explanation: 'Dijkstra\'s algorithm assumes that once a node is extracted from the priority queue, its shortest path is final. Negative weights violate this assumption.',
    xpReward: 35,
  ),
  AlgorithmProblem(
    id: 'algo_adv_9',
    instruction: 'Analyze the Trie (Prefix Tree) search operation.',
    pseudocode: '''function searchTrie(root, word):
  node = root
  for char in word:
    if char not in node.children: return false
    node = node.children[char]
  return node.isEndOfWord''',
    question: 'What is the time complexity to search for a word of length L in a Trie?',
    correctAnswer: 'O(L)',
    options: ['O(1)', 'O(L)', 'O(N) where N is number of words', 'O(L * N)'],
    explanation: 'Searching a Trie requires traversing down a path corresponding to the characters of the word, which takes time proportional to the word length L.',
    xpReward: 30,
  ),
  AlgorithmProblem(
    id: 'algo_adv_10',
    instruction: 'Analyze Topological Sort (Kahn\'s Algorithm).',
    pseudocode: '''function topologicalSort(graph):
  in_degree = map of node to integer
  for node in graph: calculate in_degree
  queue = [nodes with in_degree == 0]
  order = []
  while queue is not empty:
    node = queue.dequeue()
    order.push(node)
    for neighbor in graph[node]:
      in_degree[neighbor]--
      if in_degree[neighbor] == 0: queue.enqueue(neighbor)
  if order.length != graph.nodes.length: return "Cycle detected"
  return order''',
    question: 'For which type of graphs is Topological Sorting valid?',
    correctAnswer: 'Directed Acyclic Graphs (DAGs)',
    options: ['Undirected Trees', 'Directed Acyclic Graphs (DAGs)', 'Graphs with at least one cycle', 'Complete Graphs'],
    explanation: 'Topological sorting represents a linear ordering of vertices such that for every directed edge u -> v, vertex u comes before v. This is only possible in Directed Acyclic Graphs.',
    xpReward: 35,
  ),
];
