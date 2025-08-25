class Document {
  final String id;
  final String name;
  final String path;
  final String type; // 'pdf' or 'docx'
  final DateTime uploadedAt;
  final int size; // in bytes

  Document({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.uploadedAt,
    required this.size,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      name: json['name'],
      path: json['path'],
      type: json['type'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type,
      'uploaded_at': uploadedAt.toIso8601String(),
      'size': size,
    };
  }
}