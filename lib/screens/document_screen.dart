import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/document.dart';
import '../services/document_service.dart';
import '../widgets/document/document_card.dart';
import 'document_preview_screen.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final DocumentService _documentService = DocumentService();
  List<Document> _documents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final documents = await _documentService.getDocuments();
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load documents: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await _documentService.uploadDocument(file);
        await _loadDocuments(); // Refresh the list from the service
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to upload document: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteDocument(String id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _documentService.deleteDocument(id);
      await _loadDocuments(); // Refresh the list from the service
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete document: $e';
        _isLoading = false;
      });
    }
  }

  void _viewDocument(Document document) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DocumentPreviewScreen(document: document),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickDocument,
        child: const Icon(Icons.add),
      ),
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
              onPressed: _loadDocuments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_documents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No documents yet',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text('Tap the + button to add a document'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: ListView.builder(
        itemCount: _documents.length,
        itemBuilder: (context, index) {
          final document = _documents[index];
          return DocumentCard(
            document: document,
            onTap: () => _viewDocument(document),
            onDelete: () => _deleteDocument(document.id),
          );
        },
      ),
    );
  }
}