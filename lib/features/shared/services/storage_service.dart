import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadProfileImage(String uid, Uint8List bytes) async {
    try {
      final ref = _storage.ref().child('users').child(uid).child('profile.jpg');

      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('StorageService ERROR: $e');
      return null;
    }
  }
}
