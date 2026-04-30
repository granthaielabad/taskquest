import 'package:cloud_firestore/cloud_firestore.dart';

enum BookmarkType { article, wiki }

class BookmarkModel {
  final String id;
  final String title;
  final String type; // 'ARTICLE', 'WIKI'
  final String url;
  final String? coverImage;
  final DateTime createdAt;

  BookmarkModel({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
    this.coverImage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'url': url,
      'coverImage': coverImage,
      'createdAt': createdAt,
    };
  }

  factory BookmarkModel.fromMap(String id, Map<String, dynamic> map) {
    return BookmarkModel(
      id: id,
      title: map['title'] ?? '',
      type: map['type'] ?? 'ARTICLE',
      url: map['url'] ?? '',
      coverImage: map['coverImage'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class BookmarkService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<BookmarkModel>> getBookmarks(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookmarkModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> toggleBookmark(String userId, BookmarkModel bookmark) async {
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(bookmark.id);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set(bookmark.toMap());
    }
  }

  Future<bool> isBookmarked(String userId, String bookmarkId) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(bookmarkId)
        .get();
    return doc.exists;
  }
}
