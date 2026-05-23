import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/vocab_word.dart';

class ApiService {
  final http.Client _client;
  final String baseUrl;

  ApiService({
    http.Client? client,
    this.baseUrl = AppConfig.webBase,
  }) : _client = client ?? http.Client();

  factory ApiService.configured({http.Client? client}) {
    return ApiService(client: client, baseUrl: AppConfig.baseUrl);
  }

  Future<int> getDueCount() async {
    final response = await _client.get(Uri.parse('$baseUrl/count-due'));
    _ensureSuccess(response, 'Failed to load due count');
    return int.tryParse(response.body.trim()) ?? 0;
  }

  Future<List<VocabWord>> getRehearsalWords({int page = 0, int size = 10}) async {
    final uri = Uri.parse('$baseUrl/rehearse').replace(
      queryParameters: {
        'page': '$page',
        'size': '$size',
      },
    );
    final response = await _client.get(uri);
    _ensureSuccess(response, 'Failed to load rehearsal words');
    return _decodeWordList(response.body);
  }

  Future<List<VocabWord>> searchWords(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return const [];

    final uri = Uri.parse('$baseUrl/search').replace(
      queryParameters: {'query': trimmedQuery},
    );
    final response = await _client.get(uri);
    _ensureSuccess(response, 'Search failed');
    return _decodeWordList(response.body);
  }

  Future<void> submitGrade(int wordId, int grade) async {
    final clampedGrade = grade.clamp(1, 5);
    final response = await _client.post(
      Uri.parse('$baseUrl/$wordId/grade'),
      headers: const {'Content-Type': 'application/json'},
      body: json.encode({'grade': clampedGrade}),
    );
    _ensureSuccess(response, 'Submit grade failed');
  }

  List<VocabWord> _decodeWordList(String body) {
    final decoded = json.decode(body);
    final Iterable<dynamic> rawItems = switch (decoded) {
      {'content': final List<dynamic> content} => content,
      {'data': final List<dynamic> data} => data,
      final List<dynamic> list => list,
      _ => const [],
    };

    return rawItems
        .whereType<Map>()
        .map((item) => VocabWord.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  void _ensureSuccess(http.Response response, String message) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('$message: ${response.statusCode}');
    }
  }
}

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}
