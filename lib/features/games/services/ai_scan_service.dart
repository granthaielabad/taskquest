import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/foundation.dart';
import 'package:taskquest/features/games/providers/flashcard_provider.dart';
import 'package:taskquest/core/constants/app_constants.dart';

class AIScanService {
  final GenerativeModel _primaryModel;
  final GenerativeModel _fallbackModel;

  AIScanService()
    : _primaryModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: AppConstants.geminiApiKey,
      ),
      _fallbackModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: AppConstants.geminiApiKey,
      );

  /// ── Main Entry Point ───────────────────────────────────────
  Future<List<FlashcardModel>> generateFlashcardsFromFile(
    Uint8List bytes,
    String fileName,
  ) async {
    if (AppConstants.geminiApiKey == 'PASTE_YOUR_API_KEY_HERE') {
      throw Exception(
        'Gemini API Key missing. Please add your key in lib/core/constants/app_constants.dart',
      );
    }

    try {
      final extension = fileName.split('.').last.toLowerCase();
      String prompt =
          "You are a CS Professor. Analyze the provided content and return exactly 10 high-quality flashcards for a Computer Science student. Return the result as a JSON array of objects with 'term' and 'definition' keys. Do not include any explanation text, only the JSON array.";

      GenerateContentResponse response;

      if (extension == 'pdf') {
        final text = _extractTextFromPdf(bytes);
        response = await _executeWithFallback([
          Content.text("$prompt\n\nContent:\n$text"),
        ]);
      } else if (['png', 'jpg', 'jpeg'].contains(extension)) {
        response = await _executeWithFallback([
          Content.multi([TextPart(prompt), DataPart('image/jpeg', bytes)]),
        ]);
      } else {
        throw Exception('Unsupported file format: $extension');
      }

      if (response.text == null) {
        throw Exception('AI returned an empty response. Try a different file.');
      }

      return _parseResponse(response.text);
    } catch (e) {
      debugPrint('AI Generation Error: $e');
      if (e.toString().contains('403')) {
        throw Exception(
          'API Key invalid or restricted. Check your AI Studio settings.',
        );
      }
      throw Exception('Failed to generate cards: ${e.toString()}');
    }
  }

  /// ── Fallback Strategy ──────────────────────────────────────
  Future<GenerateContentResponse> _executeWithFallback(
    List<Content> content,
  ) async {
    try {
      // 1. Attempt with Primary Model
      return await _primaryModel.generateContent(content);
    } catch (e) {
      final errorStr = e.toString().toLowerCase();

      // 2. Check if it's a "High Demand" or "Overloaded" error (503)
      if (errorStr.contains('503') ||
          errorStr.contains('demand') ||
          errorStr.contains('overloaded') ||
          errorStr.contains('temporary')) {
        debugPrint('Primary model busy. Falling back to gemini-1.5-flash...');

        // 3. Small wait before retry
        await Future.delayed(const Duration(seconds: 2));

        // 4. Attempt with Fallback Model
        try {
          return await _fallbackModel.generateContent(content);
        } catch (fallbackError) {
          debugPrint('Fallback model also failed: $fallbackError');
          rethrow;
        }
      }

      // If it's a different kind of error, just rethrow
      rethrow;
    }
  }

  /// ── PDF Extraction ─────────────────────────────────────────
  String _extractTextFromPdf(Uint8List bytes) {
    try {
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

    String jsonString = text.trim();

    // Robust extraction: Find the first '[' and last ']' to isolate the JSON array
    try {
      final firstBracket = jsonString.indexOf('[');
      final lastBracket = jsonString.lastIndexOf(']');

      if (firstBracket != -1 &&
          lastBracket != -1 &&
          lastBracket > firstBracket) {
        jsonString = jsonString.substring(firstBracket, lastBracket + 1);
      }

      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded
          .map(
            (item) => FlashcardModel(
              id:
                  DateTime.now().millisecondsSinceEpoch.toString() +
                  decoded.indexOf(item).toString(),
              term: item['term'] ?? '',
              definition: item['definition'] ?? '',
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('AI Parsing Error: $e');
      // Final attempt: manual cleanup if brackets were missing or malformed
      final cleaned = jsonString
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      try {
        final List<dynamic> decoded = jsonDecode(cleaned);
        return decoded
            .map(
              (item) => FlashcardModel(
                id:
                    DateTime.now().millisecondsSinceEpoch.toString() +
                    decoded.indexOf(item).toString(),
                term: item['term'] ?? '',
                definition: item['definition'] ?? '',
              ),
            )
            .toList();
      } catch (innerE) {
        throw Exception('AI returned invalid format. Please try again.');
      }
    }
  }
}
