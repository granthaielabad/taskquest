// Copyright (c) 2026 TaskQuest. All rights reserved.

import 'package:taskquest/features/games/models/game_models.dart';
import 'content/quiz_content.dart';
import 'content/sdlc_content.dart';
import 'content/algorithm_content.dart';
import 'content/procedural_content_generator.dart';

class GameContentService {
  Future<void> warmUp(GameSessionConfig config) async {
    // Warmup is no longer necessary as content is generated/fetched quickly
    return;
  }

  Future<List<GameQuestion>> fetchContent(GameSessionConfig config) async {
    final pool = await _fetchFromPool(config);

    final result = List<GameQuestion>.from(pool);
    // Ensure thorough randomization
    result.shuffle();
    
    final count = int.tryParse(config.options['Questions'] ?? '10') ?? 10;
    return result.take(count).toList();
  }

  Future<List<GameQuestion>> _fetchFromPool(GameSessionConfig config) async {
    await Future.delayed(const Duration(milliseconds: 300));

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
    final difficulty = config.options['Difficulty'] ?? 'Beginner';
    return ProceduralContentGenerator.generateSyntaxSniper(language, difficulty);
  }

  List<QuizQuestion> _fetchQuizQuestions(GameSessionConfig config) {
    final pool = config.options['Pool'] ?? 'All';
    var filtered = allQuizQuestions;

    if (pool != 'All' && pool != 'Mixed') {
      final p = pool.toLowerCase();
      filtered = filtered.where((q) {
        final text = ('${q.instruction} ${q.explanation} ${q.codeSnippet}').toLowerCase();
        if (p == 'web') return text.contains('web') || text.contains('html') || text.contains('css') || text.contains('javascript');
        if (p == 'system') return text.contains('system') || text.contains('c++') || text.contains('rust') || text.contains('memory');
        if (p == 'legacy') return text.contains('legacy') || text.contains('cobol') || text.contains('fortran') || text.contains('ada');
        return true;
      }).toList();
    }
    
    if (filtered.isEmpty) return allQuizQuestions;
    return filtered;
  }

  List<GameQuestion> _fetchCodeBlocks(GameSessionConfig config) {
    final language = config.options['Language'] ?? 'Python';
    final difficulty = config.options['Difficulty'] ?? 'Beginner';
    return ProceduralContentGenerator.generateCodeBlocks(language, difficulty);
  }

  List<GameQuestion> _fetchSdlcSequences(GameSessionConfig config) {
    final modelType = config.options['Model Type'] ?? 'Mixed';
    var filtered = allSdlcSequences;
    
    if (modelType != 'Mixed' && modelType != 'All') {
      final type = modelType.toLowerCase();
      filtered = filtered.where((s) {
        final text = ('${s.instruction} ${s.explanation}').toLowerCase();
        if (type == 'waterfall') {
           return text.contains('waterfall') || text.contains('pipeline') || text.contains('standard') || text.contains('ci/cd');
        } else if (type == 'agile') {
           return text.contains('agile') || text.contains('scrum') || text.contains('sprint') || text.contains('tdd');
        } else if (type == 'spiral') {
           return text.contains('spiral') || text.contains('data') || text.contains('machine learning') || text.contains('security');
        }
        return true;
      }).toList();
    }
    
    if (filtered.isEmpty) return allSdlcSequences;
    return filtered;
  }

  List<GameQuestion> _fetchAlgorithmProblems(GameSessionConfig config) {
    final category = config.options['Category'] ?? 'All';
    final difficulty = config.options['Difficulty'] ?? 'Beginner';

    var filtered = allAlgorithmProblems;

    // Filter by Difficulty
    if (difficulty == 'Beginner') {
      filtered = filtered.where((a) => a.id.contains('_beg_')).toList();
    } else if (difficulty == 'Advanced') {
      filtered = filtered.where((a) => a.id.contains('_adv_') || a.id.contains('_int_')).toList();
    }

    // Filter by Category
    if (category != 'All' && category != 'Mixed') {
      final cat = category.toLowerCase();
      filtered = filtered.where((a) {
        final text = ('${a.instruction} ${a.question} ${a.explanation}').toLowerCase();
        if (cat == 'sorting' || cat == 'sort') {
          return text.contains('sort');
        } else if (cat == 'search') {
          return text.contains('search') || text.contains('find') || text.contains('traverse') || text.contains('traversal') || text.contains('pointers');
        } else if (cat == 'big o') {
          return text.contains('complexity') || text.contains('big o') || text.contains('o(') || text.contains('time complexity');
        }
        return true;
      }).toList();
    }

    if (filtered.isEmpty) return allAlgorithmProblems;
    return filtered;
  }
}
