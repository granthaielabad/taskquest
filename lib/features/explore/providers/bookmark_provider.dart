import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskquest/features/explore/services/bookmark_service.dart';
import 'package:taskquest/features/auth/providers/auth_provider.dart';

final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  return BookmarkService();
});

final userBookmarksProvider = StreamProvider<List<BookmarkModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(bookmarkServiceProvider).getBookmarks(user.uid);
});

final isBookmarkedProvider = FutureProvider.family<bool, String>((
  ref,
  id,
) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return false;
  return ref.watch(bookmarkServiceProvider).isBookmarked(user.uid, id);
});
