import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/translation_request.dart';
import '../models/document.dart';
import '../services/translation_service.dart';
import 'dart:convert';

class DocumentProcessingService {
  final TranslationService _translationService = TranslationService();

  // Extract text from document
  Future<String> extractText(Document document) async {
    final file = File(document.path);
    
    switch (document.type.toLowerCase()) {
      case 'docx':
        return await _extractTextFromDocx(file);
      case 'pdf':
        return await _extractTextFromPdf(file);
      default:
        throw Exception('Unsupported document type: ${document.type}. Only PDF and DOCX are supported.');
    }
  }

  Future<String> _extractTextFromDocx(File file) async {
    try {
      print('Starting DOCX extraction for: ${file.path}');
      
      // Read the DOCX file (which is a ZIP archive)
      final bytes = await file.readAsBytes();
      print('DOCX file read, size: ${bytes.length} bytes');
      
      final archive = ZipDecoder().decodeBytes(bytes);
      print('DOCX archive decoded, contains ${archive.length} files');
      
      // Find the document.xml file in the archive
      ArchiveFile? documentFile;
      for (final file in archive) {
        print('Archive file: ${file.name}');
        if (file.name == 'word/document.xml') {
          documentFile = file;
          break;
        }
      }
      
      if (documentFile == null) {
        throw Exception('Document not found in DOCX file');
      }
      
      print('Found document.xml, size: ${documentFile.content.length} bytes');
      
      // Extract and parse the XML content
      final content = documentFile.content as Uint8List;
      // Fix encoding issues by using latin1 decoding
      final xmlString = latin1.decode(content);
      print('XML content length: ${xmlString.length}');
      
      final xmlDocument = XmlDocument.parse(xmlString);
      print('XML parsed successfully');
      
      // Extract text from all <w:t> elements
      final textElements = xmlDocument.findAllElements('w:t');
      print('Found ${textElements.length} text elements');
      
      final textBuffer = StringBuffer();
      for (final element in textElements) {
        final text = element.innerText;
        if (text.trim().isNotEmpty) {
          // Fix encoding issues by replacing problematic characters
          final fixedText = text
              .replaceAll('Â ', ' ')  // Fix non-breaking space issue
              .replaceAll('â€', '"')  // Fix curly quotes
              .replaceAll('â', "'")    // Fix apostrophes
              .replaceAll('â€"', '"')  // Fix other quote variants
              .replaceAll('â€"', '"')  // Fix other quote variants
              .replaceAll('Â', '')
              .splitMapJoin(
                RegExp(r'[.:]'),
                onMatch: (m) => '${m.group(0)}\n',
                onNonMatch: (n) => n,
              );    // Remove any remaining Â characters
              
              
              
          textBuffer.write(fixedText);
          textBuffer.write(' ');
        }
      }
      
      final extractedText = textBuffer.toString().trim();
      print('Final extracted text: ${extractedText.length > 100 ? extractedText.substring(0, 100) + '...' : extractedText}');
      
      return extractedText;
    } catch (e) {
      print('Error in DOCX extraction: $e');
      throw Exception('Failed to extract text from DOCX: $e');
    }
  }

  Future<String> _extractTextFromPdf(File file) async {
    try {
      print('Starting PDF extraction for: ${file.path}');
      
      // Read file bytes
      final bytes = await file.readAsBytes();
      print('PDF file read, size: ${bytes.length} bytes');
      
      // Load the PDF document using the correct constructor
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      print('PDF document loaded successfully');
      
      // Extract text using PdfTextExtractor
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText();
      print('PDF text extracted: ${text.length > 100 ? text.substring(0, 100) + '...' : text}');
      
      // Dispose the document
      document.dispose();
      
      return text;
    } catch (e) {
      print('Error in PDF extraction: $e');
      throw Exception('Failed to extract text from PDF: $e');
    }
  }

  // Split text into sentences
  List<String> splitIntoSentences(String text) {
    // Improved sentence splitting with better regex
    final sentences = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .map((s) => s.trim())
        .toList();
    
    return sentences;
  }

  // Translate document text sentence by sentence
  Future<List<String>> translateDocument(
    String text, 
    String sourceLang, 
    String targetLang,
  ) async {
    final sentences = splitIntoSentences(text);
    final translatedSentences = <String>[];
    
    for (int i = 0; i < sentences.length; i++) {
      final sentence = sentences[i];
      try {
        final request = TranslationRequest(
          text: sentence,
          sourceLang: sourceLang,
          targetLang: targetLang,
        );
        
        final response = await _translationService.translate(request);
        translatedSentences.add(response.translation);
      } catch (e) {
        // If translation fails, keep original sentence
        translatedSentences.add(sentence);
      }
    }
    
    return translatedSentences;
  }
}