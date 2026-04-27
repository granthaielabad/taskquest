import 'dart:convert';
import 'dart:math';
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

  Future<List<String>> searchPioneers(String query) async {
    try {
      final refinedQuery =
          '$query (computer scientist OR computing OR pioneer OR technology)';
      final url =
          '$_wikiActionUrl?action=query&list=search&srsearch=${Uri.encodeComponent(refinedQuery)}&utf8=&format=json&origin=*';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['query']?['search'] as List?;
        if (results != null) {
          return results.map((m) => m['title'] as String).toList();
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

      // ── Smart Fallback ───────────────────────────────────────
      // If direct hit fails, search for the title and try the first result
      final searchResults = await searchWikipedia(title);
      if (searchResults.isNotEmpty) {
        final refinedTitle = searchResults.first.title;
        final refinedUrl =
            '$_wikiRestUrl/page/summary/${Uri.encodeComponent(refinedTitle)}';
        final refinedResponse = await http.get(Uri.parse(refinedUrl));

        if (refinedResponse.statusCode == 200) {
          return WikiPageSummary.fromJson(jsonDecode(refinedResponse.body));
        }
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

          final List<WikiHistoryEvent> techEvents = [];

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
              techEvents.add(
                WikiHistoryEvent(
                  title: 'On This Day',
                  fact: event['text'] ?? '',
                  year: event['year']?.toString() ?? '',
                ),
              );
            }
          }

          if (techEvents.isNotEmpty) {
            final random = Random();
            return techEvents[random.nextInt(techEvents.length)];
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
      WikiTimelineItem(
        title: 'World Wide Web',
        date: '1990',
        description: 'Tim Berners-Lee wrote the first web server and browser.',
      ),
      WikiTimelineItem(
        title: 'Linux kernel',
        date: '1991',
        description: 'Linus Torvalds released the first version of Linux.',
      ),
      WikiTimelineItem(
        title: 'Python (programming language)',
        date: '1991',
        description: 'Guido van Rossum released the first version of Python.',
      ),
      WikiTimelineItem(
        title: 'Java (programming language)',
        date: '1995',
        description:
            'Sun Microsystems released Java as a write-once, run-anywhere language.',
      ),
      WikiTimelineItem(
        title: 'C++',
        date: '1985',
        description: 'Bjarne Stroustrup released the C++ programming language.',
      ),
      WikiTimelineItem(
        title: 'Macintosh',
        date: '1984',
        description:
            'Apple introduced the Macintosh, the first successful GUI-based computer.',
      ),
      WikiTimelineItem(
        title: 'IBM Personal Computer',
        date: '1981',
        description:
            'IBM released its PC, setting the standard for personal computers.',
      ),
      WikiTimelineItem(
        title: 'C (programming language)',
        date: '1972',
        description: 'Dennis Ritchie developed C at Bell Labs for the Unix OS.',
      ),
      WikiTimelineItem(
        title: 'ARPANET',
        date: '1969',
        description:
            'The first message was sent over ARPANET, the precursor to the internet.',
      ),
      WikiTimelineItem(
        title: 'COBOL',
        date: '1959',
        description:
            'COBOL was designed as a portable language for business data processing.',
      ),
      WikiTimelineItem(
        title: 'Integrated circuit',
        date: '1958',
        description:
            'Jack Kilby and Robert Noyce independently invented the integrated circuit.',
      ),
      WikiTimelineItem(
        title: 'Fortran',
        date: '1957',
        description:
            'John Backus and IBM developed FORTRAN, the first high-level language.',
      ),
      WikiTimelineItem(
        title: 'ENIAC',
        date: '1946',
        description:
            'ENIAC, the first general-purpose electronic computer, was unveiled.',
      ),
      WikiTimelineItem(
        title: 'Turing machine',
        date: '1936',
        description:
            'Alan Turing published "On Computable Numbers," introducing the Turing machine.',
      ),
      WikiTimelineItem(
        title: 'Relational database',
        date: '1970',
        description:
            'E.F. Codd proposed the relational model for database management.',
      ),
      WikiTimelineItem(
        title: 'Deep Blue versus Garry Kasparov',
        date: '1997',
        description:
            'IBM\'s Deep Blue defeated world chess champion Garry Kasparov.',
      ),
      WikiTimelineItem(
        title: 'Bitcoin',
        date: '2008',
        description:
            'Satoshi Nakamoto published the whitepaper for Bitcoin, the first cryptocurrency.',
      ),
      WikiTimelineItem(
        title: 'GPT-3',
        date: '2020',
        description:
            'OpenAI released GPT-3, a massive jump in large language model capabilities.',
      ),
    ];

    // Sort items chronologically by year (descending for a "history" feel)
    items.sort((a, b) => b.date.compareTo(a.date));

    return items;
  }
}
