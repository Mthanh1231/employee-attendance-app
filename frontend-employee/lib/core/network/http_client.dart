// lib/core/network/http_client.dart
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HttpClient {
  final String _baseUrl = dotenv.env['API_URL']!;
  final http.Client client;
  String? _token;

  HttpClient({http.Client? client}) : client = client ?? http.Client();

  void setToken(String token) {
    _token = token;
  }

  Future<http.Response> post(String path, {Object? body}) {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
    return client.post(uri, headers: headers, body: body);
  }

  Future<http.Response> get(String path) {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
    return client.get(uri, headers: headers);
  }
}
