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

    for (int i = 1; i <= 30; i++) {
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
        }
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
          'segments': ['# LeetCode: Two Sum\ndef two_sum(nums, target):\n  seen = {}\n  for i, n in ', 'slot', '(nums):\n    if target - n in seen: return [seen[target-n], i]'],
          'blocks': ['enumerate', 'range', 'zip', 'iter'],
          'correct': {1: 'enumerate'},
          'explanation': 'LeetCode Easy/Med: Using enumerate for Two Sum.',
        },
        {
          'segments': ['# LeetCode: Valid Anagram\nfrom collections import ', 'slot', '\nCounter(s) == Counter(t)'],
          'blocks': ['Counter', 'defaultdict', 'deque', 'namedtuple'],
          'correct': {1: 'Counter'},
          'explanation': 'LeetCode Hash Table: Using Counter.',
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
          'segments': ['# LeetCode Hard: LRU Cache\nfrom collections import ', 'slot', '\nclass LRUCache:\n  def __init__(self, capacity): self.cache = OrderedDict()'],
          'blocks': ['OrderedDict', 'deque', 'Heap', 'TreeSet'],
          'correct': {1: 'OrderedDict'},
          'explanation': 'LeetCode Hard: LRU Cache requires O(1) ordering.',
        },
        {
          'segments': ['# CodeCrafters: Build Redis\nimport asyncio\nasync def handle_client(reader, ', 'slot', '):\n  data = await reader.read(100)'],
          'blocks': ['writer', 'socket', 'channel', 'stream'],
          'correct': {1: 'writer'},
          'explanation': 'CodeCrafters: asyncio stream manipulation.',
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
          'segments': ['// LeetCode Hard: Median of Two Sorted Arrays\n// Time: O(log(min(m,n)))\nfunction findMedian(nums1, nums2) {\n  if (nums1.length > nums2.length) return findMedian(', 'slot', ');\n}'],
          'blocks': ['nums2, nums1', 'nums1, nums2', 'nums1', 'nums2'],
          'correct': {1: 'nums2, nums1'},
          'explanation': 'LeetCode Hard: Binary Search partitioning constraint.',
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
      return CodeBlockPuzzle(
        id: 'cb_java_beg_$index',
        instruction: 'JAVA (Beginner)',
        explanation: 'HackerRank: Scanner input.',
        codeSegments: ['Scanner sc = new Scanner(System.', 'slot', ');'],
        availableBlocks: ['in', 'out', 'err', 'read'],
        correctAnswers: {1: 'in'},
        xpReward: xp,
      );
    } else if (diff == 'intermediate') {
      return CodeBlockPuzzle(
        id: 'cb_java_int_$index',
        instruction: 'JAVA (Intermediate)',
        explanation: 'LeetCode: HashMap usage.',
        codeSegments: ['Map<Integer, Integer> map = new ', 'slot', '<>();'],
        availableBlocks: ['HashMap', 'Map', 'TreeMap', 'HashTable'],
        correctAnswers: {1: 'HashMap'},
        xpReward: xp,
      );
    } else {
      return CodeBlockPuzzle(
        id: 'cb_java_adv_$index',
        instruction: 'JAVA (Advanced)',
        explanation: 'LeetCode Hard: PriorityQueue (Min Heap).',
        codeSegments: ['PriorityQueue<Integer> pq = new ', 'slot', '<>((a, b) -> a - b);'],
        availableBlocks: ['PriorityQueue', 'Queue', 'MinHeap', 'Heap'],
        correctAnswers: {1: 'PriorityQueue'},
        xpReward: xp,
      );
    }
  }

  static CodeBlockPuzzle _cppPuzzle(int index, String diff, int xp) {
    if (diff == 'beginner') {
      return CodeBlockPuzzle(
        id: 'cb_cpp_beg_$index',
        instruction: 'C++ (Beginner)',
        explanation: 'HackerRank: Vector inclusion.',
        codeSegments: ['#include <', 'slot', '>\nstd::vector<int> v;'],
        availableBlocks: ['vector', 'array', 'list', 'std'],
        correctAnswers: {1: 'vector'},
        xpReward: xp,
      );
    } else if (diff == 'intermediate') {
      return CodeBlockPuzzle(
        id: 'cb_cpp_int_$index',
        instruction: 'C++ (Intermediate)',
        explanation: 'LeetCode: Pass by reference to avoid copy.',
        codeSegments: ['void process(const std::vector<int>', 'slot', ' nums) {}'],
        availableBlocks: ['&', '*', '&&', 'ptr'],
        correctAnswers: {1: '&'},
        xpReward: xp,
      );
    } else {
      return CodeBlockPuzzle(
        id: 'cb_cpp_adv_$index',
        instruction: 'C++ (Advanced)',
        explanation: 'Memory Safe: Smart Pointers.',
        codeSegments: ['std::', 'slot', '<Node> root = std::make_unique<Node>();'],
        availableBlocks: ['unique_ptr', 'shared_ptr', 'weak_ptr', 'ptr'],
        correctAnswers: {1: 'unique_ptr'},
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

    for (int i = 1; i <= 30; i++) {
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
