import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpClient {
  final String baseUrl = dotenv.env['API_BASE_URL']!;
  final http.Client _client;
  String? _token;

  HttpClient({http.Client? client}) : _client = client ?? http.Client();

  void setToken(String token) {
    _token = token;
  }

  Future<Map<String, dynamic>> get(String path,
      {Map<String, String>? headers}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: _buildHeaders(headers),
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
      headers: _buildHeaders(headers),
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
      headers: _buildHeaders(headers),
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
      headers: _buildHeaders(headers),
    );
    return _handleResponse(response);
  }

  Map<String, String> _buildHeaders(Map<String, String>? headers) {
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
    if (headers != null) {
      defaultHeaders.addAll(headers);
    }
    return defaultHeaders;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to perform request: [31m${response.statusCode}[0m');
    }
  }
}
