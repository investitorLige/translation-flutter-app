import 'dart:async';
import 'package:flutter/services.dart';

class PdfTextExtractor {
  static const MethodChannel _channel = MethodChannel('pdf_text_extractor');

  static Future<String> extractText(String path) async {
    try {
      final String text = await _channel.invokeMethod('extractText', {'path': path});
      return text;
    } on PlatformException catch (e) {
      throw Exception('Failed to extract text: ${e.message}');
    }
  }
}