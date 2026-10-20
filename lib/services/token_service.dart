import 'dart:convert';
import 'package:http/http.dart' as http;

class TokenService {
  static const String edgeBase = 'https://edge.cowedd4855ws.sbs';

  final http.Client _client;

  TokenService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchToken(String slug) async {
    final uri = Uri.parse('$edgeBase/api/playlist-token?slug=$slug');
    final response = await _client.get(uri, headers: {
      'Origin': 'https://dembed.st',
      'Referer': 'https://dembed.st/',
      'Accept': 'application/json',
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15',
    });
    if (response.statusCode != 200) {
      throw Exception('Token error ${response.statusCode}: ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return {
      'token': data['token'] as String,
      'ttl': (data['ttl'] as num?)?.toInt() ?? 120,
    };
  }

  String buildM3u8Url(String channel, String token) {
    final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return '$edgeBase/$channel/index.m3u8?t=$token&_=$ts';
  }

  void dispose() => _client.close();
}
