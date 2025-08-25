import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/document.dart';
import '../utils/file_utils.dart';

class DocumentService {
  static final DocumentService _instance = DocumentService._internal();
  factory DocumentService() => _instance;
  DocumentService._internal();

  final List<Document> _documents = [];
  
  Future<List<Document>> getDocuments() async {
    return List<Document>.from(_documents); // Return a copy to prevent direct modification
  }

  Future<Document> uploadDocument(File file) async {
    // Validate file type
    final extension = file.path.split('.').last.toLowerCase();
    if (extension != 'pdf' && extension != 'docx') {
      throw Exception('Unsupported file type. Only PDF and DOCX are allowed.');
    }
    
    // Create a directory for documents
    final appDir = await getApplicationDocumentsDirectory();
    final documentsDir = Directory('${appDir.path}/documents');
    if (!await documentsDir.exists()) {
      await documentsDir.create(recursive: true);
    }
    
    // Generate unique filename
    final uuid = const Uuid().v4();
    final fileName = '$uuid.$extension';
    final savedFile = await file.copy('${documentsDir.path}/$fileName');
    
    // Create document object
    final document = Document(
      id: uuid,
      name: file.path.split('/').last,
      path: savedFile.path,
      type: extension,
      uploadedAt: DateTime.now(),
      size: await savedFile.length(),
    );
    
    // Add to list
    _documents.add(document);
    
    return document;
  }

  Future<void> deleteDocument(String id) async {
    // Find document
    final document = _documents.firstWhere((doc) => doc.id == id);
    
    // Delete file
    final file = File(document.path);
    if (await file.exists()) {
      await file.delete();
    }
    
    // Remove from list
    _documents.removeWhere((doc) => doc.id == id);
  }
}