class TranslationRequest {
  final String text;
  final String sourceLang;
  final String targetLang;

  TranslationRequest({
    required this.text,
    required this.sourceLang,
    required this.targetLang,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'source_lang': sourceLang,
      'target_lang': targetLang,
    };
  }
}