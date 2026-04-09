import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportModel {
  final String id;
  final String userId;
  final String gameType; // 'quiz' or 'code_blocks'
  final String contentId; // Question text or code snippet identifier
  final String reason;
  final DateTime timestamp;

  ReportModel({
    required this.id,
    required this.userId,
    required this.gameType,
    required this.contentId,
    required this.reason,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'gameType': gameType,
      'contentId': contentId,
      'reason': reason,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitReport(ReportModel report) async {
    await _db.collection('reports').doc(report.id).set(report.toMap());
  }
}

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService();
});
