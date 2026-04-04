import 'dart:convert';
import 'dart:io';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/foundation.dart';
import 'package:taskquest/features/games/providers/flashcard_provider.dart';

class AIScanService {
  final GenerativeModel _model;

  AIScanService()
      : _model = FirebaseAI.vertexAI().generativeModel(
          model: 'gemini-1.5-flash',
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );

  /// ── Main Entry Point ───────────────────────────────────────
  Future<List<FlashcardModel>> generateFlashcardsFromFile(File file) async {
    final extension = file.path.split('.').last.toLowerCase();
    String prompt = "You are a CS Professor. Analyze the provided content and return exactly 10 high-quality flashcards for a Computer Science student. Return the result as a JSON array of objects with 'term' and 'definition' keys.";

    GenerateContentResponse response;

    if (extension == 'pdf') {
      final text = await _extractTextFromPdf(file);
      response = await _model.generateContent([
        Content.text("$prompt\n\nContent:\n$text")
      ]);
    } else if (['png', 'jpg', 'jpeg'].contains(extension)) {
      final bytes = await file.readAsBytes();
      response = await _model.generateContent([
        Content.multi([
          TextPart(prompt),
          InlineDataPart('image/jpeg', bytes),
        ])
      ]);
    } else {
      throw Exception('Unsupported file format: $extension');
    }

    return _parseResponse(response.text);
  }

  /// ── PDF Extraction ─────────────────────────────────────────
  Future<String> _extractTextFromPdf(File file) async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final String text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text;
    } catch (e) {
      debugPrint('PDF Extraction Error: $e');
      throw Exception('Failed to read PDF content');
    }
  }

  /// ── Parser ─────────────────────────────────────────────────
  List<FlashcardModel> _parseResponse(String? text) {
    if (text == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(text);
      return decoded.map((item) => FlashcardModel(
        id: DateTime.now().millisecondsSinceEpoch.toString() + decoded.indexOf(item).toString(),
        term: item['term'] ?? '',
        definition: item['definition'] ?? '',
      )).toList();
    } catch (e) {
      debugPrint('AI Parsing Error: $e');
      // Fallback cleanup
      final cleaned = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final List<dynamic> decoded = jsonDecode(cleaned);
      return decoded.map((item) => FlashcardModel(
        id: DateTime.now().millisecondsSinceEpoch.toString() + decoded.indexOf(item).toString(),
        term: item['term'] ?? '',
        definition: item['definition'] ?? '',
      )).toList();
    }
  }
}
