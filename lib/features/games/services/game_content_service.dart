// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:taskquest/features/games/models/game_models.dart';

class GameContentService {
  final Map<String, List<GameQuestion>> _cache = {};

  Future<void> warmUp(GameSessionConfig config) async {
    final cacheKey = '${config.type.name}_${config.options.values.join('_')}';
    if (_cache.containsKey(cacheKey)) return;

    final questions = await _fetchFromPool(config);
    _cache[cacheKey] = questions;
  }

  Future<List<GameQuestion>> fetchContent(GameSessionConfig config) async {
    final cacheKey = '${config.type.name}_${config.options.values.join('_')}';

    if (_cache.containsKey(cacheKey)) {
      final cached = List<GameQuestion>.from(_cache[cacheKey]!);
      cached.shuffle();
      final count = int.tryParse(config.options['Questions'] ?? '10') ?? 10;
      return cached.take(count).toList();
    }

    final questions = await _fetchFromPool(config);
    _cache[cacheKey] = questions;

    final result = List<GameQuestion>.from(questions);
    result.shuffle();
    final count = int.tryParse(config.options['Questions'] ?? '10') ?? 10;
    return result.take(count).toList();
  }

  Future<List<GameQuestion>> _fetchFromPool(GameSessionConfig config) async {
    await Future.delayed(const Duration(milliseconds: 500));

    switch (config.type) {
      case GameType.quiz:
        return _fetchQuizQuestions(config);
      case GameType.codeBlocks:
        return _fetchCodeBlocks(config);
      case GameType.sdlc:
        return _fetchSdlcSequences(config);
      case GameType.algorithm:
        return _fetchAlgorithmProblems(config);
      case GameType.syntaxSniper:
        return _fetchSyntaxSniperQuestions(config);
    }
  }

  List<SyntaxQuestion> _fetchSyntaxSniperQuestions(GameSessionConfig config) {
    final language = config.options['Language'] ?? 'All';

    final List<SyntaxQuestion> allQuestions = [
      // ── Java ──
      SyntaxQuestion(
        id: 'sn_java_1',
        instruction: 'Java',
        explanation: 'Missing semicolon.',
        codeSnippet: 'public void test() {\n  int x = 5\n}',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_java_2',
        instruction: 'Java',
        explanation: 'Wrong type.',
        codeSnippet: 'string name = "Scholar";',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_java_3',
        instruction: 'Java',
        explanation: 'Correct main.',
        codeSnippet:
            'public static void main(String[] args) {\n  System.out.println("Hi");\n}',
        hasError: false,
      ),
      SyntaxQuestion(
        id: 'sn_java_4',
        instruction: 'Java',
        explanation: 'Missing brace.',
        codeSnippet: 'public class Main\n  public int x = 10;\n}',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_java_5',
        instruction: 'Java',
        explanation: 'Valid array.',
        codeSnippet: 'int[] numbers = {1, 2, 3};',
        hasError: false,
      ),
      SyntaxQuestion(
        id: 'sn_java_6',
        instruction: 'Java',
        explanation: 'Missing params.',
        codeSnippet: 'if x > 5 {\n  return;\n}',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_java_7',
        instruction: 'Java',
        explanation: 'Invalid increment.',
        codeSnippet: 'int x = 0;\nx++++',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_java_8',
        instruction: 'Java',
        explanation: 'Valid const.',
        codeSnippet: 'public class User {\n  public User() {}\n}',
        hasError: false,
      ),
      SyntaxQuestion(
        id: 'sn_java_9',
        instruction: 'Java',
        explanation: 'Final reassign.',
        codeSnippet: 'final int x = 10;\nx = 20;',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_java_10',
        instruction: 'Java',
        explanation: 'Valid switch.',
        codeSnippet:
            'var res = switch(day) {\n  case 1 -> "M";\n  default -> "O";\n};',
        hasError: false,
      ),

      // ── Python ──
      SyntaxQuestion(
        id: 'sn_py_1',
        instruction: 'Python',
        explanation: 'Missing colon.',
        codeSnippet: 'def func()\n    print("Hi")',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_py_2',
        instruction: 'Python',
        explanation: 'Indentation.',
        codeSnippet: 'if True:\nprint("T")',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_py_3',
        instruction: 'Python',
        explanation: 'Valid list.',
        codeSnippet: 'sq = [x**2 for x in range(5)]',
        hasError: false,
      ),
      SyntaxQuestion(
        id: 'sn_py_4',
        instruction: 'Python',
        explanation: 'Missing quotes.',
        codeSnippet: 'msg = Hello',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_py_5',
        instruction: 'Python',
        explanation: 'Valid init.',
        codeSnippet: 'def __init__(self, n):\n    self.n = n',
        hasError: false,
      ),
      SyntaxQuestion(
        id: 'sn_py_6',
        instruction: 'Python',
        explanation: 'Wrong keyword.',
        codeSnippet: 'function test():\n    return 1',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_py_7',
        instruction: 'Python',
        explanation: 'Bad var name.',
        codeSnippet: '1_var = 10',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_py_8',
        instruction: 'Python',
        explanation: 'Valid f-str.',
        codeSnippet: r'print(f"Hi {n}!")',
        hasError: false,
      ),
      SyntaxQuestion(
        id: 'sn_py_9',
        instruction: 'Python',
        explanation: 'No parens.',
        codeSnippet: 'print "Hi"',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_py_10',
        instruction: 'Python',
        explanation: 'Global use.',
        codeSnippet: 'global x\nx = 10',
        hasError: false,
      ),

      // ── JavaScript ──
      SyntaxQuestion(
        id: 'sn_js_1',
        instruction: 'JavaScript',
        explanation: 'Closing bracket.',
        codeSnippet: 'const u = { n: "A";',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_js_2',
        instruction: 'JavaScript',
        explanation: 'Arrow func.',
        codeSnippet: 'const add = (a, b) => a + b;',
        hasError: false,
      ),
      SyntaxQuestion(
        id: 'sn_js_3',
        instruction: 'JavaScript',
        explanation: 'Digit start var.',
        codeSnippet: 'let 1st = "S";',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_js_4',
        instruction: 'JavaScript',
        explanation: 'Template lit.',
        codeSnippet: r'const g = `Hi ${n}`;',
        hasError: false,
      ),
      SyntaxQuestion(
        id: 'sn_js_5',
        instruction: 'JavaScript',
        explanation: 'Const reassign.',
        codeSnippet: 'const x = 1;\nx = 2;',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_js_6',
        instruction: 'JavaScript',
        explanation: 'Async await.',
        codeSnippet: 'function t() {\n  await f();\n}',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_js_7',
        instruction: 'JavaScript',
        explanation: 'Spread.',
        codeSnippet: 'const a = [...b, 3];',
        hasError: false,
      ),
      SyntaxQuestion(
        id: 'sn_js_8',
        instruction: 'JavaScript',
        explanation: 'Equality.',
        codeSnippet: 'if (x == 5) return;',
        hasError: false,
      ),
      SyntaxQuestion(
        id: 'sn_js_9',
        instruction: 'JavaScript',
        explanation: 'No paren.',
        codeSnippet: 'console.log("H"',
        hasError: true,
      ),
      SyntaxQuestion(
        id: 'sn_js_10',
        instruction: 'JavaScript',
        explanation: 'Ternary.',
        codeSnippet: 'const r = a ? 1 : 0;',
        hasError: false,
      ),
    ];

    if (language == 'All') return allQuestions;
    return allQuestions.where((q) => q.instruction == language).toList();
  }

  List<QuizQuestion> _fetchQuizQuestions(GameSessionConfig config) {
    final pool = config.options['Pool'] ?? 'Popular';

    final List<QuizQuestion> all = [
      QuizQuestion(
        id: 'q_1',
        instruction: 'PYTHON',
        explanation: 'Significant whitespace.',
        codeSnippet: 'Which language uses indentation for blocks?',
        correctAnswer: 'Python',
        options: ['Java', 'C++', 'Python', 'JS'],
        xpReward: 15,
      ),
      QuizQuestion(
        id: 'q_2',
        instruction: 'C',
        explanation: 'Manual memory.',
        codeSnippet: 'Which requires manual memory management?',
        correctAnswer: 'C',
        options: ['Java', 'Python', 'JS', 'C'],
        xpReward: 20,
      ),
      QuizQuestion(
        id: 'q_3',
        instruction: 'WEB',
        explanation: 'Browser native.',
        codeSnippet: 'Which runs in every modern browser?',
        correctAnswer: 'JavaScript',
        options: ['Java', 'Python', 'JavaScript', 'Rust'],
        xpReward: 15,
      ),
      QuizQuestion(
        id: 'q_4',
        instruction: 'SQL',
        explanation: 'DB language.',
        codeSnippet: 'What is used to query databases?',
        correctAnswer: 'SQL',
        options: ['HTML', 'SQL', 'CSS', 'XML'],
        xpReward: 15,
      ),
      QuizQuestion(
        id: 'q_5',
        instruction: 'iOS',
        explanation: 'Apple dev.',
        codeSnippet: 'Primary language for iOS development?',
        correctAnswer: 'Swift',
        options: ['Swift', 'Kotlin', 'Dart', 'Java'],
        xpReward: 15,
      ),
      QuizQuestion(
        id: 'q_6',
        instruction: 'RUST',
        explanation: 'Memory safety.',
        codeSnippet: 'Known for Ownership and Borrowing?',
        correctAnswer: 'Rust',
        options: ['Go', 'C++', 'Rust', 'Java'],
        xpReward: 25,
      ),
      QuizQuestion(
        id: 'q_7',
        instruction: 'FLUTTER',
        explanation: 'Google UI.',
        codeSnippet: 'Which language powers Flutter?',
        correctAnswer: 'Dart',
        options: ['Kotlin', 'Java', 'Dart', 'Swift'],
        xpReward: 15,
      ),
      QuizQuestion(
        id: 'q_8',
        instruction: 'JAVA',
        explanation: 'Write once, run anywhere.',
        codeSnippet: 'Which language uses the JVM?',
        correctAnswer: 'Java',
        options: ['Java', 'Python', 'Swift', 'C#'],
        xpReward: 15,
      ),
      QuizQuestion(
        id: 'q_9',
        instruction: 'C#',
        explanation: 'Microsoft.',
        codeSnippet: 'Language created by Microsoft?',
        correctAnswer: 'C#',
        options: ['Apple', 'Oracle', 'Microsoft', 'Google'],
        xpReward: 15,
      ),
      QuizQuestion(
        id: 'q_10',
        instruction: 'PHP',
        explanation: 'Server side.',
        codeSnippet: 'Originally "Personal Home Page"?',
        correctAnswer: 'PHP',
        options: ['Perl', 'PHP', 'Ruby', 'Python'],
        xpReward: 10,
      ),
    ];

    if (pool == 'Web') {
      return all
          .where(
            (q) =>
                q.correctAnswer == 'JavaScript' ||
                q.instruction == 'WEB' ||
                q.correctAnswer == 'PHP',
          )
          .toList();
    }
    if (pool == 'System') {
      return all
          .where((q) => q.correctAnswer == 'C' || q.correctAnswer == 'Rust')
          .toList();
    }
    return all;
  }

  List<GameQuestion> _fetchCodeBlocks(GameSessionConfig config) {
    final language = config.options['Language'] ?? 'Python';
    final List<CodeBlockPuzzle> all = [
      CodeBlockPuzzle(
        id: 'cb_py_1',
        instruction: 'PYTHON',
        explanation: 'Range loop.',
        codeSegments: ['for i in ', 'slot', '(5):'],
        availableBlocks: ['range', 'list', 'items'],
        correctAnswers: {1: 'range'},
        xpReward: 10,
      ),
      CodeBlockPuzzle(
        id: 'cb_py_2',
        instruction: 'PYTHON',
        explanation: 'Function.',
        codeSegments: ['slot', ' add(a, b):'],
        availableBlocks: ['def', 'func', 'define'],
        correctAnswers: {1: 'def'},
        xpReward: 10,
      ),
      CodeBlockPuzzle(
        id: 'cb_js_1',
        instruction: 'JS',
        explanation: 'Map.',
        codeSegments: ['nums.', 'slot', '((n) => n * 2);'],
        availableBlocks: ['map', 'filter', 'each'],
        correctAnswers: {1: 'map'},
        xpReward: 15,
      ),
      CodeBlockPuzzle(
        id: 'cb_js_2',
        instruction: 'JS',
        explanation: 'Async.',
        codeSegments: ['slot', ' function f() {}'],
        availableBlocks: ['async', 'sync', 'wait'],
        correctAnswers: {1: 'async'},
        xpReward: 15,
      ),
      CodeBlockPuzzle(
        id: 'cb_java_1',
        instruction: 'JAVA',
        explanation: 'Main.',
        codeSegments: ['public static ', 'slot', ' main'],
        availableBlocks: ['void', 'int', 'String'],
        correctAnswers: {1: 'void'},
        xpReward: 10,
      ),
      CodeBlockPuzzle(
        id: 'cb_java_2',
        instruction: 'JAVA',
        explanation: 'Extends.',
        codeSegments: ['class A ', 'slot', ' B {}'],
        availableBlocks: ['extends', 'implements'],
        correctAnswers: {1: 'extends'},
        xpReward: 15,
      ),
      CodeBlockPuzzle(
        id: 'cb_cpp_1',
        instruction: 'C++',
        explanation: 'Pointer.',
        codeSegments: ['int', 'slot', ' p = &x;'],
        availableBlocks: ['*', '&', '#'],
        correctAnswers: {1: '*'},
        xpReward: 20,
      ),
    ];

    final filtered = all
        .where(
          (q) =>
              language == 'All' ||
              q.instruction.contains(language.toUpperCase()),
        )
        .toList();
    return filtered.isNotEmpty ? filtered : all.take(5).toList();
  }

  List<GameQuestion> _fetchSdlcSequences(GameSessionConfig config) {
    final List<SdlcSequence> all = [
      SdlcSequence(
        id: 's_1',
        instruction: 'WATERFALL',
        explanation: 'Standard sequence.',
        correctOrder: [
          'Requirements',
          'Design',
          'Implementation',
          'Verification',
          'Maintenance',
        ],
        shuffledPhases: [
          'Design',
          'Maintenance',
          'Requirements',
          'Implementation',
          'Verification',
        ],
        xpReward: 20,
      ),
      SdlcSequence(
        id: 's_2',
        instruction: 'AGILE',
        explanation: 'Iterative.',
        correctOrder: [
          'Planning',
          'Design',
          'Development',
          'Testing',
          'Deployment',
        ],
        shuffledPhases: [
          'Testing',
          'Planning',
          'Deployment',
          'Design',
          'Development',
        ],
        xpReward: 20,
      ),
      SdlcSequence(
        id: 's_3',
        instruction: 'BUG FIX',
        explanation: 'Fixing flow.',
        correctOrder: [
          'Discovery',
          'Triage',
          'Fixing',
          'Verification',
          'Deployment',
        ],
        shuffledPhases: [
          'Fixing',
          'Deployment',
          'Discovery',
          'Verification',
          'Triage',
        ],
        xpReward: 20,
      ),
      SdlcSequence(
        id: 's_4',
        instruction: 'TDD',
        explanation: 'Test driven.',
        correctOrder: [
          'Write Test',
          'Test Fails',
          'Write Code',
          'Test Passes',
          'Refactor',
        ],
        shuffledPhases: [
          'Refactor',
          'Write Code',
          'Write Test',
          'Test Passes',
          'Test Fails',
        ],
        xpReward: 25,
      ),
      SdlcSequence(
        id: 's_5',
        instruction: 'CI/CD',
        explanation: 'Automated.',
        correctOrder: ['Commit', 'Build', 'Test', 'Release', 'Deploy'],
        shuffledPhases: ['Test', 'Commit', 'Deploy', 'Build', 'Release'],
        xpReward: 20,
      ),
    ];
    return all;
  }

  List<GameQuestion> _fetchAlgorithmProblems(GameSessionConfig config) {
    final List<AlgorithmProblem> all = [
      AlgorithmProblem(
        id: 'a_1',
        instruction: 'AND',
        explanation: 'T & F = F.',
        pseudocode: 'A=T, B=F, R=A AND B',
        question: 'Value of R?',
        correctAnswer: 'False',
        options: ['True', 'False', 'None'],
        xpReward: 15,
      ),
      AlgorithmProblem(
        id: 'a_2',
        instruction: 'SWAP',
        explanation: 'Temp var.',
        pseudocode: 'x=1, y=2, t=x, x=y, y=t',
        question: 'Value of y?',
        correctAnswer: '1',
        options: ['1', '2', '0'],
        xpReward: 15,
      ),
      AlgorithmProblem(
        id: 'a_3',
        instruction: 'LOOP',
        explanation: '3 times.',
        pseudocode: 'c=0, FOR i FROM 0 TO 2: c++',
        question: 'Final c?',
        correctAnswer: '3',
        options: ['2', '3', '4'],
        xpReward: 15,
      ),
      AlgorithmProblem(
        id: 'a_4',
        instruction: 'BIG O',
        explanation: 'O(N^2).',
        pseudocode: 'FOR i in N: FOR j in N: print',
        question: 'Complexity?',
        correctAnswer: 'O(N^2)',
        options: ['O(N)', 'O(N^2)', 'O(1)'],
        xpReward: 25,
      ),
      AlgorithmProblem(
        id: 'a_5',
        instruction: 'BINARY',
        explanation: 'O(log N).',
        pseudocode: 'Binary Search core.',
        question: 'Complexity?',
        correctAnswer: 'O(log N)',
        options: ['O(N)', 'O(log N)', 'O(N^2)'],
        xpReward: 30,
      ),
    ];
    return all;
  }
}
