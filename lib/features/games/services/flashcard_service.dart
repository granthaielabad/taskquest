import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskquest/features/games/providers/flashcard_provider.dart';

class FlashcardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createDeck(FlashcardDeckModel deck) async {
    await _db.collection('decks').doc(deck.id).set(deck.toMap());
  }

  Stream<List<FlashcardDeckModel>> getUserDecks(String userId) {
    return _db
        .collection('decks')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FlashcardDeckModel.fromMap(doc.data()))
          .toList();
    });
  }

  Future<void> updateMastery(String deckId, int newProgress) async {
    await _db.collection('decks').doc(deckId).update({
      'masteryProgress': newProgress,
    });
  }

  Future<void> deleteDeck(String deckId) async {
    await _db.collection('decks').doc(deckId).delete();
  }
}
