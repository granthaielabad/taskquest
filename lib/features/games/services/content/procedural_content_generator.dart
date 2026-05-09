// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:taskquest/features/games/models/game_models.dart';

class ProceduralContentGenerator {
  static List<CodeBlockPuzzle> generateCodeBlocks(
    String language,
    String difficulty,
  ) {
    final List<CodeBlockPuzzle> puzzles = [];
    final lang = language.toUpperCase();
    final diff = difficulty.toLowerCase();

    int xp = 10;
    if (diff == 'intermediate') xp = 15;
    if (diff == 'advanced') xp = 25;

    for (int i = 0; i < 30; i++) {
      if (lang == 'PYTHON') {
        puzzles.add(_pythonPuzzle(i, diff, xp));
      } else if (lang == 'JAVASCRIPT' || lang == 'JS') {
        puzzles.add(_jsPuzzle(i, diff, xp));
      } else if (lang == 'JAVA') {
        puzzles.add(_javaPuzzle(i, diff, xp));
      } else if (lang == 'C++' || lang == 'CPP') {
        puzzles.add(_cppPuzzle(i, diff, xp));
      }
    }

    return puzzles;
  }

  static CodeBlockPuzzle _pythonPuzzle(int index, String diff, int xp) {
    if (diff == 'beginner') {
      final templates = [
        {
          'segments': ['def get_name(user):\n  ', 'slot', ' user.get("name")'],
          'blocks': ['return', 'yield', 'print', 'break'],
          'correct': {1: 'return'},
          'explanation': 'HackerRank Warmup: Returning values from dictionaries.',
        },
        {
          'segments': ['for num in ', 'slot', '(1, 10):\n  print(num)'],
          'blocks': ['range', 'xrange', 'list', 'enum'],
          'correct': {1: 'range'},
          'explanation': 'HackerRank Warmup: Basic loops.',
        },
        {
          'segments': ['words = ["a", "b"]\nwords.', 'slot', '("c")'],
          'blocks': ['append', 'push', 'add', 'insert'],
          'correct': {1: 'append'},
          'explanation': 'Exercism Basics: List manipulation.',
        },
        {
          'segments': ['name = "alice"\nprint(name.', 'slot', '())'],
          'blocks': ['upper', 'capitalize', 'large', 'to_upper'],
          'correct': {1: 'upper'},
          'explanation': 'Strings: Converting to uppercase.',
        },
        {
          'segments': ['nums = [1, 2, 3]\n', 'slot', '(nums)'],
          'blocks': ['len', 'size', 'count', 'length'],
          'correct': {1: 'len'},
          'explanation': 'Built-ins: Getting the length of a list.',
        },
        {
          'segments': ['if "apple" ', 'slot', ' fruits:\n  print("Found!")'],
          'blocks': ['in', 'has', 'contains', 'exists'],
          'correct': {1: 'in'},
          'explanation': 'Membership: Checking if an item is in a list.',
        },
        {
          'segments': ['raw_input = "123"\nnum = ', 'slot', '(raw_input)'],
          'blocks': ['int', 'str', 'float', 'parse'],
          'correct': {1: 'int'},
          'explanation': 'Types: Casting string to integer.',
        },
        {
          'segments': ['def greet(name):\n  print(', 'slot', '\"Hello, \" + name)'],
          'blocks': ['f', 'r', 'u', 'b'],
          'correct': {1: 'f'},
          'explanation': 'Strings: Modern f-string formatting.',
        },
        {
          'segments': ['data = "a,b,c"\nparts = data.', 'slot', '(",")'],
          'blocks': ['split', 'divide', 'slice', 'cut'],
          'correct': {1: 'split'},
          'explanation': 'Strings: Splitting a string into a list.',
        },
        {
          'segments': ['items = [10, 20]\nitems.', 'slot', '(1, 15)'],
          'blocks': ['insert', 'add', 'put', 'push'],
          'correct': {1: 'insert'},
          'explanation': 'Lists: Inserting at a specific index.',
        },
      ];
      final t = templates[index % templates.length];
      return CodeBlockPuzzle(
        id: 'cb_py_beg_$index',
        instruction: 'PYTHON (Beginner)',
        explanation: t['explanation'] as String,
        codeSegments: t['segments'] as List<String>,
        availableBlocks: t['blocks'] as List<String>,
        correctAnswers: t['correct'] as Map<int, String>,
        xpReward: xp,
      );
    } else if (diff == 'intermediate') {
      final templates = [
        {
          'segments': ['# LeetCode: Two Sum\ndef two_sum(nums, target):\n  for i, n in ', 'slot', '(nums):\n    pass'],
          'blocks': ['enumerate', 'range', 'zip', 'iter'],
          'correct': {1: 'enumerate'},
          'explanation': 'LeetCode Easy/Med: Using enumerate for index and value.',
        },
        {
          'segments': ['# LeetCode: Valid Anagram\nfrom collections import ', 'slot', '\nCounter(s) == Counter(t)'],
          'blocks': ['Counter', 'defaultdict', 'deque', 'namedtuple'],
          'correct': {1: 'Counter'},
          'explanation': 'LeetCode Hash Table: Frequency counting with Counter.',
        },
        {
          'segments': ['# Exercism: Scrabble Score\nscore = ', 'slot', '(letter_values.get(c, 0) for c in word)'],
          'blocks': ['sum', 'add', 'total', 'count'],
          'correct': {1: 'sum'},
          'explanation': 'Functional: Summing a generator expression.',
        },
        {
          'segments': ['# LeetCode: Group Anagrams\nd = collections.', 'slot', '(list)\nfor s in strs: d["".join(sorted(s))].append(s)'],
          'blocks': ['defaultdict', 'dict', 'OrderedDict', 'Counter'],
          'correct': {1: 'defaultdict'},
          'explanation': 'LeetCode Med: Grouping items with defaultdict.',
        },
        {
          'segments': ['# Data Processing\nsquares = [x**2 ', 'slot', ' x in nums if x > 0]'],
          'blocks': ['for', 'in', 'if', 'while'],
          'correct': {1: 'for'},
          'explanation': 'Idiomatic: List comprehension syntax.',
        },
        {
          'segments': ['# LeetCode: Merge Intervals\nintervals.', 'slot', '(key=lambda x: x[0])'],
          'blocks': ['sort', 'arrange', 'order', 'organize'],
          'correct': {1: 'sort'},
          'explanation': 'Algorithms: Sorting intervals by start time.',
        },
        {
          'segments': ['# LeetCode: Longest Substring\nchar_map = {}\nif char in char_map:\n  start = ', 'slot', '(start, char_map[char] + 1)'],
          'blocks': ['max', 'min', 'greater', 'top'],
          'correct': {1: 'max'},
          'explanation': 'Sliding Window: Updating window boundaries.',
        },
        {
          'segments': ['# File IO\nwith open("data.txt") as f:\n  lines = [line.', 'slot', '() for line in f]'],
          'blocks': ['strip', 'trim', 'clean', 'cut'],
          'correct': {1: 'strip'},
          'explanation': 'IO: Removing whitespace from file lines.',
        },
        {
          'segments': ['# LeetCode: Binary Search\ndef search(nums, target):\n  left, right = 0, ', 'slot', '(nums) - 1'],
          'blocks': ['len', 'size', 'count', 'length'],
          'correct': {1: 'len'},
          'explanation': 'Algorithms: Initializing binary search pointers.',
        },
        {
          'segments': ['# String Manipulation\nCSV_HEADER = ', 'slot', '(["id", "name", "email"])'],
          'blocks': ['",".join', '",".split', '",".add', '",".put'],
          'correct': {1: '",".join'},
          'explanation': 'Strings: Creating CSV lines efficiently.',
        },
      ];
      final t = templates[index % templates.length];
      return CodeBlockPuzzle(
        id: 'cb_py_int_$index',
        instruction: 'PYTHON (Intermediate)',
        explanation: t['explanation'] as String,
        codeSegments: t['segments'] as List<String>,
        availableBlocks: t['blocks'] as List<String>,
        correctAnswers: t['correct'] as Map<int, String>,
        xpReward: xp,
      );
    } else {
      final templates = [
        {
          'segments': ['# LeetCode Hard: LRU Cache\nfrom collections import ', 'slot', '\nclass LRUCache:\n  def __init__(self): self.cache = OrderedDict()'],
          'blocks': ['OrderedDict', 'deque', 'Heap', 'TreeSet'],
          'correct': {1: 'OrderedDict'},
          'explanation': 'LeetCode Hard: LRU Cache requires O(1) ordering.',
        },
        {
          'segments': ['# CodeCrafters: Build Redis\nimport asyncio\nasync def handle(reader, ', 'slot', '):\n  data = await reader.read(100)'],
          'blocks': ['writer', 'socket', 'channel', 'stream'],
          'correct': {1: 'writer'},
          'explanation': 'CodeCrafters: asyncio stream manipulation.',
        },
        {
          'segments': ['# LeetCode: Top K Frequent\nimport ', 'slot', '\nreturn heapq.nlargest(k, count.keys(), key=count.get)'],
          'blocks': ['heapq', 'bisect', 'math', 're'],
          'correct': {1: 'heapq'},
          'explanation': 'Algorithms: O(N log K) solution with Heaps.',
        },
        {
          'segments': ['# Performance Optimization\nfrom ', 'slot', ' import lru_cache\n@lru_cache(None)\ndef fib(n):'],
          'blocks': ['functools', 'itertools', 'collections', 'typing'],
          'correct': {1: 'functools'},
          'explanation': 'Advanced: Memoization using built-in decorators.',
        },
        {
          'segments': ['# LeetCode Hard: Median Data Stream\nimport heapq\ndef __init__(self):\n  self.small, self.large = [], ', 'slot'],
          'blocks': ['[]', '{}', 'set()', 'None'],
          'correct': {1: '[]'},
          'explanation': 'LeetCode Hard: Using two heaps for median.',
        },
        {
          'segments': ['# Custom Decorator\ndef debug(func):\n  @functools.', 'slot', '(func)\n  def wrapper(*args, **kwargs):'],
          'blocks': ['wraps', 'bind', 'decor', 'inner'],
          'correct': {1: 'wraps'},
          'explanation': 'Advanced: Preserving metadata in decorators.',
        },
        {
          'segments': ['# LeetCode: Longest Valid Parentheses\ndef longest(s):\n  stack = [', 'slot', ']\n  for i, c in enumerate(s):'],
          'blocks': ['-1', '0', 'None', '""'],
          'correct': {1: '-1'},
          'explanation': 'LeetCode Hard: Using stack with sentinel index.',
        },
        {
          'segments': ['# System Integration\nimport ', 'slot', '\nos.environ.get("DATABASE_URL")'],
          'blocks': ['os', 'sys', 'path', 'env'],
          'correct': {1: 'os'},
          'explanation': 'Backend: Accessing environment variables.',
        },
        {
          'segments': ['# LeetCode: Sliding Window Maximum\nfrom collections import ', 'slot', '\nq = deque()'],
          'blocks': ['deque', 'list', 'queue', 'stack'],
          'correct': {1: 'deque'},
          'explanation': 'LeetCode Hard: O(N) solution using monotonic queue.',
        },
        {
          'segments': ['# Typing and Validation\nfrom typing import ', 'slot', '\ndef fetch(id: int) -> Optional[User]:'],
          'blocks': ['Optional', 'Maybe', 'Nullable', 'Some'],
          'correct': {1: 'Optional'},
          'explanation': 'Software Design: Type hinting for nullable returns.',
        },
      ];
      final t = templates[index % templates.length];
      return CodeBlockPuzzle(
        id: 'cb_py_adv_$index',
        instruction: 'PYTHON (Advanced)',
        explanation: t['explanation'] as String,
        codeSegments: t['segments'] as List<String>,
        availableBlocks: t['blocks'] as List<String>,
        correctAnswers: t['correct'] as Map<int, String>,
        xpReward: xp,
      );
    }
  }

  static CodeBlockPuzzle _jsPuzzle(int index, String diff, int xp) {
    if (diff == 'beginner') {
      final templates = [
        {
          'segments': ['// Exercism: Hello World\nexport const hello = () ', 'slot', ' "Hello, World!";'],
          'blocks': ['=>', '->', '=', ':'],
          'correct': {1: '=>'},
          'explanation': 'Exercism: Arrow function syntax.',
        },
        {
          'segments': ['// HackerRank: Arrays\nconst arr = [1, 2];\narr.', 'slot', '(3);'],
          'blocks': ['push', 'append', 'add', 'insert'],
          'correct': {1: 'push'},
          'explanation': 'Array manipulation basics.',
        },
        {
          'segments': ['// String Basics\nconst s = "Dev";\nconsole.log(s.', 'slot', ');'],
          'blocks': ['length', 'size', 'count', 'len'],
          'correct': {1: 'length'},
          'explanation': 'Strings: Getting character count.',
        },
        {
          'segments': ['// Logic\nif (score >= 90) {\n  grade = "A";\n} ', 'slot', ' if (score >= 80) {'],
          'blocks': ['else', 'elif', 'otherwise', 'then'],
          'correct': {1: 'else'},
          'explanation': 'Control Flow: if/else chain.',
        },
        {
          'segments': ['// Iteration\n[1, 2, 3].', 'slot', '(x => console.log(x));'],
          'blocks': ['forEach', 'map', 'every', 'each'],
          'correct': {1: 'forEach'},
          'explanation': 'Arrays: Simple iteration.',
        },
        {
          'segments': ['// Variables\n', 'slot', ' name = "Quest";\nname = "Task";'],
          'blocks': ['let', 'const', 'var', 'def'],
          'correct': {1: 'let'},
          'explanation': 'Syntax: Reassignable variables.',
        },
        {
          'segments': ['// String formatting\nconst msg = ', 'slot', 'Hello, \${user}\`;'],
          'blocks': ['`', '"', '\'', ':'],
          'correct': {1: '`'},
          'explanation': 'Strings: Template literals.',
        },
        {
          'segments': ['// Math\nconst rounded = Math.', 'slot', '(3.6);'],
          'blocks': ['round', 'ceil', 'floor', 'trunc'],
          'correct': {1: 'round'},
          'explanation': 'Math: Rounding numbers.',
        },
        {
          'segments': ['// Array cleanup\nconst first = arr.', 'slot', '();'],
          'blocks': ['shift', 'pop', 'remove', 'first'],
          'correct': {1: 'shift'},
          'explanation': 'Arrays: Removing the first element.',
        },
        {
          'segments': ['// Type check\nif (typeof val === "', 'slot', '") {}'],
          'blocks': ['string', 'String', 'str', 'text'],
          'correct': {1: 'string'},
          'explanation': 'Types: Checking variable types.',
        },
      ];
      final t = templates[index % templates.length];
      return CodeBlockPuzzle(
        id: 'cb_js_beg_$index',
        instruction: 'JAVASCRIPT (Beginner)',
        explanation: t['explanation'] as String,
        codeSegments: t['segments'] as List<String>,
        availableBlocks: t['blocks'] as List<String>,
        correctAnswers: t['correct'] as Map<int, String>,
        xpReward: xp,
      );
    } else if (diff == 'intermediate') {
      final templates = [
        {
          'segments': ['// LeetCode: Contains Duplicate\nconst set = new ', 'slot', '(nums);\nreturn set.size !== nums.length;'],
          'blocks': ['Set', 'Map', 'WeakSet', 'Array'],
          'correct': {1: 'Set'},
          'explanation': 'LeetCode Easy: O(N) duplicate check using Set.',
        },
        {
          'segments': ['// Fetch API wrapper\n', 'slot', ' function getData() {\n  const res = await fetch(url);\n}'],
          'blocks': ['async', 'sync', 'await', 'defer'],
          'correct': {1: 'async'},
          'explanation': 'Modern JS: Async/Await promise handling.',
        },
        {
          'segments': ['// LeetCode: Two Sum\nconst map = new ', 'slot', '();\nmap.set(nums[i], i);'],
          'blocks': ['Map', 'Set', 'Object', 'Array'],
          'correct': {1: 'Map'},
          'explanation': 'LeetCode Easy: O(N) lookups with Map.',
        },
        {
          'segments': ['// Array transformations\nconst doubled = nums.', 'slot', '(x => x * 2);'],
          'blocks': ['map', 'filter', 'reduce', 'slice'],
          'correct': {1: 'map'},
          'explanation': 'Functional: Mapping values.',
        },
        {
          'segments': ['// Destructuring\nconst { name, ', 'slot', ' } = user;'],
          'blocks': ['age', 'user.age', 'this.age', 'age: age'],
          'correct': {1: 'age'},
          'explanation': 'Idiomatic: Object destructuring.',
        },
        {
          'segments': ['// LeetCode: Move Zeroes\nfor (let i = 0; i < nums.length; i++) {\n  if (nums[i] !== 0) [nums[j], nums[i]] = [', 'slot', ', nums[j]];\n}'],
          'blocks': ['nums[i]', '0', '1', 'nums[j]'],
          'correct': {1: 'nums[i]'},
          'explanation': 'LeetCode Easy: In-place array modification.',
        },
        {
          'segments': ['// Spread operator\nconst copy = ', 'slot', 'original ];'],
          'blocks': ['[...', '{...', 'copy(', '...'],
          'correct': {1: '[...'},
          'explanation': 'Idiomatic: Creating array copies.',
        },
        {
          'segments': ['// Filter pattern\nconst active = users.', 'slot', '(u => u.isActive);'],
          'blocks': ['filter', 'map', 'find', 'some'],
          'correct': {1: 'filter'},
          'explanation': 'Functional: Filtering lists.',
        },
        {
          'segments': ['// Optional chaining\nconst city = user?.address?.', 'slot', ';'],
          'blocks': ['city', 'getCity()', '["city"]', 'city?'],
          'correct': {1: 'city'},
          'explanation': 'Modern JS: Safe property access.',
        },
        {
          'segments': ['// JSON handling\nconst data = JSON.', 'slot', '(jsonString);'],
          'blocks': ['parse', 'stringify', 'load', 'read'],
          'correct': {1: 'parse'},
          'explanation': 'Data: Parsing JSON strings.',
        },
      ];
      final t = templates[index % templates.length];
      return CodeBlockPuzzle(
        id: 'cb_js_int_$index',
        instruction: 'JAVASCRIPT (Intermediate)',
        explanation: t['explanation'] as String,
        codeSegments: t['segments'] as List<String>,
        availableBlocks: t['blocks'] as List<String>,
        correctAnswers: t['correct'] as Map<int, String>,
        xpReward: xp,
      );
    } else {
      final templates = [
        {
          'segments': ['// Design Pattern: Proxy\nconst p = new Proxy(target, {\n  ', 'slot', '(obj, prop) {\n    return prop in obj ? obj[prop] : 0;\n  }\n});'],
          'blocks': ['get', 'set', 'has', 'apply'],
          'correct': {1: 'get'},
          'explanation': 'Advanced JS: Metaprogramming with Proxies.',
        },
        {
          'segments': ['// LeetCode Hard: Median Arrays\nif (n1 > n2) return findMedian(', 'slot', ');'],
          'blocks': ['nums2, nums1', 'nums1, nums2', 'nums1', 'nums2'],
          'correct': {1: 'nums2, nums1'},
          'explanation': 'LeetCode Hard: Binary Search constraints.',
        },
        {
          'segments': ['// Parallel execution\nconst results = await Promise.', 'slot', '([p1, p2]);'],
          'blocks': ['all', 'race', 'any', 'allSettled'],
          'correct': {1: 'all'},
          'explanation': 'Advanced: Running multiple promises in parallel.',
        },
        {
          'segments': ['// Generator function\nfunction', 'slot', ' range(n) {\n  for (let i = 0; i < n; i++) yield i;\n}'],
          'blocks': ['*', '!', '?', '&'],
          'correct': {1: '*'},
          'explanation': 'Advanced: Creating custom iterators with Generators.',
        },
        {
          'segments': ['// Event Loop: Macro/Micro-tasks\nsetTimeout(() => console.log(1), 0);\nPromise.resolve().', 'slot', '(() => console.log(2));'],
          'blocks': ['then', 'catch', 'finally', 'wait'],
          'correct': {1: 'then'},
          'explanation': 'JS Core: Promise microtasks execute before timeouts.',
        },
        {
          'segments': ['// Memory Management\nconst cache = new ', 'slot', '();\ncache.set(obj, "metadata");'],
          'blocks': ['WeakMap', 'Map', 'WeakSet', 'Set'],
          'correct': {1: 'WeakMap'},
          'explanation': 'Advanced: Garbage-collection friendly caching.',
        },
        {
          'segments': ['// This binding\nconst bound = fn.', 'slot', '(thisArg, arg1);'],
          'blocks': ['bind', 'call', 'apply', 'set'],
          'correct': {1: 'bind'},
          'explanation': 'JS Core: Creating functions with fixed contexts.',
        },
        {
          'segments': ['// Modules\nimport ', 'slot', ' as axios from "axios";'],
          'blocks': ['*', 'default', 'axios', 'lib'],
          'correct': {1: '*'},
          'explanation': 'Syntax: Namespaced module imports.',
        },
        {
          'segments': ['// Introspection\nObject.', 'slot', '(obj, "prop", { value: 1 });'],
          'blocks': ['defineProperty', 'create', 'assign', 'seal'],
          'correct': {1: 'defineProperty'},
          'explanation': 'Advanced: Fine-grained property control.',
        },
        {
          'segments': ['// Custom Errors\nclass MyError ', 'slot', ' Error {\n  constructor() { super(); }\n}'],
          'blocks': ['extends', 'implements', 'uses', 'of'],
          'correct': {1: 'extends'},
          'explanation': 'OOP: Inheriting from built-in types.',
        },
      ];
      final t = templates[index % templates.length];
      return CodeBlockPuzzle(
        id: 'cb_js_adv_$index',
        instruction: 'JAVASCRIPT (Advanced)',
        explanation: t['explanation'] as String,
        codeSegments: t['segments'] as List<String>,
        availableBlocks: t['blocks'] as List<String>,
        correctAnswers: t['correct'] as Map<int, String>,
        xpReward: xp,
      );
    }
  }

  static CodeBlockPuzzle _javaPuzzle(int index, String diff, int xp) {
    if (diff == 'beginner') {
      final templates = [
        {
          'segments': ['Scanner sc = new Scanner(System.', 'slot', ');'],
          'blocks': ['in', 'out', 'err', 'read'],
          'correct': {1: 'in'},
          'explanation': 'HackerRank: Standard input reading.',
        },
        {
          'segments': ['System.', 'slot', '.println("Hello");'],
          'blocks': ['out', 'in', 'err', 'write'],
          'correct': {1: 'out'},
          'explanation': 'Basics: Console output.',
        },
        {
          'segments': ['public ', 'slot', ' void main(String[] args) {}'],
          'blocks': ['static', 'final', 'abstract', 'private'],
          'correct': {1: 'static'},
          'explanation': 'Basics: Main method signature.',
        },
        {
          'segments': ['List<String> list = new ', 'slot', '<>();'],
          'blocks': ['ArrayList', 'LinkedList', 'List', 'Collection'],
          'correct': {1: 'ArrayList'},
          'explanation': 'Collections: Initializing a dynamic list.',
        },
        {
          'segments': ['String s = "Task";\nint len = s.', 'slot', '();'],
          'blocks': ['length', 'size', 'count', 'len'],
          'correct': {1: 'length'},
          'explanation': 'Strings: String length method.',
        },
        {
          'segments': ['for (int i = 0; i < ', 'slot', '; i++) {}'],
          'blocks': ['10', 'n', 'length', 'true'],
          'correct': {1: '10'},
          'explanation': 'Loops: Basic for loop structure.',
        },
        {
          'segments': ['if (x ', 'slot', ' 0) {\n  System.out.println("Positive");\n}'],
          'blocks': ['>', '<', '==', '='],
          'correct': {1: '>'},
          'explanation': 'Logic: Comparison operators.',
        },
        {
          'segments': ['int num = Integer.', 'slot', '("100");'],
          'blocks': ['parseInt', 'toString', 'valueOf', 'toInteger'],
          'correct': {1: 'parseInt'},
          'explanation': 'Types: String to integer parsing.',
        },
        {
          'segments': ['char c = s.', 'slot', '(0);'],
          'blocks': ['charAt', 'get', 'at', 'index'],
          'correct': {1: 'charAt'},
          'explanation': 'Strings: Getting char at index.',
        },
        {
          'segments': ['final double ', 'slot', ' = 3.14;'],
          'blocks': ['PI', 'val', 'var', 'num'],
          'correct': {1: 'PI'},
          'explanation': 'Syntax: Constant naming convention.',
        },
      ];
      final t = templates[index % templates.length];
      return CodeBlockPuzzle(
        id: 'cb_java_beg_$index',
        instruction: 'JAVA (Beginner)',
        explanation: t['explanation'] as String,
        codeSegments: t['segments'] as List<String>,
        availableBlocks: t['blocks'] as List<String>,
        correctAnswers: t['correct'] as Map<int, String>,
        xpReward: xp,
      );
    } else if (diff == 'intermediate') {
      final templates = [
        {
          'segments': ['Map<Integer, Integer> map = new ', 'slot', '<>();'],
          'blocks': ['HashMap', 'TreeMap', 'LinkedHashMap', 'Map'],
          'correct': {1: 'HashMap'},
          'explanation': 'LeetCode: Efficient O(1) lookups with HashMap.',
        },
        {
          'segments': ['@', 'slot', '\npublic String toString() { return ""; }'],
          'blocks': ['Override', 'Deprecated', 'SafeVarargs', 'Functional'],
          'correct': {1: 'Override'},
          'explanation': 'OOP: Explicitly overriding parent methods.',
        },
        {
          'segments': ['List<Integer> list = nums.stream().', 'slot', '(x -> x > 0).collect(Collectors.toList());'],
          'blocks': ['filter', 'map', 'forEach', 'reduce'],
          'correct': {1: 'filter'},
          'explanation': 'Java 8+: Filtering streams.',
        },
        {
          'segments': ['Optional<String> opt = Optional.', 'slot', '("data");'],
          'blocks': ['of', 'empty', 'get', 'value'],
          'correct': {1: 'of'},
          'explanation': 'Modern Java: Safe handling of nullable values.',
        },
        {
          'segments': ['public class Node<', 'slot', '> {\n  private T value;\n}'],
          'blocks': ['T', 'E', 'Object', '?'],
          'correct': {1: 'T'},
          'explanation': 'Generics: Type parameterization.',
        },
        {
          'segments': ['try {\n  process();\n} ', 'slot', ' (IOException e) {}'],
          'blocks': ['catch', 'finally', 'except', 'handle'],
          'correct': {1: 'catch'},
          'explanation': 'Robustness: Exception handling.',
        },
        {
          'segments': ['Set<String> set = new ', 'slot', '<>();'],
          'blocks': ['HashSet', 'TreeSet', 'Set', 'List'],
          'correct': {1: 'HashSet'},
          'explanation': 'Collections: Uniqueness with HashSet.',
        },
        {
          'segments': ['public int compareTo(', 'slot', ' other) {}'],
          'blocks': ['Person', 'Object', 'T', 'int'],
          'correct': {1: 'Person'},
          'explanation': 'OOP: Implementing Comparable interface.',
        },
        {
          'segments': ['String result = s.', 'slot', '();'],
          'blocks': ['trim', 'strip', 'clean', 'cut'],
          'correct': {1: 'trim'},
          'explanation': 'Strings: Removing leading/trailing whitespace.',
        },
        {
          'segments': ['StringBuilder sb = new ', 'slot', '();\nsb.append("a");'],
          'blocks': ['StringBuilder', 'String', 'Buffer', 'Array'],
          'correct': {1: 'StringBuilder'},
          'explanation': 'Performance: Efficient string concatenation.',
        },
      ];
      final t = templates[index % templates.length];
      return CodeBlockPuzzle(
        id: 'cb_java_int_$index',
        instruction: 'JAVA (Intermediate)',
        explanation: t['explanation'] as String,
        codeSegments: t['segments'] as List<String>,
        availableBlocks: t['blocks'] as List<String>,
        correctAnswers: t['correct'] as Map<int, String>,
        xpReward: xp,
      );
    } else {
      final templates = [
        {
          'segments': ['PriorityQueue<Integer> pq = new ', 'slot', '<>((a, b) -> a - b);'],
          'blocks': ['PriorityQueue', 'Queue', 'MinHeap', 'Heap'],
          'correct': {1: 'PriorityQueue'},
          'explanation': 'LeetCode Hard: PriorityQueue for Min/Max heaps.',
        },
        {
          'segments': ['ExecutorService executor = Executors.new', 'slot', 'ThreadPool(4);'],
          'blocks': ['Fixed', 'Single', 'Cached', 'Multi'],
          'correct': {1: 'Fixed'},
          'explanation': 'Advanced: Managing thread pools.',
        },
        {
          'segments': ['CompletableFuture<String> future = ', 'slot', '.supplyAsync(() -> "done");'],
          'blocks': ['CompletableFuture', 'Future', 'Thread', 'Task'],
          'correct': {1: 'CompletableFuture'},
          'explanation': 'Advanced: Asynchronous non-blocking pipelines.',
        },
        {
          'segments': ['Class<?> clazz = obj.getClass();\nField f = clazz.', 'slot', '("id");'],
          'blocks': ['getDeclaredField', 'getField', 'findField', 'loadField'],
          'correct': {1: 'getDeclaredField'},
          'explanation': 'Advanced: Runtime reflection API.',
        },
        {
          'segments': ['Map<Status, List<Task>> groups = tasks.stream().collect(Collectors.', 'slot', '(Task::getStatus));'],
          'blocks': ['groupingBy', 'toMap', 'partitioningBy', 'toList'],
          'correct': {1: 'groupingBy'},
          'explanation': 'Java 8+: Advanced grouping collectors.',
        },
        {
          'segments': ['AtomicInteger count = new ', 'slot', '(0);\ncount.incrementAndGet();'],
          'blocks': ['AtomicInteger', 'Integer', 'VolatileInt', 'SafeInt'],
          'correct': {1: 'AtomicInteger'},
          'explanation': 'Concurrency: Thread-safe counters.',
        },
        {
          'segments': ['ThreadLocal<Context> context = new ', 'slot', '<>();'],
          'blocks': ['ThreadLocal', 'ScopedValue', 'Volatile', 'Context'],
          'correct': {1: 'ThreadLocal'},
          'explanation': 'Advanced: Thread-confined storage.',
        },
        {
          'segments': ['@', 'slot', '(RetentionPolicy.RUNTIME)\npublic @interface Log {}'],
          'blocks': ['Retention', 'Target', 'Documented', 'Inherited'],
          'correct': {1: 'Retention'},
          'explanation': 'Advanced: Custom annotation policies.',
        },
        {
          'segments': ['try (', 'slot', ' reader = new BufferedReader(new FileReader(f))) {}'],
          'blocks': ['BufferedReader', 'Scanner', 'Reader', 'Stream'],
          'correct': {1: 'BufferedReader'},
          'explanation': 'Robustness: Try-with-resources and buffered IO.',
        },
        {
          'segments': ['synchronized (', 'slot', ') {\n  count++;\n}'],
          'blocks': ['this', 'lock', 'count', 'void'],
          'correct': {1: 'this'},
          'explanation': 'Concurrency: Synchronizing on object monitor.',
        },
      ];
      final t = templates[index % templates.length];
      return CodeBlockPuzzle(
        id: 'cb_java_adv_$index',
        instruction: 'JAVA (Advanced)',
        explanation: t['explanation'] as String,
        codeSegments: t['segments'] as List<String>,
        availableBlocks: t['blocks'] as List<String>,
        correctAnswers: t['correct'] as Map<int, String>,
        xpReward: xp,
      );
    }
  }

  static CodeBlockPuzzle _cppPuzzle(int index, String diff, int xp) {
    if (diff == 'beginner') {
      final templates = [
        {
          'segments': ['#include <', 'slot', '>\nstd::vector<int> v;'],
          'blocks': ['vector', 'array', 'list', 'std'],
          'correct': {1: 'vector'},
          'explanation': 'HackerRank: STL vector container.',
        },
        {
          'segments': ['std::', 'slot', ' << "Hello" << std::endl;'],
          'blocks': ['cout', 'cin', 'cerr', 'out'],
          'correct': {1: 'cout'},
          'explanation': 'Basics: Standard output stream.',
        },
        {
          'segments': ['int ', 'slot', '() {\n  return 0;\n}'],
          'blocks': ['main', 'start', 'init', 'exec'],
          'correct': {1: 'main'},
          'explanation': 'Basics: Program entry point.',
        },
        {
          'segments': ['for (int i = 0; i < n; ', 'slot', ') {}'],
          'blocks': ['i++', '++i', 'i+1', 'i+=1'],
          'correct': {1: 'i++'},
          'explanation': 'Basics: Loop increment.',
        },
        {
          'segments': ['std::string s = "Dev";\nint n = s.', 'slot', '();'],
          'blocks': ['length', 'size', 'count', 'len'],
          'correct': {1: 'length'},
          'explanation': 'Strings: String length method.',
        },
        {
          'segments': ['using namespace ', 'slot', ';'],
          'blocks': ['std', 'cpp', 'core', 'main'],
          'correct': {1: 'std'},
          'explanation': 'Basics: Namespace usage.',
        },
        {
          'segments': ['v.', 'slot', '(10);'],
          'blocks': ['push_back', 'append', 'add', 'put'],
          'correct': {1: 'push_back'},
          'explanation': 'Vectors: Adding items to the end.',
        },
        {
          'segments': ['#include <', 'slot', '>\nstd::string s;'],
          'blocks': ['string', 'iostream', 'vector', 'std'],
          'correct': {1: 'string'},
          'explanation': 'Basics: String header inclusion.',
        },
        {
          'segments': ['if (x == 0 ', 'slot', ' y == 0) {}'],
          'blocks': ['&&', '||', '!', 'and'],
          'correct': {1: '&&'},
          'explanation': 'Logic: Boolean AND operator.',
        },
        {
          'segments': ['const ', 'slot', ' PI = 3.14159;'],
          'blocks': ['double', 'int', 'bool', 'char'],
          'correct': {1: 'double'},
          'explanation': 'Types: High precision floating point.',
        },
      ];
      final t = templates[index % templates.length];
      return CodeBlockPuzzle(
        id: 'cb_cpp_beg_$index',
        instruction: 'C++ (Beginner)',
        explanation: t['explanation'] as String,
        codeSegments: t['segments'] as List<String>,
        availableBlocks: t['blocks'] as List<String>,
        correctAnswers: t['correct'] as Map<int, String>,
        xpReward: xp,
      );
    } else if (diff == 'intermediate') {
      final templates = [
        {
          'segments': ['void process(const std::vector<int>', 'slot', ' nums) {}'],
          'blocks': ['&', '*', '&&', 'ptr'],
          'correct': {1: '&'},
          'explanation': 'LeetCode: Pass by reference to avoid copying overhead.',
        },
        {
          'segments': ['std::map<string, int> m;\nm["key"] = ', 'slot', ';'],
          'blocks': ['1', 'int', 'val', 'put'],
          'correct': {1: '1'},
          'explanation': 'STL: Accessing map values.',
        },
        {
          'segments': ['std::sort(v.begin(), v.', 'slot', '());'],
          'blocks': ['end', 'last', 'stop', 'finish'],
          'correct': {1: 'end'},
          'explanation': 'STL Algorithms: Defining sort ranges.',
        },
        {
          'segments': ['class Shape {\n', 'slot', ':\n  virtual void draw() = 0;\n};'],
          'blocks': ['public', 'private', 'protected', 'internal'],
          'correct': {1: 'public'},
          'explanation': 'OOP: Access modifiers for interfaces.',
        },
        {
          'segments': ['virtual void move() ', 'slot', ' = 0;'],
          'blocks': ['override', 'final', 'pure', 'virtual'],
          'correct': {1: 'override'},
          'explanation': 'Modern C++: Explicitly marking overrides.',
        },
        {
          'segments': ['int* ptr = ', 'slot', ';\nif (ptr != nullptr) {}'],
          'blocks': ['nullptr', 'NULL', '0', 'none'],
          'correct': {1: 'nullptr'},
          'explanation': 'Modern C++: Type-safe null pointers.',
        },
        {
          'segments': ['std::unique(v.begin(), v.end());\nv.', 'slot', '(it, v.end());'],
          'blocks': ['erase', 'remove', 'delete', 'cut'],
          'correct': {1: 'erase'},
          'explanation': 'STL: Erase-remove idiom for unique elements.',
        },
        {
          'segments': ['auto it = std::', 'slot', '(v.begin(), v.end(), 5);'],
          'blocks': ['find', 'search', 'get', 'look'],
          'correct': {1: 'find'},
          'explanation': 'STL: Finding elements in a range.',
        },
        {
          'segments': ['Shape* s = new ', 'slot', '();'],
          'blocks': ['Circle', 'Shape', 'void', 'ptr'],
          'correct': {1: 'Circle'},
          'explanation': 'OOP: Polymorphic instantiation.',
        },
        {
          'segments': ['std::vector<int> v(10, ', 'slot', ');'],
          'blocks': ['0', 'size', 'capacity', 'val'],
          'correct': {1: '0'},
          'explanation': 'STL: Initializing vector with size and default value.',
        },
      ];
      final t = templates[index % templates.length];
      return CodeBlockPuzzle(
        id: 'cb_cpp_int_$index',
        instruction: 'C++ (Intermediate)',
        explanation: t['explanation'] as String,
        codeSegments: t['segments'] as List<String>,
        availableBlocks: t['blocks'] as List<String>,
        correctAnswers: t['correct'] as Map<int, String>,
        xpReward: xp,
      );
    } else {
      final templates = [
        {
          'segments': ['std::', 'slot', '<Node> root = std::make_unique<Node>();'],
          'blocks': ['unique_ptr', 'shared_ptr', 'weak_ptr', 'ptr'],
          'correct': {1: 'unique_ptr'},
          'explanation': 'Memory Safe: RAII with smart pointers.',
        },
        {
          'segments': ['template <', 'slot', ' T>\nclass Stack {};'],
          'blocks': ['typename', 'class', 'struct', 'type'],
          'correct': {1: 'typename'},
          'explanation': 'Advanced: Generic programming with templates.',
        },
        {
          'segments': ['std::string target = std::', 'slot', '(source);'],
          'blocks': ['move', 'forward', 'swap', 'copy'],
          'correct': {1: 'move'},
          'explanation': 'Performance: Move semantics to avoid copies.',
        },
        {
          'segments': ['std::thread t(', 'slot', ');\nt.join();'],
          'blocks': ['func', 'run', 'main', 'start'],
          'correct': {1: 'func'},
          'explanation': 'Concurrency: Creating OS threads.',
        },
        {
          'segments': ['std::lock_guard<std::', 'slot', '> lock(mtx);'],
          'blocks': ['mutex', 'thread', 'atomic', 'lock'],
          'correct': {1: 'mutex'},
          'explanation': 'Concurrency: RAII-based mutex locking.',
        },
        {
          'segments': ['static ', 'slot', ' int limit = 100;'],
          'blocks': ['constexpr', 'const', 'final', 'inline'],
          'correct': {1: 'constexpr'},
          'explanation': 'Advanced: Compile-time constant evaluation.',
        },
        {
          'segments': ['auto lambda = [', 'slot', '](int x) { return x + val; };'],
          'blocks': ['&', '=', 'this', 'val'],
          'correct': {1: '&'},
          'explanation': 'Advanced: Lambda capture by reference.',
        },
        {
          'segments': ['decltype(', 'slot', ') y = x;'],
          'blocks': ['x', 'int', 'auto', 'type'],
          'correct': {1: 'x'},
          'explanation': 'Modern C++: Deducing types from expressions.',
        },
        {
          'segments': ['template <typename... Args>\nvoid log(Args&&... ', 'slot', ') {}'],
          'blocks': ['args', 'T', '...', 'ptr'],
          'correct': {1: 'args'},
          'explanation': 'Advanced: Variadic templates for arbitrary arguments.',
        },
        {
          'segments': ['std::', 'slot', '<int> p = std::make_shared<int>(5);'],
          'blocks': ['shared_ptr', 'unique_ptr', 'weak_ptr', 'ptr'],
          'correct': {1: 'shared_ptr'},
          'explanation': 'Advanced: Reference-counted memory management.',
        },
      ];
      final t = templates[index % templates.length];
      return CodeBlockPuzzle(
        id: 'cb_cpp_adv_$index',
        instruction: 'C++ (Advanced)',
        explanation: t['explanation'] as String,
        codeSegments: t['segments'] as List<String>,
        availableBlocks: t['blocks'] as List<String>,
        correctAnswers: t['correct'] as Map<int, String>,
        xpReward: xp,
      );
    }
  }

  static List<SyntaxQuestion> generateSyntaxSniper(
    String language,
    String difficulty,
  ) {
    final List<SyntaxQuestion> questions = [];
    final lang = language.toUpperCase();
    final isAdv = difficulty.toLowerCase() == 'advanced';

    for (int i = 0; i < 30; i++) {
      if (lang == 'PYTHON') {
        questions.add(SyntaxQuestion(
          id: 'sn_py_$i',
          instruction: 'PYTHON',
          explanation: i % 2 == 0 
            ? 'Correct syntax.' 
            : isAdv ? 'Mutable default argument anti-pattern.' : 'Missing colon.',
          codeSnippet: i % 2 == 0 
            ? 'def add(a, b):\n  return a + b' 
            : isAdv ? 'def append_to(val, lst=[]):\n  lst.append(val)' : 'if True\n  print(1)',
          hasError: i % 2 != 0,
          xpReward: 10,
        ));
      } else if (lang == 'JAVA') {
        questions.add(SyntaxQuestion(
          id: 'sn_java_$i',
          instruction: 'JAVA',
          explanation: i % 2 == 0 ? 'Correct statement.' : 'String comparison using == instead of .equals()',
          codeSnippet: i % 2 == 0 ? 'if (s.equals("A")) {}' : 'if (s == "A") {}',
          hasError: i % 2 != 0,
          xpReward: 10,
        ));
      } else if (lang == 'JAVASCRIPT' || lang == 'JS') {
        questions.add(SyntaxQuestion(
          id: 'sn_js_$i',
          instruction: 'JAVASCRIPT',
          explanation: i % 2 == 0 ? 'Correct mapping.' : isAdv ? 'Missing await in async map.' : 'Missing const/let/var.',
          codeSnippet: i % 2 == 0 
            ? 'arr.map(x => x * 2);' 
            : isAdv ? 'await Promise.all(arr.map(async x => fetch(x)));' : 'x = 5;',
          hasError: i % 2 != 0,
          xpReward: 10,
        ));
      } else {
        questions.add(SyntaxQuestion(
          id: 'sn_cpp_$i',
          instruction: 'C++',
          explanation: i % 2 == 0 ? 'Valid.' : 'Memory leak: missing delete.',
          codeSnippet: i % 2 == 0 ? 'std::unique_ptr<int> p(new int(5));' : 'int* p = new int(5);\nreturn;',
          hasError: i % 2 != 0,
          xpReward: 10,
        ));
      }
    }
    return questions;
  }
}
