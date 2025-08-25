import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../utils/exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _client = http.Client();

  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      final response = await _client
          .post(
            url,
            headers: headers ?? {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(AppConfig.connectionTimeout);

      if (response.statusCode >= 400) {
        throw ApiException(
          'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      return response;
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}