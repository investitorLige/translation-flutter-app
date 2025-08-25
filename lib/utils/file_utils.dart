import 'dart:io';

class FileUtils {
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'docx':
        return '📝';
      default:
        return '📄';
    }
  }
}