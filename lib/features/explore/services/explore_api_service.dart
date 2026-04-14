import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ExploreArticle {
  final int id;
  final String title;
  final String description;
  final String coverImage;
  final String url;
  final List<String> tags;

  ExploreArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.url,
    required this.tags,
  });

  factory ExploreArticle.fromJson(Map<String, dynamic> json) {
    return ExploreArticle(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      coverImage:
          json['cover_image'] ?? 'https://picsum.photos/seed/tech/600/400',
      url: json['url'] ?? '',
      tags: List<String>.from(json['tag_list'] ?? []),
    );
  }
}

class WikiSearchResult {
  final String title;
  final String snippet;

  WikiSearchResult({required this.title, required this.snippet});

  factory WikiSearchResult.fromJson(Map<String, dynamic> json) {
    return WikiSearchResult(
      title: json['title'] ?? '',
      snippet: json['snippet'] ?? '',
    );
  }
}

class WikiPageSummary {
  final String title;
  final String extract;
  final String? thumbnailUrl;
  final String contentUrls;

  WikiPageSummary({
    required this.title,
    required this.extract,
    this.thumbnailUrl,
    required this.contentUrls,
  });

  factory WikiPageSummary.fromJson(Map<String, dynamic> json) {
    return WikiPageSummary(
      title: json['title'] ?? '',
      extract: json['extract'] ?? '',
      thumbnailUrl: json['thumbnail']?['source'],
      contentUrls: json['content_urls']?['desktop']?['page'] ?? '',
    );
  }
}

class WikiHistoryEvent {
  final String title;
  final String fact;
  final String year;

  WikiHistoryEvent({
    required this.title,
    required this.fact,
    required this.year,
  });

  factory WikiHistoryEvent.fromWikidata(Map<String, dynamic> binding) {
    final dateStr = binding['date']?['value'] ?? '';
    final year = dateStr.isNotEmpty ? dateStr.split('-')[0] : 'Unknown';
    return WikiHistoryEvent(
      title: binding['itemLabel']?['value'] ?? 'Unknown Event',
      fact:
          binding['description']?['value'] ??
          'A milestone in computing history.',
      year: year,
    );
  }
}

class WikiTimelineItem {
  final String title;
  final String date;
  final String? description;

  WikiTimelineItem({required this.title, required this.date, this.description});

  factory WikiTimelineItem.fromWikidata(Map<String, dynamic> binding) {
    return WikiTimelineItem(
      title: binding['itemLabel']?['value'] ?? 'Unknown',
      date:
          binding['dateLabel']?['value'] ??
          (binding['date']?['value'] ?? '').split('T')[0],
      description: binding['description']?['value'],
    );
  }
}

class WikiCategoryResponse {
  final List<String> members;
  final String? continueToken;

  WikiCategoryResponse({required this.members, this.continueToken});
}

class ExploreApiService {
  // ── Wikipedia REST API Base URLs ───────────────────────────
  static const String _wikiRestUrl = 'https://en.wikipedia.org/api/rest_v1';
  static const String _wikiActionUrl = 'https://en.wikipedia.org/w/api.php';

  Future<List<ExploreArticle>> fetchTechArticles({
    String tag = 'programming',
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://dev.to/api/articles?tag=${tag.toLowerCase()}&top=1&per_page=10',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ExploreArticle.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<ExploreArticle>> searchArticles(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://dev.to/api/articles?tag=${Uri.encodeComponent(query)}&per_page=5',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ExploreArticle.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<String> fetchArticleContent(int id) async {
    try {
      final response = await http.get(
        Uri.parse('https://dev.to/api/articles/$id'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['body_markdown'] ?? '';
      }
      return 'Failed to load article content.';
    } catch (e) {
      return 'Error: $e';
    }
  }

  // ── Wikipedia Methods ───────────────────────────────────────

  Future<List<WikiSearchResult>> searchWikipedia(String query) async {
    try {
      final refinedQuery =
          '$query (technology OR computing OR "computer science")';
      final url =
          '$_wikiActionUrl?action=query&list=search&srsearch=${Uri.encodeComponent(refinedQuery)}&utf8=&format=json&origin=*';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['query']?['search'] as List?;
        if (results != null) {
          return results
              .map((json) => WikiSearchResult.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<WikiPageSummary?> fetchWikiSummary(String title) async {
    try {
      final url = '$_wikiRestUrl/page/summary/${Uri.encodeComponent(title)}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return WikiPageSummary.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ── Optimized Historical Data Methods (CORS Friendly) ───────

  Future<WikiHistoryEvent?> fetchDailyByte() async {
    try {
      final now = DateTime.now();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');

      // Use Wikipedia's "On This Day" feed - very reliable & fast
      final url = '$_wikiRestUrl/feed/onthisday/all/$month/$day';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final events = data['selected'] as List?;

        if (events != null && events.isNotEmpty) {
          // Stricter keywords to ensure relevance to Computer Science/Tech
          final techKeywords = [
            'computer',
            'software',
            'programming language',
            'internet',
            'world wide web',
            'microprocessor',
            'artificial intelligence',
            'operating system',
            'silicon valley',
            'apple inc',
            'microsoft',
            'ibm',
            'arpanet',
            'compiler',
            'database',
            'algorithm',
          ];

          for (final event in events) {
            final text = (event['text'] as String).toLowerCase();
            // Check if text or linked pages contain strict tech keywords
            bool isTech = techKeywords.any((kw) => text.contains(kw));

            if (!isTech && event['pages'] != null) {
              for (final page in event['pages']) {
                final pageDesc = (page['description'] ?? '').toLowerCase();
                if (techKeywords.any((kw) => pageDesc.contains(kw))) {
                  isTech = true;
                  break;
                }
              }
            }

            if (isTech) {
              return WikiHistoryEvent(
                title: 'On This Day',
                fact: event['text'] ?? '',
                year: event['year']?.toString() ?? '',
              );
            }
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching daily byte: $e');
      return null;
    }
  }

  Future<WikiCategoryResponse> fetchPioneersPaginated({
    String category = 'Category:Computer_scientists',
    String? continueToken,
  }) async {
    try {
      String url =
          '$_wikiActionUrl?action=query&list=categorymembers&cmtitle=${Uri.encodeComponent(category)}&cmlimit=20&format=json&origin=*';
      if (continueToken != null) {
        url += '&cmcontinue=${Uri.encodeComponent(continueToken)}';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final members = data['query']?['categorymembers'] as List?;
        final nextToken = data['continue']?['cmcontinue'] as String?;

        if (members != null) {
          final names =
              members
                  .map((m) => m['title'] as String)
                  .where((name) => !name.contains('Category:'))
                  .toList();
          return WikiCategoryResponse(members: names, continueToken: nextToken);
        }
      }
      return WikiCategoryResponse(members: []);
    } catch (e) {
      return WikiCategoryResponse(members: []);
    }
  }

  Future<List<WikiTimelineItem>> fetchComputingTimeline() async {
    // For timeline, we'll use a curated list of significant tech milestones
    // and verify their summaries if needed. This is much faster than complex SPARQL.
    final items = [
      WikiTimelineItem(title: 'World Wide Web', date: '1990'),
      WikiTimelineItem(title: 'Linux Kernel', date: '1991'),
      WikiTimelineItem(title: 'Python (programming language)', date: '1991'),
      WikiTimelineItem(title: 'Java (programming language)', date: '1995'),
      WikiTimelineItem(title: 'C++', date: '1985'),
      WikiTimelineItem(title: 'Apple Macintosh', date: '1984'),
      WikiTimelineItem(title: 'IBM Personal Computer', date: '1981'),
      WikiTimelineItem(title: 'C (programming language)', date: '1972'),
      WikiTimelineItem(title: 'ARPANET', date: '1969'),
      WikiTimelineItem(title: 'COBOL', date: '1959'),
      WikiTimelineItem(title: 'Integrated circuit', date: '1958'),
      WikiTimelineItem(title: 'FORTRAN', date: '1957'),
      WikiTimelineItem(title: 'ENIAC', date: '1946'),
      WikiTimelineItem(title: 'Turing machine', date: '1936'),
    ];
    return items;
  }
}
