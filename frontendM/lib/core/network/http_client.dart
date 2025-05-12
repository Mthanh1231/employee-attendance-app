import 'package:http/http.dart' as http;
import 'dart:convert';

class HttpClient {
  final String baseUrl;
  final http.Client _client;

  HttpClient({
    this.baseUrl = 'http://localhost:3000',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String path,
      {Map<String, String>? headers}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await _client.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl$path'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to perform request: ${response.statusCode}');
    }
  }
}
