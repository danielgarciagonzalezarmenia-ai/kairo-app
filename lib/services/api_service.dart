import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://dlive.sx';
  static const String daddyApi = '$baseUrl/daddyapi.php';

  final String? apiKey;
  final http.Client _client;

  ApiService({this.apiKey, http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _get(String endpoint) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('API key requerida para dlive.sx');
    }
    final uri = Uri.parse('$daddyApi?key=$apiKey&endpoint=$endpoint');
    final response = await _client.get(uri, headers: {
      'Accept': 'application/json',
      'User-Agent': 'Kairo/1.0 (iOS)',
    });
    if (response.statusCode != 200) {
      throw Exception('API error ${response.statusCode}: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getChannels() async {
    final data = await _get('channels');
    final List<dynamic> list = data['data'] ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getSchedule() async {
    return await _get('schedule');
  }

  Future<Map<String, dynamic>> getInfo() async {
    return await _get('info');
  }

  void dispose() => _client.close();
}
