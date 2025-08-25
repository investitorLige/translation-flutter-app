import 'dart:io';
import 'package:flutter/material.dart';
import '../models/document.dart';
import '../services/document_processing_service.dart';
import '../services/translation_service.dart';
import '../widgets/translation_single/language_selector.dart';

class DocumentPreviewScreen extends StatefulWidget {
  final Document document;
  const DocumentPreviewScreen({super.key, required this.document});

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  final DocumentProcessingService _processingService = DocumentProcessingService();

  bool _isLoading = true;
  bool _isTranslating = false;
  String? _extractedText;
  List<String>? _translatedSentences;
  String? _errorMessage;

  String _sourceLang = 'en';
  String _targetLang = 'sr';

  File? _pdfFile;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final file = File(widget.document.path);
      if (!await file.exists()) {
        throw Exception('File does not exist at path: ${widget.document.path}');
      }

      if (widget.document.type.toLowerCase() == 'pdf') {
        _pdfFile = file;
        try {
          _extractedText = await _processingService.extractText(widget.document);
        } catch (e) {
          print('PDF text extraction failed: $e');
        }
      } else {
        _extractedText = await _processingService.extractText(widget.document);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load document: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _translateDocument() async {
    if (_extractedText == null) return;

    setState(() {
      _isTranslating = true;
      _errorMessage = null;
    });

    try {
      final translated = await _processingService.translateDocument(
        _extractedText!,
        _sourceLang,
        _targetLang,
      );

      setState(() {
        _translatedSentences = translated;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Translation failed: $e';
      });
    } finally {
      setState(() {
        _isTranslating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocument,
            tooltip: 'Reload Document',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _extractedText != null ? _buildTranslationBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDocument,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Document info header
        _buildDocumentInfo(),

        // Document content - expandable area
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                // ensure the scroll area fills available height so children with relative heights can be sized
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // main document content (pdf or text)
                    if (widget.document.type.toLowerCase() == 'pdf')
                      _buildTextContent(constraints.maxHeight)
                    else
                      _buildTextContent(constraints.maxHeight),

                    // Add translate button after document content
                    if (_extractedText != null) ...[
                      const SizedBox(height: 16),
                      _buildTranslateButton(),
                    ],

                    // translated
                    if (_translatedSentences != null) ...[
                      const SizedBox(height: 16),
                      _buildTranslatedContent(),
                    ],

                    // pushes content to top if there's extra space
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDocumentInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.document.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Type: ${widget.document.type.toUpperCase()}'),
              const SizedBox(width: 16),
              Text('Size: ${_formatFileSize(widget.document.size)}'),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Path: ${widget.document.path}',
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildTextContent(double availableHeight) {
    print('DEBUG: building TEXT content; extractedText is ${_extractedText != null}');
    final double boxHeight = (availableHeight * 0.45).clamp(200.0, availableHeight);

    String displayText = _extractedText ?? 'No text extracted';
    if (displayText.length > 1000) {
      displayText = displayText.substring(0, 1000) + '... [truncated]';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Content',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox.shrink(),
            const Spacer(),
            Text(
              '${_extractedText?.length ?? 0} characters',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: boxHeight,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Text(
                displayText,
                style: const TextStyle(height: 1.5),
              ),
            ),
          ),
        ),
        if (_extractedText != null && _extractedText!.length > 1000)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton(
              onPressed: _showFullTextDialog,
              child: const Text('View Full Text'),
            ),
          ),
      ],
    );
  }

  Widget _buildTranslateButton() {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isTranslating ? null : _translateDocument,
          icon: _isTranslating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.translate),
          label: Text(
            _isTranslating 
                ? 'Translating...' 
                : _translatedSentences != null 
                    ? 'Translate Again' 
                    : 'Translate Document',
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullTextDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final height = MediaQuery.of(context).size.height * 0.7;
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Full Document Content',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _extractedText ?? '',
                        style: const TextStyle(height: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTranslatedContent() {
    // render translations as a column of cards (no inner scrollable ListView)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Translated Content ($_sourceLang → $_targetLang)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_translatedSentences == null || _translatedSentences!.isEmpty)
            const Text('No translations yet.')
          else
            Column(
              children: _translatedSentences!
                  .asMap()
                  .entries
                  .map((entry) => Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sentence ${entry.key + 1}:',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                entry.value,
                                style: const TextStyle(height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTranslationBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: LanguageSelector(
              value: _sourceLang,
              onChanged: (value) {
                setState(() {
                  _sourceLang = value!;
                });
              },
              label: 'From',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: LanguageSelector(
              value: _targetLang,
              onChanged: (value) {
                setState(() {
                  _targetLang = value!;
                });
              },
              label: 'To',
            ),
          ),
        ],
      ),
    );
  }
}