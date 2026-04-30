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

class TutorialCourse {
  final String id;
  final String title;
  final String topic;
  final String description;
  final String difficulty;
  final String estimatedTime;
  final String contentMarkdown;

  TutorialCourse({
    required this.id,
    required this.title,
    required this.topic,
    required this.description,
    required this.difficulty,
    required this.estimatedTime,
    required this.contentMarkdown,
  });
}

class ExploreApiService {
  // ── Crash Courses (Mock Data) ──────────────────────────────
  Future<List<TutorialCourse>> fetchCrashCourses() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      TutorialCourse(
        id: 'tc_git_1',
        title: 'Git Version Control 101',
        topic: 'TOOLS',
        description:
            'Learn the essential commands to save your code and collaborate with others.',
        difficulty: 'Beginner',
        estimatedTime: '5m',
        contentMarkdown: '''
# Git Version Control 101

Welcome to your first step into professional software development! **Git** is the industry standard for version control. Think of it as a time machine for your code.

## Why use Git?
Imagine working on an essay and saving it as `essay_final.doc`, `essay_final_v2.doc`, `essay_really_final.doc`. It gets messy quickly. Git solves this by tracking changes automatically.

## Core Commands

### 1. The Setup
Before doing anything, you need to tell Git to start tracking your folder:
```bash
git init
```
This creates a hidden `.git` folder. Your time machine is now online.

### 2. Staging Changes
When you change files, Git knows, but it doesn't save them to the timeline yet. You must "stage" them:
```bash
git add .
```
*(The `.` means "add everything in this folder")*

### 3. Saving the Snapshot
Once staged, you create a "Commit" (a permanent snapshot):
```bash
git commit -m "Added the login screen"
```
Always use descriptive messages!

### 4. Pushing to the Cloud
To back up your code to GitHub, you "push" it:
```bash
git push origin main
```

## Summary
1. Change code.
2. `git add .`
3. `git commit -m "message"`
4. `git push`

You are now a Git user!
''',
      ),
      TutorialCourse(
        id: 'tc_ds_1',
        title: 'Data Structures 101',
        topic: 'CONCEPTS',
        description:
            'Learn about Arrays, Linked Lists, Stacks, and Queues conceptually.',
        difficulty: 'Beginner',
        estimatedTime: '6m',
        contentMarkdown: '''
# Data Structures 101

A **Data Structure** is a specialized way of organizing and storing data in a computer so that it can be accessed and modified efficiently.

## 1. Arrays
The most basic structure. A collection of items stored at contiguous memory locations.
* **Pros:** Fast access via index.
* **Cons:** Fixed size (in many languages) and slow insertions/deletions.

## 2. Linked Lists
A linear collection of data elements called nodes, where each node points to the next.
* **Pros:** Dynamic size and fast insertions/deletions.
* **Cons:** Slow access (must traverse from the start).

## 3. Stacks (LIFO)
Think of a stack of plates. **Last-In, First-Out**.
* **Push:** Add an item to the top.
* **Pop:** Remove the top item.

## 4. Queues (FIFO)
Think of a line at a grocery store. **First-In, First-Out**.
* **Enqueue:** Add an item to the back.
* **Dequeue:** Remove the front item.

## 5. Hash Maps (Dictionaries)
Stores data in key-value pairs. Uses a "hash function" to map keys to specific locations.
* **Pros:** Extremely fast lookups, insertions, and deletions.

## Summary
* **Array:** Indexed list.
* **Linked List:** Chain of nodes.
* **Stack:** LIFO (Last In, First Out).
* **Queue:** FIFO (First In, First Out).
* **Hash Map:** Key-Value mapping.
''',
      ),
      TutorialCourse(
        id: 'tc_algo_1',
        title: 'Algorithms & Big O',
        topic: 'CONCEPTS',
        description:
            'Understand what algorithms are and how to measure their efficiency.',
        difficulty: 'Intermediate',
        estimatedTime: '7m',
        contentMarkdown: '''
# Algorithms & Big O

An **Algorithm** is simply a step-by-step procedure for solving a problem. **Big O Notation** is the language we use to describe how long an algorithm takes to run (time complexity) or how much memory it uses (space complexity).

## Common Time Complexities

### 1. O(1) - Constant Time
The algorithm takes the same amount of time regardless of the input size.
* *Example:* Accessing an array element by index.

### 2. O(N) - Linear Time
The time grows proportionally with the size of the input.
* *Example:* Searching for a value in an unsorted array (you might have to check every item).

### 3. O(N²) - Quadratic Time
The time grows proportionally to the square of the input size. Often seen in algorithms with nested loops.
* *Example:* Bubble Sort.

### 4. O(log N) - Logarithmic Time
The input size is halved at each step. Extremely efficient for large datasets.
* *Example:* Binary Search.

## Why it matters
As data grows, the difference between O(N) and O(N²) becomes massive. A million items in O(N) might take a second, while O(N²) could take weeks!

## Summary
* **O(1):** Instant.
* **O(log N):** Fast.
* **O(N):** Fair.
* **O(N²):** Slow for large data.
''',
      ),
      TutorialCourse(
        id: 'tc_oop_1',
        title: 'Object-Oriented Programming',
        topic: 'CONCEPTS',
        description:
            'Explore the 4 pillars of OOP: Encapsulation, Abstraction, Inheritance, and Polymorphism.',
        difficulty: 'Beginner',
        estimatedTime: '6m',
        contentMarkdown: '''
# Object-Oriented Programming (OOP)

OOP is a programming paradigm based on the concept of "objects," which can contain data and code. It helps organize large software projects.

## The 4 Pillars of OOP

### 1. Encapsulation
Bundling data and the methods that operate on that data into a single unit (a class). It hides the internal state from the outside world.
* *Analogy:* A capsule hides the medicine inside.

### 2. Abstraction
Hiding complex implementation details and showing only the necessary features of an object.
* *Analogy:* You know how to drive a car by using the steering wheel and pedals, without knowing how the engine works internally.

### 3. Inheritance
The mechanism where one class (child) acquires the properties and behaviors of another class (parent).
* *Analogy:* A "Car" and a "Truck" both inherit traits from a "Vehicle."

### 4. Polymorphism
The ability of different objects to respond to the same message (method call) in their own way.
* *Analogy:* A `Shape` class might have a `draw()` method. A `Circle` draws a circle, while a `Square` draws a square.

## Summary
OOP makes code more modular, reusable, and easier to maintain.
''',
      ),
      TutorialCourse(
        id: 'tc_cli_1',
        title: 'Command Line Basics',
        topic: 'TOOLS',
        description:
            'Master essential CLI navigation and file management commands.',
        difficulty: 'Beginner',
        estimatedTime: '5m',
        contentMarkdown: '''
# Command Line Basics

The Command Line Interface (CLI) is a powerful way to interact with your computer using text commands instead of a mouse.

## Essential Commands

### 1. Navigation
* `pwd` (Print Working Directory): Shows you exactly where you are.
* `ls` (List): Lists files and folders in your current location.
* `cd <folder>` (Change Directory): Moves you into a folder.
* `cd ..`: Moves you back one folder.

### 2. File Management
* `mkdir <name>` (Make Directory): Creates a new folder.
* `touch <file>`: Creates a new empty file.
* `rm <file>` (Remove): Deletes a file. **Be careful!**
* `cp <source> <dest>` (Copy): Copies a file or folder.
* `mv <source> <dest>` (Move): Moves or renames a file or folder.

### 3. Useful Shortcuts
* **Tab Completion:** Type the first few letters of a filename and hit `Tab` to auto-fill it.
* **Up/Down Arrows:** Cycle through your previous commands.
* `clear`: Clears the terminal screen.

## Summary
The CLI is faster and more precise than a GUI once you learn the "language" of your computer.
''',
      ),
      TutorialCourse(
        id: 'tc_web_1',
        title: 'How the Web Works',
        topic: 'NETWORKING',
        description:
            'Understand HTTP, Requests, Responses, and how your browser talks to servers.',
        difficulty: 'Beginner',
        estimatedTime: '4m',
        contentMarkdown: '''
# How the Web Works

Every time you type a URL into your browser, a massive, invisible conversation happens across the globe. Let's break it down.

## The Client and the Server
* **The Client:** Your web browser (Chrome, Safari, or this app!).
* **The Server:** A powerful computer sitting in a data center somewhere, waiting to give you files.

## The Request-Response Cycle
1. **The Request:** You type `google.com`. Your browser sends an **HTTP Request** into the internet asking for that page.
2. **The Processing:** The server receives the request, gathers the HTML, CSS, and Images.
3. **The Response:** The server sends an **HTTP Response** back to your browser.

## HTTP Status Codes
When the server responds, it includes a 3-digit code telling you how it went:
* **200 OK:** Everything is great! Here is your page.
* **301 Redirect:** This page moved somewhere else.
* **404 Not Found:** I have no idea what page you are asking for.
* **500 Server Error:** My code broke. It's not you, it's me.

## JSON: The Language of APIs
When apps talk to servers (like TaskQuest fetching your quests), they don't send HTML. They send raw data using **JSON** (JavaScript Object Notation).
```json
{
  "status": 200,
  "message": "Success",
  "data": {
    "user": "Scholar",
    "xp": 500
  }
}
```

Now you know how the internet talks!
''',
      ),
    ];
  }

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
        final selected = data['selected'] as List? ?? [];
        final allEvents = data['events'] as List? ?? [];

        // Combine curated 'selected' events with the broader 'events' list
        final events = [...selected, ...allEvents];

        if (events.isNotEmpty) {
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
          final names = members
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
