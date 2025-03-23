// lib/core/network/http_client.dart
import 'package:http/http.dart' as http;

class AppHttpClient {
  // Tạo client http cho toàn app
  static final http.Client client = http.Client();
}
