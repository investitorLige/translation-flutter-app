class TranslationResponse {
  final String translation;

  TranslationResponse({required this.translation});

  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    return TranslationResponse(
      translation: json['translation'],
    );
  }
}