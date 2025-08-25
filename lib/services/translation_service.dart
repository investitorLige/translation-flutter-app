import 'dart:convert';
import 'api_client.dart';
import '../config/endpoints.dart';
import '../models/translation_request.dart';
import '../models/translation_response.dart';
import '../utils/exceptions.dart';

class TranslationService {
  final ApiClient _apiClient = ApiClient();

  Future<TranslationResponse> translate(TranslationRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.translate,
        body: jsonEncode(request.toJson()),
      );

      return TranslationResponse.fromJson(jsonDecode(response.body));
    } on ApiException catch (e) {
      throw TranslationException('API error: ${e.message}');
    } on NetworkException catch (e) {
      throw TranslationException('Network error: ${e.message}');
    } catch (e) {
      throw TranslationException('Unexpected error: $e');
    }
  }

  void dispose() {
    _apiClient.dispose();
  }
}